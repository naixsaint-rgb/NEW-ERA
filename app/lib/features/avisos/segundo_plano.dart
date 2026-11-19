import 'dart:async';
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
import '../../core/db/repositorios/ubicacion_repositorio.dart';
import '../../core/plataforma/audio/archivos_voz_disco.dart';
import '../../core/plataforma/ubicacion/ubicador.dart';
import '../../core/plataforma/ubicacion/ubicador_movil.dart';
import '../../core/sync/config_sync.dart';
import '../../core/sync/servicio_sync.dart';
import '../../core/sync/supabase_transport.dart';
import '../../core/sync/sync_transport.dart';
import '../ubicacion/toma_ubicacion.dart';
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
    ubicador: UbicadorMovil(),
    cartero: _carteroDeEntorno,
  );
}

/// Cada cuánto revisa con la app cerrada mientras la familia la busca.
const intervaloBusquedaSegundoPlano = Duration(minutes: 5);

/// El cartero de la app (Supabase), o nulo sin servidor configurado.
CarteroSegundoPlano? _carteroDeEntorno(
  AppDatabase db,
  ContextoApp contexto,
  Reloj reloj,
  AlmacenSeguro almacen,
) {
  final config = ConfigSync.desdeEntorno();
  if (!config.configurada) return null;
  Future<LlavesCirculo?> llaves() => LlavesCirculo.desdeAlmacen(almacen);
  final transporte = SupabaseTransport(
    config: config,
    circuloId: contexto.circuloId,
    remitente: contexto.dispositivoId,
    circuloToken: () async => (await llaves())?.token,
  );
  return (
    transporte: transporte,
    servicio: ServicioSync(
      db: db,
      transporte: transporte,
      llaves: llaves,
      contexto: contexto,
      reloj: reloj,
      archivos: ArchivosVozDisco(),
    ),
  );
}

/// Transporte y servicio del cartero para una revisión en segundo plano.
typedef CarteroSegundoPlano = ({
  SyncTransport transporte,
  ServicioSync servicio,
});

/// Una revisión en segundo plano: suelta la alarma [alarma] que acaba de
/// saltar ([ProgramadorAvisos.soltar]), lee los ids y la clave de [almacen],
/// abre la base cifrada, envía lo que toque ([revisarAvisos]) y, si hay
/// servidor, lleva al cartero los `aviso_enviado` para que la familia los vea
/// en Hoy. Si algún envío falla, programa otra revisión pasada
/// [EnvioAvisos.pausaTrasFallo] (con la app cerrada no hay otra forma de
/// reintentar; fuera de [ventanaAviso] ya no hay nada que enviar y se acaba).
/// Solo en el móvil de la persona (perfil `persona`). Nunca lanza.
///
/// Ubicación (con su consentimiento y el permiso «todo el tiempo»): antes de
/// revisar, recoge del [cartero] lo que haya llegado (p. ej. una búsqueda
/// pedida por la familia o una toma cerrada a distancia) y toma una posición
/// con [ubicador] (la de bajo consumo; con búsqueda, la precisa). Mientras
/// dure la búsqueda, deja otra revisión para dentro de
/// [intervaloBusquedaSegundoPlano].
@visibleForTesting
Future<void> revisionEnSegundoPlano({
  required int alarma,
  required AlmacenSeguro almacen,
  required Future<QueryExecutor> Function(String claveHex) abrir,
  required CanalAvisos canal,
  required ProgramadorAvisos programador,
  required Reloj reloj,
  Ubicador? ubicador,
  CarteroSegundoPlano? Function(
    AppDatabase db,
    ContextoApp contexto,
    Reloj reloj,
    AlmacenSeguro almacen,
  )?
  cartero,
}) async {
  await programador.soltar(alarma);
  AppDatabase? db;
  CarteroSegundoPlano? correo;
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
    final c = correo = cartero?.call(base, contexto, reloj, almacen);
    if (c != null) await recibirPendientes(c.transporte, c.servicio);
    final ubicacion = UbicacionRepositorio(
      db: base,
      reloj: reloj,
      contexto: contexto,
      eventos: eventosDePersona(base, contexto, reloj),
      autor: () => contexto.personaId,
    );
    String? posicion;
    final busqueda = await ubicacion.busqueda();
    if (ubicador != null) {
      posicion = await TomaUbicacion(ubicador: ubicador, repo: ubicacion).tomar(
        busqueda != null
            ? OrigenUbicacion.busqueda
            : OrigenUbicacion.segundoPlano,
        precisa: busqueda != null,
      );
    } else {
      await ubicacion.purgar();
    }
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
    final siguientes = <DateTime>[
      if (envio.fallidos > 0)
        reloj.ahora().add(EnvioAvisos.pausaTrasFallo + margenRevision),
      if (busqueda != null) ?_siguienteDeBusqueda(busqueda, reloj.ahora()),
    ];
    if (siguientes.isNotEmpty) await programador.programar(siguientes);
    if ((enviados > 0 || posicion != null) && c != null) {
      await _alCartero(c);
    }
  } catch (_) {
    // Sin base, sin clave o sin red: la app abierta lo vuelve a mirar.
  } finally {
    try {
      await correo?.servicio.detener();
    } catch (_) {
      // Sin red: nada que cerrar.
    }
    await db?.close();
  }
}

/// La siguiente revisión mientras dura [b]: dentro de
/// [intervaloBusquedaSegundoPlano], o nula si ya ha acabado.
DateTime? _siguienteDeBusqueda(BusquedaPedida b, DateTime ahora) {
  final t = ahora.add(intervaloBusquedaSegundoPlano);
  return t.isBefore(b.hasta.add(margenRevision)) ? t : null;
}

/// Recoge del cartero lo que haya llegado desde el último sobre guardado y
/// para cuando lleva [silencio] sin llegar nada (o pasado [maximo]). Nunca
/// lanza.
@visibleForTesting
Future<void> recibirPendientes(
  SyncTransport transporte,
  ServicioSync servicio, {
  Duration silencio = const Duration(seconds: 3),
  Duration maximo = const Duration(seconds: 20),
}) async {
  StreamSubscription<Object?>? sub;
  Timer? quieto;
  var cola = Future<void>.value();
  try {
    await transporte.conectar();
    final fin = Completer<void>();
    void acabar() {
      if (!fin.isCompleted) fin.complete();
    }

    void rearmar() {
      quieto?.cancel();
      quieto = Timer(silencio, acabar);
    }

    sub = transporte
        .recibidos(desde: await servicio.ultimoRecibido())
        .listen(
          (sobre) {
            rearmar();
            cola = cola.then((_) async {
              try {
                await servicio.recibir(sobre);
              } catch (_) {
                // Se vuelve a pedir en la próxima pasada.
              }
            });
          },
          onError: (Object _) {},
          onDone: acabar,
        );
    rearmar();
    await fin.future.timeout(maximo, onTimeout: () {});
  } catch (_) {
    // Sin red: la app lo recoge al abrirse.
  } finally {
    quieto?.cancel();
    await sub?.cancel();
    await cola;
  }
}

/// Una pasada del cartero: envía los eventos pendientes (también los
/// `aviso_enviado` y la posición recién apuntados) y se desconecta.
Future<void> _alCartero(CarteroSegundoPlano correo) async {
  try {
    await correo.transporte.conectar();
    await correo.servicio.empujar();
  } catch (_) {
    // Lo enviará la app al abrirse.
  }
}
