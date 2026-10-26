import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/features/medicacion/medicacion_pantalla.dart';
import 'package:newera/features/medicacion/pastillero.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:newera/shared/ios/ios.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';

/// El desplazable de la lista principal (los campos de texto traen los suyos).
Finder _lista() => find
    .descendant(
      of: find.byType(ListView).first,
      matching: find.byType(Scrollable),
    )
    .first;

/// La pestaña Medicación de la familia, con los datos de ejemplo. Con
/// [oscuro], se elige antes el aspecto oscuro en Ajustes.
Future<EntornoPrueba> _abrir(WidgetTester tester, {bool oscuro = false}) async {
  final entorno = await tester.runAsync(
    () => prepararEntorno(perfil: PerfilApp.familia),
  );
  await montarApp(
    tester,
    entorno!,
    rutaInicial: oscuro ? '/familia/ajustes' : '/familia/medicacion',
  );
  await pasar(tester, const Duration(seconds: 1));
  if (oscuro) {
    await tester.tap(find.byKey(ClavesUi.aspecto('oscuro')));
    await pasar(tester, const Duration(seconds: 1));
    await tester.tap(find.byKey(ClavesUi.pestana('medicacion')));
    await pasar(tester, const Duration(seconds: 1));
  }
  return entorno;
}

/// La [CeldaDia] del pastillero de [fecha] (`yyyy-MM-dd`) y [hora].
CeldaDia _celda(WidgetTester tester, String fecha, String hora) {
  final f = find.descendant(
    of: find.byKey(clavePastilleroCelda(fecha, hora)),
    matching: find.byType(CeldaDia),
  );
  expect(f, findsOneWidget, reason: '$fecha $hora');
  return tester.widget<CeldaDia>(f);
}

