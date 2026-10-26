import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';

import 'utiles/app_prueba.dart';

/// Pantallas de la familia con el texto al 200 % y en oscuro.
void main() {
  const rutas = [
    '/familia/hoy',
    '/familia/resumen',
    '/familia/medicacion',
    '/familia/medicacion/nuevo',
    '/familia/ideas',
  ];

  for (final ruta in rutas) {
    testWidgets('$ruta al 200 %: sin excepciones', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final entorno = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      );
      await montarApp(tester, entorno!, rutaInicial: ruta);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await pasar(tester, const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: ruta);
    });
  }

  for (final ruta in ['/familia/ideas', '/familia/mas', '/familia/ajustes']) {
    testWidgets('$ruta en oscuro: contraste del texto', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final manejador = tester.ensureSemantics();
      final entorno = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      );
      await montarApp(tester, entorno!, rutaInicial: ruta);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      await pasar(tester, const Duration(seconds: 1));
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.dark,
      );
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      manejador.dispose();
    });
  }
}
