import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/providers.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;

import 'utiles/base_prueba.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test('en móvil el almacén no tiene reserva en memoria; en web sí', () {
    expect(
      Arranque.almacenPorDefecto(esWeb: false),
      isA<AlmacenSeguroFlutter>(),
    );
    expect(
      Arranque.almacenPorDefecto(esWeb: true),
      isA<AlmacenSeguroConReserva>(),
    );
  });

  test('la clave del círculo son 64 caracteres hexadecimales', () {
    final a = ClaveCirculo.generar();
    final b = ClaveCirculo.generar();
    expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(a, isNot(b));
  });

  test(
    'el primer arranque crea círculo, persona e ids; no crea dispositivo',
    () async {
      final almacen = AlmacenSeguroMemoria();
      final overrides = await Arranque.iniciar(
        almacen: almacen,
        ejecutor: ejecutorEnMemoria(),
        plataforma: 'ios',
        demoWeb: false,
        sembrarDemo: false,
      );
      final c = ProviderContainer(overrides: overrides);
      addTearDown(c.dispose);
      final ctx = c.read(contextoProvider);
      final db = c.read(baseDatosProvider);
      expect(ctx.plataforma, 'ios');
      expect(await almacen.leer(ClavesAlmacen.circuloId), ctx.circuloId);
      expect(
        await almacen.leer(ClavesAlmacen.dispositivoId),
        ctx.dispositivoId,
      );
      final clave = await almacen.leer(ClavesAlmacen.circuloClave);
      expect(clave, hasLength(64));
      expect(await almacen.leer(ClavesAlmacen.circuloClaveVersion), '1');
      expect((await db.select(db.circulos).getSingle()).id, ctx.circuloId);
      expect((await db.select(db.personas).getSingle()).alias, 'Persona');
      expect(await db.select(db.dispositivos).get(), isEmpty);
      expect(c.read(sesionInicialProvider).perfil, isNull);
    },
  );

  test(
    'con perfil familia se crea el miembro Responsable y el dispositivo',
    () async {
      final almacen = AlmacenSeguroMemoria({ClavesAlmacen.perfil: 'familia'});
      final overrides = await Arranque.iniciar(
        almacen: almacen,
        ejecutor: ejecutorEnMemoria(),
        plataforma: 'android',
        demoWeb: false,
        sembrarDemo: false,
      );
      final c = ProviderContainer(overrides: overrides);
      addTearDown(c.dispose);
      final db = c.read(baseDatosProvider);
      final miembro = await db.select(db.miembros).getSingle();
      expect(miembro.nombre, 'Responsable');
      expect(miembro.ordenEscalado, 1);
      expect(miembro.rol, 'responsable');
      final d = await db.select(db.dispositivos).getSingle();
      expect(d.perfil, 'familia');
      expect(d.plataforma, 'android');
      expect(d.miembroId, miembro.id);
      final sesion = c.read(sesionInicialProvider);
      expect(sesion.perfil, PerfilApp.familia);
      expect(sesion.miembroId, miembro.id);
    },
  );

  test(
    'en la demo web, con la base vacía, se cargan los datos de ejemplo una vez',
    () async {
      final almacen = AlmacenSeguroMemoria();
      final overrides = await Arranque.iniciar(
        almacen: almacen,
        ejecutor: ejecutorEnMemoria(),
        plataforma: 'web',
        demoWeb: true,
      );
      final c = ProviderContainer(overrides: overrides);
      addTearDown(c.dispose);
      final db = c.read(baseDatosProvider);
      expect((await db.select(db.personas).getSingle()).alias, 'Carmen');
      final miembros = await db.select(db.miembros).get();
      expect(miembros.map((m) => m.nombre).toSet(), {
        'Lucía',
        'Javier',
        'Marta',
      });
      expect(miembros.map((m) => m.telefono).toSet(), {
        '000000001',
        '000000002',
        '000000003',
      });
      final meds = await db.select(db.medicamentos).get();
      expect(meds.map((m) => m.nombreParaPersona), [
        'Pastilla blanca pequeña',
        'Cápsula roja',
        'Comprimido amarillo',
      ]);
      // Sin clave en web (demo sin cifrar).
      expect(await almacen.leer(ClavesAlmacen.circuloClave), isNull);
      final eventos = await db.select(db.eventos).get();
      expect(eventos.where((e) => e.tipo == 'mensaje_familia'), hasLength(1));
      expect(
        eventos.where((e) => e.tipo == 'medicamento_creado'),
        hasLength(3),
      );
    },
  );
}
