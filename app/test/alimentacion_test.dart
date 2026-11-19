import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/app.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/png_marcador.dart';
import 'package:newera/core/db/repositorios/alimentacion_repositorio.dart';
import 'package:newera/core/db/repositorios/circulo_repositorio.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/features/alimentacion/dominio/alimentacion.dart';
import 'package:newera/features/medicacion/datos/selector_foto.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

final _clave = ClaveCirculo.generar(Random(21));
const _circulo = 'circulo-alimentacion';
const _persona = 'persona-alimentacion';
const _zona = 'Europe/Madrid';

/// Hora de Madrid (UTC+2 el 13/10/2026) a UTC.
DateTime _madrid(int hora, int minuto, {int dia = 13}) =>
    DateTime.utc(2026, 10, dia, hora - 2, minuto);

Comida _comida(
  String id,
  String momento,
  DateTime cuando, {
  int? baja,
  String cuanto = 'todo',
}) => Comida(
  id: id,
  personaId: _persona,
  momento: momento,
  cuanto: cuanto,
  ocurridaEn: cuando.millisecondsSinceEpoch,
  registradaPor: 'x',
  bajaEn: baja,
);

Hidratacion _vaso(String id, DateTime cuando, {int vasos = 1, int? baja}) =>
    Hidratacion(
      id: id,
      personaId: _persona,
      vasos: vasos,
      ocurridaEn: cuando.millisecondsSinceEpoch,
      registradaPor: 'x',
      bajaEn: baja,
    );

// ------------------------------------------------------------ Dos móviles

class _Movil {
  _Movil(this.c, this.servicio, this.reloj);

  final ProviderContainer c;
  final ServicioSync servicio;
  final RelojFijo reloj;

  AppDatabase get db => c.read(baseDatosProvider);
  AlimentacionRepositorio get repo => c.read(alimentacionRepositorioProvider);

  Future<List<Comida>> comidas() => repo.observarComidas().first;
  Future<List<Hidratacion>> vasos() => repo.observarVasos().first;

  Future<void> cerrar() async {
    await servicio.detener();
    final base = db;
    c.dispose();
    await base.close();
  }
}

Future<_Movil> _crearMovil(ServidorMemoria servidor, String dispositivo) async {
  final reloj = RelojFijo(instantePrueba);
  final almacen = AlmacenSeguroMemoria({
    ClavesAlmacen.dispositivoId: dispositivo,
    ClavesAlmacen.circuloId: _circulo,
    ClavesAlmacen.personaId: _persona,
    ClavesAlmacen.circuloClave: _clave,
    ClavesAlmacen.circuloClaveVersion: '1',
  });
  final overrides = await Arranque.iniciar(
    almacen: almacen,
    ejecutor: ejecutorEnMemoria(),
    reloj: reloj,
    plataforma: 'android',
    demoWeb: false,
    sembrarDemo: false,
    azar: Random(dispositivo.hashCode),
  );
  final transporte = TransporteMemoria(servidor);
  final c = ProviderContainer(
    overrides: [
      ...overrides,
      syncTransportProvider.overrideWithValue(transporte),
    ],
  );
  final servicio = ServicioSync(
    db: c.read(baseDatosProvider),
    transporte: transporte,
    llaves: () => c.read(llavesCirculoProvider.future),
    contexto: c.read(contextoProvider),
    reloj: c.read(relojProvider),
    pausaNuevos: const Duration(milliseconds: 1),
    esperaMinima: const Duration(milliseconds: 10),
    esperaMaxima: const Duration(milliseconds: 50),
  );
  final m = _Movil(c, servicio, reloj);
  await m.c
      .read(circuloRepositorioProvider)
      .asegurarDispositivo(PerfilApp.familia);
  return m;
}

Future<void> _entregar(
  ServidorMemoria servidor,
  _Movil a,
  _Movil b, {
  bool alReves = false,
}) async {
  await a.servicio.empujar();
  final sobres = [...servidor.sobres];
  for (final s in alReves ? sobres.reversed : sobres) {
    await b.servicio.recibir(s);
  }
}

// ------------------------------------------------------------ Pantallas

