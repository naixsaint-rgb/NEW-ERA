import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/features/persona_pastillas/persona_pastillas_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:newera/shared/widgets/boton_grande.dart';

import 'utiles/app_prueba.dart';

/// "Mis pastillas" de la persona (maqueta D-Persona-Pastillas).
void main() {
  testWidgets('a las 12:00: la de las 09:00 tomada y las demás luego', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.byType(PersonaPastillasPantalla), findsOneWidget);
    expect(find.byKey(ClavesUi.pantallaMisPastillas), findsOneWidget);
    expect(find.text('Mis pastillas'), findsOneWidget);
    expect(find.text('HOY, MARTES'), findsOneWidget);

    expect(find.text('09:00 · Mañana'), findsOneWidget);
    expect(find.text('Pastilla blanca pequeña'), findsOneWidget);
    expect(find.text('Ya tomada'), findsOneWidget);

    // La siguiente (14:00) va resaltada, pero aún no trae botón.
    expect(find.text('14:00 · MEDIODÍA'), findsOneWidget);
    expect(find.text('Cápsula roja'), findsOneWidget);
    expect(find.text('21:00 · Noche'), findsOneWidget);
    expect(find.text('Comprimido amarillo'), findsOneWidget);
    expect(find.text('Luego'), findsNWidgets(2));
    expect(find.text('Ya me la he tomado'), findsNothing);
    expect(find.text('Sin tomar'), findsNothing);

    // Solo "Volver al inicio" como botón grande.
    expect(find.byType(BotonGrande), findsOneWidget);
  });

  testWidgets('a las 14:05: "Ahora" y el botón abre la toma', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    entorno!.reloj.fijar(DateTime.utc(2026, 10, 13, 12, 5)); // 14:05 en Madrid
    await montarApp(tester, entorno, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('AHORA · 14:00 · MEDIODÍA'), findsOneWidget);
    expect(find.text('Luego'), findsOneWidget);
    expect(find.text('Ya me la he tomado'), findsOneWidget);

    await tester.ensureVisible(find.text('Ya me la he tomado'));
    await tester.pump();
    await tester.tap(find.text('Ya me la he tomado'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
    expect(find.text('Compartimento: Mediodía'), findsOneWidget);
  });

  testWidgets('a las 22:30: las que no se tomaron dicen "Sin tomar"', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    entorno!.reloj.fijar(DateTime.utc(2026, 10, 13, 20, 30)); // 22:30
    await montarApp(tester, entorno, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Ya tomada'), findsOneWidget);
    expect(find.text('Sin tomar'), findsNWidgets(2));
    expect(find.text('Luego'), findsNothing);
    // La de las 21:00 aún se puede tomar: va resaltada con su botón.
    expect(find.text('AHORA · 21:00 · NOCHE'), findsOneWidget);
    expect(find.text('Ya me la he tomado'), findsOneWidget);
  });

  testWidgets('sin pastillas: "Hoy no hay pastillas"', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona, sembrar: false),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Hoy no hay pastillas'), findsOneWidget);
    expect(find.byKey(ClavesUi.volverAlInicio), findsOneWidget);
  });

  testWidgets('"Volver" de la cabecera vuelve al inicio', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await montarApp(tester, entorno!, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));

    await tester.tap(find.text('Volver'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
    expect(find.byKey(ClavesUi.pantallaMisPastillas), findsNothing);
  });
}
