import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contexto.dart';
import 'cripto/almacen_seguro.dart';
import 'db/base_datos.dart';
import 'db/repositorios/circulo_repositorio.dart';
import 'db/repositorios/eventos_repositorio.dart';
import 'db/repositorios/medicacion_repositorio.dart';
import 'db/repositorios/voces_repositorio.dart';
import 'plataforma/alarmas/alarmas_android.dart';
import 'plataforma/alarmas/alarmas_canal.dart';
import 'plataforma/alarmas/alarmas_no_disponibles.dart';
import 'plataforma/alarmas/programador_alarmas.dart';
import 'plataforma/alarmas/servicio_alarmas.dart';
import 'plataforma/audio/archivos_voz.dart';
import 'plataforma/audio/archivos_voz_disco.dart';
import 'plataforma/audio/audio_movil.dart';
import 'plataforma/audio/audio_simulado.dart';
import 'plataforma/audio/grabadora.dart';
import 'plataforma/audio/reproductor.dart';
import 'plataforma/camara/camara_comprobacion.dart';
import 'plataforma/camara/camara_movil.dart';
import 'plataforma/camara/camara_simulada.dart';
import 'cripto/cifrado_sobres.dart';
import 'sync/config_sync.dart';
import 'sync/noop_transport.dart';
import 'sync/servicio_sync.dart';
import 'sync/supabase_transport.dart';
import 'sync/sync_transport.dart';

Never _sinOverride(String nombre) => throw StateError(
  '$nombre debe sustituirse en ProviderScope (Arranque.iniciar)',
);

// ----------------------------------------------------------- Sustituidos al arrancar

final almacenSeguroProvider = Provider<AlmacenSeguro>(
  (ref) => _sinOverride('almacenSeguroProvider'),
);

final baseDatosProvider = Provider<AppDatabase>(
  (ref) => _sinOverride('baseDatosProvider'),
);

final contextoProvider = Provider<ContextoApp>(
  (ref) => _sinOverride('contextoProvider'),
);

/// Perfil guardado al abrir la app (nulo la primera vez).
final sesionInicialProvider = Provider<Sesion>((ref) => const Sesion());

// ----------------------------------------------------------- Infraestructura

/// Nadie más llama a `DateTime.now()`.
final relojProvider = Provider<Reloj>((ref) => const RelojSistema());

final azarProvider = Provider<Random>((ref) => Random.secure());

/// `true` en la demo web: banner de aviso y datos de ejemplo.
final esDemoWebProvider = Provider<bool>((ref) => kIsWeb);

final servicioAlarmasProvider = Provider<ServicioAlarmas>((ref) {
  if (kIsWeb) return const AlarmasNoDisponibles();
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => AlarmasCanal(),
    TargetPlatform.android => AlarmasAndroid(),
    _ => const AlarmasNoDisponibles(),
  };
});

/// Cámara frontal en móvil; en web, la simulada.
final camaraProvider = Provider<CamaraComprobacion>(
  (ref) => kIsWeb ? const CamaraSimulada() : const CamaraMovil(),
);

/// Carpeta de los audios de las voces: documentos de la app en el móvil; en
/// la demo web, la memoria.
final archivosVozProvider = Provider<ArchivosVoz>(
  (ref) => kIsWeb ? ArchivosVozMemoria() : ArchivosVozDisco(),
);

/// Micrófono (paquete `record`); en la demo web, la grabadora simulada.
final grabadoraProvider = Provider<Grabadora>((ref) {
  final archivos = ref.watch(archivosVozProvider);
  final g = kIsWeb ? GrabadoraSimulada(archivos) : GrabadoraMovil(archivos);
  ref.onDispose(() => unawaited(g.liberar()));
  return g;
});

/// Altavoz (paquete `audioplayers`); en la demo web, el simulado.
final reproductorProvider = Provider<Reproductor>((ref) {
  final archivos = ref.watch(archivosVozProvider);
  final r = kIsWeb ? ReproductorSimulado() : ReproductorMovil(archivos);
  ref.onDispose(() => unawaited(r.liberar()));
  return r;
});

/// Abre enlaces y llamadas. Sustituible en tests.
final abrirEnlaceProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

// ----------------------------------------------------------- Sesión