/// Monta la familia en Alimentación (martes 13 de octubre, 12:00 en Madrid).
Future<EntornoPrueba> _abrir(
  WidgetTester tester, {
  String ruta = '/familia/alimentacion',
  Brightness brillo = Brightness.light,
  List<Override> extra = const [],
  Future<void> Function(EntornoPrueba e)? previo,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final entorno = await tester.runAsync(() async {
    final e = await prepararEntorno(perfil: PerfilApp.familia);
    if (previo != null) await previo(e);
    return e;
  });
  await montarApp(tester, entorno!, rutaInicial: ruta, extra: extra);
  await pasar(tester, const Duration(seconds: 1));
  return entorno;
}

/// El desplazable de la pantalla de más arriba.
Finder get _lista => find
    .descendant(
      of: find.byType(ListView).last,
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _pulsar(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 200, scrollable: _lista);
  }
  await Scrollable.ensureVisible(f.evaluate().first, alignment: 0.5);
  await pasar(tester, const Duration(milliseconds: 300));
  await tester.tap(f);
  // Deja correr la base de verdad (guardar, borrar) y luego el reloj falso.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await pasar(tester, const Duration(milliseconds: 700));
}

Future<List<Comida>> _comidasDe(WidgetTester tester, EntornoPrueba e) =>
    tester.runAsync(() => e.db.select(e.db.comidas).get()).then((x) => x!);

Future<List<Hidratacion>> _vasosDe(WidgetTester tester, EntornoPrueba e) =>
    tester
        .runAsync(() => e.db.select(e.db.hidrataciones).get())
        .then((x) => x!);

