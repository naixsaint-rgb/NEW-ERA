import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'archivos_voz.dart';

/// Audios en disco, en `<documentos de la app>/voces/`.
///
/// - Android: `app_flutter/voces`, almacenamiento privado de la app (no hace
///   falta ningún permiso de almacenamiento). La app no entra en copias de
///   seguridad (`android:allowBackup="false"`).
/// - iOS: `Documents/voces`. Documents entra en la copia de iCloud; marcar la
///   carpeta con `NSURLIsExcludedFromBackupKey` pide código nativo y queda
///   pendiente con la capa Swift, igual que los vídeos de comprobación. Se usa
///   Documents porque el paquete `alarm` busca ahí los sonidos de las
///   alarmas.
///
/// En los tests se le pasa una carpeta temporal.
class ArchivosVozDisco implements ArchivosVoz {
  ArchivosVozDisco([Future<Directory> Function()? base])
    : _base = base ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _base;

  @override
  Future<String> absoluta(String ruta) async {
    RutasVoz.comprobar(ruta);
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
    // Primero a un temporal y luego se renombra: nunca queda medio audio.
    final temporal = File('$destino.parcial');
    await temporal.writeAsBytes(bytes, flush: true);
    await temporal.rename(destino);
  }

  @override
  Future<Uint8List?> leer(String ruta) async {
    if (!RutasVoz.valida(ruta)) return null;
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
    if (!RutasVoz.valida(ruta)) return false;
    try {
      return await File(await absoluta(ruta)).exists();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> borrar(String ruta) async {
    if (!RutasVoz.valida(ruta)) return;
    try {
      final f = File(await absoluta(ruta));
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Un audio que no se deja borrar no debe romper nada.
    }
  }
}
