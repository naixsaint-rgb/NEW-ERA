import 'escalado.dart';

/// Avisos a la familia (plan v3, 2.2 y 2.4 bis): qué los causa, a quién van y
/// cuándo tocan. Lógica pura; el envío lo hace la app.

/// Por qué se avisa. [prioridad] es la del canal (1 a 5): 5 para lo urgente
/// (toma sin confirmar, ayuda pedida, «mal»); 4 para el resto.
enum MotivoAviso {
  /// Una toma sigue sin confirmar a los 5 (familiar 1) o 10 minutos
  /// (familiar 2).
  tomaSinConfirmar('toma_sin_confirmar', 5),

  /// La persona pidió ayuda.
  ayudaPedida('ayuda_pedida', 5),

  /// Control por horas: dijo «mal».
  estadoMal('estado_mal', 5),

  /// Control por horas: un dolor nuevo (más que en la respuesta anterior del
  /// día).
  dolorNuevo('dolor_nuevo', 4),

  /// Control por horas: una ronda sin respuesta a los 10 minutos.
  rondaSinRespuesta('ronda_sin_respuesta', 4);

  const MotivoAviso(this.nombre, this.prioridad);

  /// Nombre guardado en el `tipo` de `aviso_enviado`.
  final String nombre;
  final int prioridad;

  static MotivoAviso? desdeNombre(Object? nombre) {
    for (final m in values) {
      if (m.nombre == nombre) return m;
    }
    return null;
  }
}

/// Cómo acabó un envío.
enum ResultadoAviso {
  enviado('enviado'),
  fallido('fallido');

  const ResultadoAviso(this.nombre);
  final String nombre;

  static ResultadoAviso? desdeNombre(Object? nombre) {
    for (final r in values) {
      if (r.nombre == nombre) return r;
    }
    return null;
  }
}

/// Un familiar con su puesto en el orden de aviso (nulo: sin puesto).
typedef FamiliarAviso = ({String id, int? orden});

/// Un aviso que toca enviar: su [motivo], su origen ([sujeto]: id de la
/// toma, de la ronda o ulid del evento), el [escalon] (1 o 2 en las tomas; 0
/// en los inmediatos, que van a todos) y desde cuándo toca ([vence]).
final class AvisoPendiente {
  const AvisoPendiente({
    required this.motivo,
    required this.sujeto,
    required this.vence,
    this.escalon = 0,
  });

  final MotivoAviso motivo;
  final String sujeto;
  final int escalon;
  final DateTime vence;

  @override
  bool operator ==(Object other) =>
      other is AvisoPendiente &&
      other.motivo == motivo &&
      other.sujeto == sujeto &&
      other.escalon == escalon &&
      other.vence == vence;

  @override
  int get hashCode => Object.hash(motivo, sujeto, escalon, vence);

  @override
  String toString() =>
      'AvisoPendiente(${motivo.nombre}, $sujeto, $escalon, $vence)';
}

/// Tras su hora, un aviso aún se envía durante este tiempo (por si el móvil
/// estaba apagado o sin red); después ya no: un aviso de hace horas solo
/// confunde. La familia lo ve igualmente en su app.
const ventanaAviso = Duration(minutes: 30);

/// `true` si un aviso que vence en [vence] toca en [ahora]: ya ha llegado y
/// no han pasado más de [ventanaAviso].
bool tocaAviso(DateTime vence, DateTime ahora) =>
    !ahora.isBefore(vence) && ahora.difference(vence) <= ventanaAviso;

/// Minuto del escalón [escalon] del aviso de una toma: el 1 es el paso
/// `avisarFamiliar1` (5 por defecto) y el 2, `avisarFamiliar2YReloj` (10).
int minutoDeEscalon(ConfigEscalado config, int escalon) {
  final accion = escalon == 1
      ? AccionEscalado.avisarFamiliar1
      : AccionEscalado.avisarFamiliar2YReloj;
  for (final p in config.pasos) {
    if (p.accion == accion) return p.minuto;
  }
  return escalon == 1 ? 5 : 10;
}

/// Escalones del aviso de una toma.
const escalonesToma = [1, 2];

/// Familiares por puesto: si alguno tiene puesto, solo esos, de menor a
/// mayor (los empates, en el orden de la lista); si nadie lo tiene, todos en
/// el orden de la lista. Es la regla de `familiaresPorOrden` de la app.
List<String> familiaresPorPuesto(List<FamiliarAviso> familiares) {
  final conPuesto = [
    for (var i = 0; i < familiares.length; i++)
      if (familiares[i].orden != null) (i, familiares[i]),
  ];
  if (conPuesto.isEmpty) return [for (final f in familiares) f.id];
  conPuesto.sort((a, b) {
    final c = a.$2.orden!.compareTo(b.$2.orden!);
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });
  return [for (final (_, f) in conPuesto) f.id];
}

/// A quién va el escalón [escalon] del aviso de una toma (plan 2.2):
/// - con puestos, el 1 al primero y el 2 al segundo; si solo hay uno, los
///   dos avisos van a él;
/// - sin puestos, los dos avisos van a todos;
/// - [escalon] 0 (avisos inmediatos): a todos.
List<String> destinatariosDeEscalon(
  List<FamiliarAviso> familiares,
  int escalon,
) {
  if (familiares.isEmpty) return const [];
  final todos = [for (final f in familiares) f.id];
  if (escalon <= 0) return todos;
  if (familiares.every((f) => f.orden == null)) return todos;
  final orden = familiaresPorPuesto(familiares);
  final i = escalon - 1 < orden.length ? escalon - 1 : orden.length - 1;
  return [orden[i]];
}
