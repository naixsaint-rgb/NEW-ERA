import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:safety_core/safety_core.dart';

/// Pasa un instante UTC a la hora de pared de [zona].
DateTime aLocal(DateTime utc, String zona) {
  inicializarZonas();
  return tz.TZDateTime.from(utc.toUtc(), tz.getLocation(zona));
}

String _mayuscula(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// "Martes 13 de octubre".
String fechaLarga(DateTime local) =>
    _mayuscula(DateFormat("EEEE d 'de' MMMM", 'es_ES').format(local));

/// "13 de octubre".
String fechaCorta(DateTime local) =>
    DateFormat("d 'de' MMMM", 'es_ES').format(local);

/// "09:00".
String horaCorta(DateTime local) => DateFormat('HH:mm', 'es_ES').format(local);

/// "Martes 13, 09:00".
String diaYHora(DateTime local) =>
    _mayuscula(DateFormat("EEEE d, HH:mm", 'es_ES').format(local));

/// `yyyy-MM-dd` de un instante en [zona].
String fechaLocalTexto(DateTime utc, String zona) {
  final f = fechaLocalDe(zona, utc);
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${f.anio.toString().padLeft(4, '0')}-${dos(f.mes)}-${dos(f.dia)}';
}

/// Inicio (00:00 local) del día de [utc] en [zona], en UTC.
DateTime inicioDelDia(DateTime utc, String zona) {
  final f = fechaLocalDe(zona, utc);
  return horaLocalAUtc(zona, f.anio, f.mes, f.dia, 0, 0);
}
