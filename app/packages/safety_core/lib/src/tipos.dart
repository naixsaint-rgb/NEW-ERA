/// Tipos de evento de la semana 1 (sección 4.3 de la especificación).
enum TipoEvento {
  tomaConfirmada('toma_confirmada'),
  clipGrabado('clip_grabado'),
  clipFallido('clip_fallido'),
  tomaCerradaPorFamiliar('toma_cerrada_por_familiar'),
  alarmaProgramada('alarma_programada'),
  alarmaNoProgramada('alarma_no_programada'),
  ayudaPedida('ayuda_pedida'),
  llamadaIniciada('llamada_iniciada'),
  mensajeFamilia('mensaje_familia'),
  perfilElegido('perfil_elegido'),
  medicamentoCreado('medicamento_creado'),
  fichaModificada('ficha_modificada'),
  anulacion('anulacion');

  const TipoEvento(this.nombre);

  /// Nombre guardado en la base.
  final String nombre;

  static TipoEvento? desdeNombre(String nombre) {
    for (final t in values) {
      if (t.nombre == nombre) return t;
    }
    return null;
  }
}

/// Cómo se comprueba que la persona se tomó la pastilla.
enum TipoComprobacion {
  video('video'),
  foto('foto'),
  ninguna('ninguna');

  const TipoComprobacion(this.nombre);
  final String nombre;

  static TipoComprobacion desdeNombre(String nombre) => values.firstWhere(
    (c) => c.nombre == nombre,
    orElse: () => TipoComprobacion.video,
  );
}

/// Máscara de días de la semana: bit 0 lunes ... bit 6 domingo; 127, todos.
abstract final class DiasSemana {
  static const int todos = 127;

  /// [weekday] sigue la convención de Dart: 1 lunes ... 7 domingo.
  static bool incluye(int mascara, int weekday) =>
      (mascara >> (weekday - 1)) & 1 == 1;

  /// Construye la máscara desde días Dart (1 lunes ... 7 domingo).
  static int deLista(Iterable<int> weekdays) {
    var m = 0;
    for (final d in weekdays) {
      m |= 1 << (d - 1);
    }
    return m;
  }

  /// Días Dart (1 a 7) incluidos en la máscara, en orden.
  static List<int> aLista(int mascara) => [
    for (var d = 1; d <= 7; d++)
      if (incluye(mascara, d)) d,
  ];
}

/// Una versión de una pauta. Las pautas no se editan: cada cambio es una
/// versión nueva.
final class PautaVersion {
  const PautaVersion({
    required this.id,
    required this.pautaId,
    required this.version,
    required this.medicamentoId,
    required this.horas,
    required this.zonaHoraria,
    required this.vigenteDesde,
    required this.activa,
    this.diasSemana = DiasSemana.todos,
    this.comprobacion = TipoComprobacion.video,
  });

  /// Id de la versión.
  final String id;

  /// Id lógico de la pauta, común a todas sus versiones.
  final String pautaId;
  final int version;
  final String medicamentoId;

  /// Horas locales "HH:mm", ordenadas y sin repetir.
  final List<String> horas;
  final int diasSemana;

  /// Zona IANA, por ejemplo `Europe/Madrid`.
  final String zonaHoraria;

  /// Instante UTC desde el que rige esta versión.
  final DateTime vigenteDesde;
  final bool activa;
  final TipoComprobacion comprobacion;

  @override
  bool operator ==(Object other) =>
      other is PautaVersion &&
      other.id == id &&
      other.pautaId == pautaId &&
      other.version == version &&
      other.medicamentoId == medicamentoId &&
      _mismaLista(other.horas, horas) &&
      other.diasSemana == diasSemana &&
      other.zonaHoraria == zonaHoraria &&
      other.vigenteDesde == vigenteDesde &&
      other.activa == activa &&
      other.comprobacion == comprobacion;

  @override
  int get hashCode => Object.hash(
    id,
    pautaId,
    version,
    medicamentoId,
    Object.hashAll(horas),
    diasSemana,
    zonaHoraria,
    vigenteDesde,
    activa,
    comprobacion,
  );

  static bool _mismaLista(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
