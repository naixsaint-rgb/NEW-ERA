import 'dart:ui';

import 'package:drift/drift.dart' show QueryExecutor;
import 'package:flutter/widgets.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/avisos/canal_avisos.dart';
import '../../core/avisos/envio_avisos.dart';
import '../../core/avisos/programador_avisos.dart';
import '../../core/contexto.dart';
import '../../core/cripto/almacen_seguro.dart';
import '../../core/cripto/cifrado_sobres.dart';
import '../../core/cripto/tema_aviso.dart';
import '../../core/db/base_datos.dart';
import '../../core/db/conexion/conexion.dart';
import '../../core/sync/config_sync.dart';
import '../../core/sync/servicio_sync.dart';
import '../../core/sync/supabase_transport.dart';
import 'dominio/que_avisar.dart';
import 'revision_avisos.dart';

/// Revisión de avisos con la app cerrada (Android, `android_alarm_manager_plus`).
///
/// Corre en su propio hilo, sin pantalla. El plugin le pasa el [id] de la
/// alarma que saltó ([revisionEnSegundoPlano]). Nunca lanza.
@pragma('vm:entry-point')
Future<void> revisarAvisosEnSegundoPlano(int id) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await revisionEnSegundoPlano(
    alarma: id,
    almacen: AlmacenSeguroFlutter(),
    abrir: (clave) => abrirConexion(claveHex: clave),
    canal: CanalNtfy(),
    programador: const ProgramadorAvisosAndroid(revisarAvisosEnSegundoPlano),
    reloj: const RelojSistema(),
  );
}

/// Una revisión en segundo plano: suelta la alarma [alarma] que acaba de
/// saltar ([ProgramadorAvisos.soltar]), lee los ids y la clave de [almacen],
/// abre la base cifrada, envía lo que toque ([revisarAvisos]) y, si hay
/// servidor, lleva al cartero los `aviso_enviado` para que la familia los vea
/// en Hoy. Si algún envío falla, programa otra revisión pasada
/// [EnvioAvisos.pausaTrasFallo] (con la app cerrada no hay otra forma de
/// reintentar; fuera de [ventanaAviso] ya no hay nada que enviar y se acaba).
/// Solo en el móvil de la persona (perfil `persona`). Nunca lanza.
@visibleForTesting
Future<void> revisionEnSegundoPlano({
  required int alarma,
  required AlmacenSeguro almacen,
  required Future<QueryExecutor> Function(String claveHex) abrir,
  required CanalAvisos canal,
  required ProgramadorAvisos programador,
  required Reloj reloj,
}) async {
  await programador.soltar(alarma);
  AppDatabase? db;
  try {
    inicializarZonas();
    if (await almacen.leer(ClavesAlmacen.perfil) != PerfilApp.persona.nombre) {
      return;
    }
    final clave = await almacen.leer(ClavesAlmacen.circuloClave);
    final circuloId = await almacen.leer(ClavesAlmacen.circuloId);
    final personaId = await almacen.leer(ClavesAlmacen.personaId);
    final dispositivoId = await almacen.leer(ClavesAlmacen.dispositivoId);
    if (clave == null ||
        clave.length != 64 ||
        circuloId == null ||
        personaId == null ||
        dispositivoId == null) {
      return;
    }
    // La app puede estar escribiendo a la vez desde su propio hilo: la
    // conexión espera hasta 5 s (`busy_timeout`).
    final base = db = AppDatabase(await abrir(clave));
    final contexto = ContextoApp(
      circuloId: circuloId,
      personaId: personaId,
      dispositivoId: dispositivoId,
      plataforma: 'android',
      circuloExterno: await almacen.leer(ClavesAlmacen.circuloExterno) == '1',
    );
    final envio = EnvioAvisos(
      db: base,
      eventos: eventosDePersona(base, contexto, reloj),
      canal: canal,
      reloj: reloj,
      contexto: contexto,
      tema: (id) => TemaAviso.desdeAlmacen(almacen, id),
    );
    final enviados = await revisarAvisos(
      db: base,
      contexto: contexto,
      reloj: reloj,
      envio: envio,
    );
    if (envio.fallidos > 0) {
      await programador.programar([
        reloj.ahora().add(EnvioAvisos.pausaTrasFallo + margenRevision),
      ]);
    }
    if (enviados > 0) await _alCartero(base, contexto, reloj, almacen);
  } catch (_) {
    // Sin base, sin clave o sin red: la app abierta lo vuelve a mirar.
  } finally {
    await db?.close();
  }
}

/// Una pasada del cartero: envía los eventos pendientes (también los
/// `aviso_enviado` recién apuntados) y se desconecta. Sin servidor, nada.
Future<void> _alCartero(
  AppDatabase db,
  ContextoApp contexto,
  Reloj reloj,
  AlmacenSeguro almacen,
) async {
  final config = ConfigSync.desdeEntorno();
  if (!config.configurada) return;
  Future<LlavesCirculo?> llaves() => LlavesCirculo.desdeAlmacen(almacen);
  final transporte = SupabaseTransport(
    config: config,
    circuloId: contexto.circuloId,
    remitente: contexto.dispositivoId,
    circuloToken: () async => (await llaves())?.token,
  );
  final servicio = ServicioSync(
    db: db,
    transporte: transporte,
    llaves: llaves,
    contexto: contexto,
    reloj: reloj,
  );
  try {
    await transporte.conectar();
    await servicio.empujar();
  } catch (_) {
    // Lo enviará la app al abrirse.
  } finally {
    await servicio.detener();
  }
}
