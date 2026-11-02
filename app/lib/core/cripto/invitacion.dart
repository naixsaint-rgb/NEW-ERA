import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import 'cifrado_sobres.dart';

/// Invitación para que otro móvil se una al círculo: el id del círculo, el de
/// la persona y la clave del círculo.
///
/// Formato 1 (texto del QR y del código para escribir):
/// `NEWERA1-XXXX-XXXX-…` con 112 caracteres de base 32 de Crockford (sin
/// I, L, O ni U; se aceptan minúsculas, y O, I y L se leen como 0, 1 y 1) en
/// grupos de 4. Dentro van 70 bytes: la versión (1), los dos UUID en binario
/// (16 + 16), la clave (32) y los 5 primeros bytes de SHA-256 de todo lo
/// anterior como suma de comprobación. Un carácter mal escrito no pasa: o deja
/// de ser base 32 o cambia la suma.
///
/// Lleva la clave del círculo en claro: solo se enseña en persona.
final class Invitacion {
  const Invitacion({
    required this.circuloId,
    required this.personaId,
    required this.claveHex,
  });

  final String circuloId;
  final String personaId;

  /// 64 caracteres hexadecimales (32 bytes).
  final String claveHex;

  static const prefijo = 'NEWERA1';
  static const version = 1;

  static const _bytesUuid = 16;
  static const _bytesClave = 32;
  static const _bytesSuma = 5;
  static const _bytesDatos = 1 + _bytesUuid * 2 + _bytesClave;
  static const _bytesTotal = _bytesDatos + _bytesSuma;
  static const _caracteres = _bytesTotal * 8 ~/ 5;
  static const _grupo = 4;

  static const _alfabeto = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );
  static final _hex64 = RegExp(r'^[0-9a-fA-F]{64}$');

  /// El texto de la invitación. Lanza [ArgumentError] si los ids no son UUID
  /// o la clave no tiene 64 caracteres hexadecimales.
  String codificar() {
    final circulo = circuloId.toLowerCase();
    final persona = personaId.toLowerCase();
    if (!_uuid.hasMatch(circulo) || !_uuid.hasMatch(persona)) {
      throw ArgumentError('ids_no_uuid');
    }
    if (!_hex64.hasMatch(claveHex)) throw ArgumentError('clave_no_valida');
    final datos = Uint8List(_bytesTotal)
      ..[0] = version
      ..setAll(1, hexABytes(circulo.replaceAll('-', '')))
      ..setAll(1 + _bytesUuid, hexABytes(persona.replaceAll('-', '')))
      ..setAll(1 + _bytesUuid * 2, hexABytes(claveHex.toLowerCase()));
    datos.setAll(_bytesDatos, _suma(datos.sublist(0, _bytesDatos)));
    final b32 = _aBase32(datos);
    final grupos = [
      for (var i = 0; i < b32.length; i += _grupo)
        b32.substring(i, i + _grupo > b32.length ? b32.length : i + _grupo),
    ];
    return '$prefijo-${grupos.join('-')}';
  }

  /// Lee una invitación escrita, pegada o leída del QR. Nulo si no lo es o
  /// tiene algún carácter cambiado.
  static Invitacion? leer(String texto) {
    var s = texto.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
    if (!s.startsWith(prefijo)) return null;
    s = s
        .substring(prefijo.length)
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('L', '1');
    if (s.length != _caracteres) return null;
    final datos = _deBase32(s);
    if (datos == null || datos.length != _bytesTotal) return null;
    if (datos[0] != version) return null;
    final suma = _suma(datos.sublist(0, _bytesDatos));
    for (var i = 0; i < _bytesSuma; i++) {
      if (datos[_bytesDatos + i] != suma[i]) return null;
    }
    return Invitacion(
      circuloId: _aUuid(datos.sublist(1, 1 + _bytesUuid)),
      personaId: _aUuid(datos.sublist(1 + _bytesUuid, 1 + _bytesUuid * 2)),
      claveHex: bytesAHex(datos.sublist(1 + _bytesUuid * 2, _bytesDatos)),
    );
  }

  static List<int> _suma(List<int> datos) =>
      crypto.sha256.convert(datos).bytes.sublist(0, _bytesSuma);

  static String _aUuid(List<int> bytes) {
    final h = bytesAHex(bytes);
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  static String _aBase32(List<int> bytes) {
    final sb = StringBuffer();
    var acumulado = 0;
    var bits = 0;
    for (final b in bytes) {
      acumulado = (acumulado << 8) | b;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        sb.write(_alfabeto[(acumulado >> bits) & 31]);
      }
      acumulado &= (1 << bits) - 1;
    }
    if (bits > 0) sb.write(_alfabeto[(acumulado << (5 - bits)) & 31]);
    return sb.toString();
  }

  /// Nulo si hay un carácter fuera del alfabeto o sobran bits distintos de 0.
  static Uint8List? _deBase32(String s) {
    final salida = <int>[];
    var acumulado = 0;
    var bits = 0;
    for (final c in s.split('')) {
      final v = _alfabeto.indexOf(c);
      if (v < 0) return null;
      acumulado = (acumulado << 5) | v;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        salida.add((acumulado >> bits) & 0xff);
      }
      acumulado &= (1 << bits) - 1;
    }
    if (acumulado != 0) return null;
    return Uint8List.fromList(salida);
  }

  @override
  bool operator ==(Object other) =>
      other is Invitacion &&
      other.circuloId == circuloId &&
      other.personaId == personaId &&
      other.claveHex.toLowerCase() == claveHex.toLowerCase();

  @override
  int get hashCode => Object.hash(circuloId, personaId, claveHex.toLowerCase());
}
