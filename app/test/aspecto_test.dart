import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/app.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/enrutado/familia_shell.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/tema/aspecto.dart';
import 'package:newera/features/ajustes/ajustes_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';

ThemeMode? _modo(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;

Brightness _brillo(WidgetTester tester, Type pantalla) =>
    Theme.of(tester.element(find.byType(pantalla))).brightness;

AlmacenSeguro _almacen(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(NewEraApp)))
        .read(almacenSeguroProvider);

/// Contenedor con la familia y el reloj a [hora] (hora de Madrid, 13/10/2026).
ProviderContainer _contenedor({
  required Aspecto aspecto,
  required int hora,
  PerfilApp perfil = PerfilApp.familia,
}) {
  // Octubre de 2026 en Madrid: UTC+2.
  final instante = DateTime.utc(
    2026,
    10,
    13,
    hora,
  ).subtract(const Duration(hours: 2));
  final c = ProviderContainer(
    overrides: [
      contextoProvider.overrideWithValue(
        const ContextoApp(
          circuloId: 'c',
          personaId: 'p',
          dispositivoId: 'd',
          plataforma: 'android',
        ),
      ),
      sesionInicialProvider.overrideWithValue(Sesion(perfil: perfil)),
      aspectoInicialProvider.overrideWithValue(aspecto),
      relojProvider.overrideWithValue(RelojFijo(instante)),
      ahoraProvider.overrideWith((ref) => Stream.value(instante)),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('modoTemaProvider', () {
    test('automático sigue al sistema; claro y oscuro, fijos', () {
      expect(
        _contenedor(
          aspecto: Aspecto.automatico,
          hora: 12,
        ).read(modoTemaProvider),
        ThemeMode.system,
      );
      expect(
        _contenedor(aspecto: Aspecto.claro, hora: 23).read(modoTemaProvider),
        ThemeMode.light,
      );
      expect(
        _contenedor(aspecto: Aspecto.oscuro, hora: 12).read(modoTemaProvider),
        ThemeMode.dark,
      );
    });

    test('noche: oscuro de 22:00 a 08:00 en la hora de la zona', () {
      for (final (hora, esperado) in [
        (21, ThemeMode.light),
        (22, ThemeMode.dark),
        (2, ThemeMode.dark),
        (7, ThemeMode.dark),
        (8, ThemeMode.light),
        (12, ThemeMode.light),
      ]) {
        expect(
          _contenedor(
            aspecto: Aspecto.horas,
            hora: hora,
          ).read(modoTemaProvider),
          esperado,
          reason: '$hora h',
        );
      }
    });

    test('el móvil de la persona va siempre en claro', () {
      expect(
        _contenedor(
          aspecto: Aspecto.oscuro,
          hora: 23,
          perfil: PerfilApp.persona,
        ).read(modoTemaProvider),
        ThemeMode.light,
      );
    });

    test('un valor guardado desconocido vuelve a automático', () {
      expect(Aspecto.desdeNombre('violeta'), Aspecto.automatico);
      expect(Aspecto.desdeNombre(null), Aspecto.automatico);
      for (final a in Aspecto.values) {
        expect(Aspecto.desdeNombre(a.nombre), a);
      }
    });
  });

  test('al arrancar se lee el aspecto guardado', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final overrides = await Arranque.iniciar(
      almacen: AlmacenSeguroMemoria({ClavesAlmacen.aspecto: 'oscuro'}),
      ejecutor: ejecutorEnMemoria(),
      plataforma: 'android',
      demoWeb: false,
      sembrarDemo: false,
    );
    final c = ProviderContainer(overrides: overrides);
    addTearDown(c.dispose);
    expect(c.read(aspectoProvider), Aspecto.oscuro);
    await c.read(baseDatosProvider).close();
  });

  testWidgets('Ajustes → Aspecto cambia el tema al momento y se guarda', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/ajustes');
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Aspecto'), findsOneWidget);
    expect(_modo(tester), ThemeMode.system);
    expect(_brillo(tester, AjustesPantalla), Brightness.light);
    final almacen = _almacen(tester);
    expect(
      await tester.runAsync(() => almacen.leer(ClavesAlmacen.aspecto)),
      isNull,
    );

    await tester.tap(find.byKey(ClavesUi.aspecto('oscuro')));
    await pasar(tester, const Duration(seconds: 1));
    expect(_modo(tester), ThemeMode.dark);
    expect(_brillo(tester, AjustesPantalla), Brightness.dark);
    expect(
      await tester.runAsync(() => almacen.leer(ClavesAlmacen.aspecto)),
      'oscuro',
    );

    await tester.tap(find.byKey(ClavesUi.aspecto('claro')));
    await pasar(tester, const Duration(seconds: 1));
    expect(_modo(tester), ThemeMode.light);
    expect(_brillo(tester, AjustesPantalla), Brightness.light);
    expect(
      await tester.runAsync(() => almacen.leer(ClavesAlmacen.aspecto)),
      'claro',
    );

    // Noche: a las 12:00 de Madrid toca claro.
    await tester.tap(find.byKey(ClavesUi.aspecto('horas')));
    await pasar(tester, const Duration(seconds: 1));
    expect(_modo(tester), ThemeMode.light);
    expect(
      await tester.runAsync(() => almacen.leer(ClavesAlmacen.aspecto)),
      'horas',
    );

    await tester.tap(find.byKey(ClavesUi.aspecto('automatico')));
    await pasar(tester, const Duration(seconds: 1));
    expect(_modo(tester), ThemeMode.system);
    expect(
      await tester.runAsync(() => almacen.leer(ClavesAlmacen.aspecto)),
      'automatico',
    );
    expect(tester.takeException(), isNull);
  });

  for (final aspecto in [Aspecto.claro, Aspecto.oscuro]) {
    for (final mas in [false, true]) {
      final pantalla = mas ? 'Más' : 'Ajustes';
      testWidgets(
        '$pantalla en ${aspecto.nombre}: contraste y zonas táctiles',
        (tester) async {
          final manejador = tester.ensureSemantics();
          final entorno = await tester.runAsync(
            () => prepararEntorno(perfil: PerfilApp.familia),
          );
          await montarApp(tester, entorno!, rutaInicial: '/familia/ajustes');
          await pasar(tester, const Duration(seconds: 1));
          await tester.tap(find.byKey(ClavesUi.aspecto(aspecto.nombre)));
          await pasar(tester, const Duration(seconds: 1));
          if (mas) {
            await tester.tap(find.byKey(ClavesUi.pestana('mas')));
            await pasar(tester, const Duration(seconds: 1));
            expect(find.byType(MasPantalla), findsOneWidget);
          }
          expect(
            _modo(tester),
            aspecto == Aspecto.oscuro ? ThemeMode.dark : ThemeMode.light,
          );

          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          manejador.dispose();
        },
      );
    }
  }
}
