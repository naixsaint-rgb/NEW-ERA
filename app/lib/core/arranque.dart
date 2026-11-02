import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import 'contexto.dart';
import 'cripto/almacen_seguro.dart';
import 'cripto/clave_circulo.dart';
import 'cripto/invitacion.dart';
import 'db/base_datos.dart';
import 'db/conexion/conexion.dart';
import 'db/repositorios/circulo_repositorio.dart';
import 'db/repositorios/eventos_repositorio.dart';
import 'db/semilla_demo.dart';
import 'providers.dart';
import 'sync/servicio_sync.dart';
import 'tema/aspecto.dart';

/// Lee o crea los ids y la clave, abre la base y crea lo que falte.
///
/// Devuelve los `overrides` que `main.dart` pasa al ámbito de Riverpod.
///
/// Si hay una invitación aceptada (`newera.union.pendiente`), la aplica antes
/// de abrir la base: borra la base de este móvil (va cifrada con la clave
/// vieja), guarda círculo, persona y clave de la invitación, marca el círculo
/// como de fuera y quita el perfil. Si el móvil se apaga a medias, el
/// siguiente arranque lo repite entero. Con círculo, persona y clave en el
/// almacén no se crean otros: se crean las filas mínimas (provisionales) y la
/// recepción empieza desde la posición 0.
abstract final class Arranque {
  static Future<List<Override>> iniciar({
    AlmacenSeguro? almacen,
    QueryExecutor? ejecutor,
    Reloj reloj = const RelojSistema(),
    String? plataforma,
    bool? demoWeb,
    bool? sembrarDemo,
    Random? azar,
    Future<void> Function()? borrarBase,
  }) async {
    inicializarZonas();
    final esWeb = demoWeb ?? kIsWeb;
    final plat = plataforma ?? _plataformaActual();
    final guardia = almacen ?? almacenPorDefecto(esWeb: esWeb);
    const uuid = Uuid();
    final azarUsado = azar ?? Random.secure();

    // Identificadores y clave.
    final dispositivoId = await _leerOCrear(
      guardia,
      ClavesAlmacen.dispositivoId,
      uuid.v4,
    );

    // Invitación aceptada en la sesión anterior.
    final unido = await _aplicarUnion(
      guardia,
      esWeb: esWeb,
      borrarBase: borrarBase ?? (ejecutor == null ? borrarBaseLocal : null),
    );

    String? clave;
    if (!esWeb) {
      clave = await guardia.leer(ClavesAlmacen.circuloClave);
      if (clave == null || clave.length != 64) {
        clave = ClaveCirculo.generar();
        await guardia.escribir(ClavesAlmacen.circuloClave, clave);
        await guardia.escribir(ClavesAlmacen.circuloClaveVersion, '1');
      }
    }

    // Base de datos.
    final base = AppDatabase(ejecutor ?? await abrirConexion(claveHex: clave));

    // Círculo y persona: los del almacén; si no, los de la base; si no,
    // nuevos.
    var circuloId = await guardia.leer(ClavesAlmacen.circuloId);
    circuloId ??= (await base.select(base.circulos).get()).firstOrNull?.id;
    circuloId ??= uuid.v4();
    await guardia.escribir(ClavesAlmacen.circuloId, circuloId);
    var personaId = await guardia.leer(ClavesAlmacen.personaId);
    if (personaId == null || personaId.isEmpty) {
      final persona =
          await (base.select(base.personas)
                ..where((p) => p.circuloId.equals(circuloId!))
                ..limit(1))
              .getSingleOrNull();
      personaId = persona?.id ?? uuid.v4();
      await guardia.escribir(ClavesAlmacen.personaId, personaId);
    }
    final contexto = ContextoApp(
      circuloId: circuloId,
      personaId: personaId,
      dispositivoId: dispositivoId,
      plataforma: plat,
      circuloExterno: await guardia.leer(ClavesAlmacen.circuloExterno) == '1',
    );
    if (unido) {
      // Sincronización completa: todo lo del círculo desde el principio.
      await (base.delete(
        base.syncEstado,
      )..where((t) => t.clave.equals(ServicioSync.claveCursor))).go();
    }

    final eventos = EventosRepositorio(
      db: base,
      reloj: reloj,
      azar: azarUsado,
      contexto: contexto,
      autor: () => contexto.personaId,
    );
    final circulo = CirculoRepositorio(
      db: base,
      reloj: reloj,
      contexto: contexto,
      eventos: eventos,
    );
    await circulo.asegurarBase();

    if ((sembrarDemo ?? esWeb) && !await SemillaDemo.hayMedicamentos(base)) {
      await SemillaDemo.sembrar(
        db: base,
        contexto: contexto,
        reloj: reloj,
        azar: azarUsado,
      );
    }

    // Perfil guardado.
    var sesion = const Sesion();
    final perfil = PerfilApp.desdeNombre(
      await guardia.leer(ClavesAlmacen.perfil),
    );
    if (perfil != null) {
      final miembroId = await circulo.asegurarDispositivo(perfil);
      sesion = Sesion(perfil: perfil, miembroId: miembroId);
    }

    // Aspecto guardado (claro, oscuro...): así no parpadea al abrir.
    final aspecto = Aspecto.desdeNombre(
      await guardia.leer(ClavesAlmacen.aspecto),
    );

    return [
      almacenSeguroProvider.overrideWithValue(guardia),
      baseDatosProvider.overrideWithValue(base),
      contextoProvider.overrideWithValue(contexto),
      sesionInicialProvider.overrideWithValue(sesion),
      aspectoInicialProvider.overrideWithValue(aspecto),
      relojProvider.overrideWithValue(reloj),
      azarProvider.overrideWithValue(azarUsado),
      esDemoWebProvider.overrideWithValue(esWeb),
    ];
  }

