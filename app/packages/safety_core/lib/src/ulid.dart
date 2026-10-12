import 'dart:math';

import 'reloj.dart';

/// Identificadores ULID: 26 caracteres Crockford base 32, 48 bits de tiempo
/// (ms UTC) y 80 aleatorios. Monótonos dentro del mismo milisegundo.
abstract final class Ulid {
  static const String _alfabeto = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static int _ultimoTiempo = -1;
  static List<int> _ultimosAleatorios = List<int>.filled(16, 0);

  /// Genera un ULID con la hora de [reloj] y la fuente aleatoria [azar].
  static String generar(Reloj reloj, Random azar) {
    final tiempo = reloj.ahora().millisecondsSinceEpoch;
    final List<int> aleatorios;
    if (tiempo <= _ultimoTiempo) {
      // Mismo milisegundo (o reloj que retrocede): se incrementa el aleatorio
      // anterior para mantener el orden.
      aleatorios = List<int>.of(_ultimosAleatorios);
      var i = 15;
      while (i >= 0) {
        if (aleatorios[i] < 31) {
          aleatorios[i]++;
          break;
        }
        aleatorios[i] = 0;
        i--;
      }
      _ultimosAleatorios = aleatorios;
      return _componer(_ultimoTiempo, aleatorios);
    }
    aleatorios = List<int>.generate(16, (_) => azar.nextInt(32));
    _ultimoTiempo = tiempo;
    _ultimosAleatorios = aleatorios;
    return _componer(tiempo, aleatorios);
  }

  static String _componer(int tiempo, List<int> aleatorios) {
    final sb = StringBuffer();
    final digitosTiempo = List<int>.filled(10, 0);
    var t = tiempo;
    for (var i = 9; i >= 0; i--) {
      digitosTiempo[i] = t % 32;
      t = t ~/ 32;
    }
    for (final d in digitosTiempo) {
      sb.write(_alfabeto[d]);
    }
    for (final d in aleatorios) {
      sb.write(_alfabeto[d]);
    }
    return sb.toString();
  }

  /// Instante (ms UTC) codificado en un ULID.
  static int tiempoDe(String ulid) {
    var t = 0;
    for (var i = 0; i < 10; i++) {
      t = t * 32 + _alfabeto.indexOf(ulid[i]);
    }
    return t;
  }
}
