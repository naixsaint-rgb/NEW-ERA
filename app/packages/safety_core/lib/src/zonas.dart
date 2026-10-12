import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

bool _zonasCargadas = false;

/// Carga la base de zonas IANA (`package:timezone/data/latest.dart`).
/// Es idempotente.
void inicializarZonas() {
  if (_zonasCargadas) return;
  tzdata.initializeTimeZones();
  _zonasCargadas = true;
}

/// Convierte una hora de pared (año, mes, día, hora, minuto) de [zona] en un
/// instante UTC.
///
/// - Hora inexistente (salto de primavera): primer instante válido tras el
///   salto.
/// - Hora repetida (cambio de otoño): solo la primera vez.
DateTime horaLocalAUtc(
  String zona,
  int anio,
  int mes,
  int dia,
  int hora,
  int minuto,
) {
  inicializarZonas();
  final loc = tz.getLocation(zona);
  final pared = DateTime.utc(
    anio,
    mes,
    dia,
    hora,
    minuto,
  ).millisecondsSinceEpoch;
  const diaMs = 24 * 3600 * 1000;
  final o1 = loc.timeZone(pared - diaMs).offset;
  final o2 = loc.timeZone(pared + diaMs).offset;
  final candidatos = <int>{o1, o2};
  final validos = <int>[];
  for (final o in candidatos) {
    final u = pared - o;
    if (loc.timeZone(u).offset == o) validos.add(u);
  }
  if (validos.isNotEmpty) {
    validos.sort();
    return DateTime.fromMillisecondsSinceEpoch(validos.first, isUtc: true);
  }
  // Hueco: buscamos el instante de la transición (primer instante tras el salto).
  var lo = pared - o1 < pared - o2 ? pared - o1 : pared - o2;
  var hi = pared - o1 < pared - o2 ? pared - o2 : pared - o1;
  // En [lo, hi) el desfase cambia de o1 a o2 exactamente una vez.
  final antes = loc.timeZone(lo).offset;
  while (hi - lo > 1000) {
    final medio = lo + ((hi - lo) ~/ 2000) * 1000;
    if (medio == lo) break;
    if (loc.timeZone(medio).offset == antes) {
      lo = medio;
    } else {
      hi = medio;
    }
  }
  return DateTime.fromMillisecondsSinceEpoch(hi, isUtc: true);
}

/// Año, mes y día locales de un instante UTC en [zona].
({int anio, int mes, int dia}) fechaLocalDe(String zona, DateTime utc) {
  inicializarZonas();
  final loc = tz.getLocation(zona);
  final off = loc.timeZone(utc.millisecondsSinceEpoch).offset;
  final local = DateTime.fromMillisecondsSinceEpoch(
    utc.millisecondsSinceEpoch + off,
    isUtc: true,
  );
  return (anio: local.year, mes: local.month, dia: local.day);
}
