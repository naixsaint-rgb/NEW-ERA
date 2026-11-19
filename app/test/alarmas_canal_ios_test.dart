import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/plataforma/alarmas/alarmas_canal.dart';
import 'package:newera/core/plataforma/alarmas/servicio_alarmas.dart';

/// Fija el contrato del canal `newera/alarmas` que espera
/// `ios/Runner/AlarmasCanal.swift`: nombres de método, claves de los
/// argumentos y avisos de nativo a Dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const canal = MethodChannel(AlarmasCanal.nombreCanal);
  final llamadas = <MethodCall>[];
  final mensajero =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void responder(Future<Object?> Function(MethodCall) f) {
    mensajero.setMockMethodCallHandler(canal, (c) {
      llamadas.add(c);
      return f(c);
    });
  }

  /// Simula una llamada de nativo a Dart.
  Future<void> desdeNativo(String metodo, Map<String, Object?> args) async {
    await mensajero.handlePlatformMessage(
      AlarmasCanal.nombreCanal,
      const StandardMethodCodec().encodeMethodCall(MethodCall(metodo, args)),
      (_) {},
    );
  }

  tearDown(() {
    mensajero.setMockMethodCallHandler(canal, null);
    llamadas.clear();
  });

  test('programar una toma manda las claves que lee Swift', () async {
    responder((c) async => {'ok': true});
    await AlarmasCanal().programar(
      idToma: 'p1_20261013_0900',
      fecha: DateTime.utc(2026, 10, 13, 7),
      titulo: 'Pastilla blanca pequeña',
      rutaAudio: 'voces/v1/toma.m4a',
    );
    final c = llamadas.single;
    expect(c.method, 'programar');
    expect(c.arguments, {
      'idToma': 'p1_20261013_0900',
      'fecha': DateTime.utc(2026, 10, 13, 7).millisecondsSinceEpoch,
      'titulo': 'Pastilla blanca pequeña',
      'rutaAudio': 'voces/v1/toma.m4a',
      'tipo': 'toma',
      'cabecera': AlarmasCanal.cabeceraToma,
      'botonParar': AlarmasCanal.botonParar,
      'botonAbrir': AlarmasCanal.botonAbrir,
    });
  });

  test('programar una ronda la marca como ronda, sin audio', () async {
    responder((c) async => {'ok': true});
    await AlarmasCanal().programar(
      idToma: 'ronda_20261013_1000',
      fecha: DateTime.utc(2026, 10, 13, 8),
      titulo: 'Toca para contestar',
    );
    final args = llamadas.single.arguments as Map<Object?, Object?>;
    expect(args['tipo'], 'ronda');
    expect(args['cabecera'], AlarmasCanal.cabeceraRonda);
    expect(args.containsKey('rutaAudio'), isTrue);
    expect(args['rutaAudio'], isNull);
  });

  test('una respuesta sin ok o con un tipo raro es no_disponible', () async {
    for (final respuesta in <Object?>[
      null,
      {'ok': false},
      'raro',
    ]) {
      responder((c) async => respuesta);
      await expectLater(
        AlarmasCanal().programar(
          idToma: 'x',
          fecha: DateTime.utc(2030),
          titulo: '',
        ),
        throwsA(
          isA<ErrorAlarma>().having(
            (e) => e.codigo,
            'codigo',
            CodigoAlarma.noDisponible,
          ),
        ),
      );
    }
  });

  test('un código desconocido del canal es no_disponible', () async {
    responder((c) async => throw PlatformException(code: 'otro'));
    await expectLater(
      AlarmasCanal().cancelar('x'),
      throwsA(
        isA<ErrorAlarma>().having(
          (e) => e.codigo,
          'codigo',
          CodigoAlarma.noDisponible,
        ),
      ),
    );
  });

  test('sin plugin nativo, programar es no_implementado', () async {
    await expectLater(
      AlarmasCanal().programar(
        idToma: 'x',
        fecha: DateTime.utc(2030),
        titulo: '',
      ),
      throwsA(
        isA<ErrorAlarma>().having(
          (e) => e.codigo,
          'codigo',
          CodigoAlarma.noImplementado,
        ),
      ),
    );
    expect((await AlarmasCanal().estado()).implementado, isFalse);
  });

  test('cancelarTodas y autorizar usan sus métodos sin argumentos', () async {
    responder(
      (c) async => switch (c.method) {
        'cancelarTodas' => 3,
        'autorizar' => 'autorizada',
        _ => null,
      },
    );
    final a = AlarmasCanal();
    expect(await a.cancelarTodas(), 3);
    expect(await a.autorizar(), AutorizacionAlarma.autorizada);
    expect(
      [for (final c in llamadas) c.method],
      ['cancelarTodas', 'autorizar'],
    );
    expect([for (final c in llamadas) c.arguments], [null, null]);
  });

  test('estado ignora claves de más (motor)', () async {
    responder(
      (c) async => {
        'disponible': true,
        'autorizacion': 'denegada',
        'programadas': ['p1_20261013_0900', 'ronda_20261013_1000'],
        'implementado': true,
        'motor': 'alarmkit',
      },
    );
    final e = await AlarmasCanal().estado();
    expect(e.autorizacion, AutorizacionAlarma.denegada);
    expect(e.programadas, ['p1_20261013_0900', 'ronda_20261013_1000']);
    expect(e.implementado, isTrue);
  });

  test('sonando: pendientes, disparada y abrir emiten; parar no', () async {
    responder(
      (c) async => c.method == 'pendientes'
          ? [
              {'metodo': 'alarmaParada', 'idToma': 'p1_a', 'origen': 'abrir'},
              {'metodo': 'alarmaParada', 'idToma': 'p1_b', 'origen': 'parar'},
            ]
          : null,
    );
    final a = AlarmasCanal();
    final ids = <String>[];
    final sub = a.sonando().listen(ids.add);
    await pumpEventQueue();
    expect(llamadas.map((c) => c.method), contains('pendientes'));

    await desdeNativo('alarmaDisparada', {'idToma': 'ronda_20261013_1000'});
    await desdeNativo('alarmaParada', {'idToma': 'p1_c', 'origen': 'sistema'});
    await desdeNativo('alarmaParada', {'idToma': 'p1_d', 'origen': 'abrir'});
    await pumpEventQueue();

    expect(ids, ['p1_a', 'ronda_20261013_1000', 'p1_d']);
    await sub.cancel();
    canal.setMethodCallHandler(null);
  });
}
