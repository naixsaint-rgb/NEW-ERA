import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'archivos_clip.dart';

/// Clips en disco, en `<documentos de la app>/clips/`.
///
/// - Android: almacenamiento privado de la app, sin permisos de
///   almacenamiento y fuera de las copias (`android:allowBackup="false"`).
/// - iOS: `Documents/clips`. Excluirla de la copia de iCloud
///   (`NSURLIsExcludedFromBackupKey`) pide código nativo y queda pendiente
///   con la capa Swift, igual que las voces.
///
/// En los tests se le pasa una carpeta temporal.
class ArchivosClipDisco implements ArchivosClip {
  ArchivosClipDisco([Future<Directory> Function()? base])
    : _base = base ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _base;

  @override
  Future<String> absoluta(String ruta) async {
    RutasClip.comprobar(ruta);
    return p.join((await _base()).path, ruta);
  }

  @override
  Future<String> prepararEscritura(String ruta) async {
    final destino = await absoluta(ruta);
    await Directory(p.dirname(destino)).create(recursive: true);
    return destino;
  }

  @override
  Future<void> escribir(String ruta, Uint8List bytes) async {
    final destino = await prepararEscritura(ruta);
    // Primero a un temporal y luego se renombra: nunca queda medio clip.
    final temporal = File('$destino.parcial');
    await temporal.writeAsBytes(bytes, flush: true);
    await temporal.rename(destino);
  }

  @override
  Future<Uint8List?> leer(String ruta) async {
    if (!RutasClip.valida(ruta)) return null;
    try {
      final f = File(await absoluta(ruta));
      if (!await f.exists()) return null;
      return await f.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> existe(String ruta) async {
    if (!RutasClip.valida(ruta)) return false;
    try {
      return await File(await absoluta(ruta)).exists();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> mover(String origen, String destino) async {
    if (!RutasClip.valida(origen) || !RutasClip.valida(destino)) return false;
    try {
      final f = File(await absoluta(origen));
      if (!await f.exists()) return false;
      await f.rename(await prepararEscritura(destino));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> borrar(String ruta) async {
    if (!RutasClip.valida(ruta)) return;
    // También el temporal de una escritura que se cortó.
    for (final sufijo in const ['', '.parcial']) {
      try {
        final f = File('${await absoluta(ruta)}$sufijo');
        if (await f.exists()) await f.delete();
      } catch (_) {
        // Un clip que no se deja borrar no debe romper nada.
      }
    }
  }

  @override
  Future<List<({String ruta, DateTime modificado})>> listar() async {
    try {
      final carpeta = Directory(
        p.join((await _base()).path, RutasClip.carpeta),
      );
      if (!await carpeta.exists()) return const [];
      final r = <({String ruta, DateTime modificado})>[];
      await for (final e in carpeta.list(followLinks: false)) {
        if (e is! File) continue;
        final nombre = p.basename(e.path);
        // Un `.parcial` (escritura cortada) sale con la ruta de su clip:
        // [borrar] se lleva los dos.
        var ruta = '${RutasClip.carpeta}/$nombre';
        if (ruta.endsWith('.parcial')) {
          ruta = ruta.substring(0, ruta.length - '.parcial'.length);
        }
        if (!RutasClip.valida(ruta)) continue;
        try {
          r.add((ruta: ruta, modificado: await e.lastModified()));
        } catch (_) {}
      }
      return r;
    } catch (_) {
      return const [];
    }
  }
}
