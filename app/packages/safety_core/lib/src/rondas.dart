import 'zonas.dart';

// Control por horas (plan v3, 2.4 bis): los ajustes del círculo y las rondas
// de preguntas que salen de ellos. Lógica pura: la usan el móvil de la
// persona (alarmas y temporizador) y el de la familia ("sin respuesta").

/// Primera y última hora local que admite la franja.
const horaMinimaControl = 6;
const horaMaximaControl = 23;

/// Ritmos posibles: una ronda cada 1, 2 o 3 horas.
const ritmosControl = <int>[1, 2, 3];

/// Una toma a menos de esto de la ronda (antes o después) la retrasa.
const margenTomaRonda = Duration(minutes: 15);

/// Cuánto se retrasa una ronda cada vez.
const retrasoRonda = Duration(minutes: 15);

/// Como mucho, cuántas veces seguidas se retrasa una ronda.
const maxRetrasosRonda = 4;

/// Una ronda cuya hora pasó hace más de esto sin respuesta cuenta como "sin
/// respuesta" (la deduce la familia).
const esperaRespuestaRonda = Duration(minutes: 10);

/// Prefijo de los ids de ronda: `ronda_<yyyyMMdd>_<HHmm>`. Los ids de toma
/// empiezan por el id de su pauta (un UUID): nunca se confunden.
const prefijoRonda = 'ronda_';

/// `true` si [id] es el de una ronda (y no el de una toma).
bool esIdRonda(String id) => id.startsWith(prefijoRonda);

String _dos(int n) => n.toString().padLeft(2, '0');

/// Id de la ronda de la fecha local [anio]-[mes]-[dia] a la [hora] local en
/// punto (la hora de la franja, sin el retraso).
String idRonda(int anio, int mes, int dia, int hora) =>
    '$prefijoRonda${anio.toString().padLeft(4, '0')}${_dos(mes)}${_dos(dia)}'
    '_${_dos(hora)}00';

/// Las tres preguntas de cada ronda, en orden.
enum TipoPreguntaControl {
  /// "¿Cómo estás?"
  estado('estado'),

  /// "¿Te duele algo?"
  dolor('dolor'),

  /// "¿Qué vas a hacer luego?"
  plan('plan');

  const TipoPreguntaControl(this.nombre);

  /// Nombre guardado (columna `tipo` y payload de `pregunta_respondida`).
  final String nombre;

  static TipoPreguntaControl? desdeNombre(Object? nombre) {
    for (final t in values) {
      if (t.nombre == nombre) return t;
    }
    return null;
  }
}

/// Ajustes del control por horas de un círculo. Los cambia la familia y
/// viajan al móvil de la persona como ficha.
final class AjustesControl {
  const AjustesControl({
    this.activado = true,
    this.desde = 9,
    this.hasta = 21,
    this.cadaHoras = 1,
    this.activoDesde,
  });

  /// Decisión del promotor (12/10/2026): de 9 a 21, cada hora.
  static const porDefecto = AjustesControl();

  final bool activado;

  /// Primera hora local de la franja (ronda en punto).
  final int desde;

  /// Última hora local de la franja: puede haber ronda a esa hora en punto,
  /// nunca después.
  final int hasta;

  /// Ritmo: una ronda cada 1, 2 o 3 horas.
  final int cadaHoras;

  /// Desde cuándo está activado (UTC). Las rondas de antes no se esperan.
  /// Nulo: desde siempre (los valores por defecto).
  final DateTime? activoDesde;

  bool get valido =>
      desde >= horaMinimaControl &&
      hasta <= horaMaximaControl &&
      desde < hasta &&
      ritmosControl.contains(cadaHoras);

  /// Horas locales en punto de las rondas: [desde], [desde] + [cadaHoras]…
  /// sin pasar de [hasta].
  List<int> get horas => [
    if (valido)
      for (var h = desde; h <= hasta; h += cadaHoras) h,
  ];

  AjustesControl copiar({
    bool? activado,
    int? desde,
    int? hasta,
    int? cadaHoras,
    DateTime? activoDesde,
  }) => AjustesControl(
    activado: activado ?? this.activado,
    desde: desde ?? this.desde,
    hasta: hasta ?? this.hasta,
    cadaHoras: cadaHoras ?? this.cadaHoras,
    activoDesde: activoDesde ?? this.activoDesde,
  );

  @override
  bool operator ==(Object other) =>
      other is AjustesControl &&
      other.activado == activado &&
      other.desde == desde &&
      other.hasta == hasta &&
      other.cadaHoras == cadaHoras &&
      other.activoDesde == activoDesde;

  @override
  int get hashCode =>
      Object.hash(activado, desde, hasta, cadaHoras, activoDesde);

