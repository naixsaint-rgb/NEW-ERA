import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:newera/features/mapa/pmtiles_lector.dart';

// PMTiles mínimo para los tests, escrito aquí (nada de datos reales): unas
// pocas teselas vectoriales con un cuadrado de «tierra» y una calle de
// ejemplo.

void _varint(BytesBuilder b, int v) {
  while (v >= 0x80) {
    b.addByte((v & 0x7f) | 0x80);
    v >>= 7;
  }
  b.addByte(v);
}

Uint8List _campo(int numero, List<int> datos) {
  final b = BytesBuilder();
  _varint(b, (numero << 3) | 2);
  _varint(b, datos.length);
  b.add(datos);
  return b.toBytes();
}

Uint8List _campoVarint(int numero, int v) {
  final b = BytesBuilder();
  _varint(b, numero << 3);
  _varint(b, v);
  return b.toBytes();
}

Uint8List _empaquetados(int numero, List<int> valores) {
  final p = BytesBuilder();
  for (final v in valores) {
    _varint(p, v);
  }
  return _campo(numero, p.toBytes());
}

int _zz(int n) => (n << 1) ^ (n >> 31);
int _orden(int id, int n) => (id & 7) | (n << 3);

/// Tesela MVT con una capa `earth` (un cuadrado que la cubre) y una capa
/// `roads` con una calle de ejemplo.
Uint8List teselaMvtPrueba() {
  final cuadrado = BytesBuilder()
    ..add(_campoVarint(3, 3))
    ..add(
      _empaquetados(4, [
        _orden(1, 1), _zz(0), _zz(0), //
        _orden(2, 3), _zz(4096), _zz(0), _zz(0), _zz(4096), _zz(-4096),
        _zz(0), _orden(7, 1),
      ]),
    );
  final tierra = BytesBuilder()
    ..add(_campoVarint(15, 2))
    ..add(_campo(1, utf8.encode('earth')))
    ..add(_campo(2, cuadrado.toBytes()))
    ..add(_campoVarint(5, 4096));
  final linea = BytesBuilder()
    ..add(_empaquetados(2, [0, 0, 1, 1]))
    ..add(_campoVarint(3, 2))
    ..add(
      _empaquetados(4, [
        _orden(1, 1), _zz(0), _zz(2048), //
        _orden(2, 1), _zz(4096), _zz(0),
      ]),
    );
  final calles = BytesBuilder()
    ..add(_campoVarint(15, 2))
    ..add(_campo(1, utf8.encode('roads')))
    ..add(_campo(2, linea.toBytes()))
    ..add(_campo(3, utf8.encode('kind')))
    ..add(_campo(3, utf8.encode('name')))
    ..add(_campo(4, _campo(1, utf8.encode('minor_road'))))
    ..add(_campo(4, _campo(1, utf8.encode('Calle de Ejemplo'))))
    ..add(_campoVarint(5, 4096));
  return (BytesBuilder()
        ..add(_campo(3, tierra.toBytes()))
        ..add(_campo(3, calles.toBytes())))
      .toBytes();
}

/// Tesela que contiene (lat, lon) en el zoom [z].
(int, int) teselaDe(double lat, double lon, int z) {
  final n = 1 << z;
  final x = ((lon + 180) / 360 * n).floor();
  final r = lat * pi / 180;
  final y = ((1 - log(tan(r) + 1 / cos(r)) / pi) / 2 * n).floor();
  return (x, y);
}

/// Bytes de un PMTiles v3 con [teselas] ((z, x, y) → MVT sin comprimir).
Uint8List pmtilesPrueba(
  Map<(int, int, int), Uint8List> teselas, {
  double oeste = -3.80,
  double sur = 40.35,
  double este = -3.60,
  double norte = 40.48,
  double lat = 40.4168,
  double lon = -3.7038,
}) {
  final filas = [
    for (final e in teselas.entries)
      (idTesela(e.key.$1, e.key.$2, e.key.$3), e.key.$1, gzip.encode(e.value)),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  final datos = BytesBuilder();
  final dir = BytesBuilder();
  _varint(dir, filas.length);
  var anterior = 0;
  for (final f in filas) {
    _varint(dir, f.$1 - anterior);
    anterior = f.$1;
  }
  for (final _ in filas) {
    _varint(dir, 1);
  }
  for (final f in filas) {
    _varint(dir, f.$3.length);
  }
  for (var i = 0; i < filas.length; i++) {
    _varint(dir, i == 0 ? 1 : 0);
  }
  for (final f in filas) {
    datos.add(f.$3);
  }
  final raiz = gzip.encode(dir.toBytes());
  final meta = gzip.encode(utf8.encode('{"attribution":"prueba"}'));
  final zooms = filas.map((f) => f.$2);
  final h = ByteData(127);
  final magia = ascii.encode('PMTiles');
  for (var i = 0; i < 7; i++) {
    h.setUint8(i, magia[i]);
  }
  h.setUint8(7, 3);
  void u64(int i, int v) => h.setUint64(i, v, Endian.little);
  void i32(int i, double g) => h.setInt32(i, (g * 1e7).round(), Endian.little);
  final raizDesde = 127;
  final metaDesde = raizDesde + raiz.length;
  final hojasDesde = metaDesde + meta.length;
  final datosBytes = datos.toBytes();
  u64(8, raizDesde);
  u64(16, raiz.length);
  u64(24, metaDesde);
  u64(32, meta.length);
  u64(40, hojasDesde);
  u64(48, 0);
  u64(56, hojasDesde);
  u64(64, datosBytes.length);
  u64(72, filas.length);
  u64(80, filas.length);
  u64(88, filas.length);
  h.setUint8(96, 1);
  h.setUint8(97, 2);
  h.setUint8(98, 2);
  h.setUint8(99, 1);
  h.setUint8(100, zooms.reduce(min));
  h.setUint8(101, zooms.reduce(max));
  i32(102, oeste);
  i32(106, sur);
  i32(110, este);
  i32(114, norte);
  h.setUint8(118, 14);
  i32(119, lon);
  i32(123, lat);
  return (BytesBuilder()
        ..add(h.buffer.asUint8List())
        ..add(raiz)
        ..add(meta)
        ..add(datosBytes))
      .toBytes();
}

/// PMTiles de prueba alrededor del punto de ejemplo: la tesela de nivel 0 y
/// un bloque de 3 × 3 teselas en los niveles 13 y 14.
Uint8List pmtilesEjemplo({double lat = 40.4168, double lon = -3.7038}) {
  final mvt = teselaMvtPrueba();
  final t = <(int, int, int), Uint8List>{(0, 0, 0): mvt};
  for (final z in [13, 14]) {
    final (x, y) = teselaDe(lat, lon, z);
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        t[(z, x + dx, y + dy)] = mvt;
      }
    }
  }
  return pmtilesPrueba(t);
}
