import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/db/repositorios/medicacion_repositorio.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/features/persona_pastillas/persona_pastillas_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:newera/shared/widgets/boton_grande.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';

/// Ejecuta [f] con un contenedor de la app sobre la base de [e].
Future<void> _conContenedor(
  WidgetTester tester,
  EntornoPrueba e,
  Future<void> Function(ProviderContainer c) f,
) async {
  await tester.runAsync(() async {
    final c = ProviderContainer(overrides: e.overrides);
    try {
      await f(c);
    } finally {
      c.dispose();
    }
  });
}

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

  testWidgets('dos pastillas a las 14:00: las dos resaltadas y con su botón', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    await _conContenedor(tester, entorno!, (c) async {
      await c
          .read(medicacionRepositorioProvider)
          .crear(
            const NuevoMedicamento(
              nombre: 'Medicamento D (ejemplo)',
              nombreParaPersona: 'Pastilla verde',
              forma: 'redonda',
              horas: ['14:00'],
              dosis: '1 comprimido',
            ),
          );
    });
    entorno.reloj.fijar(DateTime.utc(2026, 10, 13, 12, 5)); // 14:05 en Madrid
    await montarApp(tester, entorno, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Cápsula roja'), findsOneWidget);
    expect(find.text('Pastilla verde'), findsOneWidget);
    expect(find.text('AHORA · 14:00 · MEDIODÍA'), findsOneWidget);
    expect(find.text('AHORA · 14:00'), findsOneWidget);
    expect(find.text('Ya me la he tomado'), findsNWidgets(2));
  });

  testWidgets(
    'letra al 130 % en 375×728: el botón de la toma se puede pulsar',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final entorno = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.persona),
      );
      entorno!.reloj.fijar(
        DateTime.utc(2026, 10, 13, 12, 5),
      ); // 14:05 en Madrid
      await montarApp(
        tester,
        entorno,
        ancho: 375,
        alto: 728,
        rutaInicial: '/persona/pastillas',
      );
      await pasar(tester, const Duration(seconds: 1));

      final boton = find.text('Ya me la he tomado');
      await tester.ensureVisible(boton);
      await tester.pump();
      // Lo que hay en el centro del botón es el botón, no "Volver al inicio".
      final volver = tester.getRect(find.byKey(ClavesUi.volverAlInicio));
      final rect = tester.getRect(boton);
      expect(rect.bottom, lessThanOrEqualTo(volver.top));
      await tester.tap(boton);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.confirmarToma), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a las 21:30 con todo tomado: "Mañana a las 09:00, …"', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona),
    );
    final ids = [
      await tester.runAsync(
        () => entorno!.idToma('Cápsula roja', '20261013', '1400'),
      ),
      await tester.runAsync(
        () => entorno!.idToma('Comprimido amarillo', '20261013', '2100'),
      ),
    ];
    await _conContenedor(tester, entorno!, (c) async {
      final eventos = c.read(eventosRepositorioProvider);
      await eventos.registrar(
        TipoEvento.tomaConfirmada,
        sujeto: ids[0],
        ocurridoEn: DateTime.utc(2026, 10, 13, 12, 1),
      );
      await eventos.registrar(
        TipoEvento.tomaConfirmada,
        sujeto: ids[1],
        ocurridoEn: DateTime.utc(2026, 10, 13, 19, 1),
      );
    });
    entorno.reloj.fijar(DateTime.utc(2026, 10, 13, 19, 30)); // 21:30
    await montarApp(tester, entorno, rutaInicial: '/persona/pastillas');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Ya me la he tomado'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Mañana a las 09:00, pastilla blanca pequeña'),
      300,
    );
    expect(
      find.text('Mañana a las 09:00, pastilla blanca pequeña'),
      findsOneWidget,
    );
  });
}
