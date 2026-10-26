import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/db/repositorios/eventos_repositorio.dart';
import '../../../core/i18n/fechas.dart';
import '../../../core/providers.dart';
import '../../hoy/dominio/tomas.dart';

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
    this.alias,
    this.ultimaConfirmacion,
    this.ultimaSenal,
    this.siguiente,
    this.mensaje,
    this.familiar1,
    this.minutosAvisoFamiliar1,
  });

  final NivelSemaforo nivel;

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

  /// Primer miembro por `ordenEscalado` y los minutos de su paso de aviso.
  final Miembro? familiar1;
  final int? minutosAvisoFamiliar1;
}

/// `true` si la toma está confirmada (con o sin vídeo).
bool estaHecha(TomaVista t) =>
    t.estado == EstadoToma.confirmada ||
    t.estado == EstadoToma.confirmadaSinVideo;

/// Tomas de [deHoy] confirmadas.
int contarHechas(Iterable<TomaVista> deHoy) => deHoy.where(estaHecha).length;

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
    if (!estaHecha(t)) continue;
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

/// Primer miembro del escalado (el de menor `ordenEscalado`).
Miembro? primerFamiliar(Iterable<Miembro> miembros) {
  Miembro? mejor;
  for (final m in miembros) {
    final orden = m.ordenEscalado;
    if (orden == null) continue;
    if (mejor == null || orden < mejor.ordenEscalado!) mejor = m;
  }
  return mejor;
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

/// Principio del día de hoy (00:00 local) en UTC.
final inicioDeHoyProvider = Provider<DateTime>((ref) {
  final ahora =
      ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
  return inicioDelDia(ahora, ref.watch(contextoProvider).zonaHoraria);
});

/// Avisos de hoy: ayuda pedida y llamadas iniciadas.
final avisosDeHoyProvider = StreamProvider<List<Evento>>((ref) {
  final desde = ref.watch(inicioDeHoyProvider);
  return ref
      .watch(eventosRepositorioProvider)
      .observarEventosDesde(
        desde,
        tipos: {
          TipoEvento.ayudaPedida.nombre,
          TipoEvento.llamadaIniciada.nombre,
        },
      );
});

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
  final avisos = ref.watch(avisosDeHoyProvider).value ?? const <Evento>[];
  final deLaPersona = ref.watch(ultimoEventoDePersonaProvider).value;
  final global = ref.watch(ultimaConfirmacionGlobalProvider).value;
  final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
  final config = ref.watch(configEscaladoProvider);

  final senal = deLaPersona ?? global;
  return AsyncValue.data(
    ResumenDatos(
      nivel: nivelSemaforo(deHoy),
      alias: ref.watch(personaProvider).value?.alias,
      ultimaConfirmacion: ultimaConfirmacionDe(deHoy),
      ultimaSenal: senal == null ? null : _instante(senal),
      hechas: contarHechas(deHoy),
      previstas: deHoy.length,
      videos: contarVideos(deHoy),
      avisos: avisos.length,
      siguiente: siguiente,
      mensaje: ref.watch(ultimoMensajeProvider).value,
      familiar1: primerFamiliar(miembros),
      minutosAvisoFamiliar1: minutosAvisoFamiliar1(config),
    ),
  );
});
