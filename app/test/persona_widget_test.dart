import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

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

    // El botón verde abre la pantalla de toma de las 14:00.
    await tester.tap(find.byKey(ClavesUi.esLaHora));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
    expect(find.text('Cápsula roja'), findsOneWidget);
  });

  testWidgets('"Mis pastillas" abre las tres tomas de hoy y vuelve', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));

    await tester.ensureVisible(find.byKey(ClavesUi.misPastillas));
    await tester.pump();
    await tester.tap(find.byKey(ClavesUi.misPastillas));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.pantallaMisPastillas), findsOneWidget);
    expect(find.text('Pastilla blanca pequeña'), findsOneWidget);
    expect(find.text('Cápsula roja'), findsOneWidget);
    expect(find.text('Comprimido amarillo'), findsOneWidget);
    // A las 12:00 aún no es la hora de ninguna: no hay botón de toma.
    expect(find.text('Ya me la he tomado'), findsNothing);

    await tester.tap(find.byKey(ClavesUi.volverAlInicio));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
    expect(find.byKey(ClavesUi.pantallaMisPastillas), findsNothing);
  });

  testWidgets('"Mis pastillas" a las 14:05: la de las 14:00 trae su botón', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    entorno!.reloj.fijar(DateTime.utc(2026, 10, 13, 12, 5)); // 14:05 en Madrid
    await montarApp(tester, entorno);
    await pasar(tester, const Duration(seconds: 1));

    await tester.ensureVisible(find.byKey(ClavesUi.misPastillas));
    await tester.pump();
    await tester.tap(find.byKey(ClavesUi.misPastillas));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Pastilla blanca pequeña'), findsOneWidget);
    expect(find.text('Cápsula roja'), findsOneWidget);
    expect(find.text('Comprimido amarillo'), findsOneWidget);
    expect(find.text('AHORA · 14:00 · MEDIODÍA'), findsOneWidget);
    expect(find.text('Ya me la he tomado'), findsOneWidget);

    await tester.ensureVisible(find.text('Ya me la he tomado'));
    await tester.pump();
    await tester.tap(find.text('Ya me la he tomado'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
    expect(find.text('Compartimento: Mediodía'), findsOneWidget);
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

  testWidgets('tocar una cara llama a ese familiar y lo dice', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));

    await tester.ensureVisible(find.text('Javier'));
    await tester.pump();
    await tester.tap(find.text('Javier'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Estoy llamando a Javier.'), findsOneWidget);
    expect(entorno.enlaces.map((u) => u.toString()), contains('tel:000000002'));
    final tipos = await tester.runAsync(
      () => entorno.db
          .select(entorno.db.eventos)
          .get()
          .then((l) => l.map((e) => e.tipo).toList()),
    );
    expect(tipos, contains('llamada_iniciada'));
    expect(tipos, isNot(contains('ayuda_pedida')));
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
    expect(find.text('Hola, Carmen'), findsOneWidget);
    expect(find.text('martes 13 · 14:00'), findsOneWidget);
    expect(find.text('AHORA TOCA'), findsOneWidget);
    expect(find.text('Llamar'), findsOneWidget);
    expect(find.text('Ayuda'), findsOneWidget);

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

  testWidgets('pantalla de toma: "Llamar" y "Ayuda" llaman a Lucía', (
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

    await tester.tap(find.text('Llamar'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Estoy llamando a Lucía.'), findsOneWidget);
    var tipos = await tester.runAsync(
      () => entorno.db
          .select(entorno.db.eventos)
          .get()
          .then((l) => l.map((e) => e.tipo).toList()),
    );
    expect(tipos, contains('llamada_iniciada'));
    expect(tipos, isNot(contains('ayuda_pedida')));

    await tester.tap(find.text('Ayuda'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await pasar(tester, const Duration(seconds: 1));
    tipos = await tester.runAsync(
      () => entorno.db
          .select(entorno.db.eventos)
          .get()
          .then((l) => l.map((e) => e.tipo).toList()),
    );
    expect(tipos, contains('ayuda_pedida'));
    expect(
      entorno.enlaces.where((u) => u.toString() == 'tel:000000001').length,
      2,
    );
    // Sigue en la pantalla de toma.
    expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
  });

  testWidgets('toma en modo prueba: "Llamar" no llama ni guarda nada', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    final id = await tester.runAsync(
      () => entorno!.idToma('Cápsula roja', '20261013', '1400'),
    );
    final antes = await tester.runAsync(
      () => entorno!.db.select(entorno.db.eventos).get(),
    );
    await montarApp(
      tester,
      entorno!,
      rutaInicial: '/persona/toma/$id?prueba=1',
    );
    await pasar(tester, const Duration(seconds: 1));

    await tester.tap(find.text('Llamar'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Modo prueba: no se guarda nada.'), findsOneWidget);
    expect(entorno.enlaces, isEmpty);
    final despues = await tester.runAsync(
      () => entorno.db.select(entorno.db.eventos).get(),
    );
    expect(despues!.length, antes!.length);
  });

  testWidgets('a las 21:30 con todo tomado: "Mañana a las 09:00, …"', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await tester.runAsync(() async {
      final c = ProviderContainer(overrides: entorno!.overrides);
      try {
        final eventos = c.read(eventosRepositorioProvider);
        await eventos.registrar(
          TipoEvento.tomaConfirmada,
          sujeto: await entorno.idToma('Cápsula roja', '20261013', '1400'),
          ocurridoEn: DateTime.utc(2026, 10, 13, 12, 1),
        );
        await eventos.registrar(
          TipoEvento.tomaConfirmada,
          sujeto: await entorno.idToma(
            'Comprimido amarillo',
            '20261013',
            '2100',
          ),
          ocurridoEn: DateTime.utc(2026, 10, 13, 19, 1),
        );
      } finally {
        c.dispose();
      }
    });
    entorno!.reloj.fijar(DateTime.utc(2026, 10, 13, 19, 30)); // 21:30
    await montarApp(tester, entorno);
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Ahora no toca nada'), findsOneWidget);
    expect(
      find.text('Mañana a las 09:00, pastilla blanca pequeña'),
      findsOneWidget,
    );
    expect(find.text('A las 09:00, pastilla blanca pequeña'), findsNothing);
  });
}
