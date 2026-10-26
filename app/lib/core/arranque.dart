import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import 'contexto.dart';
import 'cripto/almacen_seguro.dart';
import 'cripto/clave_circulo.dart';
import 'db/base_datos.dart';
import 'db/conexion/conexion.dart';
import 'db/repositorios/circulo_repositorio.dart';
import 'db/repositorios/eventos_repositorio.dart';
import 'db/semilla_demo.dart';
import 'providers.dart';
import 'tema/aspecto.dart';

/// Lee o crea los ids y la clave, abre la base y crea lo que falte.
///
/// Devuelve los `overrides` que `main.dart` pasa a `ProviderScope`.
abstract final class Arranque {
  static Future<List<Override>> iniciar({
    AlmacenSeguro? almacen,
    QueryExecutor? ejecutor,
    Reloj reloj = const RelojSistema(),
    String? plataforma,
    bool? demoWeb,
    bool? sembrarDemo,
    Random? azar,
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

    // Círculo y persona: los de la base si ya existen.
    var circuloId = await guardia.leer(ClavesAlmacen.circuloId);
    circuloId ??= (await base.select(base.circulos).get()).firstOrNull?.id;
    circuloId ??= uuid.v4();
    await guardia.escribir(ClavesAlmacen.circuloId, circuloId);
    final persona =
        await (base.select(base.personas)
              ..where((p) => p.circuloId.equals(circuloId!))
              ..limit(1))
            .getSingleOrNull();
    final contexto = ContextoApp(
      circuloId: circuloId,
      personaId: persona?.id ?? uuid.v4(),
      dispositivoId: dispositivoId,
      plataforma: plat,
    );

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
