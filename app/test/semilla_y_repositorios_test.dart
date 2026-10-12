import 'dart:math';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/png_marcador.dart';
import 'package:newera/core/db/repositorios/circulo_repositorio.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/db/repositorios/medicacion_repositorio.dart';
import 'package:newera/core/contexto.dart';
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
      expect(ev.map((e) => e.tipo), ['medicamento_creado']);
      expect(ev.single.sujeto, id);
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
      final ev = await db.select(db.eventos).get();
      expect(ev.single.tipo, 'ficha_modificada');
      final payload = EventosRepositorio.payloadDe(ev.single);
      expect(payload['tabla'], 'personas');
      expect((payload['antes']! as Map)['alias'], 'Persona');
      expect((payload['despues']! as Map)['alias'], 'Carmen');
    },
  );

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