  /// La reserva en memoria solo en la demo web: en móvil, si el llavero falla
  /// hay que parar, nunca generar otra clave y pisar la de la base cifrada.
  @visibleForTesting
  static AlmacenSeguro almacenPorDefecto({required bool esWeb}) => esWeb
      ? AlmacenSeguroConReserva(AlmacenSeguroFlutter())
      : AlmacenSeguroFlutter();

  /// Aplica la invitación pendiente, si la hay. Devuelve si se unió.
  static Future<bool> _aplicarUnion(
    AlmacenSeguro almacen, {
    required bool esWeb,
    required Future<void> Function()? borrarBase,
  }) async {
    final pendiente = await almacen.leer(ClavesAlmacen.unionPendiente);
    if (pendiente == null) return false;
    final invitacion = Invitacion.leer(pendiente);
    // La demo web no tiene clave ni cartero: no se une a nada.
    if (invitacion == null || esWeb) {
      await almacen.borrar(ClavesAlmacen.unionPendiente);
      return false;
    }
    await borrarBase?.call();
    await almacen.escribir(ClavesAlmacen.circuloClave, invitacion.claveHex);
    await almacen.escribir(ClavesAlmacen.circuloClaveVersion, '1');
    await almacen.escribir(ClavesAlmacen.circuloId, invitacion.circuloId);
    await almacen.escribir(ClavesAlmacen.personaId, invitacion.personaId);
    await almacen.escribir(ClavesAlmacen.circuloExterno, '1');
    await almacen.borrar(ClavesAlmacen.perfil);
    await almacen.borrar(ClavesAlmacen.unionPendiente);
    return true;
  }

  static Future<String> _leerOCrear(
    AlmacenSeguro almacen,
    String clave,
    String Function() crear,
  ) async {
    final actual = await almacen.leer(clave);
    if (actual != null && actual.isNotEmpty) return actual;
    final nuevo = crear();
    await almacen.escribir(clave, nuevo);
    return nuevo;
  }

  static String _plataformaActual() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }
}
