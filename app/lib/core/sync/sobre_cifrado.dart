import 'dart:typed_data';

/// Sobre cifrado de un evento, listo para el transporte (semana 3).
final class SobreCifrado {
  const SobreCifrado({
    required this.ulid,
    required this.circuloId,
    required this.versionClave,
    required this.nonce,
    required this.contenido,
  });

  final String ulid;
  final String circuloId;
  final int versionClave;
  final Uint8List nonce;
  final Uint8List contenido;
}
