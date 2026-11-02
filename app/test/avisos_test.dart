import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, Value, driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/avisos/canal_avisos.dart';
import 'package:newera/core/avisos/envio_avisos.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/cripto/tema_aviso.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/circulo_repositorio.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/enrutado/router.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/features/avisos/dominio/que_avisar.dart';
import 'package:newera/features/avisos/revision_avisos.dart';
import 'package:newera/features/circulo/familiar_pantalla.dart';
import 'package:newera/features/hoy/dominio/tomas.dart';
import 'package:newera/features/hoy/hoy_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';

/// Hora de Madrid (UTC+2 en octubre de 2026) del 13/10 a UTC.
DateTime _m(int hora, [int minuto = 0, int segundo = 0]) =>
    DateTime.utc(2026, 10, 13, hora - 2, minuto, segundo);

final _hex64 = RegExp(r'^[0-9a-f]{64}$');

/// Base con la semilla de la demo (Lucía puesto 1, Javier 2, Marta 3; tomas
/// a las 09:00, 14:00 y 21:00) en el móvil de la persona, con su envío de
/// avisos por un canal simulado.
final class _Mundo {
  _Mundo(this.db, this.contexto, this.almacen, this.reloj, this.canal);

  final AppDatabase db;
  final ContextoApp contexto;
  final AlmacenSeguro almacen;
  final RelojFijo reloj;
  final CanalAvisosSimulado canal;

  late final eventos = EventosRepositorio(
    db: db,
    reloj: reloj,
    azar: Random(7),
    contexto: contexto,
    autor: () => contexto.personaId,
  );

  EnvioAvisos envio([CanalAvisos? otro]) => EnvioAvisos(
    db: db,
    eventos: eventos,
    canal: otro ?? canal,
    reloj: reloj,
    contexto: contexto,
    tema: (id) => TemaAviso.desdeAlmacen(almacen, id),
  );

  Future<int> revisar() =>
      revisarAvisos(db: db, contexto: contexto, reloj: reloj, envio: envio());

  Future<String> idMiembro(String nombre) async => (await (db.select(
    db.miembros,
  )..where((m) => m.nombre.equals(nombre))).getSingle()).id;

  Future<String> tema(String nombre) async =>
      (await TemaAviso.desdeAlmacen(almacen, await idMiembro(nombre)))!;

  /// Id de la toma de las 14:00 de hoy (cápsula roja).
  Future<String> tomaDeLas14() async {
    final med = await (db.select(
      db.medicamentos,
    )..where((m) => m.nombreParaPersona.equals('Cápsula roja'))).getSingle();
    final p = await (db.select(
      db.pautas,
    )..where((x) => x.medicamentoId.equals(med.id))).getSingle();
    return '${p.pautaId}_20261013_1400';
  }

  Future<void> puesto(String nombre, int? orden) async {
    await (db.update(db.miembros)..where((m) => m.nombre.equals(nombre))).write(
      MiembrosCompanion(ordenEscalado: Value(orden)),
    );
  }

  Future<List<Map<String, Object?>>> avisosApuntados() async => [
    for (final e in await (db.select(
      db.eventos,
    )..where((e) => e.tipo.equals('aviso_enviado'))).get())
      {'sujeto': e.sujeto, ...EventosRepositorio.payloadDe(e)},
  ];

  Future<void> evento(
    String tipo,
    DateTime cuando, {
    String? sujeto,
    Map<String, Object?> payload = const {},
  }) async {
    reloj.fijar(cuando);
    await eventos.registrar(
      TipoEvento.desdeNombre(tipo)!,
      sujeto: sujeto,
      payload: payload,
      ocurridoEn: cuando,
    );
  }

  Future<void> respuesta(
    String ronda,
    String tipo,
    String valor,
    DateTime cuando,
  ) => evento(
    'pregunta_respondida',
    cuando,
    sujeto: ronda,
    payload: {
      'ronda': ronda,
      'tipo': tipo,
      'respuesta': valor,
      'tiempo_ms': 1500,
      'origen': 'movil',
    },
  );
}

