import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Índice de mapas que publica el flujo `.github/workflows/mapas.yml` como
/// archivo de una Release del propio repositorio. Un mapa por comunidad
/// autónoma de España: la lista es fija y no dice dónde vive nadie.
const urlIndiceMapas =
    'https://github.com/naixsaint-rgb/NEW-ERA/releases/download/mapas/indice.json';

/// Un mapa que se puede descargar (una fila del índice).
class MapaZona {
  const MapaZona({
    required this.id,
    required this.nombre,
    required this.archivo,
    required this.bytes,
    required this.sha256,
    required this.url,
    this.zoomMaximo,
  });

  /// Lee una fila del índice; [base] es la URL del índice (los archivos van
  /// a su lado).
  factory MapaZona.desdeJson(Map<String, Object?> j, Uri base) {
    final archivo = j['archivo'] as String;
    if (!RegExp(r'^[a-z0-9_-]+\.pmtiles$').hasMatch(archivo)) {
      throw const FormatException('nombre de archivo no válido');
    }
    final sha = (j['sha256'] as String).toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(sha)) {
      throw const FormatException('sha256 no válido');
    }
    return MapaZona(
      id: j['id'] as String,
      nombre: j['nombre'] as String,
      archivo: archivo,
      bytes: (j['bytes'] as num).toInt(),
      sha256: sha,
      url: base.resolve(archivo),
      zoomMaximo: (j['zoom_maximo'] as num?)?.toInt(),
    );
  }

  final String id;
  final String nombre;
  final String archivo;
  final int bytes;
  final String sha256;
  final Uri url;
  final int? zoomMaximo;
}

/// El mapa guardado en el móvil.
class MapaInstalado {
  const MapaInstalado({
    required this.id,
    required this.nombre,
    required this.archivo,
    required this.bytes,
  });

  final String id;
  final String nombre;
  final File archivo;
  final int bytes;
}

/// Progreso de una descarga: [recibidos] de [total] bytes.
class ProgresoMapa {
  const ProgresoMapa(this.recibidos, this.total, {this.comprobando = false});

  final int recibidos;
  final int total;

  /// `true` mientras se comprueba la huella sha256 al final.
  final bool comprobando;

  double get fraccion => total <= 0 ? 0 : (recibidos / total).clamp(0, 1);
}

enum MotivoErrorMapa { red, huella, indice }

class ErrorMapa implements Exception {
  const ErrorMapa(this.motivo);

  final MotivoErrorMapa motivo;

  @override
  String toString() => 'ErrorMapa(${motivo.name})';
}

/// Lista, descarga (reanudable, con comprobación sha256), guarda y borra el
/// mapa de la zona en `Documentos/mapas/`. Solo hay un mapa a la vez: al
/// descargar otro se sustituye el anterior.
///
/// Solo se conecta para bajar el índice y el archivo elegido, cuando la
/// familia lo pide. Al usar el mapa no se conecta a nada.
class GestorMapas {
  GestorMapas({required this.carpeta, required this.cliente, Uri? indice})
    : indice = indice ?? Uri.parse(urlIndiceMapas);

  /// Carpeta `mapas` (se crea si falta).
  final Future<Directory> Function() carpeta;

  /// Cliente HTTP nuevo para cada descarga (se cierra al terminar).
  final http.Client Function() cliente;
  final Uri indice;

  static const _instalado = 'instalado.json';

  Future<Directory> _dir() async {
    final d = await carpeta();
    if (!d.existsSync()) await d.create(recursive: true);
    return d;
  }

  /// Los mapas del índice.
  Future<List<MapaZona>> lista() async {
    final c = cliente();
    try {
      final r = await c.get(indice);
      if (r.statusCode != 200) throw const ErrorMapa(MotivoErrorMapa.red);
      final j = jsonDecode(utf8.decode(r.bodyBytes));
      final filas = (j is Map ? j['mapas'] : null);
      if (filas is! List) throw const ErrorMapa(MotivoErrorMapa.indice);
      return [
        for (final f in filas)
          MapaZona.desdeJson(f as Map<String, Object?>, indice),
      ];
    } on ErrorMapa {
      rethrow;
    } on FormatException {
      throw const ErrorMapa(MotivoErrorMapa.indice);
    } on TypeError {
      throw const ErrorMapa(MotivoErrorMapa.indice);
    } catch (_) {
      throw const ErrorMapa(MotivoErrorMapa.red);
    } finally {
      c.close();
    }
  }

