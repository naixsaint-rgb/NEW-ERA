import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/features/persona_pastillas/persona_pastillas_pantalla.dart';
import 'package:newera/features/pregunta/pregunta_pantalla.dart';
import 'package:newera/features/resumen/resumen_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';

import 'utiles/app_prueba.dart';

/// Pantallas provisionales de la fase 1: existen, se leen bien y se sale de
/// ellas. Las pantallas de verdad las sustituyen.
void main() {
  testWidgets('Resumen: pestaña con su cabecera y el aviso', (tester) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));
    await tester.tap(find.byKey(ClavesUi.pestana('resumen')));
    await pasar(tester, const Duration(seconds: 1));

    expect(find.byType(ResumenPantalla), findsOneWidget);
    expect(find.byKey(ClavesUi.pantallaResumen), findsOneWidget);
    expect(find.text('Resumen'), findsWidgets);
    expect(find.text('En construcción'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    manejador.dispose();
  });

  testWidgets('Mis pastillas (persona): "Volver al inicio" vuelve', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.byType(PersonaPastillasPantalla), findsOneWidget);
    expect(find.byKey(ClavesUi.pantallaMisPastillas), findsOneWidget);
    expect(find.text('Mis pastillas'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    await tester.tap(find.byKey(ClavesUi.volverAlInicio));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
    manejador.dispose();
  });

  testWidgets('Pregunta en modo prueba (familia): vuelve a Medicación', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(
      tester,
      entorno!,
      rutaInicial: '/persona/pregunta?prueba=1',
    );
    await pasar(tester, const Duration(seconds: 1));

    expect(find.byType(PreguntaPantalla), findsOneWidget);
    expect(find.byKey(ClavesUi.pregunta), findsOneWidget);
    expect(find.text('Modo prueba: no se guarda nada.'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    await tester.tap(find.byKey(ClavesUi.volverAlInicio));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Probar pantalla de toma'), findsOneWidget);
    manejador.dispose();
  });

  testWidgets('Pregunta (persona): vuelve al inicio', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/pregunta');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Modo prueba: no se guarda nada.'), findsNothing);
    await tester.tap(find.byKey(ClavesUi.volverAlInicio));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
  });

  for (final ruta in ['/familia/ajustes', '/familia/mas', '/familia/resumen']) {
    testWidgets('$ruta con el texto al 200 % no se rompe', (tester) async {
      final entorno = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      );
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await montarApp(tester, entorno!, rutaInicial: ruta);
      await pasar(tester, const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  }
}