void main() {
  group('dominio', () {
    test('cuenta las cuatro comidas, sin «otro» ni las borradas', () {
      final dia = diaAlimentacion(
        comidas: [
          _comida('a', 'desayuno', _madrid(9, 0)),
          _comida('b', 'desayuno', _madrid(10, 0)),
          _comida('c', 'comida', _madrid(14, 0)),
          _comida('d', 'merienda', _madrid(17, 0), baja: 1),
          _comida('e', 'otro', _madrid(18, 0)),
        ],
        vasos: [
          _vaso('v1', _madrid(9, 0)),
          _vaso('v2', _madrid(10, 0), baja: 5),
          _vaso('v3', _madrid(11, 0), vasos: 2),
        ],
        fecha: '2026-10-13',
        zona: _zona,
      );
      expect(dia.principalesAnotadas, 2);
      expect(dia.comidas.map((c) => c.id), ['a', 'b', 'c', 'e']);
      expect(dia.deMomento('desayuno'), hasLength(2));
      expect(dia.vasos, 3);
    });

    test('el día es el de la persona: 23:30 y 00:30 no son el mismo', () {
      final comidas = [
        _comida('tarde', 'cena', _madrid(23, 30)),
        _comida('noche', 'otro', _madrid(0, 30, dia: 14)),
      ];
      DiaAlimentacion de(String f) => diaAlimentacion(
        comidas: comidas,
        vasos: const [],
        fecha: f,
        zona: _zona,
      );
      expect(de('2026-10-13').comidas.map((c) => c.id), ['tarde']);
      expect(de('2026-10-14').comidas.map((c) => c.id), ['noche']);
    });

    test('la semana son siete días, del más reciente al más antiguo', () {
      final s = semanaAlimentacion(
        comidas: [_comida('a', 'desayuno', _madrid(9, 0, dia: 7))],
        vasos: [_vaso('v', _madrid(9, 0, dia: 10))],
        hoy: '2026-10-13',
        zona: _zona,
      );
      expect(s.map((d) => d.fecha), [
        '2026-10-13',
        '2026-10-12',
        '2026-10-11',
        '2026-10-10',
        '2026-10-09',
        '2026-10-08',
        '2026-10-07',
      ]);
      // Hace seis días cae dentro; el 7 de octubre es el último.
      expect(s.last.principalesAnotadas, 1);
      expect(s[3].vasos, 1);
      expect(s.first.principalesAnotadas, 0);
    });
  });

  group('repositorio y cartero', () {
    late ServidorMemoria servidor;
    late _Movil a;
    late _Movil b;

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      servidor = ServidorMemoria();
      a = await _crearMovil(servidor, 'movil-a');
      b = await _crearMovil(servidor, 'movil-b');
      await a.c.read(circuloRepositorioProvider).asegurarBase();
      await b.c.read(circuloRepositorioProvider).asegurarBase();
      await _entregar(servidor, a, b);
    });

    tearDown(() async {
      await a.cerrar();
      await b.cerrar();
    });

    test('crear, editar y borrar una comida (baja lógica)', () async {
      final id = await a.repo.crearComida(
        DatosComida(
          momento: MomentoComida.comida,
          cuanto: CuantoComio.mitad,
          ocurridaEn: _madrid(14, 5),
          nota: '  Sopa  ',
        ),
      );
      var c = (await a.comidas()).single;
      expect(c.id, id);
      expect(c.momento, 'comida');
      expect(c.cuanto, 'mitad');
      expect(c.nota, 'Sopa');
      expect(c.personaId, _persona);
      expect(c.ocurridaEn, _madrid(14, 5).millisecondsSinceEpoch);
      expect(c.bajaEn, isNull);

      await a.repo.editarComida(
        id,
        DatosComida(
          momento: MomentoComida.merienda,
          cuanto: CuantoComio.poco,
          ocurridaEn: _madrid(17, 0),
        ),
      );
      c = (await a.comidas()).single;
      expect(c.momento, 'merienda');
      expect(c.cuanto, 'poco');
      expect(c.nota, isNull);

      a.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
      await a.repo.borrarComida(id);
      expect(await a.comidas(), isEmpty);
      final fila = (await a.db.select(a.db.comidas).get()).single;
      expect(
        fila.bajaEn,
        instantePrueba.add(const Duration(minutes: 1)).millisecondsSinceEpoch,
      );
      // Una comida borrada ya no se edita.
      await a.repo.editarComida(
        id,
        DatosComida(momento: MomentoComida.cena, ocurridaEn: _madrid(21, 0)),
      );
      expect(
        (await a.db.select(a.db.comidas).get()).single.momento,
        'merienda',
      );
    });

    test('una comida no válida no se guarda', () async {
      await expectLater(
        a.repo.crearComida(
          DatosComida(momento: 'brunch', ocurridaEn: _madrid(11, 0)),
        ),
        throwsArgumentError,
      );
      await expectLater(
        a.repo.crearComida(
          DatosComida(
            momento: 'comida',
            cuanto: 'bastante',
            ocurridaEn: _madrid(11, 0),
          ),
        ),
        throwsArgumentError,
      );
      expect(await a.db.select(a.db.comidas).get(), isEmpty);
    });

    test(
      'los vasos suman de uno en uno y restar quita el último de hoy',
      () async {
        expect(await a.repo.restarVaso(), isFalse);
        await a.repo.sumarVaso();
        a.reloj.avanzar(const Duration(minutes: 30));
        final segundo = await a.repo.sumarVaso();
        a.reloj.avanzar(const Duration(minutes: 30));
        final tercero = await a.repo.sumarVaso();
        expect(await a.vasos(), hasLength(3));

        a.reloj.avanzar(const Duration(minutes: 5));
        expect(await a.repo.restarVaso(), isTrue);
        expect((await a.vasos()).map((v) => v.id), isNot(contains(tercero)));
        expect(await a.vasos(), hasLength(2));
        expect(await a.repo.restarVaso(), isTrue);
        expect((await a.vasos()).map((v) => v.id), isNot(contains(segundo)));
        expect(await a.vasos(), hasLength(1));
        // Las filas se conservan con su baja.
        final todas = await a.db.select(a.db.hidrataciones).get();
        expect(todas, hasLength(3));
        expect(todas.where((v) => v.bajaEn != null), hasLength(2));
      },
    );

    test('restar no toca los vasos de ayer', () async {
      await a.repo.anotarVasoEn(_madrid(20, 0, dia: 12));
      expect(await a.repo.restarVaso(), isFalse);
      expect(await a.vasos(), hasLength(1));
    });

    test('una comida con foto, editada y borrada en A llega a B', () async {
      final foto = FotoNueva(
        PngMarcador.pastilla(forma: 'redonda', color: 0xFFE0B040),
        mime: 'image/png',
      );
      final id = await a.repo.crearComida(
        DatosComida(
          momento: MomentoComida.desayuno,
          ocurridaEn: _madrid(9, 0),
          nota: 'Tostada',
          fotoNueva: foto,
        ),
      );
      await _entregar(servidor, a, b);
      var enB = (await b.comidas()).single;
      expect(enB.id, id);
      expect(enB.nota, 'Tostada');
      expect(enB.fotoId, isNotNull);
      expect(enB.fotoId, (await a.comidas()).single.fotoId);
      expect(
        await b.c.read(circuloRepositorioProvider).foto(enB.fotoId!),
        isNotNull,
      );
      // Quién la anotó viaja con la ficha.
      expect(enB.registradaPor, (await a.comidas()).single.registradaPor);

      a.reloj.fijar(instantePrueba.add(const Duration(seconds: 30)));
      await a.repo.editarComida(
        id,
        DatosComida(
          momento: MomentoComida.desayuno,
          cuanto: CuantoComio.poco,
          ocurridaEn: _madrid(9, 15),
          fotoId: enB.fotoId,
        ),
      );
      await _entregar(servidor, a, b);
      enB = (await b.comidas()).single;
      expect(enB.cuanto, 'poco');
      expect(enB.nota, isNull);
      expect(enB.fotoId, isNotNull);

      a.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
      await a.repo.borrarComida(id);
      await _entregar(servidor, a, b);
      expect(await b.comidas(), isEmpty);
      expect((await b.db.select(b.db.comidas).get()).single.bajaEn, isNotNull);
    });

    test(
      'los vasos de A y de B se suman y restar llega al otro móvil',
      () async {
        await a.repo.sumarVaso();
        await b.repo.sumarVaso();
        await _entregar(servidor, a, b);
        await _entregar(servidor, b, a);
        expect(await a.vasos(), hasLength(2));
        expect(await b.vasos(), hasLength(2));

        a.reloj.avanzar(const Duration(minutes: 5));
        expect(await a.repo.restarVaso(), isTrue);
        await _entregar(servidor, a, b);
        expect(await b.vasos(), hasLength(1));
      },
    );

    test('dos cambios de la misma comida: gana el más reciente', () async {
      final id = await a.repo.crearComida(
        DatosComida(momento: MomentoComida.cena, ocurridaEn: _madrid(21, 0)),
      );
      await _entregar(servidor, a, b);
      b.reloj.fijar(instantePrueba.add(const Duration(seconds: 5)));
      await b.repo.editarComida(
        id,
        DatosComida(
          momento: MomentoComida.cena,
          cuanto: CuantoComio.nada,
          ocurridaEn: _madrid(21, 0),
        ),
      );
      a.reloj.fijar(instantePrueba.add(const Duration(seconds: 10)));
      await a.repo.editarComida(
        id,
        DatosComida(
          momento: MomentoComida.cena,
          cuanto: CuantoComio.mitad,
          ocurridaEn: _madrid(21, 0),
        ),
      );
      await _entregar(servidor, a, b);
      await _entregar(servidor, b, a);
      expect((await a.comidas()).single.cuanto, 'mitad');
      expect((await b.comidas()).single.cuanto, 'mitad');
    });

    test('una comida de otra persona o con datos raros se descarta', () async {
      final eventos = a.c.read(eventosRepositorioProvider);
      Future<void> ficha(String id, Map<String, Object?> cambios) =>
          eventos.registrar(
            TipoEvento.fichaCreada,
            sujeto: id,
            payload: {
              'tipo': 'comida',
              'fila': {
                'id': id,
                'persona_id': _persona,
                'momento': 'comida',
                'cuanto': 'todo',
                'foto_id': null,
                'nota': null,
                'ocurrida_en': 1,
                'registrada_por': 'x',
                'baja_en': null,
                ...cambios,
              },
            },
          );
      await ficha('c-otra', {'persona_id': 'otra-persona'});
      await ficha('c-momento', {'momento': 'brunch'});
      await ficha('c-cuanto', {'cuanto': 'muchisimo'});
      await ficha('c-buena', const {});
      await _entregar(servidor, a, b);
      expect((await b.comidas()).map((c) => c.id), ['c-buena']);
    });

    test(
      'un vaso de otra persona o con vasos fuera de rango se descarta',
      () async {
        final eventos = a.c.read(eventosRepositorioProvider);
        Future<void> ficha(String id, Map<String, Object?> cambios) =>
            eventos.registrar(
              TipoEvento.fichaCreada,
              sujeto: id,
              payload: {
                'tipo': 'hidratacion',
                'fila': {
                  'id': id,
                  'persona_id': _persona,
                  'vasos': 1,
                  'ocurrida_en': 1,
                  'registrada_por': 'x',
                  'baja_en': null,
                  ...cambios,
                },
              },
            );
        await ficha('v-otra', {'persona_id': 'otra-persona'});
        await ficha('v-cero', {'vasos': 0});
        await ficha('v-mil', {'vasos': 1000});
        await ficha('v-bien', const {});
        await _entregar(servidor, a, b);
        expect((await b.vasos()).map((v) => v.id), ['v-bien']);
      },
    );

    test('las comidas y los vasos de antes se publican al emparejar', () async {
      final id = await a.repo.crearComida(
        DatosComida(momento: MomentoComida.cena, ocurridaEn: _madrid(21, 0)),
      );
      await a.repo.sumarVaso();
      // Un móvil nuevo que se une después recibe lo que ya había.
      final c = await _crearMovil(servidor, 'movil-c');
      addTearDown(c.cerrar);
      await c.c.read(circuloRepositorioProvider).asegurarBase();
      await _entregar(servidor, a, c);
      expect((await c.comidas()).map((x) => x.id), [id]);
      expect(await c.vasos(), hasLength(1));
    });
  });

  test('migración 6→7: las comidas y los vasos dejan de ser de solo '
      'inserción', () async {
    final dir = await Directory.systemTemp.createTemp('newera_alim_');
    addTearDown(() => dir.delete(recursive: true));
    final archivo = File('${dir.path}/v6.db');

    // Base del esquema 6: sin `baja_en` y con los disparadores de hechos.
    final v6 = AppDatabase(NativeDatabase(archivo));
    await v6
        .into(v6.circulos)
        .insert(
          CirculosCompanion.insert(id: 'c1', nombre: 'Familia', creadoEn: 1),
        );
    await v6
        .into(v6.eventos)
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
    await v6
        .into(v6.personas)
        .insert(
          PersonasCompanion.insert(
            id: 'p1',
            circuloId: 'c1',
            alias: 'Persona',
            creadaEn: 1,
          ),
        );
    await v6
        .into(v6.comidas)
        .insert(
          ComidasCompanion.insert(
            id: 'm1',
            personaId: 'p1',
            momento: 'comida',
            cuanto: 'todo',
            ocurridaEn: 1,
            registradaPor: 'x',
          ),
        );
    await v6.customStatement('DROP TABLE grabaciones_consulta');
    await v6.customStatement('DROP TABLE notas_consulta');
    await v6.customStatement('DROP TABLE preguntas_consulta');
    await v6.customStatement('ALTER TABLE comidas DROP COLUMN baja_en');
    await v6.customStatement('ALTER TABLE hidrataciones DROP COLUMN baja_en');
    for (final t in ['comidas', 'hidrataciones']) {
      await v6.customStatement(
        'CREATE TRIGGER ${t}_no_update BEFORE UPDATE ON $t '
        "BEGIN SELECT RAISE(ABORT, 'solo_insercion'); END",
      );
      await v6.customStatement(
        'CREATE TRIGGER ${t}_no_delete BEFORE DELETE ON $t '
        "BEGIN SELECT RAISE(ABORT, 'solo_insercion'); END",
      );
    }
    await v6.customStatement('PRAGMA user_version = 6');
    await v6.close();

    final v7 = AppDatabase(NativeDatabase(archivo));
    addTearDown(v7.close);
    final version = await v7.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 8);
    expect(v7.schemaVersion, 8);
    // La comida de antes sigue y ahora admite baja lógica.
    final antes = await v7.select(v7.comidas).getSingle();
    expect(antes.bajaEn, isNull);
    await (v7.update(v7.comidas))
        .write(const ComidasCompanion(bajaEn: Value(5)));
    expect((await v7.select(v7.comidas).getSingle()).bajaEn, 5);
    final disparadores = await v7
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'trigger' "
          "AND (tbl_name = 'comidas' OR tbl_name = 'hidrataciones')",
        )
        .get();
    expect(disparadores, isEmpty);
    // Los demás hechos siguen siendo de solo inserción.
    await expectLater(
      v7.customStatement('DELETE FROM eventos'),
      throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
    );
  });

  group('pantalla Hoy', () {
    testWidgets('las cuatro comidas con su estado, el botón y el agua', (
      tester,
    ) async {
      await _abrir(tester);
      expect(find.byKey(ClavesUi.pantallaAlimentacion), findsOneWidget);
      expect(find.text('Alimentación'), findsWidgets);
      // La semilla: desayuno entero a las 09:00 y comida a medias a las 11:30.
      expect(find.text('Desayuno'), findsOneWidget);
      expect(find.text('09:00 · Todo'), findsOneWidget);
      expect(find.text('Comida'), findsOneWidget);
      expect(find.text('11:30 · La mitad · Comida de ejemplo'), findsOneWidget);
      expect(find.text('Merienda'), findsOneWidget);
      expect(find.text('Cena'), findsOneWidget);
      expect(find.text('Sin anotar'), findsNWidgets(2));
      expect(find.byKey(ClavesUi.alimAnotar), findsOneWidget);
      expect(find.text('Anotar comida'), findsOneWidget);
      // Ya no es la plantilla reservada.
      expect(find.text('Lo que tendrá'), findsNothing);
      expect(find.text('Llega en la semana 14'), findsNothing);
      // Agua: tres vasos de ejemplo y objetivo por defecto de 6.
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.alimVasosTexto),
        200,
        scrollable: _lista,
      );
      expect(find.text('3 de 6 vasos'), findsOneWidget);
      expect(find.text('6 vasos'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('anotar una comida desde una fila sin anotar', (tester) async {
      final e = await _abrir(tester);
      await _pulsar(tester, find.byKey(ClavesUi.alimFila('merienda')));
      // El formulario abre con la merienda elegida y la hora de ahora.
      expect(find.text('Anotar comida'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.alimCuanto('mitad')));
      await tester.enterText(find.byKey(ClavesUi.alimNota), 'Fruta');
      await _pulsar(tester, find.byKey(ClavesUi.alimGuardar));

      expect(find.byKey(ClavesUi.pantallaAlimentacion), findsOneWidget);
      expect(find.text('12:00 · La mitad · Fruta'), findsOneWidget);
      expect(find.text('Sin anotar'), findsOneWidget);

      final comidas = await _comidasDe(tester, e);
      final nueva = comidas.firstWhere((c) => c.momento == 'merienda');
      expect(nueva.cuanto, 'mitad');
      expect(nueva.nota, 'Fruta');
      expect(nueva.ocurridaEn, _madrid(12, 0).millisecondsSinceEpoch);
      // La anota el miembro de este móvil.
      final contenedor = ProviderScope.containerOf(
        tester.element(find.byType(NewEraApp)),
      );
      expect(
        nueva.registradaPor,
        contenedor.read(sesionProvider).miembroId ?? e.contexto.personaId,
      );
      expect(nueva.personaId, e.contexto.personaId);
      expect(tester.takeException(), isNull);
    });

    testWidgets('«Anotar comida» abre el formulario en blanco', (tester) async {
      final e = await _abrir(tester);
      await _pulsar(tester, find.byKey(ClavesUi.alimAnotar));
      expect(find.byKey(ClavesUi.alimGuardar), findsOneWidget);
      expect(find.byKey(ClavesUi.alimBorrar), findsNothing);
      await _pulsar(tester, find.byKey(ClavesUi.alimMomento('cena')));
      await _pulsar(tester, find.byKey(ClavesUi.alimCuanto('poco')));
      await _pulsar(tester, find.byKey(ClavesUi.alimGuardar));
      final cena = (await _comidasDe(
        tester,
        e,
      )).firstWhere((c) => c.momento == 'cena');
      expect(cena.cuanto, 'poco');
      expect(find.text('12:00 · Poco'), findsOneWidget);
    });

    testWidgets('editar una comida anotada', (tester) async {
      final e = await _abrir(tester);
      final previa = (await _comidasDe(
        tester,
        e,
      )).firstWhere((c) => c.momento == 'desayuno');
      await _pulsar(tester, find.byKey(ClavesUi.alimComida(previa.id)));
      expect(find.text('Editar comida'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.alimBorrar),
        200,
        scrollable: _lista,
      );
      expect(find.byKey(ClavesUi.alimBorrar), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.alimCuanto('poco')));
      await tester.enterText(find.byKey(ClavesUi.alimNota), 'Solo el café');
      await _pulsar(tester, find.byKey(ClavesUi.alimGuardar));

      expect(find.text('09:00 · Poco · Solo el café'), findsOneWidget);
      final despues = (await _comidasDe(
        tester,
        e,
      )).firstWhere((c) => c.id == previa.id);
      expect(despues.cuanto, 'poco');
      expect(despues.nota, 'Solo el café');
      // La hora y quién la anotó no cambian.
      expect(despues.ocurridaEn, previa.ocurridaEn);
      expect(despues.registradaPor, previa.registradaPor);
    });

    testWidgets('borrar una comida pide confirmar y deja la fila sin anotar', (
      tester,
    ) async {
      final e = await _abrir(tester);
      final previa = (await _comidasDe(
        tester,
        e,
      )).firstWhere((c) => c.momento == 'desayuno');
      await _pulsar(tester, find.byKey(ClavesUi.alimComida(previa.id)));
      await _pulsar(tester, find.byKey(ClavesUi.alimBorrar));
      expect(find.text('¿Borrar esta comida?'), findsOneWidget);
      // Cancelar no borra.
      await _pulsar(tester, find.text('Cancelar'));
      expect(find.byKey(ClavesUi.alimBorrar), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.alimBorrar));
      await _pulsar(tester, find.byKey(ClavesUi.alimBorrarConfirmar));

      expect(find.byKey(ClavesUi.pantallaAlimentacion), findsOneWidget);
      expect(find.byKey(ClavesUi.alimFila('desayuno')), findsOneWidget);
      expect(find.text('Sin anotar'), findsNWidgets(3));
      final fila = (await _comidasDe(
        tester,
        e,
      )).firstWhere((c) => c.id == previa.id);
      expect(fila.bajaEn, isNotNull);
    });

    testWidgets('con foto: se elige, se guarda y se ve en la fila', (
      tester,
    ) async {
      final foto = FotoNueva(
        PngMarcador.pastilla(forma: 'redonda', color: 0xFFE0B040),
        mime: 'image/png',
      );
      final e = await _abrir(
        tester,
        extra: [selectorFotoProvider.overrideWithValue((_) async => foto)],
      );
      await _pulsar(tester, find.byKey(ClavesUi.alimFila('cena')));
      expect(find.byKey(ClavesUi.alimFotoQuitar), findsNothing);
      await _pulsar(tester, find.byKey(ClavesUi.alimFotoElegir));
      expect(find.byKey(ClavesUi.alimFotoQuitar), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.alimGuardar));

      final cena = (await _comidasDe(
        tester,
        e,
      )).firstWhere((c) => c.momento == 'cena');
      expect(cena.fotoId, isNotNull);
      final fotos = await tester.runAsync(() => e.db.select(e.db.fotos).get());
      expect(fotos!.map((f) => f.id), contains(cena.fotoId));
      expect(find.bySemanticsLabel('Foto de la comida'), findsWidgets);

      // Quitar la foto al editar la deja sin ella.
      await _pulsar(tester, find.byKey(ClavesUi.alimComida(cena.id)));
      await _pulsar(tester, find.byKey(ClavesUi.alimFotoQuitar));
      await _pulsar(tester, find.byKey(ClavesUi.alimGuardar));
      final sin = (await _comidasDe(
        tester,
        e,
      )).firstWhere((c) => c.id == cena.id);
      expect(sin.fotoId, isNull);
    });

    testWidgets('vasos: más y menos, sin pasar de cero', (tester) async {
      final e = await _abrir(tester);
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.alimVasoMas),
        200,
        scrollable: _lista,
      );
      expect(find.text('3 de 6 vasos'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.alimVasoMas));
      expect(find.text('4 de 6 vasos'), findsOneWidget);
      for (var i = 0; i < 4; i++) {
        await _pulsar(tester, find.byKey(ClavesUi.alimVasoMenos));
      }
      expect(find.text('0 de 6 vasos'), findsOneWidget);
      final menos = tester.widget<IconButton>(
        find.byKey(ClavesUi.alimVasoMenos),
      );
      expect(menos.onPressed, isNull);
      // Restar da de baja; nada se borra de la tabla.
      final filas = await _vasosDe(tester, e);
      expect(filas, hasLength(4));
      expect(filas.where((v) => v.bajaEn == null), isEmpty);
      await _pulsar(tester, find.byKey(ClavesUi.alimVasoMas));
      expect(find.text('1 de 6 vasos'), findsOneWidget);
    });

    testWidgets('el objetivo diario se ajusta y se recuerda', (tester) async {
      final e = await _abrir(tester);
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.alimObjetivoMas),
        200,
        scrollable: _lista,
      );
      await _pulsar(tester, find.byKey(ClavesUi.alimObjetivoMas));
      expect(find.text('7 vasos'), findsOneWidget);
      expect(find.text('3 de 7 vasos'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.alimObjetivoMenos));
      await _pulsar(tester, find.byKey(ClavesUi.alimObjetivoMenos));
      expect(find.text('5 vasos'), findsOneWidget);
      expect(find.text('3 de 5 vasos'), findsOneWidget);
      expect(
        await tester.runAsync(
          () => e.almacen.leer(ClavesAlmacen.objetivoVasos),
        ),
        '5',
      );
      // Mínimo 1: el botón de bajar se apaga.
      for (var i = 0; i < 4; i++) {
        await _pulsar(tester, find.byKey(ClavesUi.alimObjetivoMenos));
      }
      expect(find.text('1 vasos'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(ClavesUi.alimObjetivoMenos))
            .onPressed,
        isNull,
      );
    });

    testWidgets('el objetivo guardado se lee al abrir', (tester) async {
      await _abrir(
        tester,
        previo: (e) => e.almacen.escribir(ClavesAlmacen.objetivoVasos, '8'),
      );
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.alimVasosTexto),
        200,
        scrollable: _lista,
      );
      expect(find.text('3 de 8 vasos'), findsOneWidget);
    });
  });

  group('pantalla Semana', () {
    testWidgets('siete días con comidas de 4 y vasos', (tester) async {
      await _abrir(tester);
      await _pulsar(tester, find.byKey(ClavesUi.alimVista('semana')));
      expect(find.byKey(ClavesUi.alimDia('2026-10-13')), findsOneWidget);
      expect(find.text('Martes 13 de octubre'), findsOneWidget);
      expect(find.text('Comidas 2 de 4 · Vasos 3'), findsOneWidget);
      expect(find.text('2/4'), findsOneWidget);
      expect(find.text('Comidas 0 de 4 · Vasos 0'), findsNWidgets(6));
      expect(find.text('0/4'), findsNWidgets(6));
      // Siete días: hoy y los seis anteriores.
      for (final f in [
        '2026-10-12',
        '2026-10-11',
        '2026-10-10',
        '2026-10-09',
        '2026-10-08',
        '2026-10-07',
      ]) {
        expect(find.byKey(ClavesUi.alimDia(f)), findsOneWidget, reason: f);
      }
      expect(find.byKey(ClavesUi.alimDia('2026-10-06')), findsNothing);
      // Las celdas se leen sin depender del color.
      expect(find.bySemanticsLabel(RegExp('Comidas: 2 de 4')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Vasos: 3')), findsOneWidget);
      // Volver a Hoy.
      await _pulsar(tester, find.byKey(ClavesUi.alimVista('hoy')));
      expect(find.byKey(ClavesUi.alimAnotar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un día completo y el objetivo cumplido salen en verde', (
      tester,
    ) async {
      await _abrir(
        tester,
        previo: (e) async {
          final repo = e.db;
          for (final (i, m) in [
            'desayuno',
            'comida',
            'merienda',
            'cena',
          ].indexed) {
            await repo
                .into(repo.comidas)
                .insert(
                  ComidasCompanion.insert(
                    id: 'ayer-$i',
                    personaId: e.contexto.personaId,
                    momento: m,
                    cuanto: 'todo',
                    ocurridaEn: _madrid(
                      9 + i * 4,
                      0,
                      dia: 12,
                    ).millisecondsSinceEpoch,
                    registradaPor: 'x',
                  ),
                );
          }
        },
      );
      await _pulsar(tester, find.byKey(ClavesUi.alimVista('semana')));
      expect(find.text('Comidas 4 de 4 · Vasos 0'), findsOneWidget);
      expect(find.text('4/4'), findsOneWidget);
      expect(find.text('Comidas 2 de 4 · Vasos 3'), findsOneWidget);
    });
  });

  group('Resumen', () {
    testWidgets('«Comidas de hoy: N de 4 · Vasos: N» lleva a Alimentación', (
      tester,
    ) async {
      await _abrir(tester, ruta: '/familia/resumen');
      expect(find.byKey(ClavesUi.pantallaResumen), findsOneWidget);
      final fila = find.byKey(ClavesUi.resumenAlimentacion);
      await tester.scrollUntilVisible(fila, 200, scrollable: _lista);
      expect(find.text('Comidas de hoy: 2 de 4 · Vasos: 3'), findsOneWidget);
      await _pulsar(tester, fila);
      expect(find.byKey(ClavesUi.pantallaAlimentacion), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('la fila sigue lo que se anota', (tester) async {
      await _abrir(
        tester,
        ruta: '/familia/resumen',
        previo: (e) async {
          final c = ProviderContainer(overrides: e.overrides);
          final repo = c.read(alimentacionRepositorioProvider);
          await repo.sumarVaso();
          await repo.sumarVaso();
          c.dispose();
        },
      );
      final fila = find.byKey(ClavesUi.resumenAlimentacion);
      await tester.scrollUntilVisible(fila, 200, scrollable: _lista);
      expect(find.text('Comidas de hoy: 2 de 4 · Vasos: 5'), findsOneWidget);
    });
  });

  group('accesibilidad', () {
    for (final oscuro in [false, true]) {
      final modo = oscuro ? 'oscuro' : 'claro';
      for (final caso in [
        ('Hoy', '/familia/alimentacion', null),
        ('Semana', '/familia/alimentacion', ClavesUi.alimVista('semana')),
        (
          'Anotar comida',
          '/familia/alimentacion/comida/nueva?momento=cena',
          null,
        ),
      ]) {
        testWidgets('${caso.$1} en $modo: contraste, toques y etiquetas', (
          tester,
        ) async {
          final manejador = tester.ensureSemantics();
          await _abrir(
            tester,
            ruta: caso.$2,
            brillo: oscuro ? Brightness.dark : Brightness.light,
          );
          final vista = caso.$3;
          if (vista != null) await _pulsar(tester, find.byKey(vista));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(tester.takeException(), isNull);
          manejador.dispose();
        });
      }

      testWidgets('Editar comida en $modo: contraste, toques y etiquetas', (
        tester,
      ) async {
        final manejador = tester.ensureSemantics();
        final e = await _abrir(
          tester,
          brillo: oscuro ? Brightness.dark : Brightness.light,
        );
        final previa = (await _comidasDe(tester, e)).first;
        await _pulsar(tester, find.byKey(ClavesUi.alimComida(previa.id)));
        expect(find.text('Editar comida'), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        manejador.dispose();
      });
    }

    testWidgets('con el texto al 200 % no se rompe', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await _abrir(tester);
      expect(tester.takeException(), isNull);
      await _pulsar(tester, find.byKey(ClavesUi.alimVista('semana')));
      expect(tester.takeException(), isNull);
    });
  });
}
