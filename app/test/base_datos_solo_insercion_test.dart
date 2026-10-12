import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/db/base_datos.dart';

import 'utiles/base_prueba.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = baseEnMemoria();
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await db
        .into(db.circulos)
        .insert(
          CirculosCompanion.insert(id: 'c1', nombre: 'Familia', creadoEn: 1),
        );
    await db
        .into(db.eventos)
        .insert(
          EventosCompanion.insert(
            ulid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
            circuloId: 'c1',
            autor: 'a',
            dispositivo: 'd',
            tipo: 'ayuda_pedida',
            ocurridoEn: 1,
            registradoEn: 1,
          ),
        );
    await db
        .into(db.pautas)
        .insert(
          PautasCompanion.insert(
            id: 'v1',
            pautaId: 'p1',
            version: 1,
            medicamentoId: 'm1',
            personaId: 'x',
            dosis: '1',
            horas: '["09:00"]',
            zonaHoraria: 'Europe/Madrid',
            vigenteDesde: 1,
            activa: true,
            creadaPor: 'a',
            creadaEn: 1,
          ),
        );
  });

  tearDown(() => db.close());

  test('se puede insertar y leer', () async {
    expect((await db.select(db.eventos).get()).length, 1);
    expect((await db.select(db.pautas).get()).length, 1);
  });

  test('UPDATE y DELETE en eventos fallan', () async {
    expect(
      () => db.customStatement("UPDATE eventos SET tipo = 'otro'"),
      throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
    );
    expect(
      () => db.customStatement('DELETE FROM eventos'),
      throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
    );
  });

  test('UPDATE y DELETE en pautas fallan', () async {
    expect(
      () => db.customStatement("UPDATE pautas SET dosis = '2'"),
      throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
    );
    expect(
      () => db.customStatement('DELETE FROM pautas'),
      throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
    );
  });

  test('INSERT OR REPLACE no se salta el solo inserción', () async {
    expect(
      () => db
          .into(db.eventos)
          .insert(
            EventosCompanion.insert(
              ulid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
              circuloId: 'c1',
              autor: 'b',
              dispositivo: 'd',
              tipo: 'otro',
              ocurridoEn: 2,
              registradoEn: 2,
            ),
            mode: InsertMode.insertOrReplace,
          ),
      throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
    );
    expect((await db.select(db.eventos).getSingle()).tipo, 'ayuda_pedida');
  });

  test('todas las tablas de hechos tienen sus dos disparadores', () async {
    final filas = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'trigger'")
        .get();
    expect(filas.length, tablasDeHechos.length * 2);
  });

  test('las fichas sí se actualizan', () async {
    await (db.update(db.circulos)..where((c) => c.id.equals('c1'))).write(
      const CirculosCompanion(nombre: Value('Otra')),
    );
    expect((await db.select(db.circulos).getSingle()).nombre, 'Otra');
  });
}
