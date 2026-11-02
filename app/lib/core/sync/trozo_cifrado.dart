import 'dart:typed_data';

/// Un trozo cifrado de un clip (vídeo o foto de comprobación), listo para el
/// transporte. El servidor solo ve estos campos y el token del círculo; no
/// sabe de qué toma es ni qué hay dentro.
final class TrozoCifrado {
  const TrozoCifrado({
    required this.clipId,
    required this.n,
    required this.total,
    required this.nonce,
    required this.contenido,
  });

  /// ULID del clip (no es el del evento `clip_grabado`).
  final String clipId;

  /// Posición del trozo: de 0 a [total] - 1.
  final int n;
  final int total;
  final Uint8List nonce;

  /// Trozo cifrado + etiqueta de autenticación (16 bytes).
  final Uint8List contenido;
}
