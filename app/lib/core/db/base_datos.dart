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
    ClipsPendientes,
    AjustesControlHoras,
    Citas,
    Turnos,
    PreguntasConsulta,
    NotasConsulta,
    GrabacionesConsulta,
    AjustesUbicacion,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 1: semana 1. 2: tablas del cartero cifrado (`sobres_enviados` y
  /// `sync_estado`); las tablas de hechos no cambian. 3: cola de subida de
  /// los clips (`clips_pendientes`). 4: ajustes del control por horas
  /// (`ajustes_control_horas`). 5: baja lógica de los familiares
  /// (`miembros.baja_en`). 6: citas y turnos de la familia (`citas`,
  /// `turnos`). 7: comidas y vasos de agua pasan a fichas con baja lógica
  /// (`comidas.baja_en`, `hidrataciones.baja_en`): dejan de ser de solo
  /// inserción. 8: preguntas, notas y marca de grabación de las consultas
  /// (`preguntas_consulta`, `notas_consulta`, `grabaciones_consulta`). 9:
  /// zona segura (`ajustes_ubicacion`) y las posiciones
  /// (`ubicacion_registrada`) se pueden borrar de `eventos` a los 7 días
  /// ([disparadorBorradoEventos]).
  @override
  int get schemaVersion => 9;

  /// Tipos de evento que sí se pueden borrar: las posiciones, que no deben
  /// quedarse más de 7 días en el móvil.
  static const eventosBorrables = ['ubicacion_registrada'];

  /// `eventos` es de solo inserción salvo [eventosBorrables].
  static final disparadorBorradoEventos =
      'CREATE TRIGGER eventos_no_delete BEFORE DELETE ON eventos '
      "WHEN OLD.tipo NOT IN (${eventosBorrables.map((t) => "'$t'").join(', ')}) "
      "BEGIN SELECT RAISE(ABORT, 'solo_insercion'); END";

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
          t == 'eventos'
              ? disparadorBorradoEventos
              : 'CREATE TRIGGER ${t}_no_delete BEFORE DELETE ON $t '
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
      if (from < 3) {
        await m.createTable(clipsPendientes);
      }
      if (from < 4) {
        await m.createTable(ajustesControlHoras);
      }
      if (from < 5) {
        await m.addColumn(miembros, miembros.bajaEn);
      }
      if (from < 6) {
        await m.createTable(citas);
        await m.createTable(turnos);
      }
      if (from < 7) {
        await m.addColumn(comidas, comidas.bajaEn);
        await m.addColumn(hidrataciones, hidrataciones.bajaEn);
        // Antes eran hechos de solo inserción; ahora se corrigen y se dan de
        // baja como el resto de fichas.
        for (final t in ['comidas', 'hidrataciones']) {
          await customStatement('DROP TRIGGER IF EXISTS ${t}_no_update');
          await customStatement('DROP TRIGGER IF EXISTS ${t}_no_delete');
        }
      }
      if (from < 8) {
        await m.createTable(preguntasConsulta);
        await m.createTable(notasConsulta);
        await m.createTable(grabacionesConsulta);
      }
      if (from < 9) {
        await m.createTable(ajustesUbicacion);
        // Las posiciones caducan: el resto de eventos sigue sin borrarse.
        await customStatement('DROP TRIGGER IF EXISTS eventos_no_delete');
        await customStatement(disparadorBorradoEventos);
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
