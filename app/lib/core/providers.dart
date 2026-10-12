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
import 'plataforma/alarmas/alarmas_android.dart';
import 'plataforma/alarmas/alarmas_canal.dart';
import 'plataforma/alarmas/alarmas_no_disponibles.dart';
import 'plataforma/alarmas/programador_alarmas.dart';
import 'plataforma/alarmas/servicio_alarmas.dart';
import 'plataforma/camara/camara_comprobacion.dart';
import 'plataforma/camara/camara_movil.dart';
import 'plataforma/camara/camara_simulada.dart';
import 'sync/noop_transport.dart';
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

final syncTransportProvider = Provider<SyncTransport>(
  (ref) => const NoopTransport(),
);

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
  );
});
