import 'estado_toma.dart';

/// Acciones del escalado de una toma (plan 2.2).
enum AccionEscalado {
  /// Minuto 0: suena el aviso.
  aviso('aviso'),

  /// Minuto 2: repetir la voz y subir el volumen.
  repetirVozYSubirVolumen('repetir_voz_subir_volumen'),

  /// Minuto 5: avisar al familiar 1.
  avisarFamiliar1('avisar_familiar_1'),

  /// Minuto 10: avisar al familiar 2 y al reloj.
  avisarFamiliar2YReloj('avisar_familiar_2_reloj'),

  /// Minuto 15: llamada del reloj al familiar 1.
  llamadaRelojFamiliar1('llamada_reloj_familiar_1'),

  /// Minuto 30: se da la toma por no confirmada.
  marcarNoConfirmada('marcar_no_confirmada');

  const AccionEscalado(this.nombre);
  final String nombre;
}

/// Un paso del escalado: el [minuto] (desde la hora prevista) y su [accion].
final class PasoEscalado {
  const PasoEscalado(this.minuto, this.accion);

  final int minuto;
  final AccionEscalado accion;

  @override
  bool operator ==(Object other) =>
      other is PasoEscalado && other.minuto == minuto && other.accion == accion;

  @override
  int get hashCode => Object.hash(minuto, accion);

  @override
  String toString() => 'PasoEscalado($minuto, ${accion.nombre})';
}

/// Configuración del escalado. Los valores por defecto son los del plan 2.2.
final class ConfigEscalado {
  const ConfigEscalado({
    this.pasos = const [
      PasoEscalado(0, AccionEscalado.aviso),
      PasoEscalado(2, AccionEscalado.repetirVozYSubirVolumen),
      PasoEscalado(5, AccionEscalado.avisarFamiliar1),
      PasoEscalado(10, AccionEscalado.avisarFamiliar2YReloj),
      PasoEscalado(15, AccionEscalado.llamadaRelojFamiliar1),
      PasoEscalado(30, AccionEscalado.marcarNoConfirmada),
    ],
    this.noConfirmadaTras = const Duration(minutes: 30),
  });

  final List<PasoEscalado> pasos;

  /// Tiempo tras la hora prevista a partir del cual la toma sin confirmar
  /// pasa a `noConfirmada`.
  final Duration noConfirmadaTras;
}

/// Pasos del escalado ya vencidos en [ahora]. Solo hay pasos si el [estado]
/// es `prevista` o `noConfirmada`; confirmada o cerrada no escala más.
List<PasoEscalado> accionesVencidas(
  DateTime previstaPara,
  DateTime ahora,
  EstadoToma estado,
  ConfigEscalado config,
) {
  if (estado != EstadoToma.prevista && estado != EstadoToma.noConfirmada) {
    return const [];
  }
  final transcurrido = ahora.toUtc().difference(previstaPara.toUtc());
  return [
    for (final p in config.pasos)
      if (transcurrido >= Duration(minutes: p.minuto)) p,
  ];
}
