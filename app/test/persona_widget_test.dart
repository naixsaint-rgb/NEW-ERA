import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/shared/claves_ui.dart';

import 'utiles/app_prueba.dart';

void main() {
  testWidgets('inicio de la persona: lo siguiente, mi gente y ayuda', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Martes 13 de octubre'), findsOneWidget);
    expect(find.text('Por la mañana'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
    expect(find.text('A las 14:00, cápsula roja'), findsOneWidget);
    expect(find.text('Mi gente'), findsOneWidget);
    expect(find.text('Lucía'), findsOneWidget);
    expect(find.text('Javier'), findsOneWidget);
    expect(find.text('Marta'), findsOneWidget);
    expect(find.byKey(ClavesUi.necesitoAyuda), findsOneWidget);
    expect(find.textContaining('Un abrazo grande'), findsOneWidget);
    // Aún no es la hora de la pastilla de las 14:00.
    expect(find.byKey(ClavesUi.esLaHora), findsNothing);
  });

  testWidgets('a su hora aparece el botón "Es la hora"', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    entorno!.reloj.fijar(DateTime.utc(2026, 10, 13, 12, 5)); // 14:05 en Madrid
    await montarApp(tester, entorno);
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.esLaHora), findsOneWidget);
    expect(find.text('Es la hora: cápsula roja'), findsOneWidget);
  });

  testWidgets('necesito ayuda deja el evento y avisa al familiar 1', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));

    await tester.tap(find.byKey(ClavesUi.necesitoAyuda));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Estoy llamando a Lucía.'), findsOneWidget);
    expect(entorno.enlaces.map((u) => u.toString()), contains('tel:000000001'));
    final tipos = await tester.runAsync(
      () => entorno.db
          .select(entorno.db.eventos)
          .get()
          .then((l) => l.map((e) => e.tipo).toList()),
    );
    expect(tipos, containsAll(['ayuda_pedida', 'llamada_iniciada']));
  });

  testWidgets('pantalla de toma: confirmar, cámara simulada y "Muy bien"', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    final id = await tester.runAsync(
      () => entorno!.idToma('Cápsula roja', '20261013', '1400'),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/toma/$id');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Cápsula roja'), findsOneWidget);
    expect(find.text('Compartimento: Mediodía'), findsOneWidget);
    expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
    expect(find.text('YA ME LA HE TOMADO'), findsOneWidget);

    await tester.tap(find.byKey(ClavesUi.confirmarToma));
    await tester.pump();
    await pasar(tester, const Duration(milliseconds: 500));
    expect(find.text('Demo: aquí se vería la cámara frontal'), findsOneWidget);
    expect(
      find.text('Enséñame la pastilla y tómatela delante del móvil'),
      findsOneWidget,
    );

    await pasar(tester, const Duration(seconds: 4));
    expect(find.byKey(ClavesUi.muyBien), findsOneWidget);
    expect(find.text('Muy bien'), findsOneWidget);

    await pasar(tester, const Duration(seconds: 5));
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);

    final eventos = await tester.runAsync(
      () => entorno.db.select(entorno.db.eventos).get(),
    );
    final deLaToma = eventos!
        .where((e) => e.sujeto == id)
        .map((e) => e.tipo)
        .toList();
    expect(deLaToma, contains('toma_confirmada'));
    expect(deLaToma, contains('clip_fallido'));
  });

  testWidgets('una toma ya confirmada muestra "Ya está tomada"', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    final id = await tester.runAsync(
      () => entorno!.idToma('Pastilla blanca pequeña', '20261013', '0900'),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/toma/$id');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Ya está tomada'), findsOneWidget);
    expect(find.text('Volver al inicio'), findsOneWidget);
    await tester.tap(find.text('Volver al inicio'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
  });
}