void main() {
  testWidgets('Medicación: pastillas, prueba y alta de un medicamento', (
    tester,
  ) async {
    final entorno = await _abrir(tester);
    expect(find.text('Probar pantalla de toma'), findsOneWidget);
    // Las tomas de hoy ya no se listan aquí (están en Hoy).
    expect(find.text('Tomas de hoy'), findsNothing);
    await tester.scrollUntilVisible(find.text('Medicamento A (ejemplo)'), 300);
    expect(find.text('Medicamento A (ejemplo)'), findsOneWidget);
    expect(find.text('PASTILLAS · CON SU FOTO'), findsOneWidget);
    // El pie dice dónde se ve la foto hoy, sin prometer lo que aún no hay.
    await tester.scrollUntilVisible(
      find.textContaining('Ella la ve en la alarma y en Mis pastillas'),
      300,
    );
    expect(find.textContaining('vídeo de comprobación'), findsNothing);
    await tester.scrollUntilVisible(find.text('Medicamento A (ejemplo)'), -300);
    expect(find.textContaining('09:00 · 1 comprimido'), findsOneWidget);
    // La foto la hizo quien dio de alta el medicamento (la semilla, la persona).
    expect(find.textContaining('Foto de Carmen · 13 de octubre'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Añadir medicamento'),
      -300,
      scrollable: _lista(),
    );
    await tester.tap(find.text('Añadir medicamento'));
    await pasar(tester, const Duration(seconds: 1));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre del medicamento'),
      'Medicamento D (ejemplo)',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre para la persona'),
      'Pastilla verde',
    );
    final dosis = find.widgetWithText(TextFormField, 'Dosis');
    await tester.scrollUntilVisible(dosis, 300, scrollable: _lista());
    await tester.enterText(dosis, '1 comprimido');
    await tester.pump();
    final guardar = find.text('Guardar medicamento');
    await tester.scrollUntilVisible(guardar, 300, scrollable: _lista());
    await tester.tap(guardar);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await pasar(tester, const Duration(seconds: 1));

    final meds = await tester.runAsync(
      () => entorno.db.select(entorno.db.medicamentos).get(),
    );
    expect(meds!.map((m) => m.nombre), contains('Medicamento D (ejemplo)'));
    final eventos = await tester.runAsync(
      () => entorno.db.select(entorno.db.eventos).get(),
    );
    expect(eventos!.map((e) => e.tipo), contains('medicamento_creado'));
  });

  testWidgets('el botón Añadir medicamento va bajo la cabecera, sin flotante', (
    tester,
  ) async {
    await _abrir(tester);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(CabeceraGrande), findsOneWidget);
    expect(find.text('PASTILLERO Y PASTILLAS'), findsOneWidget);
    final cabecera = tester.getRect(find.byType(CabeceraGrande));
    final boton = tester.getRect(
      find.widgetWithText(FilledButton, 'Añadir medicamento'),
    );
    expect(boton.top, greaterThanOrEqualTo(cabecera.bottom));
    expect(boton.right, closeTo(390 - 20, 0.5));
    expect(boton.height, greaterThanOrEqualTo(44));
  });

  testWidgets('pastillero: 7 columnas, 3 filas y el estado de cada toma', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    await _abrir(tester);
    final pastillero = find.byKey(ClavesUi.pastillero);
    expect(pastillero, findsOneWidget);
    expect(find.text('Pastillero de la semana'), findsOneWidget);

    // Cabecera L M X J V S D con el martes (hoy) en azul.
    for (final d in ['L', 'M', 'X', 'J', 'V', 'S', 'D']) {
      expect(
        find.descendant(of: pastillero, matching: find.text(d)),
        findsOneWidget,
        reason: d,
      );
    }
    expect(
      tester
          .widget<Text>(
            find.descendant(of: pastillero, matching: find.text('M')),
          )
          .style
          ?.color,
      const Color(0xFF0066CC),
    );
    // Una fila por hora distinta.
    for (final h in ['09:00', '14:00', '21:00']) {
      expect(
        find.descendant(of: pastillero, matching: find.text(h)),
        findsOneWidget,
        reason: h,
      );
    }
    expect(
      find.descendant(of: pastillero, matching: find.byType(CeldaDia)),
      findsNWidgets(21),
    );

    // Semana del 12 al 18 de octubre de 2026; hoy es martes 13, 12:00.
    expect(_celda(tester, '2026-10-12', '09:00').estado, EstadoCelda.completa);
    expect(_celda(tester, '2026-10-12', '14:00').estado, EstadoCelda.completa);
    expect(_celda(tester, '2026-10-12', '21:00').estado, EstadoCelda.fallida);
    final martes = _celda(tester, '2026-10-13', '09:00');
    expect(martes.estado, EstadoCelda.completa);
    expect(martes.etiquetaSemantica, 'Martes 09:00: tomada');
    expect(
      tester
          .getSemantics(find.byKey(clavePastilleroCelda('2026-10-13', '09:00')))
          .label,
      'Martes 09:00: tomada',
    );
    expect(_celda(tester, '2026-10-13', '14:00').estado, EstadoCelda.hoy);
    expect(_celda(tester, '2026-10-13', '21:00').estado, EstadoCelda.futura);
    expect(_celda(tester, '2026-10-18', '09:00').estado, EstadoCelda.futura);
    expect(
      _celda(tester, '2026-10-12', '21:00').etiquetaSemantica,
      'Lunes 21:00: no confirmada',
    );
    manejador.dispose();
  });

  test('semanaDe: de lunes a domingo en la zona de la persona', () {
    // Domingo 18/10/2026 23:30 en Madrid (21:30Z): sigue siendo la misma semana.
    final s = semanaDe(DateTime.utc(2026, 10, 18, 21, 30), 'Europe/Madrid');
    expect(s.fechas.first, '2026-10-12');
    expect(s.fechas.last, '2026-10-18');
    expect(s.indiceHoy, 6);
    expect(s.inicio, DateTime.utc(2026, 10, 11, 22));
    expect(s.fin, DateTime.utc(2026, 10, 18, 22));
    // Lunes 19 a las 00:30 en Madrid (22:30Z del domingo): ya es otra semana.
    final n = semanaDe(DateTime.utc(2026, 10, 18, 22, 30), 'Europe/Madrid');
    expect(n.fechas.first, '2026-10-19');
    expect(n.indiceHoy, 0);
    // Semana del cambio de hora (25/10/2026): el lunes siguiente es UTC+1.
    final c = semanaDe(DateTime.utc(2026, 10, 25, 10), 'Europe/Madrid');
    expect(c.fin, DateTime.utc(2026, 10, 25, 23));
  });

  testWidgets('Probar pantalla de toma abre la toma en modo prueba', (
    tester,
  ) async {
    await _abrir(tester);
    await tester.tap(find.text('Probar pantalla de toma'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
  });

  testWidgets('Probar pregunta abre la pantalla de pregunta', (tester) async {
    await _abrir(tester);
    final probar = find.byKey(ClavesUi.probarPregunta);
    await tester.ensureVisible(probar);
    await tester.pump();
    await tester.tap(probar);
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.pregunta), findsOneWidget);
  });

  testWidgets('una pastilla abre su ficha', (tester) async {
    await _abrir(tester);
    final fila = find.text('Medicamento B (ejemplo)');
    await tester.scrollUntilVisible(fila, 300);
    await tester.ensureVisible(fila);
    await tester.pump();
    await tester.tap(fila);
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Cápsula roja'), findsWidgets);
    expect(find.text('Cambiar la pauta'), findsOneWidget);
  });

  for (final oscuro in [false, true]) {
    testWidgets(
      'Medicación en ${oscuro ? 'oscuro' : 'claro'}: contraste y zonas táctiles',
      (tester) async {
        final manejador = tester.ensureSemantics();
        await _abrir(tester, oscuro: oscuro);
        expect(
          Theme.of(tester.element(find.byType(MedicacionPantalla))).brightness,
          oscuro ? Brightness.dark : Brightness.light,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // Y más abajo, con la lista de pastillas a la vista.
        await tester.scrollUntilVisible(
          find.text('Medicamento C (ejemplo)'),
          300,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        manejador.dispose();
      },
    );
  }

  testWidgets('pastillero: si la pauta cambia de hora, la hora antigua sigue', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    // El martes a las 12:00 la pastilla de las 09:00 pasa a las 10:00.
    await tester.runAsync(() async {
      final meds = await entorno!.db.select(entorno.db.medicamentos).get();
      final med = meds.firstWhere(
        (m) => m.nombreParaPersona == 'Pastilla blanca pequeña',
      );
      final pautas = await entorno.db.select(entorno.db.pautas).get();
      final pauta = pautas.firstWhere((p) => p.medicamentoId == med.id);
      final c = ProviderContainer(overrides: entorno.overrides);
      try {
        await c
            .read(medicacionRepositorioProvider)
            .cambiarPauta(
              pautaId: pauta.pautaId,
              motivo: 'Cambio de prueba',
              horas: const ['10:00'],
              diasSemana: pauta.diasSemana,
              dosis: pauta.dosis,
              compartimento: pauta.compartimento,
              comprobacion: TipoComprobacion.desdeNombre(pauta.comprobacion),
              segundosVideo: pauta.segundosVideo,
            );
      } finally {
        c.dispose();
      }
    });
    await montarApp(tester, entorno!, rutaInicial: '/familia/medicacion');
    await pasar(tester, const Duration(seconds: 1));

    final pastillero = find.byKey(ClavesUi.pastillero);
    for (final h in ['09:00', '10:00', '14:00', '21:00']) {
      expect(
        find.descendant(of: pastillero, matching: find.text(h)),
        findsOneWidget,
        reason: h,
      );
    }
    // Lunes y martes a las 09:00, con la pauta antigua: tomadas.
    expect(_celda(tester, '2026-10-12', '09:00').estado, EstadoCelda.completa);
    expect(_celda(tester, '2026-10-13', '09:00').estado, EstadoCelda.completa);
    // Desde el miércoles, a las 10:00.
    expect(_celda(tester, '2026-10-14', '10:00').estado, EstadoCelda.futura);
  });
}