Future<_Mundo> _mundo() async {
  final reloj = RelojFijo(instantePrueba);
  final almacen = AlmacenSeguroMemoria({ClavesAlmacen.perfil: 'persona'});
  final overrides = await Arranque.iniciar(
    almacen: almacen,
    ejecutor: ejecutorEnMemoria(),
    reloj: reloj,
    plataforma: 'android',
    demoWeb: false,
    sembrarDemo: true,
    azar: Random(42),
  );
  final c = ProviderContainer(overrides: overrides);
  final db = c.read(baseDatosProvider);
  final contexto = c.read(contextoProvider);
  c.dispose();
  final m = _Mundo(db, contexto, almacen, reloj, CanalAvisosSimulado());
  addTearDown(db.close);
  return m;
}

/// Temas a los que se publicó, en orden.
List<String> _temas(CanalAvisosSimulado c) => [
  for (final e in c.enviados) e.tema,
];

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    inicializarZonas();
  });

  group('tema de ntfy', () {
    test(
      'estable, 64 hexadecimales y distinto por familiar y por clave',
      () async {
        final clave = ClaveCirculo.generar(Random(1));
        final otra = ClaveCirculo.generar(Random(2));
        final a1 = await TemaAviso.derivar(clave, 'miembro-a');
        final a2 = await TemaAviso.derivar(clave, 'miembro-a');
        final b = await TemaAviso.derivar(clave, 'miembro-b');
        final aOtra = await TemaAviso.derivar(otra, 'miembro-a');
        expect(a1, a2);
        expect(a1, matches(_hex64));
        // ntfy admite temas de hasta 64 caracteres: letras, números, _ y -.
        expect(a1, matches(RegExp(r'^[-_A-Za-z0-9]{1,64}$')));
        expect(b, isNot(a1));
        expect(aOtra, isNot(a1));
        // No es el token del servidor ni lleva el id del familiar.
        expect(a1.contains('miembro'), isFalse);
        expect(TemaAviso.etiqueta('x'), 'newera/v1/aviso/x');
      },
    );

    test('desde el almacén; sin clave (demo web), nulo', () async {
      final clave = ClaveCirculo.generar(Random(3));
      final almacen = AlmacenSeguroMemoria({ClavesAlmacen.circuloClave: clave});
      expect(
        await TemaAviso.desdeAlmacen(almacen, 'm1'),
        await TemaAviso.derivar(clave, 'm1'),
      );
      expect(
        await TemaAviso.desdeAlmacen(AlmacenSeguroMemoria(), 'm1'),
        isNull,
      );
    });

    test('enlace de suscripción ntfy://ntfy.sh/<tema>', () {
      final tema = 'a' * 64;
      expect(
        TemaAviso.enlaceSuscripcion(tema).toString(),
        'ntfy://ntfy.sh/$tema?display=NEW-ERA',
      );
    });
  });

  group('a quién se avisa', () {
    const conPuesto = <FamiliarAviso>[
      (id: 'marta', orden: 3),
      (id: 'lucia', orden: 1),
      (id: 'javier', orden: 2),
    ];
    const sinPuesto = <FamiliarAviso>[
      (id: 'lucia', orden: null),
      (id: 'javier', orden: null),
    ];

    test('con orden: el 1 a los 5 minutos, el 2 a los 10', () {
      expect(destinatariosDeEscalon(conPuesto, 1), ['lucia']);
      expect(destinatariosDeEscalon(conPuesto, 2), ['javier']);
      expect(destinatariosDeEscalon(conPuesto, 0), [
        'marta',
        'lucia',
        'javier',
      ]);
      const config = ConfigEscalado();
      expect(minutoDeEscalon(config, 1), 5);
      expect(minutoDeEscalon(config, 2), 10);
    });

    test('sin orden: los dos avisos a todos', () {
      expect(destinatariosDeEscalon(sinPuesto, 1), ['lucia', 'javier']);
      expect(destinatariosDeEscalon(sinPuesto, 2), ['lucia', 'javier']);
    });

    test('con un solo familiar con puesto, los dos avisos van a él', () {
      const uno = <FamiliarAviso>[
        (id: 'lucia', orden: null),
        (id: 'javier', orden: 1),
      ];
      expect(destinatariosDeEscalon(uno, 1), ['javier']);
      expect(destinatariosDeEscalon(uno, 2), ['javier']);
      expect(destinatariosDeEscalon(const [(id: 'solo', orden: null)], 2), [
        'solo',
      ]);
      expect(destinatariosDeEscalon(const [], 1), isEmpty);
    });

    test('prioridad 5 para toma, ayuda y «mal»; 4 para el resto', () {
      expect(MotivoAviso.tomaSinConfirmar.prioridad, 5);
      expect(MotivoAviso.ayudaPedida.prioridad, 5);
      expect(MotivoAviso.estadoMal.prioridad, 5);
      expect(MotivoAviso.dolorNuevo.prioridad, 4);
      expect(MotivoAviso.rondaSinRespuesta.prioridad, 4);
    });

    test('revisiones en segundo plano: +5 y +10 por toma, +10 por ronda', () {
      final ronda = RondaControl(
        id: 'ronda_20261013_1600',
        fechaLocal: '2026-10-13',
        horaLocal: '16:00',
        enPunto: _m(16),
        hora: _m(16),
      );
      final r = instantesDeRevision(
        tomas: [_m(14), _m(9)],
        rondas: [ronda],
        config: const ConfigEscalado(),
        ahora: _m(12),
      );
      expect(r, [_m(14, 5, 5), _m(14, 10, 5), _m(16, 10, 5)]);
    });
  });

  group('escalado de una toma (móvil de la persona)', () {
    test('a los 5 minutos al familiar 1 y a los 10 al familiar 2', () async {
      final w = await _mundo();
      final toma = await w.tomaDeLas14();
      w.reloj.fijar(_m(14, 4, 59));
      expect(await w.revisar(), 0);
      w.reloj.fijar(_m(14, 5));
      expect(await w.revisar(), 1);
      expect(_temas(w.canal), [await w.tema('Lucía')]);
      expect(w.canal.enviados.single.prioridad, 5);
      w.reloj.fijar(_m(14, 10, 5));
      expect(await w.revisar(), 1);
      expect(_temas(w.canal), [await w.tema('Lucía'), await w.tema('Javier')]);
      final apuntados = await w.avisosApuntados();
      expect(apuntados, hasLength(2));
      expect(apuntados.first, {
        'sujeto': toma,
        'tipo': 'toma_sin_confirmar',
        'miembroId': await w.idMiembro('Lucía'),
        'canal': 'ntfy',
        'resultado': 'enviado',
        'escalon': 1,
      });
      expect(apuntados.last['escalon'], 2);
      expect(apuntados.last['miembroId'], await w.idMiembro('Javier'));
    });

    test('sin orden, los dos avisos a todos los familiares', () async {
      final w = await _mundo();
      for (final n in ['Lucía', 'Javier', 'Marta']) {
        await w.puesto(n, null);
      }
      w.reloj.fijar(_m(14, 5, 10));
      expect(await w.revisar(), 3);
      w.reloj.fijar(_m(14, 10, 10));
      expect(await w.revisar(), 3);
      expect(w.canal.enviados, hasLength(6));
      expect(_temas(w.canal).toSet(), {
        await w.tema('Lucía'),
        await w.tema('Javier'),
        await w.tema('Marta'),
      });
    });

    test('con un solo familiar con puesto, los dos avisos van a él', () async {
      final w = await _mundo();
      await w.puesto('Javier', null);
      await w.puesto('Marta', null);
      w.reloj.fijar(_m(14, 5));
      await w.revisar();
      w.reloj.fijar(_m(14, 10));
      await w.revisar();
      final lucia = await w.tema('Lucía');
      expect(_temas(w.canal), [lucia, lucia]);
      expect([for (final a in await w.avisosApuntados()) a['escalon']], [1, 2]);
    });

    test('si se confirma a los 4 minutos, no se avisa a nadie', () async {
      final w = await _mundo();
      final toma = await w.tomaDeLas14();
      await w.evento('toma_confirmada', _m(14, 4), sujeto: toma);
      for (final t in [_m(14, 5), _m(14, 5, 5), _m(14, 10, 5), _m(14, 30)]) {
        w.reloj.fijar(t);
        expect(await w.revisar(), 0);
      }
      expect(w.canal.enviados, isEmpty);
      expect(await w.avisosApuntados(), isEmpty);
    });

    test('pasada la ventana de 30 minutos, ya no se avisa', () async {
      final w = await _mundo();
      w.reloj.fijar(_m(14, 40, 1));
      expect(await w.revisar(), 0);
      expect(w.canal.enviados, isEmpty);
    });

    test(
      'idempotente: nunca dos avisos iguales para la misma toma y escalón',
      () async {
        final w = await _mundo();
        w.reloj.fijar(_m(14, 6));
        expect(await w.revisar(), 1);
        expect(await w.revisar(), 0);
        // Otro envío (como la revisión en segundo plano) con la misma base.
        expect(
          await revisarAvisos(
            db: w.db,
            contexto: w.contexto,
            reloj: w.reloj,
            envio: w.envio(),
          ),
          0,
        );
        expect(w.canal.enviados, hasLength(1));
        expect(await w.avisosApuntados(), hasLength(1));
      },
    );

    test(
      'idempotente también a la vez: dos envíos simultáneos, un aviso',
      () async {
        final w = await _mundo();
        final lento = _CanalLento();
        final aviso = AvisoPendiente(
          motivo: MotivoAviso.tomaSinConfirmar,
          sujeto: await w.tomaDeLas14(),
          escalon: 1,
          vence: _m(14, 5),
        );
        w.reloj.fijar(_m(14, 5));
        final r = await Future.wait([
          w.envio(lento).enviar(aviso),
          w.envio(lento).enviar(aviso),
        ]);
        expect(r.reduce((a, b) => a + b), 1);
        expect(lento.publicados, 1);
        expect(await w.avisosApuntados(), hasLength(1));
      },
    );

    test(
      'si falla, se apunta una vez y se reintenta pasados 2 minutos',
      () async {
        final w = await _mundo();
        final canal = CanalAvisosSimulado(respuestas: [ResultadoAviso.fallido]);
        w.reloj.fijar(_m(14, 5));
        final envio = w.envio(canal);
        Future<int> revisar() => revisarAvisos(
          db: w.db,
          contexto: w.contexto,
          reloj: w.reloj,
          envio: envio,
        );
        expect(await revisar(), 0);
        w.reloj.fijar(_m(14, 6));
        expect(await revisar(), 0);
        expect(canal.enviados, hasLength(1));
        w.reloj.fijar(_m(14, 7, 1));
        expect(await revisar(), 1);
        expect(canal.enviados, hasLength(2));
        expect(
          [for (final a in await w.avisosApuntados()) a['resultado']],
          ['fallido', 'enviado'],
        );
        final envios = agruparEnvios(
          await (w.db.select(
            w.db.eventos,
          )..where((e) => e.tipo.equals('aviso_enviado'))).get(),
        );
        expect(envios.single.resultado, ResultadoAviso.enviado);
      },
    );

    test(
      'sin clave del círculo (demo web) no sale nada ni se apunta',
      () async {
        final w = await _mundo();
        await w.almacen.borrar(ClavesAlmacen.circuloClave);
        w.reloj.fijar(_m(14, 5));
        expect(await w.revisar(), 0);
        expect(w.canal.enviados, isEmpty);
        expect(await w.avisosApuntados(), isEmpty);
      },
    );
  });

  group('avisos inmediatos y rondas', () {
    test('«mal»: al momento, a todos, prioridad 5', () async {
      final w = await _mundo();
      await w.respuesta('ronda_20261013_1200', 'estado', 'mal', _m(12, 1));
      expect(await w.revisar(), 3);
      expect(w.canal.enviados.map((e) => e.prioridad).toSet(), {5});
      final a = await w.avisosApuntados();
      expect(a.map((x) => x['tipo']).toSet(), {'estado_mal'});
      expect(a.first['sujeto'], 'ronda_20261013_1200');
      expect(a.first.containsKey('escalon'), isFalse);
    });

    test(
      'dolor nuevo del día: a todos, prioridad 4; el mismo dolor, no',
      () async {
        final w = await _mundo();
        await w.respuesta('ronda_20261013_1100', 'dolor', 'poco', _m(11, 2));
        expect(await w.revisar(), 3);
        expect(w.canal.enviados.map((e) => e.prioridad).toSet(), {4});
        await w.respuesta('ronda_20261013_1200', 'dolor', 'poco', _m(12, 2));
        expect(await w.revisar(), 0);
        await w.respuesta('ronda_20261013_1300', 'dolor', 'mucho', _m(13, 2));
        expect(await w.revisar(), 3);
        expect((await w.avisosApuntados()).map((x) => x['sujeto']).toSet(), {
          'ronda_20261013_1100',
          'ronda_20261013_1300',
        });
      },
    );

    test('ayuda pedida: al momento, a todos, prioridad 5', () async {
      final w = await _mundo();
      await w.evento('ayuda_pedida', _m(12, 3));
      expect(await w.revisar(), 3);
      expect(w.canal.enviados.map((e) => e.prioridad).toSet(), {5});
      final a = await w.avisosApuntados();
      expect(a.map((x) => x['tipo']).toSet(), {'ayuda_pedida'});
      // El origen es el evento de la ayuda.
      final ayuda = await (w.db.select(
        w.db.eventos,
      )..where((e) => e.tipo.equals('ayuda_pedida'))).getSingle();
      expect(a.first['sujeto'], ayuda.ulid);
    });

    test(
      'ronda sin respuesta a los 10 minutos: a todos, prioridad 4',
      () async {
        final w = await _mundo();
        // El móvil de la persona hace rondas desde las 08:00.
        await w.evento(
          'perfil_elegido',
          _m(8),
          payload: const {'perfil': 'persona'},
        );
        w.reloj.fijar(_m(13, 9, 59));
        expect(await w.revisar(), 0);
        w.reloj.fijar(_m(13, 10, 5));
        expect(await w.revisar(), 3);
        expect(w.canal.enviados.map((e) => e.prioridad).toSet(), {4});
        final a = await w.avisosApuntados();
        expect(a.map((x) => x['sujeto']).toSet(), {'ronda_20261013_1300'});
        expect(a.map((x) => x['tipo']).toSet(), {'ronda_sin_respuesta'});
      },
    );

    test('ronda contestada: no se avisa', () async {
      final w = await _mundo();
      await w.evento(
        'perfil_elegido',
        _m(8),
        payload: const {'perfil': 'persona'},
      );
      await w.respuesta('ronda_20261013_1300', 'estado', 'bien', _m(13, 4));
      w.reloj.fijar(_m(13, 10, 5));
      expect(await w.revisar(), 0);
      expect(w.canal.enviados, isEmpty);
    });
  });

  group('canal ntfy', () {
    test('POST a ntfy.sh/<tema> con el texto fijo y las cabeceras', () async {
      final peticiones = <http.Request>[];
      final canal = CanalNtfy(
        cliente: MockClient((r) async {
          peticiones.add(r);
          return http.Response('{}', 200);
        }),
        esperar: (_) async {},
      );
      final tema = 'b' * 64;
      expect(
        await canal.publicar(tema: tema, prioridad: 5),
        ResultadoAviso.enviado,
      );
      final r = peticiones.single;
      expect(r.method, 'POST');
      expect(r.url.toString(), 'https://ntfy.sh/$tema');
      expect(r.body, 'NEW-ERA: hay un aviso. Abre la app.');
      expect(r.headers['Title'], 'NEW-ERA');
      expect(r.headers['Priority'], '5');
      expect(r.headers['Tags'], 'bell');
      expect(r.headers['Click'], 'newera://hoy');
    });

    test('429: espera lo que pide Retry-After y reintenta', () async {
      var n = 0;
      final esperas = <Duration>[];
      final canal = CanalNtfy(
        cliente: MockClient((r) async {
          n++;
          return n == 1
              ? http.Response('', 429, headers: {'retry-after': '7'})
              : http.Response('{}', 200);
        }),
        esperar: (d) async => esperas.add(d),
      );
      expect(
        await canal.publicar(tema: 'c' * 64, prioridad: 4),
        ResultadoAviso.enviado,
      );
      expect(n, 2);
      expect(esperas, [const Duration(seconds: 7)]);
    });

    test('429 sin Retry-After: al menos 5 segundos, cada vez más', () async {
      var n = 0;
      final esperas = <Duration>[];
      final canal = CanalNtfy(
        cliente: MockClient((r) async {
          n++;
          return n < 3 ? http.Response('', 429) : http.Response('{}', 200);
        }),
        esperar: (d) async => esperas.add(d),
      );
      expect(
        await canal.publicar(tema: 'd' * 64, prioridad: 4),
        ResultadoAviso.enviado,
      );
      expect(esperas, hasLength(2));
      expect(esperas.first, greaterThanOrEqualTo(const Duration(seconds: 5)));
      expect(esperas.last, greaterThan(esperas.first));
    });

    test(
      'sin red: reintenta con espera creciente y acaba en fallido',
      () async {
        var n = 0;
        final esperas = <Duration>[];
        final canal = CanalNtfy(
          cliente: MockClient((r) async {
            n++;
            throw http.ClientException('sin red');
          }),
          intentos: 3,
          esperar: (d) async => esperas.add(d),
        );
        expect(
          await canal.publicar(tema: 'e' * 64, prioridad: 4),
          ResultadoAviso.fallido,
        );
        expect(n, 3);
        expect(esperas, hasLength(2));
        expect(esperas.last, greaterThan(esperas.first));
      },
    );

    test('400 o tema no válido: fallido sin reintentar', () async {
      var n = 0;
      final canal = CanalNtfy(
        cliente: MockClient((r) async {
          n++;
          return http.Response('', 400);
        }),
        esperar: (_) async {},
      );
      expect(
        await canal.publicar(tema: 'f' * 64, prioridad: 4),
        ResultadoAviso.fallido,
      );
      expect(n, 1);
      expect(
        await canal.publicar(tema: 'no/vale', prioridad: 4),
        ResultadoAviso.fallido,
      );
      expect(n, 1);
    });

    test('un envío cada vez: sin ráfagas', () async {
      var activos = 0, maximo = 0;
      final canal = CanalNtfy(
        cliente: MockClient((r) async {
          activos++;
          maximo = max(maximo, activos);
          await Future<void>.delayed(const Duration(milliseconds: 5));
          activos--;
          return http.Response('{}', 200);
        }),
        esperar: (_) async {},
      );
      final r = await Future.wait([
        for (var i = 0; i < 4; i++)
          canal.publicar(tema: '$i' * 64, prioridad: 4),
      ]);
      expect(r.toSet(), {ResultadoAviso.enviado});
      expect(maximo, 1);
    });
  });

  group('pantallas', () {
    testWidgets('Hoy: «Aviso enviado a Lucía» y el que no salió', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      await tester.runAsync(() async {
        final toma = await e.idToma('Cápsula roja', '20261013', '1400');
        final miembros = await e.db.select(e.db.miembros).get();
        String id(String n) => miembros.firstWhere((m) => m.nombre == n).id;
        Future<void> apuntar(String miembro, String resultado, int min) => e.db
            .into(e.db.eventos)
            .insert(
              EventosCompanion.insert(
                ulid: Ulid.generar(
                  RelojFijo(instantePrueba.subtract(Duration(minutes: min))),
                  Random(min),
                ),
                circuloId: e.contexto.circuloId,
                autor: e.contexto.personaId,
                dispositivo: 'movil-persona',
                tipo: 'aviso_enviado',
                sujeto: Value(toma),
                ocurridoEn: instantePrueba
                    .subtract(Duration(minutes: min))
                    .millisecondsSinceEpoch,
                registradoEn: instantePrueba.millisecondsSinceEpoch,
                payload: Value(
                  jsonEncode({
                    'tipo': 'toma_sin_confirmar',
                    'miembroId': id(miembro),
                    'canal': 'ntfy',
                    'resultado': resultado,
                    'escalon': miembro == 'Lucía' ? 1 : 2,
                  }),
                ),
              ),
            );
        await apuntar('Lucía', 'enviado', 10);
        await apuntar('Javier', 'fallido', 5);
      });
      await montarApp(tester, e);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byType(HoyPantalla), findsOneWidget);
      await tester.scrollUntilVisible(find.text('AVISOS DE HOY'), 300);
      await tester.scrollUntilVisible(
        find.text('No se pudo avisar a Javier'),
        200,
      );
      expect(find.text('Aviso enviado a Lucía'), findsOneWidget);
      expect(find.text('Toma de las 14:00 sin confirmar'), findsNWidgets(2));
      expect(find.text('11:50'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Círculo: avisos en este móvil, prueba y orden de aviso', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final ids = await tester.runAsync(() async {
        final m = await e.db.select(e.db.miembros).get();
        return {for (final x in m) x.nombre: x.id};
      });
      final temaLucia = await tester.runAsync(
        () => TemaAviso.desdeAlmacen(e.almacen, ids!['Lucía']!),
      );
      await montarApp(tester, e, rutaInicial: Rutas.pestana('circulo'));
      await pasar(tester, const Duration(seconds: 1));
      // Lucía es la familiar de este móvil (la responsable).
      await tester.tap(find.byKey(ClavesUi.circFamiliar(ids!['Lucía']!)));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byType(FamiliarPantalla), findsOneWidget);
      expect(find.text('AVISOS EN ESTE MÓVIL'), findsOneWidget);
      expect(find.text(temaLucia!), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.circAvisosAbrir));
      await pasar(tester, const Duration(milliseconds: 300));
      expect(
        e.enlaces.last.toString(),
        'ntfy://ntfy.sh/$temaLucia?display=NEW-ERA',
      );
      await tester.tap(find.byKey(ClavesUi.circAvisosPrueba));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await pasar(tester, const Duration(milliseconds: 500));
      expect(e.canal.enviados.single.tema, temaLucia);
      expect(
        find.text('Aviso de prueba enviado. Si no llega, repasa los pasos.'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.circAvisosCopiar),
        200,
        scrollable: find
            .descendant(
              of: find.byType(FamiliarPantalla),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.textContaining('Qué ve ntfy.sh'), findsOneWidget);
      expect(find.textContaining('1. Instala la app ntfy'), findsOneWidget);
      // La prueba no deja evento.
      final apuntados = await tester.runAsync(
        () => (e.db.select(
          e.db.eventos,
        )..where((x) => x.tipo.equals('aviso_enviado'))).get(),
      );
      expect(apuntados, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Círculo: otro familiar; su puesto cambia y viaja como ficha', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      final ids = await tester.runAsync(() async {
        final m = await e.db.select(e.db.miembros).get();
        return {for (final x in m) x.nombre: x.id};
      });
      final javier = ids!['Javier']!;
      await montarApp(tester, e, rutaInicial: Rutas.familiar(javier));
      await pasar(tester, const Duration(seconds: 1));
      expect(
        find.text(
          'Javier activa sus avisos desde su propio móvil, en Círculo.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(ClavesUi.circAvisosAbrir), findsNothing);
      await tester.tap(find.byKey(ClavesUi.circPuesto(0)));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await pasar(tester, const Duration(milliseconds: 500));
      final fila = await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.id.equals(javier))).getSingle(),
      );
      expect(fila!.ordenEscalado, isNull);
      final fichas = await tester.runAsync(
        () =>
            (e.db.select(e.db.eventos)..where(
                  (x) =>
                      x.tipo.equals('ficha_modificada') &
                      x.sujeto.equals(javier),
                ))
                .get(),
      );
      final p = EventosRepositorio.payloadDe(fichas!.last);
      expect(p['despues'], {'orden_escalado': null});
      expect((p['fila'] as Map)['orden_escalado'], isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('app de la persona abierta: a las 14:05 avisa a Lucía', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.persona),
      ))!;
      e.reloj.fijar(_m(14, 5, 1));
      await montarApp(tester, e);
      for (var i = 0; i < 6 && e.canal.enviados.isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await pasar(tester, const Duration(milliseconds: 300));
      }
      final lucia = await tester.runAsync(() async {
        final m = await (e.db.select(
          e.db.miembros,
        )..where((x) => x.nombre.equals('Lucía'))).getSingle();
        return TemaAviso.desdeAlmacen(e.almacen, m.id);
      });
      expect(e.canal.enviados, hasLength(1));
      expect(e.canal.enviados.single.tema, lucia);
      expect(e.canal.enviados.single.prioridad, 5);
      // 15 s después (el reloj de la app vuelve a mirar): no se repite.
      await pasar(tester, const Duration(seconds: 16));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      expect(e.canal.enviados, hasLength(1));
      expect(tester.takeException(), isNull);
    });

    test('newera://hoy lleva al inicio del perfil', () {
      final uri = Uri.parse('newera://hoy');
      expect(rutaDeUri(uri), Rutas.raiz);
      expect(
        redirigirSegunPerfil(
          const Sesion(perfil: PerfilApp.familia),
          rutaDeUri(uri),
        ),
        Rutas.pestana('hoy'),
      );
      expect(
        redirigirSegunPerfil(
          const Sesion(perfil: PerfilApp.persona),
          rutaDeUri(uri),
        ),
        Rutas.persona,
      );
      expect(rutaDeUri(Uri.parse('/familia/hoy')), '/familia/hoy');
    });

    testWidgets('newera://hoy abre Hoy en la app de la familia', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      await montarApp(tester, e, rutaInicial: Rutas.pestana('circulo'));
      await pasar(tester, const Duration(seconds: 1));
      final contenedor = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      contenedor.read(routerProvider).go('newera://hoy');
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byType(HoyPantalla), findsOneWidget);
    });
  });

  test('cambiar el puesto: no admite 0 ni negativos', () async {
    final w = await _mundo();
    final repo = CirculoRepositorio(
      db: w.db,
      reloj: w.reloj,
      contexto: w.contexto,
      eventos: w.eventos,
    );
    final javier = await w.idMiembro('Javier');
    expect(() => repo.cambiarOrdenEscalado(javier, 0), throwsArgumentError);
    await repo.cambiarOrdenEscalado(javier, 1);
    expect(
      (await (w.db.select(
        w.db.miembros,
      )..where((m) => m.id.equals(javier))).getSingle()).ordenEscalado,
      1,
    );
  });
}

/// Canal que tarda: deja que dos envíos se crucen.
final class _CanalLento implements CanalAvisos {
  int publicados = 0;

  @override
  String get nombre => 'ntfy';

  @override
  Future<ResultadoAviso> publicar({
    required String tema,
    required int prioridad,
  }) async {
    publicados++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return ResultadoAviso.enviado;
  }
}
