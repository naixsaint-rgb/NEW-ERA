import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'almacen_seguro.dart';

/// Lo que el cartero cifrado saca de la clave del círculo.
///
/// De los 32 bytes de la clave salen, con HKDF-SHA256 y una etiqueta distinta
/// para cada uso (separación de dominios):
/// - [token]: va al servidor en la cabecera `x-circulo-token` para que solo
///   entregue los sobres de este círculo. Conocerlo no permite descifrar nada,
///   porque de un resultado de HKDF no se puede volver a la clave ni sacar el
///   otro.
/// - la clave de los sobres (AES-256-GCM), que nunca sale del móvil.
/// - la clave de los trozos de vídeo y foto de comprobación
///   ([CifradoClips]), con su propia etiqueta: un trozo no se puede abrir
///   como sobre ni al revés.
///
/// La clave del círculo no se guarda aquí: se lee del almacén seguro, se
/// deriva y se suelta. Solo quedan en memoria los derivados.
final class LlavesCirculo {
  LlavesCirculo._({
    required this.version,
    required this.token,
    required this._claveSobres,
    required this._claveClips,
  });

  /// Versión de la clave del círculo (`newera.circulo.clave.version`).
  final int version;

  /// 64 caracteres hexadecimales. Identifica el círculo ante el servidor.
  final String token;

  final SecretKey _claveSobres;
  final SecretKey _claveClips;

  static const _infoToken = 'newera/v1/token-servidor';
  static const _infoSobres = 'newera/v1/sobres/aes-256-gcm';
  static const _infoClips = 'newera/v1/clips/aes-256-gcm';

  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  /// Deriva el token y la clave de los sobres de [claveHex] (64 hex).
  static Future<LlavesCirculo> derivar(
    String claveHex, {
    int version = 1,
  }) async {
    final semilla = SecretKey(hexABytes(claveHex));
    final token = await _hkdf.deriveKey(
      secretKey: semilla,
      info: utf8.encode(_infoToken),
    );
    final sobres = await _hkdf.deriveKey(
      secretKey: semilla,
      info: utf8.encode(_infoSobres),
    );
    final clips = await _hkdf.deriveKey(
      secretKey: semilla,
      info: utf8.encode(_infoClips),
    );
    return LlavesCirculo._(
      version: version,
      token: bytesAHex(token.bytes),
      claveSobres: sobres,
      claveClips: clips,
    );
  }

  /// Lee la clave del almacén seguro y la deriva. Nulo si no hay clave (demo
  /// web) o no tiene el formato esperado.
  static Future<LlavesCirculo?> desdeAlmacen(AlmacenSeguro almacen) async {
    final clave = await almacen.leer(ClavesAlmacen.circuloClave);
    if (clave == null || !_hex64.hasMatch(clave)) return null;
    final version =
        int.tryParse(
          await almacen.leer(ClavesAlmacen.circuloClaveVersion) ?? '',
        ) ??
        1;
    return derivar(clave, version: version);
  }

  static final _hex64 = RegExp(r'^[0-9a-fA-F]{64}$');
}

/// Contenido de un sobre ya cifrado.
typedef SobreSellado = ({Uint8List nonce, Uint8List contenido});

/// AES-256-GCM con nonce aleatorio de 12 bytes para el contenido de los sobres.
///
/// El `ulid` y la versión de la clave van como datos asociados (AAD): el
/// servidor no puede cambiar el contenido de un sobre por el de otro sin que
/// el descifrado falle.
abstract final class CifradoSobres {
  static final _aes = AesGcm.with256bits();

  /// Bytes de la etiqueta de autenticación que van al final del contenido.
  static const bytesEtiqueta = 16;

  static Future<SobreSellado> cifrar(
    List<int> claro, {
    required LlavesCirculo llaves,
    required String ulid,
  }) async {
    final caja = await _aes.encrypt(
      claro,
      secretKey: llaves._claveSobres,
      aad: _aad(ulid, llaves.version),
    );
    return (
      nonce: Uint8List.fromList(caja.nonce),
      contenido: caja.concatenation(nonce: false),
    );
  }

  /// Devuelve el claro, o nulo si el sobre no es de esta clave o está alterado.
  static Future<Uint8List?> descifrar({
    required Uint8List nonce,
    required Uint8List contenido,
    required LlavesCirculo llaves,
    required String ulid,
  }) async {
    if (nonce.length != _aes.nonceLength || contenido.length < bytesEtiqueta) {
      return null;
    }
    final corte = contenido.length - bytesEtiqueta;
    try {
      final claro = await _aes.decrypt(
        SecretBox(
          contenido.sublist(0, corte),
          nonce: nonce,
          mac: Mac(contenido.sublist(corte)),
        ),
        secretKey: llaves._claveSobres,
        aad: _aad(ulid, llaves.version),
      );
      return Uint8List.fromList(claro);
    } on SecretBoxAuthenticationError {
      return null;
    }
  }

  static List<int> _aad(String ulid, int version) =>
      utf8.encode('newera/sobre/v1|$ulid|$version');
}

/// AES-256-GCM para cada trozo de un clip (vídeo o foto de comprobación).
///
/// Clave propia (HKDF con `newera/v1/clips/aes-256-gcm`), nonce aleatorio de
/// 12 bytes por trozo y, como datos asociados, el id del clip, el número del
/// trozo, el total de trozos y la versión de la clave: el servidor no puede
/// cambiar el orden de los trozos, mezclar trozos de dos clips ni quitar los
/// últimos sin que el descifrado falle.
abstract final class CifradoClips {
  static final _aes = AesGcm.with256bits();

  static Future<SobreSellado> cifrar(
    List<int> claro, {
    required LlavesCirculo llaves,
    required String clipId,
    required int n,
    required int total,
  }) async {
    final caja = await _aes.encrypt(
      claro,
      secretKey: llaves._claveClips,
      aad: _aad(clipId, n, total, llaves.version),
    );
    return (
      nonce: Uint8List.fromList(caja.nonce),
      contenido: caja.concatenation(nonce: false),
    );
  }

  /// El trozo en claro, o nulo si no es de esta clave, de este clip, de esta
  /// posición o está alterado.
  static Future<Uint8List?> descifrar({
    required Uint8List nonce,
    required Uint8List contenido,
    required LlavesCirculo llaves,
    required String clipId,
    required int n,
    required int total,
  }) async {
    if (nonce.length != _aes.nonceLength ||
        contenido.length < CifradoSobres.bytesEtiqueta) {
      return null;
    }
    final corte = contenido.length - CifradoSobres.bytesEtiqueta;
    try {
      final claro = await _aes.decrypt(
        SecretBox(
          contenido.sublist(0, corte),
          nonce: nonce,
          mac: Mac(contenido.sublist(corte)),
        ),
        secretKey: llaves._claveClips,
        aad: _aad(clipId, n, total, llaves.version),
      );
      return Uint8List.fromList(claro);
    } on SecretBoxAuthenticationError {
      return null;
    }
  }

  static List<int> _aad(String clipId, int n, int total, int version) =>
      utf8.encode('newera/clip/v1|$clipId|$n|$total|$version');
}

/// `"0aff"` → `[0x0a, 0xff]`.
Uint8List hexABytes(String hex) {
  if (hex.length.isOdd) throw const FormatException('hex_impar');
  final r = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < r.length; i++) {
    r[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return r;
}

/// `[0x0a, 0xff]` → `"0aff"`.
String bytesAHex(List<int> bytes) {
  final sb = StringBuffer();
  for (final b in bytes) {
    sb.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}
