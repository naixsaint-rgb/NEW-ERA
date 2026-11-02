import 'dart:async';
import 'dart:math';

/// Espera creciente para el intento número [intento] (1, 2, 3...):
/// [minima] · 2^(intento-1), con tope en [maxima] y hasta un 20 % de azar
/// para que varios móviles no reintenten a la vez.
Duration esperaCreciente(
  int intento, {
  required Duration minima,
  required Duration maxima,
  Random? azar,
}) {
  final exp = min(max(intento - 1, 0), 20);
  final base = min(minima.inMilliseconds * (1 << exp), maxima.inMilliseconds);
  final extra = azar == null ? 0 : azar.nextInt(base ~/ 5 + 1);
  return Duration(milliseconds: min(base + extra, maxima.inMilliseconds));
}

/// Ejecuta [accion] hasta [intentos] veces, esperando cada vez más entre
/// fallos. Si todos fallan, relanza el último error.
Future<T> conReintentos<T>(
  Future<T> Function() accion, {
  int intentos = 3,
  Duration minima = const Duration(seconds: 1),
  Duration maxima = const Duration(seconds: 30),
  Random? azar,
}) async {
  for (var n = 1; ; n++) {
    try {
      return await accion();
    } catch (_) {
      if (n >= intentos) rethrow;
      await Future<void>.delayed(
        esperaCreciente(n, minima: minima, maxima: maxima, azar: azar),
      );
    }
  }
}
