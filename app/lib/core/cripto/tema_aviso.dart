import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'almacen_seguro.dart';
import 'cifrado_sobres.dart';

/// Tema de ntfy de cada familiar: el «buzón» público donde su móvil recibe
/// los avisos.
///
/// Se saca de la clave del círculo con HKDF-SHA256 y la etiqueta
/// `newera/v1/aviso/<miembroId>` (separación de dominios: no sirve como
/// token del servidor ni como clave de los sobres). Son 32 bytes en
/// hexadecimal: 64 caracteres, el máximo que admite ntfy en un tema (solo
/// letras, números, `_` y `-`). Todos los móviles del círculo llegan al mismo
/// tema sin enviarse nada; quien no tiene la clave no puede adivinarlo ni
/// sacar de él la clave ni el id del familiar. En ntfy.sh, «el tema es la
/// contraseña»: quien lo conozca puede leer o publicar avisos, que solo dicen
/// «NEW-ERA: hay un aviso. Abre la app.».
abstract final class TemaAviso {
  /// Servidor público y gratuito de ntfy (sin cuenta).
  static const servidor = 'ntfy.sh';

  /// Nombre que se ve en la app de ntfy al suscribirse con el enlace.
  static const nombreVisible = 'NEW-ERA';

  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  static final _hex64 = RegExp(r'^[0-9a-fA-F]{64}$');

  /// Etiqueta HKDF del tema de [miembroId].
  static String etiqueta(String miembroId) => 'newera/v1/aviso/$miembroId';

  /// Tema de [miembroId] con la clave del círculo [claveHex] (64 hex).
  static Future<String> derivar(String claveHex, String miembroId) async {
    final k = await _hkdf.deriveKey(
      secretKey: SecretKey(hexABytes(claveHex)),
      info: utf8.encode(etiqueta(miembroId)),
    );
    return bytesAHex(await k.extractBytes());
  }

  /// Lee la clave del almacén, deriva el tema y la suelta. Nulo sin clave
  /// (demo web) o con una clave que no tiene el formato esperado.
  static Future<String?> desdeAlmacen(
    AlmacenSeguro almacen,
    String miembroId,
  ) async {
    final clave = await almacen.leer(ClavesAlmacen.circuloClave);
    if (clave == null || !_hex64.hasMatch(clave)) return null;
    return derivar(clave, miembroId);
  }

  /// Enlace que abre la app de ntfy en Android y se suscribe al tema
  /// (documentación de ntfy, «deep linking»). En iPhone, sin verificar.
  static Uri enlaceSuscripcion(String tema) => Uri(
    scheme: 'ntfy',
    host: servidor,
    path: '/$tema',
    queryParameters: {'display': nombreVisible},
  );
}