class SesionNotifier extends Notifier<Sesion> {
  @override
  Sesion build() => ref.watch(sesionInicialProvider);

  /// Guarda el perfil, registra el dispositivo y deja `perfil_elegido`.
  Future<void> elegirPerfil(PerfilApp perfil) async {
    final contexto = ref.read(contextoProvider);
    await ref
        .read(almacenSeguroProvider)
        .escribir(ClavesAlmacen.perfil, perfil.nombre);
    final miembroId = await ref
        .read(circuloRepositorioProvider)
        .asegurarDispositivo(perfil);
    state = Sesion(perfil: perfil, miembroId: miembroId);
    await ref
        .read(eventosRepositorioProvider)
        .registrar(
          TipoEvento.perfilElegido,
          payload: {'perfil': perfil.nombre},
          autor: miembroId ?? contexto.personaId,
        );
  }

  /// Vuelve a la elección de perfil.
  Future<void> cambiarPerfil() async {
    await ref.read(almacenSeguroProvider).borrar(ClavesAlmacen.perfil);
    state = const Sesion();
  }
}

final sesionProvider = NotifierProvider<SesionNotifier, Sesion>(
  SesionNotifier.new,
);

/// Quién firma los eventos: el miembro (familia) o la persona.
String autorActual(Ref ref) {
  final s = ref.read(sesionProvider);
  return s.miembroId ?? ref.read(contextoProvider).personaId;
}

// ----------------------------------------------------------- Repositorios

final eventosRepositorioProvider = Provider<EventosRepositorio>((ref) {
  return EventosRepositorio(
    db: ref.watch(baseDatosProvider),
    reloj: ref.watch(relojProvider),
    azar: ref.watch(azarProvider),
    contexto: ref.watch(contextoProvider),
    autor: () => autorActual(ref),
  );
});

final circuloRepositorioProvider = Provider<CirculoRepositorio>((ref) {
  return CirculoRepositorio(
    db: ref.watch(baseDatosProvider),
    reloj: ref.watch(relojProvider),
    contexto: ref.watch(contextoProvider),
    eventos: ref.watch(eventosRepositorioProvider),
  );
});

final medicacionRepositorioProvider = Provider<MedicacionRepositorio>((ref) {
  return MedicacionRepositorio(
    db: ref.watch(baseDatosProvider),
    reloj: ref.watch(relojProvider),
    contexto: ref.watch(contextoProvider),
    eventos: ref.watch(eventosRepositorioProvider),
    circulo: ref.watch(circuloRepositorioProvider),
    autor: () => autorActual(ref),
  );
});

final vocesRepositorioProvider = Provider<VocesRepositorio>((ref) {
  return VocesRepositorio(
    db: ref.watch(baseDatosProvider),
    reloj: ref.watch(relojProvider),
    contexto: ref.watch(contextoProvider),
    eventos: ref.watch(eventosRepositorioProvider),
    archivos: ref.watch(archivosVozProvider),
  );
});

// ----------------------------------------------------------- Datos observados

final personaProvider = StreamProvider<Persona?>(
  (ref) => ref.watch(circuloRepositorioProvider).observarPersona(),
);

final miembrosProvider = StreamProvider<List<Miembro>>(
  (ref) => ref.watch(circuloRepositorioProvider).observarMiembros(),
);

final medicamentosProvider = StreamProvider<List<Medicamento>>(
  (ref) => ref.watch(medicacionRepositorioProvider).observarMedicamentos(),
);

final pautasProvider = StreamProvider<List<Pauta>>(
  (ref) => ref.watch(medicacionRepositorioProvider).observarPautas(),
);

final ultimoMensajeProvider = StreamProvider<Evento?>(
  (ref) => ref.watch(eventosRepositorioProvider).observarUltimoMensaje(),
);

/// Voces grabadas de los familiares (también las retiradas).
final vocesProvider = StreamProvider<List<Voz>>(
  (ref) => ref.watch(vocesRepositorioProvider).observarVoces(),
);

/// Frases de esas voces.
final frasesProvider = StreamProvider<List<Frase>>(
  (ref) => ref.watch(vocesRepositorioProvider).observarFrases(),
);

