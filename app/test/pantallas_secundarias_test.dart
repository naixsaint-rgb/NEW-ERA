import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/shared/claves_ui.dart';

import 'utiles/app_prueba.dart';

/// Las pantallas secundarias con el aspecto iOS: pasan contraste y objetivos
/// táctiles en claro y en oscuro y conservan los textos de siempre.
class _Caso {
  const _Caso(this.nombre, this.ruta, this.textos, {this.sinPerfil = false});

  final String nombre;
  final String ruta;
  final List<String> textos;

  /// Se monta sin perfil elegido (la pantalla "¿De quién es este móvil?").
  final bool sinPerfil;
}

const _casos = [
  _Caso('Perfil', '/perfil', [
    '¿De quién es este móvil?',
    'De la persona',
    'De un familiar o cuidador',
    'Se puede cambiar más tarde desde Ajustes.',
  ], sinPerfil: true),
  _Caso('Círculo', '/familia/circulo', [
    'Círculo',
    'Lucía',
    'Javier',
    'Marta',
    'Hija · Responsable\nSe le avisa en el puesto 1',
    'Hijo · Cuidador o cuidadora\nSe le avisa en el puesto 2',
  ]),
  _Caso('Alimentación', '/familia/alimentacion', [
    'Alimentación',
    'Lo que tendrá',
    'Registro de comidas y de vasos de agua, con foto si se quiere.',
    'Llega en la semana 14',
  ]),
  _Caso('Alarmas', '/familia/alarmas', [
    'Alarmas',
    'Lo que tendrá',
    'Llega en las semanas 4 y 5',
    'Ver el control por horas',
  ]),
  _Caso('Control por horas', '/familia/alarmas/control-horas', [
    'Control por horas',
    'Lo que tendrá',
    'Llega en la semana 5',
    'Volver',
  ]),
  _Caso('Voces', '/familia/voces', [
    'Voces',
    'Lo que tendrá',
    'Llega en las semanas 8 y 9',
  ]),
  _Caso('Calendario', '/familia/calendario', [
    'Calendario',
    'Lo que tendrá',
    'Llega en la semana 13',
  ]),
  _Caso('Consultas', '/familia/consultas', [
    'Consultas',
    'Lo que tendrá',
    'Llega en la semana 12',
  ]),
  _Caso('Más', '/familia/mas', [
    'Más',
    'Calendario',
    'Consultas',
    'Alarmas',
    'Voces',
    'Círculo',
    'Ajustes',
  ]),
];

void main() {
  for (final oscuro in [false, true]) {
    for (final caso in _casos) {
      testWidgets(
        '${caso.nombre} en ${oscuro ? 'oscuro' : 'claro'}: textos, contraste y '
        'zonas táctiles',
        (tester) async {
          // El aspecto automático sigue al sistema.
          tester.platformDispatcher.platformBrightnessTestValue = oscuro
              ? Brightness.dark
              : Brightness.light;
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          final manejador = tester.ensureSemantics();
          final entorno = await tester.runAsync(
            () => prepararEntorno(
              perfil: caso.sinPerfil ? null : PerfilApp.familia,
              sembrar: !caso.sinPerfil,
            ),
          );
          await montarApp(tester, entorno!, rutaInicial: caso.ruta);
          await pasar(tester, const Duration(seconds: 1));

          final brillo = Theme.of(tester.element(find.byType(Scaffold).first))
              .brightness;
          expect(brillo, oscuro ? Brightness.dark : Brightness.light);
          for (final texto in caso.textos) {
            expect(find.text(texto), findsWidgets, reason: texto);
          }
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(tester.takeException(), isNull);
          manejador.dispose();
        },
      );
    }
  }

  testWidgets('Ideas y tablas, resumen y dosier: cabecera grande y sus '
      'textos', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/ideas');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Ideas y tablas'), findsWidgets);
    expect(find.byType(AppBar), findsNothing);

    await tester.tap(find.text('Resumen por grupo'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Resumen por grupo'), findsWidgets);
    expect(find.byType(AppBar), findsNothing);
    // "Volver" lleva otra vez a Ideas y tablas.
    await tester.tap(find.text('Volver'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.buscadorCatalogo), findsOneWidget);
  });

  testWidgets('"Volver" solo aparece si se llegó con un push', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/alarmas');
    await pasar(tester, const Duration(seconds: 1));
    // Una pestaña no tiene adónde volver.
    expect(find.text('Volver'), findsNothing);

    await tester.tap(find.text('Ver el control por horas'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Control por horas'), findsWidgets);
    expect(find.text('Volver'), findsOneWidget);

    await tester.tap(find.text('Volver'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Ver el control por horas'), findsOneWidget);
    expect(find.text('Volver'), findsNothing);
  });

  testWidgets('el perfil elegido se guarda al tocar la tarjeta de la persona', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(sembrar: false),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('¿De quién es este móvil?'), findsOneWidget);

    await tester.tap(find.text('De la persona'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
  });

  testWidgets('alta de medicamento: comprobación en segmentos, hora fija y '
      'muestras con borde', (tester) async {
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/medicacion/nuevo');
    await pasar(tester, const Duration(seconds: 1));

    // La ayuda del nombre admite hasta tres líneas.
    final ayuda = tester.widget<InputDecorator>(
      find.descendant(
        of: find.widgetWithText(TextFormField, 'Nombre para la persona'),
        matching: find.byType(InputDecorator),
      ),
    );
    expect(ayuda.decoration.helperMaxLines, 3);

    // La muestra "Blanco" lleva un borde de 1 px.
    await tester.scrollUntilVisible(
      find.widgetWithText(ChoiceChip, 'Blanco'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final blanco = find.descendant(
      of: find.widgetWithText(ChoiceChip, 'Blanco'),
      matching: find.byType(Container),
    );
    final decoracion = tester
        .widgetList<Container>(blanco)
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.shape == BoxShape.circle)
        .single;
    expect(decoracion.border, isNotNull);
    expect(decoracion.border!.top.width, 1);

    await tester.scrollUntilVisible(
      find.text('09:00'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    // Una sola hora: chip normal, habilitado y sin botón de borrar.
    expect(find.byType(InputChip), findsNothing);
    final hora = tester.widget<Chip>(find.widgetWithText(Chip, '09:00'));
    expect(hora.onDeleted, isNull);

    // Comprobación: selector de segmentos con etiquetas cortas.
    await tester.scrollUntilVisible(
      find.text('Cómo se comprueba'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(SegmentedButton<Object>), findsNothing);
    for (final v in ['video', 'foto', 'ninguna']) {
      expect(
        find.byKey(ClavesUi.segmento('comprobacion_$v')),
        findsOneWidget,
        reason: v,
      );
    }
    expect(find.text('Vídeo'), findsOneWidget);
    expect(find.text('Ninguna'), findsOneWidget);
    // El vídeo está elegido por defecto y su duración sale como ayuda.
    expect(find.text('Vídeo de 10 s'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(ClavesUi.segmento('comprobacion_ninguna')),
    );
    await tester.pump();
    await tester.tap(find.byKey(ClavesUi.segmento('comprobacion_ninguna')));
    await pasar(tester, const Duration(milliseconds: 500));
    expect(find.text('Vídeo de 10 s'), findsNothing);

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    expect(tester.takeException(), isNull);
    manejador.dispose();
  });
}
