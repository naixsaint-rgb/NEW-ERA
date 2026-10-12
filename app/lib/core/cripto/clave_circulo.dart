import 'dart:math';

/// Clave del círculo: 32 bytes de `Random.secure()` en hexadecimal (64 caracteres).
/// Nunca va a la base, a los logs ni a los eventos.
abstract final class ClaveCirculo {
  static String generar([Random? azar]) {
    final r = azar ?? Random.secure();
    final sb = StringBuffer();
    for (var i = 0; i < 32; i++) {
      sb.write(r.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}
