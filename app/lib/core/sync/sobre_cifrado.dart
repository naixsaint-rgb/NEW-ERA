import 'dart:typed_data';

/// Sobre cifrado de un evento, listo para el transporte.
///
/// El servidor solo ve estos campos; el evento va cifrado en [contenido].
final class SobreCifrado {
  const SobreCifrado({
    required this.ulid,
    required this.circuloId,
    required this.versionClave,
    required this.nonce,
    required this.contenido,
    this.remitente = '',
    this.posicion,
  });

  final String ulid;

  /// Círculo local del sobre. No viaja: ante el servidor, el círculo es su
  /// token (ver `LlavesCirculo.token`).
  final String circuloId;
  final int versionClave;
  final Uint8List nonce;
  final Uint8List contenido;

  /// Id del dispositivo que lo envió.
  final String remitente;

  /// Orden del sobre en el servidor (`sobres.id`). Nulo en los que salen.
  final int? posicion;
}