  @override
  String toString() =>
      'AjustesControl($activado, $desde-$hasta, cada $cadaHoras h, '
      'desde $activoDesde)';
}

/// Una ronda de preguntas: su hora en punto en la franja y la hora a la que
/// se lanza de verdad (con el retraso por una toma cercana).
final class RondaControl {
  const RondaControl({
    required this.id,
    required this.fechaLocal,
    required this.horaLocal,
    required this.enPunto,
    required this.hora,
  });

  /// `ronda_<yyyyMMdd>_<HHmm>` con la hora en punto ([idRonda]).
  final String id;

  /// `yyyy-MM-dd` local.
  final String fechaLocal;

  /// `HH:mm` local en punto (sin el retraso).
  final String horaLocal;

  /// La hora en punto, en UTC.
  final DateTime enPunto;

  /// Cuándo se lanza, en UTC: [enPunto] más los retrasos.
  final DateTime hora;

  bool get retrasada => hora != enPunto;

  @override
  bool operator ==(Object other) =>
      other is RondaControl &&
      other.id == id &&
      other.enPunto == enPunto &&
      other.hora == hora;

  @override
  int get hashCode => Object.hash(id, enPunto, hora);

  @override
  String toString() => 'RondaControl($id, $hora)';
}

/// Hora a la que se lanza una ronda prevista a [enPunto]: si hay una toma a
/// menos de [margenTomaRonda] (antes o después), se retrasa
/// [retrasoRonda]; y otra vez si sigue cerca de una toma, como mucho
/// [maxRetrasosRonda] veces.
DateTime horaConRetraso(DateTime enPunto, Iterable<DateTime> tomas) {
  var hora = enPunto;
  for (var i = 0; i < maxRetrasosRonda; i++) {
    final cerca = tomas.any((t) => t.difference(hora).abs() < margenTomaRonda);
    if (!cerca) break;
    hora = hora.add(retrasoRonda);
  }
  return hora;
}

/// Rondas de [ajustes] en la zona [zona] que se lanzan en `[desde, hasta)`,
/// ordenadas por hora.
///
/// - Desactivado o con ajustes no válidos: ninguna.
/// - Nunca fuera de la franja: una ronda que el retraso por las [tomas] (sus
///   instantes previstos) llevaría más allá de la última hora en punto no se
///   lanza.
/// - Las de antes de [AjustesControl.activoDesde] no cuentan.
List<RondaControl> rondasControl({
  required AjustesControl ajustes,
  required String zona,
  required DateTime desde,
  required DateTime hasta,
  Iterable<DateTime> tomas = const [],
}) {
  if (!ajustes.activado || !ajustes.valido || !hasta.isAfter(desde)) {
    return const [];
  }
  final listaTomas = tomas.toList(growable: false);
  final primero = fechaLocalDe(zona, desde);
  final ultimo = fechaLocalDe(zona, hasta);
  final dia0 = DateTime.utc(primero.anio, primero.mes, primero.dia);
  final diaN = DateTime.utc(ultimo.anio, ultimo.mes, ultimo.dia);
  final dias = diaN.difference(dia0).inDays;
  final r = <RondaControl>[];
  for (var k = 0; k <= dias; k++) {
    final d = DateTime.utc(dia0.year, dia0.month, dia0.day + k);
    final fin = horaLocalAUtc(zona, d.year, d.month, d.day, ajustes.hasta, 0);
    for (final h in ajustes.horas) {
      final enPunto = horaLocalAUtc(zona, d.year, d.month, d.day, h, 0);
      final hora = horaConRetraso(enPunto, listaTomas);
      if (hora.isAfter(fin)) continue;
      final activo = ajustes.activoDesde;
      if (activo != null && hora.isBefore(activo)) continue;
      if (hora.isBefore(desde) || !hora.isBefore(hasta)) continue;
      r.add(
        RondaControl(
          id: idRonda(d.year, d.month, d.day, h),
          fechaLocal:
              '${d.year.toString().padLeft(4, '0')}-${_dos(d.month)}-'
              '${_dos(d.day)}',
          horaLocal: '${_dos(h)}:00',
          enPunto: enPunto,
          hora: hora,
        ),
      );
    }
  }
  r.sort((a, b) => a.hora.compareTo(b.hora));
  return r;
}

/// La primera ronda que se lanza después de [ahora] (estrictamente), en las
/// próximas 26 horas; nula si no hay.
RondaControl? siguienteRonda({
  required AjustesControl ajustes,
  required String zona,
  required DateTime ahora,
  Iterable<DateTime> tomas = const [],
}) {
  for (final r in rondasControl(
    ajustes: ajustes,
    zona: zona,
    desde: ahora,
    hasta: ahora.add(const Duration(hours: 26)),
    tomas: tomas,
  )) {
    if (r.hora.isAfter(ahora)) return r;
  }
  return null;
}
