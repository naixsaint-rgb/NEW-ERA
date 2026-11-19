import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Lector mínimo de archivos PMTiles v3 guardados en el móvil.
///
/// Solo lee del archivo local: no abre conexiones de red de ningún tipo.
/// Formato: https://github.com/protomaps/PMTiles/blob/main/spec/v3/spec.md
/// (cabecera de 127 bytes, directorios con varints y curva de Hilbert para
/// el id de cada tesela). Se escribe aquí porque el paquete `pmtiles` de
/// pub.dev choca con `vector_tile` por la versión de `protobuf`.
class LectorPmtiles {
  LectorPmtiles._(this._archivo, this.cabecera);

  final RandomAccessFile _archivo;

  /// Datos de la cabecera.
  final CabeceraPmtiles cabecera;

  final _directorios = <int, List<_Entrada>>{};
  Future<void> _cola = Future<void>.value();

  /// Abre [archivo] y comprueba la cabecera. Lanza [FormatException] si no
  /// es un PMTiles v3.
  static Future<LectorPmtiles> abrir(File archivo) async {
    final raf = await archivo.open();
    try {
      final b = await raf.read(127);
      final cabecera = CabeceraPmtiles.leer(Uint8List.fromList(b));
      return LectorPmtiles._(raf, cabecera);
    } catch (_) {
      await raf.close();
      rethrow;
    }
  }

  Future<void> cerrar() async {
    await _cola;
    await _archivo.close();
  }

  /// Lee [largo] bytes desde [desde], de uno en uno: un RandomAccessFile no
  /// admite dos operaciones a la vez.
  Future<Uint8List> _leer(int desde, int largo) {
    final c = Completer<Uint8List>();
    _cola = _cola.then((_) async {
      try {
        await _archivo.setPosition(desde);
        c.complete(await _archivo.read(largo));
      } catch (e, s) {
        c.completeError(e, s);
      }
    });
    return c.future;
  }

  Uint8List _descomprimir(Uint8List b, int compresion) => switch (compresion) {
    0 || 1 => b,
    2 => Uint8List.fromList(gzip.decode(b)),
    _ => throw const FormatException('compresión no admitida'),
  };

  Future<List<_Entrada>> _directorio(int desde, int largo) async {
    final hecho = _directorios[desde];
    if (hecho != null) return hecho;
    final b = _descomprimir(
      await _leer(desde, largo),
      cabecera.compresionInterna,
    );
    final d = _Entrada.leerDirectorio(b);
    if (_directorios.length > 64) _directorios.clear();
    _directorios[desde] = d;
    return d;
  }

  /// La tesela z/x/y ya descomprimida, o nula si el archivo no la tiene.
  Future<Uint8List?> tesela(int z, int x, int y) async {
    if (z < cabecera.zoomMinimo || z > cabecera.zoomMaximo) return null;
    final id = idTesela(z, x, y);
    var desde = cabecera.raizDesde, largo = cabecera.raizLargo;
    for (var nivel = 0; nivel < 4; nivel++) {
      final d = await _directorio(desde, largo);
      final e = _Entrada.buscar(d, id);
      if (e == null) return null;
      if (e.repeticiones == 0) {
        desde = cabecera.hojasDesde + e.desde;
        largo = e.largo;
        continue;
      }
      final datos = await _leer(cabecera.datosDesde + e.desde, e.largo);
      return _descomprimir(datos, cabecera.compresionTeselas);
    }
    return null;
  }

  /// Metadatos JSON del archivo (atribución, capas…).
  Future<Map<String, Object?>> metadatos() async {
    if (cabecera.metadatosLargo == 0) return const {};
    final b = _descomprimir(
      await _leer(cabecera.metadatosDesde, cabecera.metadatosLargo),
      cabecera.compresionInterna,
    );
    final j = jsonDecode(utf8.decode(b));
    return j is Map<String, Object?> ? j : const {};
  }
}

/// Cabecera de un PMTiles v3.
class CabeceraPmtiles {
  const CabeceraPmtiles({
    required this.raizDesde,
    required this.raizLargo,
    required this.metadatosDesde,
    required this.metadatosLargo,
    required this.hojasDesde,
    required this.datosDesde,
    required this.compresionInterna,
    required this.compresionTeselas,
    required this.tipoTesela,
    required this.zoomMinimo,
    required this.zoomMaximo,
    required this.oeste,
    required this.sur,
    required this.este,
    required this.norte,
    required this.zoomCentro,
    required this.lonCentro,
    required this.latCentro,
  });

