import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:newera/core/db/base_datos.dart';

/// Ejecutor en memoria sin temporizadores pendientes.
QueryExecutor ejecutorEnMemoria() => DatabaseConnection(
  NativeDatabase.memory(),
  closeStreamsSynchronously: true,
);

/// Base en memoria para tests.
AppDatabase baseEnMemoria() => AppDatabase(ejecutorEnMemoria());