  /// El mapa guardado, o nulo.
  Future<MapaInstalado?> instalado() async {
    final d = await _dir();
    final f = File('${d.path}/$_instalado');
    if (!f.existsSync()) return null;
    try {
      final j = jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
      final archivo = File('${d.path}/${j['archivo']}');
      if (!archivo.existsSync()) return null;
      return MapaInstalado(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        archivo: archivo,
        bytes: archivo.lengthSync(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Bytes ya bajados de [m] en una descarga anterior sin terminar.
  Future<int> parcial(MapaZona m) async {
    final p = File('${(await _dir()).path}/${m.archivo}.part');
    return p.existsSync() ? p.lengthSync() : 0;
  }

  /// Descarga [m]. Si se corta (o se cancela la suscripción), lo bajado se
  /// queda en `<archivo>.part` y la siguiente vez sigue desde ahí con una
  /// petición `Range`. Al terminar comprueba el sha256: si no coincide borra
  /// lo bajado y lanza [ErrorMapa] con [MotivoErrorMapa.huella].
  Stream<ProgresoMapa> descargar(MapaZona m) async* {
    final d = await _dir();
    final parte = File('${d.path}/${m.archivo}.part');
    var ya = parte.existsSync() ? parte.lengthSync() : 0;
    if (ya > m.bytes) {
      await parte.delete();
      ya = 0;
    }
    yield ProgresoMapa(ya, m.bytes);
    if (ya < m.bytes) {
      final c = cliente();
      IOSink? salida;
      try {
        final pet = http.Request('GET', m.url);
        if (ya > 0) pet.headers['Range'] = 'bytes=$ya-';
        final http.StreamedResponse r;
        try {
          r = await c.send(pet);
        } catch (_) {
          throw const ErrorMapa(MotivoErrorMapa.red);
        }
        if (r.statusCode == 200) {
          ya = 0; // El servidor no reanuda: se empieza de cero.
        } else if (r.statusCode != 206 || ya == 0) {
          throw const ErrorMapa(MotivoErrorMapa.red);
        }
        salida = parte.openWrite(
          mode: ya == 0 ? FileMode.write : FileMode.append,
        );
        try {
          await for (final trozo in r.stream) {
            salida.add(trozo);
            ya += trozo.length;
            if (ya > m.bytes) throw const ErrorMapa(MotivoErrorMapa.huella);
            yield ProgresoMapa(ya, m.bytes);
          }
        } on ErrorMapa {
          rethrow;
        } catch (_) {
          throw const ErrorMapa(MotivoErrorMapa.red);
        }
      } finally {
        await salida?.flush();
        await salida?.close();
        c.close();
      }
      if (ya < m.bytes) throw const ErrorMapa(MotivoErrorMapa.red);
    }
    yield ProgresoMapa(ya, m.bytes, comprobando: true);
    final huella = await sha256.bind(parte.openRead()).first;
    if (huella.toString() != m.sha256) {
      await parte.delete();
      throw const ErrorMapa(MotivoErrorMapa.huella);
    }
    await _instalar(d, m, parte);
    yield ProgresoMapa(m.bytes, m.bytes);
  }

  Future<void> _instalar(Directory d, MapaZona m, File parte) async {
    final anterior = await instalado();
    final destino = File('${d.path}/${m.archivo}');
    if (destino.existsSync()) await destino.delete();
    await parte.rename(destino.path);
    if (anterior != null && anterior.archivo.path != destino.path) {
      await _borrarArchivo(anterior.archivo);
    }
    await _borrarCache();
    await File('${d.path}/$_instalado').writeAsString(
      jsonEncode({'id': m.id, 'nombre': m.nombre, 'archivo': m.archivo}),
    );
  }

  /// Borra el mapa guardado, las descargas a medias y la caché de dibujo.
  Future<void> borrar() async {
    final d = await _dir();
    for (final f in d.listSync()) {
      if (f is File &&
          (f.path.endsWith('.pmtiles') ||
              f.path.endsWith('.part') ||
              f.path.endsWith(_instalado))) {
        await _borrarArchivo(f);
      }
    }
    await _borrarCache();
  }

  /// Caché de dibujo del mapa (`mapas/cache`, la crea el mapa al pintar).
  Future<void> _borrarCache() async {
    final c = Directory('${(await _dir()).path}/cache');
    try {
      if (c.existsSync()) await c.delete(recursive: true);
    } catch (_) {
      // Se intenta la próxima vez.
    }
  }

  static Future<void> _borrarArchivo(File f) async {
    try {
      if (f.existsSync()) await f.delete();
    } catch (_) {
      // Si no se puede borrar ahora, se intenta la próxima vez.
    }
  }
}
