import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Abre `<applicationSupport>/newera.db` cifrada con SQLCipher.
///
/// Con sqlite3 3.x la biblioteca SQLCipher se elige en `pubspec.yaml`
/// (`hooks: user_defines: sqlite3: source: sqlcipher` para Android e iOS), por
/// lo que ya no hace falta `sqlcipher_flutter_libs` ni `open.overrideFor`.
/// Si `PRAGMA cipher_version` sale vacío, nunca se sigue sin cifrar.
Future<QueryExecutor> abrirConexion({required String? claveHex}) async {
  if (claveHex == null || claveHex.isEmpty) {
    throw StateError('clave_circulo_ausente');
  }
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  final archivo = File(p.join(dir.path, 'newera.db'));
  return NativeDatabase.createInBackground(
    archivo,
    setup: (db) {
      db.execute('PRAGMA key = "x\'$claveHex\'";');
      final version = db.select('PRAGMA cipher_version;');
      final valor = version.isEmpty
          ? null
          : version.first.values.first as String?;
      if (valor == null || valor.isEmpty) {
        throw StateError('sqlcipher_no_disponible');
      }
      db.execute('PRAGMA foreign_keys = ON;');
    },
  );
}
