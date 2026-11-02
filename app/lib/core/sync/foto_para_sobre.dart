import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Foto lista para viajar dentro de un sobre del cartero.
typedef FotoSobre = ({Uint8List bytes, String mime});

/// Reduce las fotos de las fichas para que quepan en un sobre.
///
/// Objetivo: 512 px de lado mayor y JPEG de calidad 80. El tope real lo pone
/// el servidor: el contenido cifrado de un sobre, en base64, no pasa de
/// 90 000 caracteres (`supabase/schema.sql`), unos 67 KB de evento. La foto va
/// en base64 dentro del evento, así que se deja en [maxBytes]. Si no cabe, se
/// prueba con menos calidad y menos lado; si aun así no cabe o no se puede
/// leer, nulo: la ficha viaja sin foto y lo anota.
abstract final class FotoParaSobre {
  static const ladoMayor = 512;
  static const calidad = 80;
  static const maxBytes = 45000;

  /// Lado mayor y calidad, en orden, hasta que la foto quepa.
  static const _intentos = <(int, int)>[
    (ladoMayor, calidad),
    (ladoMayor, 65),
    (384, 60),
    (256, 50),
  ];

  static FotoSobre? reducir(Uint8List bytes, String mime) {
    try {
      final original = img.decodeImage(bytes);
      if (original == null) return null;
      final lado = max(original.width, original.height);
      // Ya pequeña (las de marcador de la demo): tal cual, sin recomprimir.
      if (lado <= ladoMayor &&
          bytes.length <= maxBytes &&
          (mime == 'image/jpeg' || mime == 'image/png')) {
        return (bytes: bytes, mime: mime);
      }
      var base = img.bakeOrientation(original);
      if (base.hasAlpha || base.hasPalette) {
        // JPEG no tiene transparencia: se pone sobre blanco.
        final fondo = img.Image(width: base.width, height: base.height);
        img.fill(fondo, color: img.ColorRgb8(255, 255, 255));
        base = img.compositeImage(fondo, base.convert(numChannels: 4));
      }
      for (final (maximo, q) in _intentos) {
        final ajustada = max(base.width, base.height) <= maximo
            ? base
            : img.copyResize(
                base,
                width: base.width >= base.height ? maximo : null,
                height: base.height > base.width ? maximo : null,
                interpolation: img.Interpolation.average,
              );
        final jpg = img.encodeJpg(ajustada, quality: q);
        if (jpg.length <= maxBytes) return (bytes: jpg, mime: 'image/jpeg');
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
