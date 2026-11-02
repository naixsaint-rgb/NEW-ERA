import 'package:drift/drift.dart';

import 'tablas.dart';

part 'base_datos.g.dart';

/// Tablas de hechos: solo se inserta, corregir es insertar.
const tablasDeHechos = <String>[
  'fotos',
  'pautas',
  'tomas',
  'comprobaciones',
  'eventos',
  'preguntas_control',
  'respuestas',
  'consentimientos',
  'comidas',
  'hidrataciones',
];

@DriftDatabase(
  tables: [
    Circulos,
    Personas,
    Miembros,
    Dispositivos,
    Medicamentos,
    Voces,
    Frases,
    Fotos,
    Pautas,
    Tomas,
    Comprobaciones,
    Eventos,
    PreguntasControl,
    Respuestas,
    Consentimientos,
    Comidas,
    Hidrataciones,
    SobresEnviados,
    SyncEstado,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 1: semana 1. 2: tablas del cartero cifrado (`sobres_enviados` y
  /// `sync_estado`); las tablas de hechos no cambian.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final t in tablasDeHechos) {
        await customStatement(
          'CREATE TRIGGER ${t}_no_update BEFORE UPDATE ON $t '
          "BEGIN SELECT RAISE(ABORT, 'solo_insercion'); END",
        );
        await customStatement(
          'CREATE TRIGGER ${t}_no_delete BEFORE DELETE ON $t '
          "BEGIN SELECT RAISE(ABORT, 'solo_insercion'); END",
        );
      }
    },
    onUpgrade: (m, from, to) async {
      // Solo se añaden tablas: los hechos y sus disparadores no se tocan.
      if (from < 2) {
        await m.createTable(sobresEnviados);
        await m.createTable(syncEstado);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Sin esto, INSERT OR REPLACE borra la fila vieja sin disparar el
      // BEFORE DELETE y se salta el "solo inserción".
      await customStatement('PRAGMA recursive_triggers = ON');
    },
  );
}
