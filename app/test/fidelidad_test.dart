import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/features/hoy/hoy_pantalla.dart';
import 'package:newera/features/hoy/vistas/piezas_hoy.dart';
import 'package:newera/features/persona_inicio/llamadas.dart';
import 'package:newera/features/resumen/resumen_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';

/// Hora de Madrid (UTC+2 el 13/10/2026) a UTC.
DateTime _madrid(int hora, int minuto) =>
    DateTime.utc(2026, 10, 13, hora - 2, minuto);

/// Monta la familia (empieza en Hoy) con el reloj a [ahora].
Future<EntornoPrueba> _montarFamilia(
  WidgetTester tester, {
  DateTime? ahora,
  Future<void> Function(EntornoPrueba e, ProviderContainer c)? antes,
  double ancho = 390,
  double alto = 844,
}) async {
  final entorno = await tester.runAsync(
    () => prepararEntorno(perfil: PerfilApp.familia),
  );
  if (antes != null) {
    await tester.runAsync(() async {
      final c = ProviderContainer(overrides: entorno!.overrides);
      try {
        await antes(entorno, c);
      } finally {
        c.dispose();
      }
    });
  }
  if (ahora != null) entorno!.reloj.fijar(ahora);
  await montarApp(tester, entorno!, ancho: ancho, alto: alto);
  await pasar(tester, const Duration(seconds: 1));
  expect(find.byType(HoyPantalla), findsOneWidget);
  return entorno;
}

Future<void> _irAResumen(WidgetTester tester) async {
  await tester.tap(find.byKey(ClavesUi.pestana('resumen')));
  await pasar(tester, const Duration(seconds: 1));
  expect(find.byType(ResumenPantalla), findsOneWidget);
}

/// `true` si el texto [texto] se pinta entero en una sola línea (ni partido
/// ni cortado con "…").
bool _enUnaLinea(WidgetTester tester, Finder texto) {
  final p = tester.renderObject<RenderParagraph>(texto);
  final medida = TextPainter(
    text: p.text,
    textDirection: TextDirection.ltr,
    textScaler: p.textScaler,
    maxLines: 1,
  )..layout();
  final una =
      (p.size.height - medida.height).abs() < 0.5 &&
      (p.size.width - medida.width).abs() < 0.5;
  medida.dispose();
  return una;
}

void main() {
  testWidgets('una toma cerrada por un familiar cuenta igual en Hoy y en '
      'Resumen', (tester) async {
    await _montarFamilia(
      tester,
      antes: (e, c) async {
        final miembros = await e.db.select(e.db.miembros).get();
        final lucia = miembros.firstWhere((m) => m.nombre == 'Lucía');
        await c
            .read(eventosRepositorioProvider)
            .registrar(
              TipoEvento.tomaCerradaPorFamiliar,
              sujeto: await e.idToma('Cápsula roja', '20261013', '1400'),
              ocurridoEn: _madrid(11, 50),
              autor: lucia.id,
            );
      },
    );
    // Hoy: 09:00 confirmada y 14:00 cerrada por Lucía.
    expect(find.text('2 de 3'), findsOneWidget);
    await _irAResumen(tester);
    expect(find.text('2 de 3'), findsOneWidget);
  });

  group('semáforo: naranja desde el aviso al familiar 1', () {
    testWidgets('a las 14:20 sin confirmar la de las 14:00: naranja', (
      tester,
    ) async {
      final manejador = tester.ensureSemantics();
      await _montarFamilia(tester, ahora: _madrid(14, 20));
      expect(find.text('Una toma se retrasa'), findsOneWidget);
      expect(find.text('Todo en orden por ahora'), findsNothing);
      expect(
        tester.getSemantics(find.byKey(ClavesUi.semaforo)).label,
        contains('Una toma se retrasa'),
      );
      await _irAResumen(tester);
      expect(find.text('Carmen: una toma se retrasa'), findsOneWidget);
      expect(find.text('Tomas de Carmen al día'), findsNothing);
      manejador.dispose();
    });

    testWidgets('a las 14:03 sigue verde', (tester) async {
      await _montarFamilia(tester, ahora: _madrid(14, 3));
      expect(find.text('Todo en orden por ahora'), findsOneWidget);
      expect(find.text('Una toma se retrasa'), findsNothing);
      await _irAResumen(tester);
      expect(find.text('Tomas de Carmen al día'), findsOneWidget);
    });
  });

  test('familiaresPorOrden: solo los que tienen orden; si nadie, todos', () {
    Miembro m(String id, int? orden) => Miembro(
      id: id,
      circuloId: 'c',
      nombre: id,
      relacion: 'r',
      rol: 'apoyo',
      ordenEscalado: orden,
      enMiGente: true,
      creadoEn: 0,
    );
    String ids(List<Miembro> l) =>
        familiaresPorOrden(l).map((x) => x.id).join();
    expect(ids([m('a', null), m('b', 2), m('c', 1)]), 'cb');
    expect(ids([m('a', 1), m('b', 1)]), 'ab');
    expect(ids([m('a', null), m('b', null)]), 'ab');
    expect(familiaresPorOrden(const []), isEmpty);
    expect(primerFamiliar([m('a', null), m('b', 2), m('c', 1)])?.id, 'c');
  });

  testWidgets('toma al 130 % en 375 de ancho: "Llamar" en una línea', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    final id = await tester.runAsync(
      () => entorno!.idToma('Cápsula roja', '20261013', '1400'),
    );
    await montarApp(
      tester,
      entorno!,
      ancho: 375,
      alto: 728,
      rutaInicial: '/persona/toma/$id',
    );
    await pasar(tester, const Duration(seconds: 1));
    for (final t in ['Llamar', 'Ayuda']) {
      final f = find.text(t);
      await tester.ensureVisible(f);
      await tester.pump();
      expect(_enUnaLinea(tester, f), isTrue, reason: t);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('al 200 %: horas, casillas y etiquetas sin partir palabras', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await _montarFamilia(tester);

    // Hoy: casillas y la hora de cada toma.
    for (final t in ['Tomas', 'Vídeos', 'Avisos']) {
      expect(_enUnaLinea(tester, find.text(t)), isTrue, reason: t);
    }
    final hora = find.descendant(
      of: find.byType(FilaTomaHoy),
      matching: find.text('09:00'),
    );
    await tester.scrollUntilVisible(hora, 300);
    expect(_enUnaLinea(tester, hora), isTrue, reason: '09:00');

    // Semana: las etiquetas de la rejilla.
    await tester.drag(find.byType(ListView).first, const Offset(0, 4000));
    await pasar(tester, const Duration(milliseconds: 500));
    await tester.tap(find.byKey(ClavesUi.segmento('semana')));
    await pasar(tester, const Duration(milliseconds: 600));
    for (final t in ['Tomas', 'Respondió']) {
      final f = find.text(t);
      await tester.scrollUntilVisible(f, 300);
      expect(_enUnaLinea(tester, f), isTrue, reason: t);
    }

    // Resumen: títulos de las tarjetas y "siguiente 14:00".
    await _irAResumen(tester);
    for (final t in ['Tomas', 'Mensaje', 'siguiente 14:00']) {
      final f = find.text(t);
      await tester.ensureVisible(f);
      await tester.pump();
      expect(_enUnaLinea(tester, f), isTrue, reason: t);
    }
    expect(tester.takeException(), isNull);
  });
}
