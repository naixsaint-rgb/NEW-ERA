import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/features/persona_pastillas/persona_pastillas_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';

import 'utiles/app_prueba.dart';

/// Pantallas provisionales de la fase 1: existen, se leen bien y se sale de
/// ellas. Las pantallas de verdad las sustituyen.
void main() {
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
