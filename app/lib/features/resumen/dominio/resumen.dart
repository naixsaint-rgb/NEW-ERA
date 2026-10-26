import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/db/repositorios/eventos_repositorio.dart';
import '../../../core/providers.dart';
import '../../hoy/dominio/tomas.dart';
import '../../persona_inicio/llamadas.dart';

/// Cómo se confirmó la última toma.
enum OrigenConfirmacion { movil, reloj, familiar }

/// La última toma confirmada de hoy: cuándo, qué, quién y desde dónde.
final class UltimaConfirmacion {
  const UltimaConfirmacion({
    required this.cuando,
    required this.medicamento,
    required this.autorId,
    required this.origen,
  });

  final DateTime cuando;

  /// Nombre del medicamento para la persona.
  final String medicamento;
  final String autorId;
  final OrigenConfirmacion origen;
}

/// Todo lo que enseña la pestaña Resumen, calculado.
final class ResumenDatos {
  const ResumenDatos({
    required this.nivel,
    required this.hechas,
    required this.previstas,
    required this.videos,
    required this.avisos,
    required this.ahora,
    this.retraso = false,
    this.alias,
    this.ultimaConfirmacion,
    this.ultimaSenal,
    this.siguiente,
    this.mensaje,
    this.familiar1,
    this.minutosAvisoFamiliar1,
  });

  final NivelSemaforo nivel;

  /// `true` si el naranja es por una toma que se retrasa ([hayRetraso]).
  final bool retraso;

  /// El instante con el que se calculó (para "ayer", "mañana", "pendiente").
  final DateTime ahora;

  /// Alias de la persona (nulo mientras carga).
  final String? alias;

  final UltimaConfirmacion? ultimaConfirmacion;

  /// Último evento de la persona (o, si no hay, la última confirmación).
  final DateTime? ultimaSenal;

  /// Tomas de hoy confirmadas y tomas de hoy en total.
  final int hechas;
  final int previstas;

  /// Clips grabados en las tomas de hoy.
  final int videos;

  /// `ayuda_pedida` y `llamada_iniciada` de hoy.
  final int avisos;

  final TomaVista? siguiente;

  /// Último mensaje a la persona.
  final Evento? mensaje;

  /// Familiar 1 ([primerFamiliar]) y los minutos de su paso de aviso.
  final Miembro? familiar1;
  final int? minutosAvisoFamiliar1;
}

/// Tomas de [deHoy] hechas ([esHecha]: confirmadas o cerradas por un
/// familiar).
int contarHechas(Iterable<TomaVista> deHoy) =>
    deHoy.where((t) => esHecha(t.estado)).length;

/// Clips grabados (`clip_grabado`, sin contar los anulados) en las tomas de
/// [deHoy].
int contarVideos(Iterable<TomaVista> deHoy) {
  var n = 0;
  for (final t in deHoy) {
    final anulados = {
      for (final e in t.eventos)
        if (e.tipo == TipoEvento.anulacion.nombre && e.corrigeA != null)
          e.corrigeA,
    };
    n += t.eventos
        .where(
          (e) =>
              e.tipo == TipoEvento.clipGrabado.nombre &&
              !anulados.contains(e.ulid),
        )
        .length;
  }
  return n;
}

/// La confirmación más reciente entre las tomas de [deHoy] confirmadas.
UltimaConfirmacion? ultimaConfirmacionDe(Iterable<TomaVista> deHoy) {
  UltimaConfirmacion? mejor;
  for (final t in deHoy) {
    if (!esHecha(t.estado)) continue;
    final e = t.ultimoDe(TipoEvento.tomaConfirmada);
    if (e == null) continue;
    final cuando = _instante(e);
    if (mejor != null && !cuando.isAfter(mejor.cuando)) continue;
    mejor = UltimaConfirmacion(
      cuando: cuando,
      medicamento: t.nombreParaPersona,
      autorId: e.autor,
      origen: switch (EventosRepositorio.payloadDe(e)['origen']) {
        'reloj' => OrigenConfirmacion.reloj,
        'familiar' => OrigenConfirmacion.familiar,
        _ => OrigenConfirmacion.movil,
      },
    );
  }
  return mejor;
}

/// Minutos del paso `avisarFamiliar1`, si [config] lo tiene.
int? minutosAvisoFamiliar1(ConfigEscalado config) {
  for (final p in config.pasos) {
    if (p.accion == AccionEscalado.avisarFamiliar1) return p.minuto;
  }
  return null;
}

/// Eventos con los que la persona "da señales de vida".
const tiposDeSenal = {
  'toma_confirmada',
  'clip_grabado',
  'clip_fallido',
  'ayuda_pedida',
  'llamada_iniciada',
};

DateTime _instante(Evento e) =>
    DateTime.fromMillisecondsSinceEpoch(e.ocurridoEn, isUtc: true);

/// Último evento firmado por la persona que cuenta como señal.
final ultimoEventoDePersonaProvider = StreamProvider<Evento?>((ref) {
  final persona = ref.watch(contextoProvider).personaId;
  return ref
      .watch(eventosRepositorioProvider)
      .observarUltimoEvento(tipos: tiposDeSenal, autor: persona);
});

/// Última confirmación de cualquiera (por si la persona no ha firmado nada).
final ultimaConfirmacionGlobalProvider = StreamProvider<Evento?>((ref) {
  return ref
      .watch(eventosRepositorioProvider)
      .observarUltimoEvento(tipos: {TipoEvento.tomaConfirmada.nombre});
});

/// Los datos de la pestaña Resumen; carga mientras no estén las tomas.
final resumenProvider = Provider<AsyncValue<ResumenDatos>>((ref) {
  final hoy = ref.watch(tomasDeHoyProvider);
  if (hoy.hasError && !hoy.hasValue) {
    return AsyncValue.error(hoy.error!, hoy.stackTrace ?? StackTrace.empty);
  }
  if (!hoy.hasValue) return const AsyncValue.loading();
  final deHoy = hoy.requireValue;
  final siguiente = ref.watch(siguienteTomaProvider).value;
  final avisos = ref.watch(avisosDeHoyProvider).value ?? 0;
  final deLaPersona = ref.watch(ultimoEventoDePersonaProvider).value;
  final global = ref.watch(ultimaConfirmacionGlobalProvider).value;
  final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
  final config = ref.watch(configEscaladoProvider);
  final ahora =
      ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();

  final senal = deLaPersona ?? global;
  return AsyncValue.data(
    ResumenDatos(
      nivel: nivelSemaforo(deHoy, ahora, config),
      retraso: hayRetraso(deHoy, ahora, config),
      ahora: ahora,
      alias: ref.watch(personaProvider).value?.alias,
      ultimaConfirmacion: ultimaConfirmacionDe(deHoy),
      ultimaSenal: senal == null ? null : _instante(senal),
      hechas: contarHechas(deHoy),
      previstas: deHoy.length,
      videos: contarVideos(deHoy),
      avisos: avisos,
      siguiente: siguiente,
      mensaje: ref.watch(ultimoMensajeProvider).value,
      familiar1: primerFamiliar(miembros),
      minutosAvisoFamiliar1: minutosAvisoFamiliar1(config),
    ),
  );
});
