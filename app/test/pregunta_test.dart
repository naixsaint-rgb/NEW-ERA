import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/features/pregunta/pregunta_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';

import 'utiles/app_prueba.dart';

/// La pregunta de la persona (maqueta C-Persona): tres preguntas en orden,
/// "Gracias" con lo contestado y vuelta a Medicación (prueba) o al inicio.
void main() {
  Future<EntornoPrueba> entorno(WidgetTester tester, PerfilApp perfil) async =>
      (await tester.runAsync(() => prepararEntorno(perfil: perfil)))!;

  testWidgets('modo prueba: tres preguntas, Gracias con las respuestas y '
      'vuelta a Medicación', (tester) async {
    final manejador = tester.ensureSemantics();
    final e = await entorno(tester, PerfilApp.familia);
    await montarApp(tester, e, rutaInicial: '/persona/pregunta?prueba=1');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.byType(PreguntaPantalla), findsOneWidget);
    expect(find.byKey(ClavesUi.pregunta), findsOneWidget);

    // Pregunta 1: hora local, progreso, voz de Lucía y tres respuestas.
    expect(find.text('12:00 · pregunta 1 de 3'), findsOneWidget);
    expect(find.text('Te lo pregunta Lucía'), findsOneWidget);
    expect(find.text('Toca para volver a oírla'), findsOneWidget);
    expect(find.text('¿Cómo estás?'), findsOneWidget);
    for (final r in ['bien', 'regular', 'mal']) {
      expect(find.byKey(ClavesUi.respuesta(r)), findsOneWidget, reason: r);
    }
    expect(find.text('Bien'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);
    expect(find.text('Mal'), findsOneWidget);
    expect(find.text('Prefiero decirlo'), findsOneWidget);
    // Los botones de respuesta miden 108 y los dedos llegan sin esfuerzo.
    for (final r in ['bien', 'regular', 'mal']) {
      expect(
        tester.getSize(find.byKey(ClavesUi.respuesta(r))).height,
        108,
        reason: r,
      );
    }
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    // Sin voz grabada todavía: aviso, y sigue en la misma pregunta.
    await tester.tap(find.text('Toca para volver a oírla'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('La voz grabada llega en la semana 5'), findsOneWidget);
    expect(find.text('12:00 · pregunta 1 de 3'), findsOneWidget);

    await tester.tap(find.byKey(ClavesUi.respuesta('regular')));
    await pasar(tester, const Duration(milliseconds: 300));

    // Pregunta 2.
    expect(find.text('12:00 · pregunta 2 de 3'), findsOneWidget);
    expect(find.text('¿Te duele algo?'), findsOneWidget);
    for (final r in ['nada', 'poco', 'mucho']) {
      expect(find.byKey(ClavesUi.respuesta(r)), findsOneWidget, reason: r);
    }
    expect(find.text('Nada'), findsOneWidget);
    expect(find.text('Un poco'), findsOneWidget);
    expect(find.text('Mucho'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tester.tap(find.byKey(ClavesUi.respuesta('poco')));
    await pasar(tester, const Duration(milliseconds: 300));

    // Pregunta 3: cuatro respuestas de 80 en dos filas de dos.
    expect(find.text('12:00 · pregunta 3 de 3'), findsOneWidget);
    expect(find.text('¿Qué vas a hacer luego?'), findsOneWidget);
    final centros = [
      for (final r in ['pasear', 'descansar', 'tele', 'otra'])
        tester.getCenter(find.byKey(ClavesUi.respuesta(r))),
    ];
    expect(centros[0].dy, centros[1].dy);
    expect(centros[2].dy, centros[3].dy);
    expect(centros[2].dy, greaterThan(centros[0].dy));
    expect(centros[0].dx, lessThan(centros[1].dx));
    expect(tester.getSize(find.byKey(ClavesUi.respuesta('tele'))).height, 80);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await tester.tap(find.byKey(ClavesUi.respuesta('tele')));
    await pasar(tester, const Duration(milliseconds: 300));

    // Gracias, con lo contestado en palabras.
    expect(find.text('Gracias'), findsOneWidget);
    expect(find.text('¿Cómo estás?'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);
    expect(find.text('¿Te duele algo?'), findsOneWidget);
    expect(find.text('Un poco'), findsOneWidget);
    expect(find.text('¿Qué vas a hacer luego?'), findsOneWidget);
    expect(find.text('Ver la tele'), findsOneWidget);
    expect(find.text('Modo prueba: no se guarda nada.'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    // A los 2 s vuelve a Medicación.
    await pasar(tester, const Duration(seconds: 3));
    expect(find.text('Gracias'), findsNothing);
    expect(find.text('Probar pantalla de toma'), findsOneWidget);

    // En esta entrega no se guarda nada: ningún evento de pregunta.
    final eventos = await tester.runAsync(
      () => e.db.select(e.db.eventos).get(),
    );
    expect(
      eventos!.where((x) => x.tipo.contains('pregunta')),
      isEmpty,
      reason: 'las respuestas no se guardan todavía',
    );
    manejador.dispose();
  });

  testWidgets('"Prefiero decirlo" avisa y pasa a la siguiente pregunta', (
    tester,
  ) async {
    final e = await entorno(tester, PerfilApp.familia);
    await montarApp(tester, e, rutaInicial: '/persona/pregunta?prueba=1');
    await pasar(tester, const Duration(seconds: 1));

    // Con la letra de los tests la pregunta ocupa dos líneas y el botón queda
    // más abajo: se desplaza hasta verlo.
    Future<void> decirlo() async {
      await tester.ensureVisible(find.text('Prefiero decirlo'));
      await tester.pump();
      await tester.tap(find.text('Prefiero decirlo'));
    }

    await decirlo();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Llega en la semana 5'), findsOneWidget);
    expect(find.text('12:00 · pregunta 2 de 3'), findsOneWidget);
    expect(find.text('¿Te duele algo?'), findsOneWidget);

    // El aviso dura 2 s y tapa el botón: se espera a que se quite.
    await pasar(tester, const Duration(seconds: 3));
    await decirlo();
    await pasar(tester, const Duration(seconds: 3));
    await decirlo();
    await pasar(tester, const Duration(milliseconds: 300));
    expect(find.text('Gracias'), findsOneWidget);
    expect(find.text('Prefiero decirlo'), findsNWidgets(3));
    await pasar(tester, const Duration(seconds: 3));
    expect(find.text('Probar pantalla de toma'), findsOneWidget);
  });

  testWidgets('persona sin modo prueba: al terminar vuelve al inicio', (
    tester,
  ) async {
    final e = await entorno(tester, PerfilApp.persona);
    await montarApp(tester, e, rutaInicial: '/persona/pregunta');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Te lo pregunta Lucía'), findsOneWidget);

    await tester.tap(find.byKey(ClavesUi.respuesta('bien')));
    await pasar(tester, const Duration(milliseconds: 300));
    await tester.tap(find.byKey(ClavesUi.respuesta('nada')));
    await pasar(tester, const Duration(milliseconds: 300));
    await tester.tap(find.byKey(ClavesUi.respuesta('pasear')));
    await pasar(tester, const Duration(milliseconds: 300));
    expect(find.text('Gracias'), findsOneWidget);
    expect(find.text('Bien'), findsOneWidget);
    expect(find.text('Nada'), findsOneWidget);
    expect(find.text('Pasear'), findsOneWidget);
    expect(find.text('Modo prueba: no se guarda nada.'), findsNothing);

    await pasar(tester, const Duration(seconds: 3));
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
  });

  testWidgets('sin familiares con puesto de aviso: "tu familia"', (
    tester,
  ) async {
    final e = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona, sembrar: false),
    );
    await montarApp(tester, e!, rutaInicial: '/persona/pregunta');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Te lo pregunta tu familia'), findsOneWidget);
    expect(find.text('Te lo pregunta Lucía'), findsNothing);
  });

  testWidgets('con el texto al 130 % las cuatro respuestas caben, una '
      'debajo de otra', (tester) async {
    final e = await entorno(tester, PerfilApp.persona);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await montarApp(tester, e, rutaInicial: '/persona/pregunta');
    await pasar(tester, const Duration(seconds: 1));
    await tester.tap(find.byKey(ClavesUi.respuesta('bien')));
    await pasar(tester, const Duration(milliseconds: 300));
    await tester.tap(find.byKey(ClavesUi.respuesta('nada')));
    await pasar(tester, const Duration(milliseconds: 300));
    expect(find.text('¿Qué vas a hacer luego?'), findsOneWidget);
    final y = [
      for (final r in ['pasear', 'descansar', 'tele', 'otra'])
        tester.getTopLeft(find.byKey(ClavesUi.respuesta(r))).dy,
    ];
    expect(y, orderedEquals([...y]..sort()));
    expect(y.toSet(), hasLength(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('el diseño de la pantalla es siempre claro', (tester) async {
    final e = await entorno(tester, PerfilApp.persona);
    await montarApp(tester, e, rutaInicial: '/persona/pregunta');
    await pasar(tester, const Duration(seconds: 1));
    final tema = Theme.of(tester.element(find.byType(PreguntaPantalla)));
    expect(tema.brightness, Brightness.light);
    final scaffold = tester.widget<Scaffold>(find.byKey(ClavesUi.pregunta));
    expect(scaffold.backgroundColor, Colors.white);
  });
}
