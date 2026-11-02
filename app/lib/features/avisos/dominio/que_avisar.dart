import 'package:safety_core/safety_core.dart';

import '../../hoy/dominio/control_horas.dart';
import '../../hoy/dominio/tomas.dart';

// Qué avisos tocan en el móvil de la persona (plan v3, 2.2 y 2.4 bis). Lógica
// pura: la usan la app abierta (cada 15 segundos y con cada cambio) y la
// revisión en segundo plano de Android. El envío es idempotente
// (`EnvioAvisos`): que dos caminos pidan el mismo aviso no lo repite.

/// Margen de las revisiones en segundo plano tras cada instante: la ronda
/// cuenta como sin respuesta pasado el minuto 10, no en él.
const margenRevision = Duration(seconds: 5);

/// Lo que toca avisar en [ahora]:
/// - Tomas sin hacer: el escalón 1 a los 5 minutos y el 2 a los 10 (de
///   [config]); una toma confirmada o cerrada no avisa.
/// - Rondas de [control] sin respuesta a los 10 minutos.
/// - De [situaciones]: ayuda pedida, «mal» y dolor nuevo, al momento.
///
/// Solo lo que está dentro de [ventanaAviso] ([tocaAviso]).
List<AvisoPendiente> avisosQueTocan({
  required Iterable<TomaVista> tomas,
  required ControlDelDia? control,
  required Iterable<AvisoDelDia> situaciones,
  required ConfigEscalado config,
  required DateTime ahora,
}) {
  final r = <AvisoPendiente>[];
  for (final t in tomas) {
    if (esHecha(t.estado)) continue;
    for (final e in escalonesToma) {
      final vence = t.toma.previstaPara.add(
        Duration(minutes: minutoDeEscalon(config, e)),
      );
      if (tocaAviso(vence, ahora)) {
        r.add(
          AvisoPendiente(
            motivo: MotivoAviso.tomaSinConfirmar,
            sujeto: t.toma.id,
            escalon: e,
            vence: vence,
          ),
        );
      }
    }
  }
  for (final x in control?.rondas ?? const <RondaDelDia>[]) {
    if (x.estado != EstadoRonda.sinRespuesta) continue;
    final vence = x.ronda.hora.add(esperaRespuestaRonda);
    if (tocaAviso(vence, ahora)) {
      r.add(
        AvisoPendiente(
          motivo: MotivoAviso.rondaSinRespuesta,
          sujeto: x.ronda.id,
          vence: vence,
        ),
      );
    }
  }
  for (final s in situaciones) {
    final (motivo, sujeto) = switch (s.tipo) {
      TipoAviso.ayudaPedida => (MotivoAviso.ayudaPedida, s.origen),
      TipoAviso.estadoMal => (MotivoAviso.estadoMal, s.rondas.firstOrNull),
      TipoAviso.dolorNuevo => (MotivoAviso.dolorNuevo, s.rondas.firstOrNull),
      _ => (null, null),
    };
    if (motivo == null || sujeto == null) continue;
    if (!tocaAviso(s.cuando, ahora)) continue;
    r.add(AvisoPendiente(motivo: motivo, sujeto: sujeto, vence: s.cuando));
  }
  r.sort((a, b) => a.vence.compareTo(b.vence));
  return r;
}

/// Instantes en los que el móvil de la persona revisa los avisos con la app
/// cerrada: cada toma de [tomas] a los minutos de sus dos escalones y cada
/// ronda de [rondas] a los 10 minutos, más [margenRevision]. Solo los
/// futuros, sin repetir y en orden.
List<DateTime> instantesDeRevision({
  required Iterable<DateTime> tomas,
  required Iterable<RondaControl> rondas,
  required ConfigEscalado config,
  required DateTime ahora,
}) {
  final r = <DateTime>{
    for (final t in tomas)
      for (final e in escalonesToma)
        t.add(Duration(minutes: minutoDeEscalon(config, e)) + margenRevision),
    for (final x in rondas) x.hora.add(esperaRespuestaRonda + margenRevision),
  };
  return [
    for (final t in r)
      if (t.isAfter(ahora)) t,
  ]..sort();
}
