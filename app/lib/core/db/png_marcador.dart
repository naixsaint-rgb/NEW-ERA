import 'dart:math' as math;
import 'dart:typed_data';

/// Genera imágenes PNG de marcador por código (sin dependencias ni `dart:io`),
/// para los datos de ejemplo: nunca son fotos reales.
abstract final class PngMarcador {
  /// Pastilla sobre fondo claro. [forma]: `redonda`, `ovalada`, `capsula`, `otra`.
  static Uint8List pastilla({
    required String forma,
    required int color,
    int ancho = 160,
    int alto = 160,
  }) {
    final r = (color >> 16) & 0xFF, g = (color >> 8) & 0xFF, b = color & 0xFF;
    return _png(ancho, alto, (x, y) {
      final dx = (x + 0.5) / ancho - 0.5;
      final dy = (y + 0.5) / alto - 0.5;
      const fondo = (0xF3, 0xEE, 0xE2);
      bool dentro;
      double borde;
      switch (forma) {
        case 'redonda':
          final d = math.sqrt(dx * dx + dy * dy);
          dentro = d < 0.34;
          borde = (d - 0.34).abs();
        case 'ovalada':
          final d = math.sqrt(
            (dx / 0.42) * (dx / 0.42) + (dy / 0.25) * (dy / 0.25),
          );
          dentro = d < 1;
          borde = (d - 1).abs() * 0.25;
        case 'capsula':
          final cx = dx.clamp(-0.22, 0.22);
          final d = math.sqrt((dx - cx) * (dx - cx) + dy * dy);
          dentro = d < 0.2;
          borde = (d - 0.2).abs();
          if (dentro && dx > 0) return (0xFF, 0xFF, 0xFF);
        default:
          dentro = dx.abs() < 0.28 && dy.abs() < 0.28;
          borde = math.min((dx.abs() - 0.28).abs(), (dy.abs() - 0.28).abs());
      }
      if (borde < 0.012) return (0x55, 0x55, 0x55);
      return dentro ? (r, g, b) : fondo;
    });
  }

  /// Caja de medicamento de marcador: un rectángulo con una franja de color.
  static Uint8List caja({required int color, int ancho = 192, int alto = 144}) {
    final r = (color >> 16) & 0xFF, g = (color >> 8) & 0xFF, b = color & 0xFF;
    return _png(ancho, alto, (x, y) {
      final fx = x / ancho, fy = y / alto;
      const fondo = (0xF3, 0xEE, 0xE2);
      final dentro = fx > 0.12 && fx < 0.88 && fy > 0.14 && fy < 0.86;
      if (!dentro) return fondo;
      final borde = fx < 0.135 || fx > 0.865 || fy < 0.155 || fy > 0.845;
      if (borde) return (0x55, 0x55, 0x55);
      if (fy > 0.55 && fy < 0.75) return (r, g, b);
      return (0xFF, 0xFF, 0xFF);
    });
  }

  static Uint8List _png(
    int ancho,
    int alto,
    (int, int, int) Function(int x, int y) pixel,
  ) {
    final crudo = BytesBuilder();
    for (var y = 0; y < alto; y++) {
      crudo.addByte(0); // filtro ninguno
      for (var x = 0; x < ancho; x++) {
        final (r, g, b) = pixel(x, y);
        crudo.add([r, g, b]);
      }
    }
    final datos = crudo.toBytes();
    // zlib sin compresión: bloques "stored" de hasta 65535 bytes.
    final z = BytesBuilder()..add([0x78, 0x01]);
    var pos = 0;
    while (pos < datos.length) {
      final n = math.min(65535, datos.length - pos);
      final ultimo = pos + n >= datos.length;
      z.addByte(ultimo ? 1 : 0);
      z.add([n & 0xFF, (n >> 8) & 0xFF, (~n) & 0xFF, ((~n) >> 8) & 0xFF]);
      z.add(Uint8List.sublistView(datos, pos, pos + n));
      pos += n;
    }
    final adler = _adler32(datos);
    z.add([
      (adler >> 24) & 0xFF,
      (adler >> 16) & 0xFF,
      (adler >> 8) & 0xFF,
      adler & 0xFF,
    ]);

    final out = BytesBuilder()
      ..add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    void trozo(String tipo, List<int> contenido) {
      final cabecera = Uint8List(4);
      ByteData.sublistView(cabecera).setUint32(0, contenido.length);
      out.add(cabecera);
      final cuerpo = [...tipo.codeUnits, ...contenido];
      out.add(cuerpo);
      final crc = Uint8List(4);
      ByteData.sublistView(crc).setUint32(0, _crc32(cuerpo));
      out.add(crc);
    }

    final ihdr = Uint8List(13);
    final bd = ByteData.sublistView(ihdr);
    bd.setUint32(0, ancho);
    bd.setUint32(4, alto);
    ihdr[8] = 8; // bits por canal
    ihdr[9] = 2; // RGB
    trozo('IHDR', ihdr);
    trozo('IDAT', z.toBytes());
    trozo('IEND', const []);
    return out.toBytes();
  }

  static int _adler32(List<int> datos) {
    var a = 1, b = 0;
    for (final d in datos) {
      a = (a + d) % 65521;
      b = (b + a) % 65521;
    }
    return (b << 16) | a;
  }

  static final List<int> _tablaCrc = () {
    final t = List<int>.filled(256, 0);
    for (var n = 0; n < 256; n++) {
      var c = n;
      for (var k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
      }
      t[n] = c;
    }
    return t;
  }();

  static int _crc32(List<int> datos) {
    var c = 0xFFFFFFFF;
    for (final d in datos) {
      c = _tablaCrc[(c ^ d) & 0xFF] ^ (c >> 8);
    }
    return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }
}
