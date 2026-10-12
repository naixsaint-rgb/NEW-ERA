import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/circulo_repositorio.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/db/repositorios/medicacion_repositorio.dart';
import 'package:newera/core/db/semilla_demo.dart';
import 'package:newera/core/plataforma/alarmas/alarmas_canal.dart';
import 'package:newera/core/plataforma/alarmas/alarmas_no_disponibles.dart';
import 'package:newera/core/plataforma/alarmas/programador_alarmas.dart';
import 'package:newera/core/plataforma/alarmas/servicio_alarmas.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/base_prueba.dart';

class _ServicioFalso implements ServicioAlarmas {
  _ServicioFalso({this.programadasInicial = const []});

  final List<String> programadasInicial;
  final programadas = <String>[];
  final canceladas = <String>[];

  @override
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  }) async => programadas.add(idToma);

  @override
  Future<bool> cancelar(String idToma) async {
    canceladas.add(idToma);
    return true;
  }

  @override
  Future<EstadoAlarmas> estado() async => EstadoAlarmas(
    disponible: true,
    autorizacion: AutorizacionAlarma.autorizada,
    programadas: programadasInicial,
    implementado: true,
  );

  @override
  Stream<String> sonando() => const Stream.empty();
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    inicializarZonas();
  });

  late AppDatabase db;
  late RelojFijo reloj;
  late EventosRepositorio eventos;
  late MedicacionRepositorio medicacion;
  const ctx = ContextoApp(
    circuloId: 'c1',
    personaId: 'p1',
    dispositivoId: 'd1',
    plataforma: 'ios',
  );

  setUp(() async {
    db = baseEnMemoria();
    reloj = RelojFijo(DateTime.utc(2026, 10, 13, 10)); // 12:00 en Madrid
    eventos = EventosRepositorio(
      db: db,
      reloj: reloj,
      azar: Random(1),
      contexto: ctx,
      autor: () => 'p1',
    );
    final circulo = CirculoRepositorio(
      db: db,
      reloj: reloj,
      contexto: ctx,
      eventos: eventos,
    );
    medicacion = MedicacionRepositorio(
      db: db,
      reloj: reloj,
      contexto: ctx,
      eventos: eventos,
      circulo: circulo,
      autor: () => 'p1',
    );
    await SemillaDemo.sembrar(
      db: db,
      contexto: ctx,
      reloj: reloj,
      azar: Random(1),
    );
  });

  tearDown(() => db.close());

  ProgramadorAlarmas programador(ServicioAlarmas s) => ProgramadorAlarmas(
    servicio: s,
    medicacion: medicacion,
    eventos: eventos,
    reloj: reloj,
    contexto: ctx,
  );

  test('programa las tomas de las próximas 48 h, las inserta y cancela las sobrantes', () async {
    final servicio = _ServicioFalso(
      programadasInicial: ['vieja_20260101_0900'],
    );
    await programador(servicio).reprogramar();
    // Desde las 12:00 de hoy hasta las 12:00 de pasado mañana: 14:00 y 21:00 de
    // hoy; 09:00, 14:00 y 21:00 de mañana; y 09:00 de pasado mañana.
    expect(servicio.programadas, hasLength(6));
    expect(servicio.programadas.toSet(), hasLength(6));
    expect(servicio.canceladas, ['vieja_20260101_0900']);
    final tomas = await db.select(db.tomas).get();
    expect(
      {for (final t in tomas) t.id}.containsAll(servicio.programadas),
      isTrue,
    );
    final ev = await db.select(db.eventos).get();
    expect(ev.where((e) => e.tipo == 'alarma_programada'), hasLength(6));
    expect(ev.where((e) => e.tipo == 'alarma_no_programada'), isEmpty);
  });

  test(
    'no cancela la alarma de una toma que empezó hace menos de 30 min',
    () async {
      final pautas = await db.select(db.pautas).get();
      final p14 = pautas.firstWhere((p) => p.horas.contains('14:00'));
      final sonando = '${p14.pautaId}_20261013_1400';
      reloj.fijar(DateTime.utc(2026, 10, 13, 12, 10)); // 14:10 en Madrid
      final servicio = _ServicioFalso(
        programadasInicial: [sonando, 'vieja_20260101_0900'],
      );
      await programador(servicio).reprogramar();
      expect(servicio.canceladas, ['vieja_20260101_0900']);
      expect(servicio.programadas, isNot(contains(sonando)));
    },
  );

  test('no vuelve a programar lo que ya está programado', () async {
    final primera = _ServicioFalso();
    await programador(primera).reprogramar();
    final segunda = _ServicioFalso(programadasInicial: primera.programadas);
    await programador(segunda).reprogramar();
    expect(segunda.programadas, isEmpty);
    expect(segunda.canceladas, isEmpty);
  });

  test(
    'sin alarmas del sistema: un solo alarma_no_programada por arranque',
    () async {
      await programador(const AlarmasNoDisponibles()).reprogramar();
      final ev = await db.select(db.eventos).get();
      final no = ev.where((e) => e.tipo == 'alarma_no_programada').toList();
      expect(no, hasLength(1));
      expect(
        EventosRepositorio.payloadDe(no.single)['codigo'],
        'no_disponible',
      );
      // Las tomas se insertan igualmente.
      expect(await db.select(db.tomas).get(), isNotEmpty);
    },
  );

  group('canal de iOS', () {
    const canal = MethodChannel('newera/alarmas');
    final llamadas = <MethodCall>[];

    tearDown(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canal, null);
      llamadas.clear();
    });

    void responder(Future<Object?> Function(MethodCall) f) {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canal, (c) {
            llamadas.add(c);
            return f(c);
          });
    }

    test(
      'programar envía idToma, fecha en ms UTC, titulo y rutaAudio',
      () async {
        responder((c) async => {'ok': true});
        await AlarmasCanal().programar(
          idToma: 'p1_20261013_0900',
          fecha: DateTime.utc(2026, 10, 13, 7),
          titulo: 'Pastilla blanca pequeña',
        );
        expect(llamadas.single.method, 'programar');
        final args = llamadas.single.arguments as Map<Object?, Object?>;
        expect(args['idToma'], 'p1_20261013_0900');
        expect(
          args['fecha'],
          DateTime.utc(2026, 10, 13, 7).millisecondsSinceEpoch,
        );
        expect(args['titulo'], 'Pastilla blanca pequeña');
        expect(args.containsKey('rutaAudio'), isTrue);
      },
    );

    test('los errores del canal se traducen a códigos', () async {
      for (final codigo in [
        'no_implementado',
        'no_disponible',
        'no_autorizado',
        'argumentos',
        'limite',
      ]) {
        responder((c) async => throw PlatformException(code: codigo));
        await expectLater(
          AlarmasCanal().programar(
            idToma: 'x',
            fecha: DateTime.utc(2030),
            titulo: '',
          ),
          throwsA(
            isA<ErrorAlarma>().having((e) => e.codigo.codigo, 'codigo', codigo),
          ),
        );
      }
    });

    test(
      'estado lee disponible, autorizacion, programadas e implementado',
      () async {
        responder(
          (c) async => {
            'disponible': true,
            'autorizacion': 'autorizada',
            'programadas': ['a', 'b'],
            'implementado': false,
          },
        );
        final e = await AlarmasCanal().estado();
        expect(e.disponible, isTrue);
        expect(e.autorizacion, AutorizacionAlarma.autorizada);
        expect(e.programadas, ['a', 'b']);
        expect(e.implementado, isFalse);
      },
    );

    test('cancelar devuelve el booleano del canal', () async {
      responder((c) async => true);
      expect(await AlarmasCanal().cancelar('x'), isTrue);
      expect(llamadas.single.arguments, {'idToma': 'x'});
    });
  });
}
