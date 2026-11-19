import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/agenda_repositorio.dart';
import 'package:newera/core/db/repositorios/consultas_repositorio.dart';
import 'package:newera/core/plataforma/audio/archivos_voz.dart';
import 'package:newera/core/plataforma/audio/audio_simulado.dart';
import 'package:newera/core/plataforma/audio/grabadora.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/features/consultas/dominio/consultas.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

final _clave = ClaveCirculo.generar(Random(33));
const _circulo = 'circulo-consultas';
const _persona = 'persona-consultas';
const _zona = 'Europe/Madrid';

Cita _cita(
  String id,
  String fecha,
  String hora, {
  String tipo = 'medico',
  int? baja,
}) => Cita(
  id: id,
  circuloId: _circulo,
  titulo: 'Cita $id',
  tipo: tipo,
  fecha: fecha,
  hora: hora,
  creadaPor: 'x',
  creadaEn: 1,
  modificadaPor: 'x',
  modificadaEn: 1,
  bajaEn: baja,
);

// ------------------------------------------------------------ Dos móviles

class _Movil {
  _Movil(this.c, this.servicio, this.reloj);

  final ProviderContainer c;
  final ServicioSync servicio;
  final RelojFijo reloj;

  AppDatabase get db => c.read(baseDatosProvider);
  ConsultasRepositorio get repo => c.read(consultasRepositorioProvider);
  AgendaRepositorio get agenda => c.read(agendaRepositorioProvider);

  Future<List<PreguntaConsulta>> preguntas(String cita) =>
      repo.observarPreguntas(cita).first;
  Future<List<NotaConsulta>> notas(String cita) =>
      repo.observarNotas(cita).first;
  Future<GrabacionConsulta?> marca(String cita) =>
      repo.observarGrabacion(cita).first;

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

/// Monta la familia en [ruta]; `@cita` es la cita de ejemplo de la semilla
/// (mañana a las 10:30; hoy es el martes 13 de octubre, 12:00 en Madrid).
Future<EntornoPrueba> _abrir(
  WidgetTester tester, {
  String ruta = '/familia/consultas/@cita',
  Brightness brillo = Brightness.light,
  Future<void> Function(EntornoPrueba e, String citaId)? previo,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  late String id;
  final entorno = await tester.runAsync(() async {
    final e = await prepararEntorno(perfil: PerfilApp.familia);
    id = (await e.db.select(e.db.citas).getSingle()).id;
    if (previo != null) await previo(e, id);
    return e;
  });
  await montarApp(tester, entorno!, rutaInicial: ruta.replaceAll('@cita', id));
  await pasar(tester, const Duration(seconds: 1));
  return entorno;
}

/// La cita de ejemplo de la semilla.
Future<String> _citaDe(WidgetTester tester, EntornoPrueba e) => tester
    .runAsync(() async {
      final citas = await e.db.select(e.db.citas).get();
      return citas.firstWhere((c) => c.titulo == 'Revisión (ejemplo)').id;
    })
    .then((id) => id!);

/// Deja correr la base de verdad (las cifras se calculan al abrir la ficha,
/// con varias lecturas seguidas) alternando el reloj real y el falso.
Future<void> _calcular(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await pasar(tester, const Duration(milliseconds: 100));
  }
}

/// El desplazable de la pantalla de más arriba.
Finder get _lista => find
    .descendant(
      of: find.byType(ListView).last,
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _ver(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 200, scrollable: _lista);
  }
  await Scrollable.ensureVisible(f.evaluate().first, alignment: 0.5);
  await pasar(tester, const Duration(milliseconds: 300));
}

Future<void> _pulsar(WidgetTester tester, Finder f) async {
  await _ver(tester, f);
  await tester.tap(f);
  // Deja correr la base de verdad (guardar, borrar) y luego el reloj falso.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await pasar(tester, const Duration(milliseconds: 700));
}

Future<void> _escribir(WidgetTester tester, Finder f, String texto) async {
  await _ver(tester, f);
  await tester.enterText(f, texto);
  await tester.pump();
}

/// El valor (a la derecha) de la cifra [nombre] del bloque «Desde la última».
String _cifra(WidgetTester tester, String nombre) {
  final fila = find.byKey(ClavesUi.consCifra(nombre));
  expect(fila, findsOneWidget, reason: nombre);
  return tester
      .widgetList<Text>(find.descendant(of: fila, matching: find.byType(Text)))
      .map((t) => t.data!)
      .last;
}

Future<T> _db<T>(WidgetTester tester, Future<T> Function() f) =>
    tester.runAsync(f).then((x) => x as T);

