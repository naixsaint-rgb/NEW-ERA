import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/enrutado/familia_shell.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/shared/claves_ui.dart';

import 'utiles/app_prueba.dart';

void main() {
  const etiquetas = [
    'Hoy',
    'Resumen',
    'Medicación',
    'Calendario',
    'Consultas',
    'Alarmas',
    'Voces',
    'Alimentación',
    'Ideas y tablas',
    'Círculo',
    'Ajustes',
  ];

  testWidgets('pantalla ancha: las 11 secciones con sus etiquetas', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, ancho: 1280, alto: 800);
    await pasar(tester, const Duration(seconds: 1));

    expect(Rutas.slugs, hasLength(11));
    for (final slug in Rutas.slugs) {
      expect(find.byKey(ClavesUi.pestana(slug)), findsOneWidget, reason: slug);
    }
    // En pantalla ancha no hay botón "Más": el carril lo tiene todo.
    expect(find.byKey(ClavesUi.pestana('mas')), findsNothing);
    for (final e in etiquetas) {
      expect(find.text(e), findsWidgets, reason: e);
    }
    // Navegar por cada pestaña no rompe nada.
    for (final slug in Rutas.slugs) {
      await tester.tap(find.byKey(ClavesUi.pestana(slug)));
      await pasar(tester, const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull, reason: slug);
    }
  });

  testWidgets('pantalla estrecha: cinco pestañas y Más con seis', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));

    const barra = ['hoy', 'resumen', 'medicacion', 'alimentacion', 'ideas'];
    const enMas = [
      'calendario',
      'consultas',
      'alarmas',
      'voces',
      'circulo',
      'ajustes',
    ];
    for (final slug in [...barra, 'mas']) {
      expect(find.byKey(ClavesUi.pestana(slug)), findsOneWidget, reason: slug);
    }
    for (final slug in enMas) {
      expect(find.byKey(ClavesUi.pestana(slug)), findsNothing, reason: slug);
    }
    // Las cinco pestañas, en orden de izquierda a derecha.
    final xs = [
      for (final slug in barra)
        tester.getCenter(find.byKey(ClavesUi.pestana(slug))).dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));
    // El botón "Más" va arriba a la derecha.
    final mas = tester.getRect(find.byKey(ClavesUi.pestana('mas')));
    expect(mas.right, closeTo(390 - 16, 0.5));
    expect(mas.top, closeTo(8, 0.5));

    // Cada pestaña de la barra abre su sección y el botón "Más" sigue ahí.
    for (final slug in barra.reversed) {
      await tester.tap(find.byKey(ClavesUi.pestana(slug)));
      await pasar(tester, const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull, reason: slug);
      expect(find.byKey(ClavesUi.pestana('mas')), findsOneWidget, reason: slug);
    }

    await tester.tap(find.byKey(ClavesUi.pestana('mas')));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byType(MasPantalla), findsOneWidget);
    for (final slug in enMas) {
      expect(find.byKey(ClavesUi.pestana(slug)), findsOneWidget, reason: slug);
    }
    // "Volver" deja la pestaña donde estaba.
    await tester.tap(find.text('Volver'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byType(MasPantalla), findsNothing);
    expect(find.byKey(ClavesUi.semaforo), findsOneWidget);

    await tester.tap(find.byKey(ClavesUi.pestana('mas')));
    await pasar(tester, const Duration(seconds: 1));
    await tester.tap(find.byKey(ClavesUi.pestana('circulo')));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Lucía'), findsOneWidget);
    // Fuera de la barra (Círculo) ninguna pestaña queda activa, pero siguen
    // las cinco y el botón "Más".
    for (final slug in [...barra, 'mas']) {
      expect(find.byKey(ClavesUi.pestana(slug)), findsOneWidget, reason: slug);
    }
  });

  testWidgets('el botón Más solo sale en las pestañas, no en las anidadas', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/medicacion');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.pestana('mas')), findsOneWidget);

    // Alta de medicamento (anidada, con su AppBar): sin botón Más.
    await tester.tap(find.text('Añadir medicamento'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.pestana('mas')), findsNothing);
    expect(find.byType(AppBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final ruta in [
    '/familia/medicacion/nuevo',
    '/familia/ideas/resumen',
    '/familia/ideas/tema/cobre_metales',
    '/familia/alarmas/control-horas',
  ]) {
    testWidgets('sin botón Más en la pantalla anidada $ruta', (tester) async {
      final entorno = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      );
      await montarApp(tester, entorno!, rutaInicial: ruta);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.pestana('mas')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
