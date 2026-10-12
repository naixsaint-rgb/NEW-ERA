import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Base de la demo web: sin cifrado ni clave. Sin COOP/COEP en GitHub Pages,
/// drift usará IndexedDB. `sqlite3.wasm` y `drift_worker.js` viven en `web/`.
Future<QueryExecutor> abrirConexion({required String? claveHex}) async {
  final resultado = await WasmDatabase.open(
    databaseName: 'newera_demo',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
  return resultado.resolvedExecutor;
}
