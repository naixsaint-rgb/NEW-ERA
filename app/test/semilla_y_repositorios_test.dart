import 'dart:math';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show OrderingTerm, driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/png_marcador.dart';
import 'package:newera/core/db/repositorios/circulo_repositorio.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/db/repositorios/control_horas_repositorio.dart';
import 'package:newera/core/db/repositorios/medicacion_repositorio.dart';
import 'package:newera/core/db/semilla_demo.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/features/hoy/dominio/control_horas.dart';
import 'package:newera/features/hoy/dominio/tomas.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/base_prueba.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    inicializarZonas();
  });

  late AppDatabase db;
  late RelojFijo reloj;
  late MedicacionRepositorio medicacion;
  late EventosRepositorio eventos;
  const ctx = ContextoApp(
    circuloId: 'c1',
    personaId: 'p1',
    dispositivoId: 'd1',
    plataforma: 'android',
  );

  setUp(() async {
    db = baseEnMemoria();
    reloj = RelojFijo(DateTime.utc(2026, 10, 13, 5));
    eventos = EventosRepositorio(
      db: db,
      reloj: reloj,
      azar: _Azar(),
      contexto: ctx,
      autor: () => 'p1',
    );
    final circulo = CirculoRepositorio(
      db: db,
      reloj: reloj,
      contexto: ctx,
      eventos: eventos,
    );
    await circulo.asegurarBase();
    medicacion = MedicacionRepositorio(
      db: db,
      reloj: reloj,
      contexto: ctx,
      eventos: eventos,
      circulo: circulo,
      autor: () => 'p1',
    );
  });

  tearDown(() => db.close());

  NuevoMedicamento nuevo({
    List<String> horas = const ['14:00', '09:00', '09:00'],
  }) => NuevoMedicamento(
    nombre: 'Medicamento X (ejemplo)',
    nombreParaPersona: 'Pastilla de prueba',
    forma: 'redonda',
    horas: horas,
    dosis: '1 comprimido',
    fotoPastilla: FotoNueva(
      PngMarcador.pastilla(forma: 'redonda', color: 0xF5F5F5),
      mime: 'image/png',
    ),
  );

  test(
    'crear guarda foto, medicamento, pauta v1 y el evento en una transacción',
    () async {
      final id = await medicacion.crear(nuevo());
      expect(await db.select(db.fotos).get(), hasLength(1));
      final med = await db.select(db.medicamentos).getSingle();
      expect(med.id, id);
      expect(med.fotoPastillaId, isNotNull);
      final pauta = await db.select(db.pautas).getSingle();
      expect(pauta.version, 1);
      expect(pauta.horas, '["09:00","14:00"]'); // ordenadas y sin repetir
      expect(pauta.activa, isTrue);
      expect(pauta.vigenteDesde, reloj.ahora().millisecondsSinceEpoch);
      final ev = await db.select(db.eventos).get();
      final creado = ev.where((e) => e.tipo == 'medicamento_creado');
      expect(creado.single.sujeto, id);
      // Y las fichas para los demás móviles, en orden: foto, medicamento y
      // pauta (la persona es del arranque).
      final fichas = [
        for (final e in ev)
          if (e.tipo == 'ficha_creada') EventosRepositorio.payloadDe(e)['tipo'],
      ];
      expect(fichas, ['persona', 'foto', 'medicamento', 'pauta']);
    },
  );

  test(
    'cambiar la pauta crea la versión 2; el motivo es obligatorio',
    () async {
      final id = await medicacion.crear(nuevo());
      final v1 = await db.select(db.pautas).getSingle();
      expect(
        () => medicacion.cambiarPauta(
          pautaId: v1.pautaId,
          motivo: '  ',
          horas: const ['10:00'],
          diasSemana: DiasSemana.todos,
          dosis: '2',
          comprobacion: TipoComprobacion.foto,
          segundosVideo: 10,
        ),
        throwsArgumentError,
      );
      reloj.avanzar(const Duration(hours: 3));
      await medicacion.cambiarPauta(
        pautaId: v1.pautaId,
        motivo: 'Cambio indicado en la consulta',
        horas: const ['10:00'],
        diasSemana: DiasSemana.deLista([1, 4]),
        dosis: '2 comprimidos',
        comprobacion: TipoComprobacion.foto,
        segundosVideo: 10,
      );
      final versiones = await medicacion.versionesDeMedicamento(id);
      expect(versiones.map((v) => v.version), [2, 1]);
      expect(versiones.first.motivo, 'Cambio indicado en la consulta');
      expect(
        versiones.first.vigenteDesde,
        reloj.ahora().millisecondsSinceEpoch,
      );

      // Las tomas de v1 hasta el cambio; las de v2 desde entonces.
      final todas = await db.select(db.pautas).get();
      final tomas = proximasTomas(
        versiones: [for (final p in todas) MedicacionRepositorio.aVersion(p)],
        desde: DateTime.utc(2026, 10, 13),
        hasta: DateTime.utc(2026, 10, 16),
      );
      expect(tomas.map((t) => '${t.fechaLocal} ${t.horaLocal}'), [
        '2026-10-13 09:00', // v1, antes del cambio (07:00Z < 08:00Z)
        '2026-10-15 10:00', // v2, jueves
      ]);
    },
  );

  test('suspender crea una versión inactiva y no hay más tomas', () async {
    await medicacion.crear(nuevo());
    final v1 = await db.select(db.pautas).getSingle();
    reloj.avanzar(const Duration(hours: 1));
    await medicacion.suspender(
      pautaId: v1.pautaId,
      motivo: 'Descanso indicado',
    );
    final todas = await db.select(db.pautas).get();
    expect(todas.where((p) => !p.activa), hasLength(1));
    final tomas = proximasTomas(
      versiones: [for (final p in todas) MedicacionRepositorio.aVersion(p)],
      desde: reloj.ahora(),
      hasta: reloj.ahora().add(const Duration(days: 3)),
    );
    expect(tomas, isEmpty);
  });

  test('asegurarToma es INSERT OR IGNORE', () async {
    await medicacion.crear(nuevo());
    final pautas = await db.select(db.pautas).get();
    final tomas = proximasTomas(
      versiones: [for (final p in pautas) MedicacionRepositorio.aVersion(p)],
      desde: reloj.ahora(),
      hasta: reloj.ahora().add(const Duration(days: 1)),
    );
    expect(tomas, isNotEmpty);
    await medicacion.asegurarToma(tomas.first);
    await medicacion.asegurarToma(tomas.first);
    expect(await db.select(db.tomas).get(), hasLength(1));
  });

  test(
    'cambiar el alias deja ficha_modificada en la misma transacción',
    () async {
      final circulo = CirculoRepositorio(
        db: db,
        reloj: reloj,
        contexto: ctx,
        eventos: eventos,
      );
      await circulo.cambiarAlias('Carmen');
      // Sin contar la ficha de la persona del arranque.
      final ev = [
        for (final e in await db.select(db.eventos).get())
          if (e.tipo != 'ficha_creada') e,
      ];
      expect(ev.single.tipo, 'ficha_modificada');
      final payload = EventosRepositorio.payloadDe(ev.single);
      // Lleva además la fila entera para los demás móviles.
      expect(payload['tipo'], 'persona');
      expect((payload['fila']! as Map)['alias'], 'Carmen');
      expect(payload['tabla'], 'personas');
      expect((payload['antes']! as Map)['alias'], 'Persona');
      expect((payload['despues']! as Map)['alias'], 'Carmen');
    },
  );

  group('semilla de la demo: control por horas y avisos', () {
    /// Madrid es UTC+2 el 13/10/2026.
    DateTime m(int hora, [int minuto = 0, int dia = 13, int segundo = 0]) =>
        DateTime.utc(2026, 10, dia, hora - 2, minuto, segundo);

    Future<void> sembrar(DateTime ahora, {bool control = true}) async {
      reloj.fijar(ahora);
      await SemillaDemo.sembrar(
        db: db,
        contexto: ctx,
        reloj: reloj,
        azar: _Azar(),
        control: control,
      );
    }

    Future<List<Evento>> deTipo(String tipo) async =>
        (await (db.select(db.eventos)
              ..where((e) => e.tipo.equals(tipo))
              ..orderBy([(e) => OrderingTerm.asc(e.ocurridoEn)]))
            .get());

    Future<String> idDe(String nombre) async => (await (db.select(
      db.miembros,
    )..where((x) => x.nombre.equals(nombre))).getSingle()).id;

    /// El control de hoy como lo calcula la familia a [ahora].
    Future<ControlDelDia> controlDeHoy(DateTime ahora) async {
      final respuestas = [
        for (final e in await deTipo('pregunta_respondida'))
          ?RespuestaControl.desdeEvento(e),
      ];
      final primer = (await deTipo('perfil_elegido'))
          .firstWhere((e) => e.payload.contains('"persona"'));
      final ajustes = await ControlHorasRepositorio(
        db: db,
        reloj: reloj,
        contexto: ctx,
        eventos: eventos,
        autor: () => 'p1',
      ).ajustes();
      final pautas = await db.select(db.pautas).get();
      final dia = diaLocal(ahora, ctx.zonaHoraria);
      final tomas = [
        for (final t in proximasTomas(
          versiones: [
            for (final p in pautas) MedicacionRepositorio.aVersion(p),
          ],
          desde: dia.inicio.subtract(margenTomaRonda),
          hasta: dia.fin.add(margenTomaRonda),
        ))
          t.previstaPara,
      ];
      return calcularControlDelDia(
        ajustes: ajustes,
        dia: dia,
        zona: ctx.zonaHoraria,
        tomas: tomas,
        respuestas: respuestas,
        ahora: ahora,
        inicio: DateTime.fromMillisecondsSinceEpoch(
          primer.ocurridoEn,
          isUtc: true,
        ),
      );
    }

    test('a las 12:00: 42 respuestas, una ronda sin respuesta y un aviso a '
        'Lucía', () async {
      final ahora = m(12);
      await sembrar(ahora);

      // Ayer: 12 rondas (de 9 a 20; la de las 21:00 no cabe por la toma).
      // Hoy: las de 9, 10 y 11, con la de las 10:00 sin respuesta. Tres
      // preguntas cada una: 14 rondas contestadas, 42 respuestas.
      final preguntas = await db.select(db.preguntasControl).get();
      final respuestas = await db.select(db.respuestas).get();
      expect(preguntas, hasLength(42));
      expect(respuestas, hasLength(42));
      expect({for (final r in respuestas) r.preguntaId}, hasLength(42));
      final eventosRespuesta = await deTipo('pregunta_respondida');
      expect(eventosRespuesta, hasLength(42));
      final rondas = {
        for (final e in eventosRespuesta)
          EventosRepositorio.payloadDe(e)['ronda']! as String,
      };
      expect(rondas, hasLength(14));
      expect(
        rondas.where((r) => r.startsWith('ronda_20261013_')).toList()..sort(),
        ['ronda_20261013_0900', 'ronda_20261013_1100'],
      );
      expect(rondas.contains('ronda_20261013_1000'), isFalse);
      // Ninguna respuesta es del futuro.
      for (final r in respuestas) {
        expect(r.respondidaEn, lessThanOrEqualTo(ahora.millisecondsSinceEpoch));
        expect(r.origen, 'movil');
      }

      // Valores: hoy bien / nada / pasear; ayer lo mismo salvo un «regular»
      // y un «poco» de dolor.
      Map<String, int> cuenta(Iterable<Evento> es) {
        final c = <String, int>{};
        for (final e in es) {
          final p = EventosRepositorio.payloadDe(e);
          final k = '${p['tipo']}:${p['respuesta']}';
          c[k] = (c[k] ?? 0) + 1;
        }
        return c;
      }

      bool deHoy(Evento e) =>
          (EventosRepositorio.payloadDe(e)['ronda']! as String).startsWith(
            'ronda_20261013_',
          );
      expect(cuenta(eventosRespuesta.where(deHoy)), {
        'estado:bien': 2,
        'dolor:nada': 2,
        'plan:pasear': 2,
      });
      expect(cuenta(eventosRespuesta.where((e) => !deHoy(e))), {
        'estado:bien': 11,
        'estado:regular': 1,
        'dolor:nada': 11,
        'dolor:poco': 1,
        'plan:pasear': 12,
      });

      // Ajustes: sin fila, los de por defecto.
      expect(await db.select(db.ajustesControlHoras).get(), isEmpty);

      // La familia espera rondas desde ayer a las 08:00 (primer móvil de la
      // persona) y ve hoy 2 contestadas y 1 sin respuesta.
      final persona = (await deTipo('perfil_elegido'))
          .where((e) => e.payload.contains('"persona"'))
          .toList();
      expect(persona, hasLength(1));
      expect(persona.single.ocurridoEn, m(8, 0, 12).millisecondsSinceEpoch);
      final control = await controlDeHoy(ahora);
      expect(control.contestadas, 2);
      expect(control.sinRespuesta.map((r) => r.ronda.id), [
        'ronda_20261013_1000',
      ]);
      expect(control.dosSeguidasSinRespuesta, isFalse);
      expect(control.nivel, NivelSemaforo.naranja);

      // Un solo aviso, a Lucía, por esa ronda (formato de EnvioAvisos).
      final avisos = await deTipo('aviso_enviado');
      expect(avisos, hasLength(1));
      final aviso = avisos.single;
      expect(aviso.sujeto, 'ronda_20261013_1000');
      expect(aviso.ocurridoEn, m(10, 10, 13, 30).millisecondsSinceEpoch);
      expect(EventosRepositorio.payloadDe(aviso), {
        'tipo': 'ronda_sin_respuesta',
        'miembroId': await idDe('Lucía'),
        'canal': 'ntfy',
        'resultado': 'enviado',
      });
      final envios = agruparEnvios(avisos);
      expect(envios, hasLength(1));
      expect(envios.single.motivo, MotivoAviso.rondaSinRespuesta);
      expect(envios.single.miembros, [await idDe('Lucía')]);

      // Voces: sin audio ni consentimientos (todo «sin grabar»).
      expect(await db.select(db.voces).get(), isEmpty);
      expect(await db.select(db.frases).get(), isEmpty);
      expect(await db.select(db.consentimientos).get(), isEmpty);
    });

    test('a las 23:00: las rondas de hoy llegan hasta las 20:00 y la ronda '
        'sin respuesta es la última que cabe', () async {
      final ahora = m(23);
      await sembrar(ahora);
      // Ayer 12 rondas y hoy otras 12 (de 9 a 20), una sin respuesta.
      expect(await db.select(db.respuestas).get(), hasLength(36 + 33));
      final control = await controlDeHoy(ahora);
      expect(control.contestadas, 11);
      expect(control.sinRespuesta.map((r) => r.ronda.id), [
        'ronda_20261013_2000',
      ]);
      expect(
        (await deTipo('aviso_enviado')).single.sujeto,
        'ronda_20261013_2000',
      );
    });

    test('a las 07:00 solo hay rondas de ayer: sin ronda sin respuesta ni '
        'aviso', () async {
      await sembrar(m(7));
      expect(await db.select(db.respuestas).get(), hasLength(36));
      expect(await deTipo('aviso_enviado'), isEmpty);
      expect(await deTipo('perfil_elegido'), hasLength(1));
    });

    test('con control: false no hay respuestas, aviso ni móvil de la '
        'persona', () async {
      await sembrar(m(12), control: false);
      expect(await db.select(db.medicamentos).get(), hasLength(3));
      expect(await db.select(db.preguntasControl).get(), isEmpty);
      expect(await db.select(db.respuestas).get(), isEmpty);
      expect(await deTipo('pregunta_respondida'), isEmpty);
      expect(await deTipo('aviso_enviado'), isEmpty);
      expect(await deTipo('perfil_elegido'), isEmpty);
    });
  });

  test('los ULID de eventos crecen en orden de inserción', () async {
    final a = await eventos.registrar(TipoEvento.ayudaPedida);
    final b = await eventos.registrar(TipoEvento.ayudaPedida);
    expect(a.compareTo(b), lessThan(0));
  });

  test('los PNG de marcador son imágenes válidas', () async {
    for (final bytes in [
      PngMarcador.pastilla(forma: 'redonda', color: 0xD32F2F),
      PngMarcador.pastilla(forma: 'capsula', color: 0xD32F2F),
      PngMarcador.pastilla(forma: 'ovalada', color: 0xF9D648),
      PngMarcador.pastilla(forma: 'otra', color: 0x42A5F5),
      PngMarcador.caja(color: 0x42A5F5),
    ]) {
      final codec = await ui.instantiateImageCodec(bytes);
      final marco = await codec.getNextFrame();
      expect(marco.image.width, greaterThan(50));
      marco.image.dispose();
      codec.dispose();
    }
  });
}

class _Azar implements Random {
  int _s = 3;
  @override
  bool nextBool() => nextInt(2) == 1;
  @override
  double nextDouble() => nextInt(1 << 20) / (1 << 20);
  @override
  int nextInt(int max) {
    _s = (_s * 1103515245 + 12345) & 0x7fffffff;
    return _s % max;
  }
}