void main() {
  group('dominio', () {
    test('repartir: próximas por orden, pasadas de la más reciente atrás', () {
      final r = repartirCitas(
        [
          _cita('a', '2026-10-20', '09:00'),
          _cita('b', '2026-10-13', '12:00'),
          _cita('c', '2026-10-13', '11:59'),
          _cita('d', '2026-10-01', '10:00'),
          _cita('e', '2026-10-05', '10:00'),
          _cita('f', '2026-10-14', '08:00'),
          _cita('g', '2026-10-30', '08:00', baja: 5),
        ],
        fechaHoy: '2026-10-13',
        horaAhora: '12:00',
      );
      // La que empieza ahora aún es próxima; la borrada no sale.
      expect(r.proximas.map((c) => c.id), ['b', 'f', 'a']);
      expect(r.pasadas.map((c) => c.id), ['c', 'e', 'd']);
    });

    test('la cita anterior es la última del mismo tipo que empezó antes', () {
      final citas = [
        _cita('vieja', '2026-08-01', '10:00'),
        _cita('anterior', '2026-09-10', '10:00'),
        _cita('analisis', '2026-09-20', '10:00', tipo: 'analisis'),
        _cita('borrada', '2026-09-25', '10:00', baja: 9),
        _cita('esta', '2026-10-14', '10:30'),
        _cita('despues', '2026-11-01', '10:00'),
      ];
      expect(citaAnterior(citas, citas[4])!.id, 'anterior');
      expect(citaAnterior(citas, citas.first), isNull);
    });

    test('el instante de una cita es su hora de pared en la zona', () {
      expect(
        instanteDeCita(_cita('x', '2026-10-14', '10:30'), _zona),
        DateTime.utc(2026, 10, 14, 8, 30),
      );
    });

    test('una ventana vacía da todo a cero', () {
      final d = calcularDesdeUltima(
        inicio: DateTime.utc(2026, 10, 13),
        fin: DateTime.utc(2026, 10, 13),
        porCitaAnterior: false,
        ahora: DateTime.utc(2026, 10, 13, 10),
        zona: _zona,
        pautas: const [],
        medicamentos: const [],
        eventosToma: const [],
        ajustes: AjustesControl.porDefecto,
        respuestas: const [],
        primerMovil: null,
        comidas: const [],
      );
      expect(d.tomasPrevistas, 0);
      expect(d.rondasContestadas, 0);
      expect(d.comidasAnotadas, 0);
    });

    test('las comidas cuentan dentro de la ventana y sin las borradas', () {
      Comida comida(String id, DateTime t, {int? baja}) => Comida(
        id: id,
        personaId: _persona,
        momento: 'comida',
        cuanto: 'todo',
        ocurridaEn: t.millisecondsSinceEpoch,
        registradaPor: 'x',
        bajaEn: baja,
      );
      final d = calcularDesdeUltima(
        inicio: DateTime.utc(2026, 10, 10, 8),
        fin: DateTime.utc(2026, 10, 13, 8),
        porCitaAnterior: true,
        ahora: DateTime.utc(2026, 10, 13, 10),
        zona: _zona,
        pautas: const [],
        medicamentos: const [],
        eventosToma: const [],
        ajustes: AjustesControl.porDefecto,
        respuestas: const [],
        primerMovil: null,
        comidas: [
          comida('antes', DateTime.utc(2026, 10, 10, 7, 59)),
          comida('justo', DateTime.utc(2026, 10, 10, 8)),
          comida('dentro', DateTime.utc(2026, 10, 12, 12)),
          comida('borrada', DateTime.utc(2026, 10, 12, 13), baja: 5),
          comida('fin', DateTime.utc(2026, 10, 13, 8)),
        ],
      );
      expect(d.comidasAnotadas, 2);
    });
  });

  group('repositorio y cartero', () {
    late ServidorMemoria servidor;
    late _Movil a;
    late _Movil b;
    late String cita;

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      servidor = ServidorMemoria();
      a = await _crearMovil(servidor, 'movil-a');
      b = await _crearMovil(servidor, 'movil-b');
      await a.c.read(circuloRepositorioProvider).asegurarBase();
      await b.c.read(circuloRepositorioProvider).asegurarBase();
      await _entregar(servidor, a, b);
      cita = await a.agenda.crearCita(
        const DatosCita(titulo: 'Revisión', fecha: '2026-10-14', hora: '10:30'),
      );
      await _entregar(servidor, a, b);
    });

    tearDown(() async {
      await a.cerrar();
      await b.cerrar();
    });

    test('crear, editar, marcar y borrar una pregunta', () async {
      final id = await a.repo.crearPregunta(cita, '  ¿Más dosis?  ');
      var p = (await a.preguntas(cita)).single;
      expect(p.id, id);
      expect(p.texto, '¿Más dosis?');
      expect(p.preguntada, isFalse);
      expect(p.citaId, cita);
      expect(p.creadaPor, _persona);

      a.reloj.avanzar(const Duration(minutes: 1));
      await a.repo.editarPregunta(id, '¿Menos dosis?');
      expect((await a.preguntas(cita)).single.texto, '¿Menos dosis?');

      await a.repo.marcarPreguntada(id, true);
      expect((await a.preguntas(cita)).single.preguntada, isTrue);
      await a.repo.marcarPreguntada(id, false);
      expect((await a.preguntas(cita)).single.preguntada, isFalse);

      a.reloj.avanzar(const Duration(minutes: 1));
      await a.repo.borrarPregunta(id);
      expect(await a.preguntas(cita), isEmpty);
      p = (await a.db.select(a.db.preguntasConsulta).get()).single;
      expect(p.bajaEn, isNotNull);
      // Una pregunta borrada ya no se edita ni se marca.
      await a.repo.editarPregunta(id, 'otra');
      await a.repo.marcarPreguntada(id, true);
      p = (await a.db.select(a.db.preguntasConsulta).get()).single;
      expect(p.texto, '¿Menos dosis?');
      expect(p.preguntada, isFalse);
    });

    test(
      'una pregunta vacía, larga o de una cita que no existe falla',
      () async {
        await expectLater(
          a.repo.crearPregunta(cita, '   '),
          throwsArgumentError,
        );
        await expectLater(
          a.repo.crearPregunta(
            cita,
            'x' * (ConsultasRepositorio.maxPregunta + 1),
          ),
          throwsArgumentError,
        );
        await expectLater(
          a.repo.crearPregunta('no-existe', 'hola'),
          throwsArgumentError,
        );
        await a.agenda.borrarCita(cita);
        await expectLater(a.repo.crearNota(cita, 'hola'), throwsArgumentError);
        expect(await a.db.select(a.db.preguntasConsulta).get(), isEmpty);
      },
    );

    test('crear, editar y borrar una nota con su autor y su hora', () async {
      final id = await a.repo.crearNota(cita, 'Subir la dosis');
      var n = (await a.notas(cita)).single;
      expect(n.texto, 'Subir la dosis');
      expect(n.creadaPor, _persona);
      expect(n.creadaEn, instantePrueba.millisecondsSinceEpoch);

      a.reloj.avanzar(const Duration(minutes: 2));
      await a.repo.editarNota(id, 'Mantener la dosis');
      n = (await a.notas(cita)).single;
      expect(n.texto, 'Mantener la dosis');
      expect(n.modificadaEn, greaterThan(n.creadaEn));
      expect(n.creadaEn, instantePrueba.millisecondsSinceEpoch);

      await a.repo.borrarNota(id);
      expect(await a.notas(cita), isEmpty);
      expect(await a.db.select(a.db.notasConsulta).get(), hasLength(1));
    });

    test(
      'la marca de grabación: una por cita, quitar y volver a grabar',
      () async {
        expect(await a.marca(cita), isNull);
        await a.repo.marcarGrabacion(cita, 125);
        var m = (await a.marca(cita))!;
        expect(m.id, cita);
        expect(m.segundos, 125);
        expect(m.grabadaPor, _persona);
        // Con una vigente no se graba otra encima.
        await expectLater(
          a.repo.marcarGrabacion(cita, 5),
          throwsA(isA<StateError>()),
        );
        await expectLater(
          a.repo.marcarGrabacion(cita, FormatoConsulta.segundosMaximos + 1),
          throwsArgumentError,
        );

        a.reloj.avanzar(const Duration(minutes: 1));
        await a.repo.quitarGrabacion(cita);
        expect(await a.marca(cita), isNull);
        expect(await a.db.select(a.db.grabacionesConsulta).get(), hasLength(1));

        a.reloj.avanzar(const Duration(minutes: 1));
        await a.repo.marcarGrabacion(cita, 60);
        m = (await a.marca(cita))!;
        expect(m.segundos, 60);
        expect(m.bajaEn, isNull);
      },
    );

    test('preguntas y notas de A llegan a B con su autor', () async {
      final p = await a.repo.crearPregunta(cita, '¿Cada cuánto vuelvo?');
      final n = await a.repo.crearNota(cita, 'Volver en tres meses');
      await a.repo.marcarPreguntada(p, true);
      await _entregar(servidor, a, b);
      final pb = (await b.preguntas(cita)).single;
      expect(pb.id, p);
      expect(pb.texto, '¿Cada cuánto vuelvo?');
      expect(pb.preguntada, isTrue);
      expect(pb.creadaPor, _persona);
      final nb = (await b.notas(cita)).single;
      expect(nb.id, n);
      expect(nb.texto, 'Volver en tres meses');
      expect(nb.creadaEn, instantePrueba.millisecondsSinceEpoch);
    });

    test(
      'gana el cambio más reciente, llegue en el orden que llegue',
      () async {
        final id = await a.repo.crearPregunta(cita, 'Primera');
        await _entregar(servidor, a, b);
        a.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
        await a.repo.editarPregunta(id, 'Del móvil A');
        b.reloj.fijar(instantePrueba.add(const Duration(minutes: 5)));
        await b.repo.editarPregunta(id, 'Del móvil B');
        await _entregar(servidor, a, b, alReves: true);
        await _entregar(servidor, b, a, alReves: true);
        expect((await a.preguntas(cita)).single.texto, 'Del móvil B');
        expect((await b.preguntas(cita)).single.texto, 'Del móvil B');
      },
    );

    test(
      'borrar en B la pregunta de A la quita también en A (baja lógica)',
      () async {
        final id = await a.repo.crearPregunta(cita, 'Se borrará');
        await _entregar(servidor, a, b);
        b.reloj.fijar(instantePrueba.add(const Duration(minutes: 3)));
        await b.repo.borrarPregunta(id);
        await _entregar(servidor, b, a);
        expect(await a.preguntas(cita), isEmpty);
        expect(
          (await a.db.select(a.db.preguntasConsulta).get()).single.bajaEn,
          isNotNull,
        );
      },
    );

    test(
      'una pregunta que llega antes que su cita espera a que llegue',
      () async {
        final nueva = await a.agenda.crearCita(
          const DatosCita(titulo: 'Otra', fecha: '2026-11-02', hora: '09:00'),
        );
        await a.repo.crearPregunta(nueva, '¿Qué análisis hacen falta?');
        await _entregar(servidor, a, b, alReves: true);
        expect((await b.preguntas(nueva)).map((p) => p.texto), [
          '¿Qué análisis hacen falta?',
        ]);
      },
    );

    test(
      'la marca viaja, el audio no: en el sobre solo hay la marca',
      () async {
        // El audio está solo en A (en la memoria de su carpeta de consultas).
        final archivos = ArchivosVozMemoria();
        await archivos.escribir(
          RutasVoz.consulta(cita),
          GrabadoraSimulada.relleno(4096),
        );
        await a.repo.marcarGrabacion(cita, 900);
        await _entregar(servidor, a, b);
        final enB = (await b.marca(cita))!;
        expect(enB.segundos, 900);
        expect(enB.grabadaPor, _persona);

        final eventos = await (a.db.select(
          a.db.eventos,
        )..where((e) => e.sujeto.equals(cita))).get();
        final ficha = eventos.firstWhere(
          (e) => e.payload.contains('grabacion_consulta'),
        );
        final payload = jsonDecode(ficha.payload) as Map<String, dynamic>;
        expect(payload.containsKey('audio'), isFalse);
        expect((payload['fila'] as Map<String, dynamic>).keys.toSet(), {
          'id',
          'grabada_por',
          'grabada_en',
          'segundos',
          'baja_en',
        });
        expect(ficha.payload.length, lessThan(1000));
        // En B no hay ningún audio: lo que hay es solo la marca.
        expect(await archivos.existe(RutasVoz.consulta(cita)), isTrue);
      },
    );

    test('quitar la marca en A la quita en B', () async {
      await a.repo.marcarGrabacion(cita, 30);
      await _entregar(servidor, a, b);
      expect(await b.marca(cita), isNotNull);
      a.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
      await a.repo.quitarGrabacion(cita);
      await _entregar(servidor, a, b);
      expect(await b.marca(cita), isNull);
    });

    test(
      'las fichas de consultas anteriores al emparejamiento se publican',
      () async {
        final c = await _crearMovil(servidor, 'movil-c');
        addTearDown(c.cerrar);
        await c.c.read(circuloRepositorioProvider).asegurarBase();
        final id = await c.agenda.crearCita(
          const DatosCita(titulo: 'Sola', fecha: '2026-12-01', hora: '11:00'),
        );
        await c.repo.crearPregunta(id, 'Pregunta');
        await c.repo.crearNota(id, 'Nota');
        await c.repo.marcarGrabacion(id, 10);
        // Sin publicar nada nuevo: ya están todas las fichas.
        final servidor2 = servidor.sobres.length;
        await c.servicio.empujar();
        expect(servidor.sobres.length, greaterThan(servidor2));
      },
    );
  });

  test('migra del esquema 7 al 8 con las tablas de consultas', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('newera_migracion8_');
    addTearDown(() => dir.delete(recursive: true));
    final archivo = File('${dir.path}/v7.db');
    final v8 = AppDatabase(NativeDatabase(archivo));
    await v8.customSelect('PRAGMA user_version').getSingle();
    await v8.customStatement('DROP TABLE ajustes_ubicacion');
    await v8.customStatement('DROP TABLE grabaciones_consulta');
    await v8.customStatement('DROP TABLE notas_consulta');
    await v8.customStatement('DROP TABLE preguntas_consulta');
    await v8.customStatement('PRAGMA user_version = 7');
    await v8.close();

    final nueva = AppDatabase(NativeDatabase(archivo));
    addTearDown(nueva.close);
    final version = await nueva.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 9);
    expect(await nueva.select(nueva.preguntasConsulta).get(), isEmpty);
    expect(await nueva.select(nueva.notasConsulta).get(), isEmpty);
    expect(await nueva.select(nueva.grabacionesConsulta).get(), isEmpty);
  });

  group('lista de consultas', () {
    testWidgets('próximas arriba y pasadas abajo, con su cuenta de preguntas', (
      tester,
    ) async {
      final e = await _abrir(
        tester,
        ruta: '/familia/consultas',
        previo: (e, id) async {
          final agenda = _agendaDe(e);
          await agenda.crearCita(
            const DatosCita(
              titulo: 'Analítica anterior',
              fecha: '2026-10-01',
              hora: '09:00',
              tipo: TipoCita.analisis,
            ),
          );
          await _consultasDe(e).crearPregunta(id, 'Tercera pregunta');
        },
      );
      final id = await _citaDe(tester, e);
      expect(find.text('Consultas'), findsWidgets);
      expect(find.text('PRÓXIMAS'), findsOneWidget);
      expect(find.text('PASADAS'), findsOneWidget);
      expect(find.text('Nueva cita'), findsOneWidget);
      final proxima = find.byKey(ClavesUi.consFila(id));
      expect(proxima, findsOneWidget);
      // 2 de la semilla + 1 más, sin preguntar.
      expect(find.textContaining('3 preguntas'), findsOneWidget);
      final pasada = find.text('Analítica anterior');
      expect(pasada, findsOneWidget);
      expect(
        tester.getTopLeft(proxima).dy,
        lessThan(tester.getTopLeft(pasada).dy),
      );
    });

    testWidgets('«Nueva cita» abre el formulario de cita y vuelve a la lista', (
      tester,
    ) async {
      await _abrir(tester, ruta: '/familia/consultas');
      await _pulsar(tester, find.byKey(ClavesUi.consNuevaCita));
      expect(find.byKey(ClavesUi.agTitulo), findsOneWidget);
      await tester.enterText(find.byKey(ClavesUi.agTitulo), 'Neurología');
      await _pulsar(tester, find.byKey(ClavesUi.agGuardar));
      expect(find.byKey(ClavesUi.pantallaConsultas), findsOneWidget);
      expect(find.text('Neurología'), findsOneWidget);
    });

    testWidgets('tocar una cita abre su ficha', (tester) async {
      final e = await _abrir(tester, ruta: '/familia/consultas');
      final id = await _citaDe(tester, e);
      await _pulsar(tester, find.byKey(ClavesUi.consFila(id)));
      expect(find.byKey(ClavesUi.pantallaFichaConsulta), findsOneWidget);
      expect(find.text('Revisión (ejemplo)'), findsWidgets);
    });

    testWidgets('sin citas, lo dice', (tester) async {
      await _abrir(
        tester,
        ruta: '/familia/consultas',
        previo: (e, id) => _agendaDe(e).borrarCita(id),
      );
      expect(
        find.text('Aún no hay citas. Crea una para preparar la consulta.'),
        findsOneWidget,
      );
      expect(find.text('PRÓXIMAS'), findsNothing);
    });

    testWidgets('la plantilla reservada ya no está', (tester) async {
      await _abrir(tester, ruta: '/familia/consultas');
      expect(find.text('Lo que tendrá'), findsNothing);
      expect(find.textContaining('Llega en la semana'), findsNothing);
    });
  });

  group('ficha: preguntas', () {
    testWidgets('las de la semilla salen con quién las apuntó', (tester) async {
      await _abrir(tester);
      expect(find.text('PREGUNTAS PARA LLEVAR'), findsOneWidget);
      expect(
        find.text('¿Hay que cambiar algo de la medicación? (ejemplo)'),
        findsOneWidget,
      );
      expect(
        find.text('¿Cada cuánto conviene volver a revisión? (ejemplo)'),
        findsOneWidget,
      );
      expect(find.textContaining('Apuntada por'), findsNWidgets(2));
    });

    testWidgets('crear, marcar, editar y borrar una pregunta', (tester) async {
      final e = await _abrir(tester);
      final id = await _citaDe(tester, e);
      await _escribir(
        tester,
        find.byKey(ClavesUi.consPreguntaCampo),
        '  ¿Puede conducir?  ',
      );
      await _pulsar(tester, find.byKey(ClavesUi.consPreguntaAnadir));
      var filas = await _db(
        tester,
        () => e.db.select(e.db.preguntasConsulta).get(),
      );
      expect(filas, hasLength(3));
      final nueva = filas.firstWhere((p) => p.texto == '¿Puede conducir?');
      expect(nueva.citaId, id);
      expect(find.text('¿Puede conducir?'), findsOneWidget);
      // El campo queda vacío.
      expect(
        tester
            .widget<TextField>(find.byKey(ClavesUi.consPreguntaCampo))
            .controller!
            .text,
        isEmpty,
      );

      // Marcar como preguntada: sale «Preguntada» y se guarda.
      await _pulsar(tester, find.byKey(ClavesUi.consPreguntaMarca(nueva.id)));
      expect(find.textContaining('Preguntada · '), findsOneWidget);
      filas = await _db(
        tester,
        () => e.db.select(e.db.preguntasConsulta).get(),
      );
      expect(filas.firstWhere((p) => p.id == nueva.id).preguntada, isTrue);
      // Y se desmarca.
      await _pulsar(tester, find.byKey(ClavesUi.consPreguntaMarca(nueva.id)));
      expect(find.textContaining('Preguntada · '), findsNothing);

      // Editar.
      await _pulsar(tester, find.byKey(ClavesUi.consPreguntaEditar(nueva.id)));
      await tester.enterText(
        find.byKey(ClavesUi.consDialogoCampo),
        '¿Puede conducir ahora?',
      );
      await _pulsar(tester, find.byKey(ClavesUi.consDialogoGuardar));
      expect(find.text('¿Puede conducir ahora?'), findsOneWidget);
      expect(find.text('¿Puede conducir?'), findsNothing);

      // Borrar, con confirmación.
      await _pulsar(tester, find.byKey(ClavesUi.consPreguntaBorrar(nueva.id)));
      expect(find.text('¿Borrar esta pregunta?'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.consBorrarConfirmar));
      expect(find.text('¿Puede conducir ahora?'), findsNothing);
      filas = await _db(
        tester,
        () => e.db.select(e.db.preguntasConsulta).get(),
      );
      expect(filas.firstWhere((p) => p.id == nueva.id).bajaEn, isNotNull);
    });

    testWidgets('cancelar el borrado no borra', (tester) async {
      final e = await _abrir(tester);
      final p = (await _db(
        tester,
        () => e.db.select(e.db.preguntasConsulta).get(),
      )).first;
      await _pulsar(tester, find.byKey(ClavesUi.consPreguntaBorrar(p.id)));
      await _pulsar(tester, find.text('Cancelar'));
      expect(find.text(p.texto), findsOneWidget);
    });

    testWidgets('una pregunta en blanco no se añade', (tester) async {
      final e = await _abrir(tester);
      await _escribir(tester, find.byKey(ClavesUi.consPreguntaCampo), '   ');
      await _pulsar(tester, find.byKey(ClavesUi.consPreguntaAnadir));
      expect(
        await _db(tester, () => e.db.select(e.db.preguntasConsulta).get()),
        hasLength(2),
      );
    });

    testWidgets('una cita que no existe lo dice', (tester) async {
      await _abrir(tester, ruta: '/familia/consultas/no-existe');
      expect(find.text('Esta cita ya no existe.'), findsOneWidget);
    });
  });

  group('ficha: notas', () {
    testWidgets('añadir, editar y borrar una nota con quién y cuándo', (
      tester,
    ) async {
      final e = await _abrir(tester);
      await _ver(tester, find.text('Todavía no hay notas.'));
      expect(find.text('Todavía no hay notas.'), findsOneWidget);
      await _escribir(
        tester,
        find.byKey(ClavesUi.consNotaCampo),
        'Pide análisis en ayunas',
      );
      await _pulsar(tester, find.byKey(ClavesUi.consNotaAnadir));
      final n = (await _db(
        tester,
        () => e.db.select(e.db.notasConsulta).get(),
      )).single;
      expect(n.texto, 'Pide análisis en ayunas');
      expect(find.text('Pide análisis en ayunas'), findsOneWidget);
      // Quién la escribió y cuándo: «Carmen · martes 13 de octubre, 12:00».
      expect(find.textContaining('Lucía · '), findsOneWidget);
      expect(find.textContaining('12:00'), findsWidgets);

      await _pulsar(tester, find.byKey(ClavesUi.consNotaEditar(n.id)));
      await tester.enterText(
        find.byKey(ClavesUi.consDialogoCampo),
        'Pide análisis en ayunas y orina',
      );
      await _pulsar(tester, find.byKey(ClavesUi.consDialogoGuardar));
      expect(find.text('Pide análisis en ayunas y orina'), findsOneWidget);
      final editada = (await _db(
        tester,
        () => e.db.select(e.db.notasConsulta).get(),
      )).single;
      expect(editada.texto, 'Pide análisis en ayunas y orina');
      // Quién la escribió y cuándo no cambia al editar.
      expect(editada.creadaEn, n.creadaEn);

      await _pulsar(tester, find.byKey(ClavesUi.consNotaBorrar(n.id)));
      await _pulsar(tester, find.byKey(ClavesUi.consBorrarConfirmar));
      await _ver(tester, find.text('Todavía no hay notas.'));
      expect(find.text('Todavía no hay notas.'), findsOneWidget);
      expect(
        (await _db(
          tester,
          () => e.db.select(e.db.notasConsulta).get(),
        )).single.bajaEn,
        isNotNull,
      );
    });
  });

  group('ficha: qué ha pasado desde la última consulta', () {
    testWidgets('las cifras de la semilla, tal cual', (tester) async {
      await _abrir(tester);
      await _calcular(tester);
      await _ver(tester, find.byKey(ClavesUi.consDesde));
      expect(
        find.text('QUÉ HA PASADO DESDE LA ÚLTIMA CONSULTA'),
        findsOneWidget,
      );
      String valor(String c) => _cifra(tester, c);

      // Tomas de ayer y de hoy hasta las 12:00 (3 hechas, 6 sin confirmar);
      // rondas de la semilla: 14 contestadas y 1 sin respuesta; un dolor
      // «poco»; ningún «mal»; 2 comidas anotadas.
      expect(valor('tomas_ok'), '3 de 9');
      expect(valor('tomas_sin'), '6');
      expect(valor('rondas_ok'), '14');
      expect(valor('rondas_sin'), '1');
      expect(valor('mal'), '0');
      expect(valor('dolor'), '1');
      expect(valor('comidas'), '2');
      // Sin cita anterior: los últimos 30 días.
      expect(find.textContaining('Los últimos 30 días'), findsOneWidget);
      // Solo cifras: no hay botones ni palabras de consejo en el bloque.
      expect(
        find.descendant(
          of: find.byKey(ClavesUi.consDesde),
          matching: find.byType(FilledButton),
        ),
        findsNothing,
      );
    });

    testWidgets('con cita anterior, cuenta desde ella', (tester) async {
      final e = await _abrir(
        tester,
        previo: (e, id) async {
          // Hoy a las 08:00 (hora de Madrid): una cita médica anterior a la
          // de mañana. Solo cuenta lo que pasó después.
          await _agendaDe(e).crearCita(
            const DatosCita(
              titulo: 'Anterior',
              fecha: '2026-10-13',
              hora: '08:00',
            ),
          );
        },
      );
      await _calcular(tester);
      await _ver(tester, find.byKey(ClavesUi.consDesde));
      expect(find.textContaining('Desde la cita anterior'), findsOneWidget);
      // Desde las 08:00 hasta las 12:00: la toma de las 07:00 ya no cuenta;
      // las rondas de 09:00 a 11:00 (3) están contestadas salvo una.
      // Desde las 08:00 hasta las 12:00: solo la toma de las 09:00 (hecha);
      // rondas de las 09:00 a las 11:00, dos contestadas y una sin
      // respuesta; la toma de ayer y los dolores de ayer ya no cuentan.
      expect(_cifra(tester, 'tomas_ok'), '1 de 1');
      expect(_cifra(tester, 'tomas_sin'), '0');
      expect(_cifra(tester, 'rondas_ok'), '2');
      expect(_cifra(tester, 'rondas_sin'), '1');
      expect(_cifra(tester, 'mal'), '0');
      expect(_cifra(tester, 'dolor'), '0');
      expect(_cifra(tester, 'comidas'), '2');
      expect(e.reloj.ahora(), instantePrueba);
    });
  });

  group('ficha: grabación con permiso', () {
    Future<void> abrirAviso(WidgetTester tester) async {
      await _pulsar(tester, find.byKey(ClavesUi.consGrabar));
    }

    testWidgets('el aviso pide permiso y sin la casilla no se graba', (
      tester,
    ) async {
      final e = await _abrir(tester);
      await abrirAviso(tester);
      expect(
        find.text('Pide permiso al médico antes de grabar'),
        findsOneWidget,
      );
      expect(find.text('Tengo su permiso'), findsOneWidget);
      // «Empezar a grabar» está apagado hasta marcar la casilla.
      FilledButton empezar() =>
          tester.widget<FilledButton>(find.byKey(ClavesUi.consGrabEmpezar));
      expect(empezar().onPressed, isNull);
      await tester.tap(
        find.byKey(ClavesUi.consGrabEmpezar),
        warnIfMissed: false,
      );
      await pasar(tester, const Duration(milliseconds: 300));
      expect(find.byKey(ClavesUi.consGrabTiempo), findsNothing);
      // Cancelar tampoco graba.
      await _pulsar(tester, find.text('Cancelar'));
      expect(find.byKey(ClavesUi.consGrabTiempo), findsNothing);
      expect(e.grabadora.grabadas, isEmpty);
      expect(
        await _db(tester, () => e.db.select(e.db.grabacionesConsulta).get()),
        isEmpty,
      );
      expect(e.archivos.archivos, isEmpty);
    });

    testWidgets('con permiso graba, guarda solo aquí, se escucha y se borra', (
      tester,
    ) async {
      final e = await _abrir(tester);
      final id = await _citaDe(tester, e);
      await abrirAviso(tester);
      await tester.tap(find.byKey(ClavesUi.consGrabPermiso));
      await pasar(tester, const Duration(milliseconds: 300));
      expect(
        tester
            .widget<FilledButton>(find.byKey(ClavesUi.consGrabEmpezar))
            .onPressed,
        isNotNull,
      );
      await _pulsar(tester, find.byKey(ClavesUi.consGrabEmpezar));
      expect(find.text('Grabando · 0:00'), findsOneWidget);
      expect(find.text('Se para sola a los 60 minutos.'), findsOneWidget);

      // Pasan 75 segundos (con el reloj inyectado).
      e.reloj.avanzar(const Duration(seconds: 75));
      await pasar(tester, const Duration(seconds: 2));
      expect(find.text('Grabando · 1:15'), findsOneWidget);

      await _pulsar(tester, find.byKey(ClavesUi.consGrabParar));
      final ruta = 'consultas/$id.m4a';
      expect(e.grabadora.grabadas, [ruta]);
      // El audio está en la carpeta de consultas de este móvil.
      expect(e.archivos.archivos.keys, [ruta]);
      final marca = (await _db(
        tester,
        () => e.db.select(e.db.grabacionesConsulta).getSingle(),
      ));
      expect(marca.id, id);
      expect(marca.segundos, 75);
      expect(find.text('Hay una grabación de 1:15'), findsOneWidget);
      // Y lo dice: el audio no viaja.
      expect(
        find.textContaining('No viaja a los demás móviles'),
        findsOneWidget,
      );
      expect(find.byKey(ClavesUi.consGrabar), findsNothing);

      // Escuchar.
      await _pulsar(tester, find.byKey(ClavesUi.consGrabEscuchar));
      expect(e.reproductor.reproducidas, [ruta]);
      expect(find.text('Parar'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.consGrabEscuchar));
      expect(e.reproductor.paradas, greaterThan(0));

      // Borrar, con confirmación: se va el audio y la marca.
      await _pulsar(tester, find.byKey(ClavesUi.consGrabBorrar));
      expect(find.text('¿Borrar la grabación?'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.consBorrarConfirmar));
      expect(e.archivos.archivos, isEmpty);
      expect(
        (await _db(
          tester,
          () => e.db.select(e.db.grabacionesConsulta).getSingle(),
        )).bajaEn,
        isNotNull,
      );
      expect(find.byKey(ClavesUi.consGrabar), findsOneWidget);
    });

    testWidgets('a los 60 minutos se para sola', (tester) async {
      final e = await _abrir(tester);
      await abrirAviso(tester);
      await tester.tap(find.byKey(ClavesUi.consGrabPermiso));
      await pasar(tester, const Duration(milliseconds: 300));
      await _pulsar(tester, find.byKey(ClavesUi.consGrabEmpezar));
      expect(find.byKey(ClavesUi.consGrabTiempo), findsOneWidget);
      e.reloj.avanzar(const Duration(minutes: 61));
      await pasar(tester, const Duration(seconds: 2));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await pasar(tester, const Duration(milliseconds: 700));
      expect(find.byKey(ClavesUi.consGrabTiempo), findsNothing);
      final marca = await _db(
        tester,
        () => e.db.select(e.db.grabacionesConsulta).getSingle(),
      );
      expect(marca.segundos, FormatoConsulta.segundosMaximos);
      expect(find.text('Hay una grabación de 1:00:00'), findsOneWidget);
    });

    testWidgets('sin permiso del micrófono avisa y no graba', (tester) async {
      final e = await _abrir(tester);
      e.grabadora.permiso = false;
      await abrirAviso(tester);
      await tester.tap(find.byKey(ClavesUi.consGrabPermiso));
      await pasar(tester, const Duration(milliseconds: 300));
      await _pulsar(tester, find.byKey(ClavesUi.consGrabEmpezar));
      expect(
        find.text(
          'No se puede usar el micrófono. Revisa el permiso del móvil.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(ClavesUi.consGrabTiempo), findsNothing);
      expect(
        await _db(tester, () => e.db.select(e.db.grabacionesConsulta).get()),
        isEmpty,
      );
    });

    testWidgets('mientras graba no se puede salir de la ficha', (tester) async {
      final e = await _abrir(tester);
      await abrirAviso(tester);
      await tester.tap(find.byKey(ClavesUi.consGrabPermiso));
      await pasar(tester, const Duration(milliseconds: 300));
      await _pulsar(tester, find.byKey(ClavesUi.consGrabEmpezar));
      await tester.drag(_lista, const Offset(0, 5000));
      await pasar(tester, const Duration(milliseconds: 500));
      await tester.tap(find.text('Volver'));
      await pasar(tester, const Duration(milliseconds: 500));
      expect(find.byKey(ClavesUi.pantallaFichaConsulta), findsOneWidget);
      expect(find.text('Para la grabación antes de salir.'), findsOneWidget);
      // Sigue grabando: se para con su botón y entonces se guarda.
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.consGrabParar),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await _pulsar(tester, find.byKey(ClavesUi.consGrabParar));
      expect(e.grabadora.grabadas, hasLength(1));
    });

    testWidgets('en otro móvil solo sale dónde está la grabación', (
      tester,
    ) async {
      final e = await _abrir(
        tester,
        previo: (e, id) async {
          final javier = await (e.db.select(
            e.db.miembros,
          )..where((m) => m.nombre.equals('Javier'))).getSingle();
          await e.db
              .into(e.db.grabacionesConsulta)
              .insert(
                GrabacionesConsultaCompanion.insert(
                  id: id,
                  grabadaPor: javier.id,
                  grabadaEn: 1,
                  segundos: 600,
                ),
              );
        },
      );
      await _ver(tester, find.byKey(ClavesUi.consGrabEstado));
      expect(
        find.text('Hay una grabación en el móvil de Javier'),
        findsOneWidget,
      );
      // Aquí no hay audio: ni grabar encima, ni escuchar, ni borrar.
      expect(find.byKey(ClavesUi.consGrabar), findsNothing);
      expect(find.byKey(ClavesUi.consGrabEscuchar), findsNothing);
      expect(find.byKey(ClavesUi.consGrabBorrar), findsNothing);
      expect(e.archivos.archivos, isEmpty);
    });
  });

  group('ficha: resumen para la familia', () {
    testWidgets(
      'compone el texto con fecha, preguntas marcadas y notas, y lo copia',
      (tester) async {
        String? copiado;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copiado = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        final e = await _abrir(
          tester,
          previo: (e, id) async {
            final repo = _consultasDe(e);
            final preguntas = await repo.observarPreguntas(id).first;
            await repo.marcarPreguntada(preguntas.first.id, true);
            await repo.crearNota(id, 'Subir una pastilla por la noche');
          },
        );
        await _pulsar(tester, find.byKey(ClavesUi.consCompartir));
        expect(find.text('Resumen para la familia'), findsOneWidget);
        final texto = tester
            .widget<SelectableText>(find.byKey(ClavesUi.consResumenTexto))
            .data!;
        expect(
          texto,
          'Consulta: Revisión (ejemplo)\n'
          'Miércoles 14 de octubre a las 10:30\n'
          'Centro de salud (ejemplo)\n'
          '\n'
          'Preguntas para llevar:\n'
          '• ¿Hay que cambiar algo de la medicación? (ejemplo) (preguntada)\n'
          '• ¿Cada cuánto conviene volver a revisión? (ejemplo)\n'
          '\n'
          'Notas de la consulta:\n'
          '• Subir una pastilla por la noche (Lucía)',
        );
        await _pulsar(tester, find.byKey(ClavesUi.consCopiar));
        expect(copiado, texto);
        expect(find.text('Resumen para la familia'), findsNothing);
        expect(find.text('Resumen copiado'), findsOneWidget);
        // No se envía nada fuera: ni enlaces ni avisos.
        expect(e.enlaces, isEmpty);
        expect(e.canal.enviados, isEmpty);
      },
    );

    testWidgets('sin preguntas ni notas, lo dice', (tester) async {
      await _abrir(
        tester,
        previo: (e, id) async {
          final repo = _consultasDe(e);
          for (final p in await repo.observarPreguntas(id).first) {
            await repo.borrarPregunta(p.id);
          }
        },
      );
      await _pulsar(tester, find.byKey(ClavesUi.consCompartir));
      final texto = tester
          .widget<SelectableText>(find.byKey(ClavesUi.consResumenTexto))
          .data!;
      expect(texto, contains('Sin preguntas apuntadas.'));
      expect(texto, contains('Sin notas.'));
    });
  });

  group('accesibilidad', () {
    for (final oscuro in [false, true]) {
      testWidgets(
        'la ficha, de arriba abajo, en ${oscuro ? 'oscuro' : 'claro'}: '
        'contraste, toques y nombres',
        (tester) async {
          final manejador = tester.ensureSemantics();
          final entorno = await _abrir(
            tester,
            brillo: oscuro ? Brightness.dark : Brightness.light,
            previo: (e, id) async {
              final repo = _consultasDe(e);
              final preguntas = await repo.observarPreguntas(id).first;
              await repo.marcarPreguntada(preguntas.first.id, true);
              await repo.crearNota(id, 'Una nota');
            },
          );
          // Cada botón de la fila de una pregunta se lee con su nombre.
          final preguntas = await _db(
            tester,
            () => entorno.db.select(entorno.db.preguntasConsulta).get(),
          );
          String nombre(Key k) {
            final sem = tester.getSemantics(find.byKey(k));
            return '${sem.label}|${sem.tooltip}';
          }

          expect(
            nombre(ClavesUi.consPreguntaMarca(preguntas.first.id)),
            contains('Marcar como sin preguntar'),
          );
          expect(
            nombre(ClavesUi.consPreguntaMarca(preguntas.last.id)),
            contains('Marcar como preguntada'),
          );
          expect(
            nombre(ClavesUi.consPreguntaEditar(preguntas.last.id)),
            contains('Editar la pregunta'),
          );
          expect(
            nombre(ClavesUi.consPreguntaBorrar(preguntas.last.id)),
            contains('Borrar la pregunta'),
          );
          await _calcular(tester);
          for (final destino in [
            find.byKey(ClavesUi.consPreguntaCampo),
            find.byKey(ClavesUi.consDesde),
            find.byKey(ClavesUi.consNotaCampo),
            find.byKey(ClavesUi.consGrabar),
            find.byKey(ClavesUi.consCompartir),
          ]) {
            await _ver(tester, destino);
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            await expectLater(
              tester,
              meetsGuideline(androidTapTargetGuideline),
            );
            await expectLater(
              tester,
              meetsGuideline(labeledTapTargetGuideline),
            );
          }
          expect(tester.takeException(), isNull);
          manejador.dispose();
        },
      );
    }

    testWidgets('la lista, en claro y con el texto al 200 %, no se rompe', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await _abrir(tester, ruta: '/familia/consultas');
      expect(tester.takeException(), isNull);
    });

    testWidgets('la ficha con el texto al 200 % no se rompe', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await _abrir(tester);
      await _ver(tester, find.byKey(ClavesUi.consCompartir));
      expect(tester.takeException(), isNull);
    });
  });
}

AgendaRepositorio _agendaDe(EntornoPrueba e) {
  final c = ProviderContainer(overrides: e.overrides);
  addTearDown(c.dispose);
  return c.read(agendaRepositorioProvider);
}

ConsultasRepositorio _consultasDe(EntornoPrueba e) {
  final c = ProviderContainer(overrides: e.overrides);
  addTearDown(c.dispose);
  return c.read(consultasRepositorioProvider);
}
