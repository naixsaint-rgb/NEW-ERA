import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:newera/shared/widgets/boton_grande.dart';

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

  testWidgets('inicio a su hora ("Es la hora"): contraste y tamaño', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    entorno!.reloj.fijar(DateTime.utc(2026, 10, 13, 12, 5)); // 14:05 en Madrid
    await montarApp(tester, entorno);
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.esLaHora), findsOneWidget);

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    manejador.dispose();
  });

  testWidgets('inicio: como mucho tres botones grandes a la vez', (
    tester,
  ) async {
    // Sin "Es la hora" (12:00): "Mis pastillas" y "Necesito ayuda".
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.esLaHora), findsNothing);
    expect(find.byType(BotonGrande), findsNWidgets(2));

    // A su hora (14:05): más "Es la hora", y nada más.
    entorno.reloj.fijar(DateTime.utc(2026, 10, 13, 12, 5));
    await pasar(tester, const Duration(seconds: 16));
    expect(find.byKey(ClavesUi.esLaHora), findsOneWidget);
    expect(find.byType(BotonGrande), findsNWidgets(3));

    // Con el aviso de llamada y el mensaje de la familia sigue habiendo tres.
    await tester.tap(find.byKey(ClavesUi.necesitoAyuda));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Estoy llamando a Lucía.'), findsOneWidget);
    expect(find.byType(BotonGrande), findsNWidgets(3));
  });

  testWidgets('Mis pastillas: contraste y tamaño, antes y a su hora', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.pantallaMisPastillas), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    entorno.reloj.fijar(DateTime.utc(2026, 10, 13, 12, 5)); // 14:05
    await pasar(tester, const Duration(seconds: 16));
    expect(find.text('Ya me la he tomado'), findsOneWidget);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    manejador.dispose();
  });

  testWidgets('toma en modo prueba: contraste y tamaño de los botones', (
    tester,
  ) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    final id = await tester.runAsync(
      () => entorno!.idToma('Cápsula roja', '20261013', '1400'),
    );
    await montarApp(
      tester,
      entorno!,
      rutaInicial: '/persona/toma/$id?prueba=1',
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    manejador.dispose();
  });

  testWidgets('"Ya está tomada": contraste y tamaño del botón', (tester) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    final id = await tester.runAsync(
      () => entorno!.idToma('Pastilla blanca pequeña', '20261013', '0900'),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/toma/$id');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Ya está tomada'), findsOneWidget);

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

    // Lo mismo en "Mis pastillas" y en la toma, a su hora.
    entorno.reloj.fijar(DateTime.utc(2026, 10, 13, 12, 5));
    await pasar(tester, const Duration(seconds: 16));
    await tester.ensureVisible(find.byKey(ClavesUi.misPastillas));
    await tester.pump();
    await tester.tap(find.byKey(ClavesUi.misPastillas));
    await pasar(tester, const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Ya me la he tomado'));
    await tester.tap(find.text('Ya me la he tomado'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
