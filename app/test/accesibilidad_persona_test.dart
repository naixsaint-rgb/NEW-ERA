import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';

import 'utiles/app_prueba.dart';

void main() {
  testWidgets('inicio de la persona: contraste y tamaño de los botones', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    manejador.dispose();
  });

  testWidgets('pantalla de toma: contraste y tamaño de los botones', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    final id = await tester.runAsync(
      () => entorno!.idToma('Cápsula roja', '20261013', '1400'),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/toma/$id');
    await pasar(tester, const Duration(seconds: 1));

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    manejador.dispose();
  });

  testWidgets('con la escala de texto al máximo (1,3) no se rompe el diseño', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    tester.platformDispatcher.textScaleFactorTestValue =
        3.0; // el tema la limita a 1,3
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
