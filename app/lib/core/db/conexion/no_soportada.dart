import 'package:drift/drift.dart';

/// Plataforma sin base de datos disponible.
Future<QueryExecutor> abrirConexion({required String? claveHex}) async {
  throw UnsupportedError('Esta plataforma no admite la base de datos.');
}