  factory CabeceraPmtiles.leer(Uint8List b) {
    if (b.length < 127 ||
        ascii.decode(b.sublist(0, 7), allowInvalid: true) != 'PMTiles' ||
        b[7] != 3) {
      throw const FormatException('no es un PMTiles v3');
    }
    final v = ByteData.sublistView(b);
    int u64(int i) => v.getUint64(i, Endian.little);
    double grados(int i) => v.getInt32(i, Endian.little) / 1e7;
    return CabeceraPmtiles(
      raizDesde: u64(8),
      raizLargo: u64(16),
      metadatosDesde: u64(24),
      metadatosLargo: u64(32),
      hojasDesde: u64(40),
      datosDesde: u64(56),
      compresionInterna: b[97],
      compresionTeselas: b[98],
      tipoTesela: b[99],
      zoomMinimo: b[100],
      zoomMaximo: b[101],
      oeste: grados(102),
      sur: grados(106),
      este: grados(110),
      norte: grados(114),
      zoomCentro: b[118],
      lonCentro: grados(119),
      latCentro: grados(123),
    );
  }

  final int raizDesde, raizLargo, metadatosDesde, metadatosLargo;
  final int hojasDesde, datosDesde;

  /// 0 desconocida, 1 ninguna, 2 gzip.
  final int compresionInterna, compresionTeselas;

  /// 1 vectorial (MVT), 2 PNG, 3 JPEG, 4 WebP.
  final int tipoTesela;
  final int zoomMinimo, zoomMaximo, zoomCentro;
  final double oeste, sur, este, norte, lonCentro, latCentro;

  bool get vectorial => tipoTesela == 1;

  /// `true` si (lat, lon) cae dentro del recuadro del archivo.
  bool contiene(double lat, double lon) =>
      lat >= sur && lat <= norte && lon >= oeste && lon <= este;
}

/// Id de la tesela z/x/y en la curva de Hilbert de PMTiles.
int idTesela(int z, int x, int y) {
  var acc = ((1 << (2 * z)) - 1) ~/ 3;
  for (var s = z == 0 ? 0 : 1 << (z - 1); s > 0; s >>= 1) {
    final rx = (x & s) != 0 ? 1 : 0;
    final ry = (y & s) != 0 ? 1 : 0;
    acc += s * s * ((3 * rx) ^ ry);
    if (ry == 0) {
      if (rx == 1) {
        x = s - 1 - x;
        y = s - 1 - y;
      }
      final t = x;
      x = y;
      y = t;
    }
  }
  return acc;
}

class _Entrada {
  const _Entrada(this.id, this.repeticiones, this.largo, this.desde);

  final int id, repeticiones, largo, desde;

  static List<_Entrada> leerDirectorio(Uint8List b) {
    var i = 0;
    int varint() {
      var valor = 0, desplazamiento = 0;
      while (true) {
        if (i >= b.length) throw const FormatException('directorio cortado');
        final c = b[i++];
        valor |= (c & 0x7f) << desplazamiento;
        if (c < 0x80) return valor;
        desplazamiento += 7;
      }
    }

    final n = varint();
    final ids = List<int>.filled(n, 0);
    var ultimo = 0;
    for (var k = 0; k < n; k++) {
      ultimo += varint();
      ids[k] = ultimo;
    }
    final reps = [for (var k = 0; k < n; k++) varint()];
    final largos = [for (var k = 0; k < n; k++) varint()];
    final desdes = List<int>.filled(n, 0);
    for (var k = 0; k < n; k++) {
      final o = varint();
      desdes[k] = (o == 0 && k > 0) ? desdes[k - 1] + largos[k - 1] : o - 1;
    }
    return [
      for (var k = 0; k < n; k++)
        _Entrada(ids[k], reps[k], largos[k], desdes[k]),
    ];
  }

  /// La entrada que cubre [id] (búsqueda binaria), o nula.
  static _Entrada? buscar(List<_Entrada> d, int id) {
    var lo = 0, hi = d.length - 1;
    while (lo <= hi) {
      final m = (lo + hi) >> 1;
      final e = d[m];
      if (e.id < id) {
        lo = m + 1;
      } else if (e.id > id) {
        hi = m - 1;
      } else {
        return e;
      }
    }
    if (hi < 0) return null;
    final e = d[hi];
    if (e.repeticiones == 0) return e;
    return id - e.id < e.repeticiones ? e : null;
  }
}