/// Frase que suena para un uso, con la voz preferida (la de la pauta) o la
/// primera del círculo ([elegirFrase]). Nula si no hay: no suena nada.
final fraseSonoraProvider =
    Provider.family<FraseSonora?, ({UsoFrase uso, String? vozId})>((ref, p) {
      final voces = ref.watch(vocesProvider).value;
      final frases = ref.watch(frasesProvider).value;
      final miembros = ref.watch(miembrosProvider).value;
      if (voces == null || frases == null || miembros == null) return null;
      return elegirFrase(
        uso: p.uso,
        vozPreferida: p.vozId,
        voces: voces,
        frases: frases,
        miembros: miembros,
      );
    });

/// Resumen de las frases `toma` que pueden sonar en una alarma (nulo
/// mientras carga). Si cambia, se reprograman las alarmas.
final firmaVozTomaProvider = Provider<String?>((ref) {
  final voces = ref.watch(vocesProvider).value;
  final frases = ref.watch(frasesProvider).value;
  if (voces == null || frases == null) return null;
  final activas = {
    for (final v in voces)
      if (v.retiradaEn == null) v.id,
  };
  return ([
    for (final f in frases)
      if (f.uso == UsoFrase.toma.nombre &&
          f.aprobada &&
          f.audioRuta != null &&
          activas.contains(f.vozId))
        '${f.vozId}:${f.audioRuta}',
  ]..sort()).join('|');
});

/// Foto por id (nula si no existe).
final fotoProvider = FutureProvider.family<Uint8List?, String>((ref, id) async {
  final f = await ref.watch(circuloRepositorioProvider).foto(id);
  return f?.bytes;
});

/// Instante actual del [Reloj], renovado cada 15 segundos.
final ahoraProvider = StreamProvider<DateTime>((ref) async* {
  final reloj = ref.watch(relojProvider);
  yield reloj.ahora();
  yield* Stream.periodic(const Duration(seconds: 15), (_) => reloj.ahora());
});

// ----------------------------------------------------------- Alarmas

final programadorAlarmasProvider = Provider<ProgramadorAlarmas>((ref) {
  return ProgramadorAlarmas(
    servicio: ref.watch(servicioAlarmasProvider),
    medicacion: ref.watch(medicacionRepositorioProvider),
    eventos: ref.watch(eventosRepositorioProvider),
    reloj: ref.watch(relojProvider),
    contexto: ref.watch(contextoProvider),
    voces: ref.watch(vocesRepositorioProvider),
  );
});

// ----------------------------------------------------------- Cartero cifrado

/// URL y clave anon de Supabase fijadas al compilar (vacías: solo local).
final configSyncProvider = Provider<ConfigSync>(
  (ref) => ConfigSync.desdeEntorno(),
);

/// Token del servidor y clave de los sobres, derivados de la clave del
/// círculo (nulo sin clave, como en la demo web).
final llavesCirculoProvider = FutureProvider<LlavesCirculo?>(
  (ref) => LlavesCirculo.desdeAlmacen(ref.watch(almacenSeguroProvider)),
);

/// Supabase si hay configuración; si no, [NoopTransport].
final syncTransportProvider = Provider<SyncTransport>((ref) {
  final config = ref.watch(configSyncProvider);
  if (!config.configurada) return const NoopTransport();
  final contexto = ref.watch(contextoProvider);
  final transporte = SupabaseTransport(
    config: config,
    circuloId: contexto.circuloId,
    remitente: contexto.dispositivoId,
    circuloToken: () async =>
        (await ref.read(llavesCirculoProvider.future))?.token,
  );
  ref.onDispose(() => unawaited(transporte.desconectar()));
  return transporte;
});

/// Servicio de sincronización; nulo con [NoopTransport] (no toca nada).
final servicioSyncProvider = Provider<ServicioSync?>((ref) {
  final transporte = ref.watch(syncTransportProvider);
  if (transporte is NoopTransport) return null;
  final servicio = ServicioSync(
    db: ref.watch(baseDatosProvider),
    transporte: transporte,
    llaves: () => ref.read(llavesCirculoProvider.future),
    contexto: ref.watch(contextoProvider),
    reloj: ref.watch(relojProvider),
    archivos: ref.watch(archivosVozProvider),
  );
  ref.onDispose(() => unawaited(servicio.detener()));
  return servicio;
});
