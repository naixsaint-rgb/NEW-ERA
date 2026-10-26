import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/features/hoy/hoy_pantalla.dart';
import 'package:newera/features/hoy/vistas/piezas_hoy.dart';
import 'package:newera/features/hoy/vistas/vista_semana.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:newera/shared/ios/ios.dart';

import 'utiles/app_prueba.dart';

/// Monta la familia en Hoy (o en [ruta]) con el sistema en [brillo].
Future<void> _montar(
  WidgetTester tester, {
  String? ruta,
  Brightness brillo = Brightness.light,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  final entorno = await tester.runAsync(
    () => prepararEntorno(perfil: PerfilApp.familia),
  );
  await montarApp(tester, entorno!, rutaInicial: ruta);
  await pasar(tester, const Duration(seconds: 1));
  expect(find.byType(HoyPantalla), findsOneWidget);
}

Future<void> _elegir(WidgetTester tester, String vista) async {
  await tester.tap(find.byKey(ClavesUi.segmento(vista)));
  await pasar(tester, const Duration(milliseconds: 600));
}

List<CeldaDia> _celdas(WidgetTester tester) =>
    tester.widgetList<CeldaDia>(find.byType(CeldaDia)).toList();

void main() {
  testWidgets('Hoy: semáforo, última toma y tomas de hoy', (tester) async {
    await _montar(tester);
    expect(find.byKey(ClavesUi.semaforo), findsOneWidget);
    // Fecha larga de hoy en la víspera (en mayúsculas).
    expect(find.text('MARTES 13 DE OCTUBRE'), findsOneWidget);
    // Hoy 09:00 confirmada con clip y ayer 21:00 sin confirmar: el semáforo de
    // hoy es verde.
    expect(find.text('Todo en orden por ahora'), findsOneWidget);
    expect(find.text('Última toma'), findsOneWidget);
    expect(find.text('A las 09:00, pastilla blanca pequeña'), findsOneWidget);
    expect(find.text('Confirmada por Carmen, desde el móvil'), findsOneWidget);
    // Casillas: 1 de 3 tomas, 1 vídeo, 0 avisos.
    expect(find.text('Tomas'), findsOneWidget);
    expect(find.text('1 de 3'), findsOneWidget);
    expect(find.text('Vídeos'), findsOneWidget);
    expect(find.text('Avisos'), findsOneWidget);
    // Próxima toma: 14:00 en el compartimento de mediodía, aviso a los 5 min.
    expect(find.text('PRÓXIMA TOMA'), findsOneWidget);
    expect(find.text('14:00 · Mediodía'), findsOneWidget);
    expect(find.text('Si no la toma: aviso a las 14:05'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('TOMAS DE HOY'), 300);
    expect(find.text('TOMAS DE HOY'), findsOneWidget);
    expect(find.byType(FilaTomaHoy), findsNWidgets(3));
    await tester.scrollUntilVisible(
      find.text('Vídeo de la toma de las 09:00 · 10 s'),
      300,
    );
    expect(find.text('COMPROBACIONES'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Respuesta de control'), 300);
    expect(find.text('Respuesta de control'), findsOneWidget);
    expect(find.text('LLEGA PRONTO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ayer: la toma de las 21:00 sale como no confirmada', (
    tester,
  ) async {
    await _montar(tester);
    await _elegir(tester, 'ayer');
    expect(find.text('TOMAS DE AYER'), findsOneWidget);
    expect(find.byType(FilaTomaHoy), findsNWidgets(3));
    final noConfirmada = find.text('No confirmada');
    expect(noConfirmada, findsOneWidget);
    final fila = find.ancestor(
      of: noConfirmada,
      matching: find.byType(FilaTomaHoy),
    );
    expect(
      find.descendant(of: fila, matching: find.text('21:00')),
      findsOneWidget,
    );
    // Las dos de antes las confirmó Carmen desde el móvil.
    expect(
      find.text('Confirmada por Carmen, desde el móvil'),
      findsNWidgets(2),
    );
    await tester.scrollUntilVisible(
      find.text('Respuestas de control: llega en la semana 5'),
      300,
    );
    expect(find.text('Vídeo de la toma de las 09:00 · 10 s'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mañana: tres tomas y los familiares por orden de aviso', (
    tester,
  ) async {
    await _montar(tester);
    await _elegir(tester, 'manana');
    expect(find.text('TOMAS DE MAÑANA'), findsOneWidget);
    expect(find.byType(FilaTomaHoy), findsNWidgets(3));
    for (final hora in ['09:00', '14:00', '21:00']) {
      expect(find.text(hora), findsOneWidget, reason: hora);
    }
    expect(find.text('Comprimido amarillo'), findsOneWidget);
    expect(find.text('Noche'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lucía a los 5 min · Javier a los 10 min'),
      300,
    );
    expect(find.text('QUIÉN RECIBE LOS AVISOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Semana: siete días con hoy a la derecha y el total', (
    tester,
  ) async {
    await _montar(tester);
    await _elegir(tester, 'semana');
    expect(find.text('Últimos 7 días · 7 a 13 de octubre'), findsOneWidget);
    // Las pautas empiezan el sábado 10 a mediodía: 2 + 3 + 3 + 3 = 11 tomas;
    // hechas: dos de ayer y una de hoy. Hoy quedan las de las 14:00 y 21:00.
    expect(find.text('3 de 11'), findsOneWidget);
    expect(find.text('tomas hechas · hoy quedan 2'), findsOneWidget);
    expect(find.text('Respuestas: llega en la semana 5'), findsOneWidget);

    final celdas = _celdas(tester);
    expect(celdas, hasLength(7));
    expect(celdas.map((c) => c.texto), [
      null,
      null,
      null,
      '0/2',
      '0/3',
      '2/3',
      '1/3',
    ]);
    expect(celdas.map((c) => c.estado), [
      EstadoCelda.vacia,
      EstadoCelda.vacia,
      EstadoCelda.vacia,
      EstadoCelda.fallida,
      EstadoCelda.fallida,
      EstadoCelda.parcial,
      EstadoCelda.hoy,
    ]);
    // Iniciales del miércoles 7 al martes 13; hoy, la última.
    final iniciales = ['X', 'J', 'V', 'S', 'D', 'L', 'M'];
    final xs = [
      for (final i in iniciales)
        tester
            .getCenter(
              find.descendant(
                of: find.byType(VistaSemana),
                matching: find.text(i),
              ),
            )
            .dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));
    expect(find.text('Respondió'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sus respuestas a las preguntas de cada hora'),
      300,
    );
    expect(find.text('LO QUE DIJO ESTA SEMANA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('/familia/hoy?vista=semana empieza en Semana', (tester) async {
    await _montar(tester, ruta: Rutas.hoyVista('semana'));
    expect(_celdas(tester), hasLength(7));
    expect(find.byKey(ClavesUi.semaforo), findsNothing);
  });

  testWidgets('una ?vista= desconocida empieza en Hoy', (tester) async {
    await _montar(tester, ruta: Rutas.hoyVista('luna'));
    expect(find.byKey(ClavesUi.semaforo), findsOneWidget);
  });

  for (final brillo in Brightness.values) {
    testWidgets('Hoy en ${brillo.name}: contraste y zonas táctiles', (
      tester,
    ) async {
      final manejador = tester.ensureSemantics();
      await _montar(tester, brillo: brillo);
      expect(
        Theme.of(tester.element(find.byType(HoyPantalla))).brightness,
        brillo,
      );
      Future<void> comprobar(String donde) async {
        await expectLater(
          tester,
          meetsGuideline(textContrastGuideline),
          reason: donde,
        );
        await expectLater(
          tester,
          meetsGuideline(androidTapTargetGuideline),
          reason: donde,
        );
        await expectLater(
          tester,
          meetsGuideline(labeledTapTargetGuideline),
          reason: donde,
        );
      }

      for (final vista in ['hoy', 'ayer', 'manana', 'semana']) {
        await _elegir(tester, vista);
        await comprobar(vista);
        // Y al final de la lista.
        await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
        await pasar(tester, const Duration(milliseconds: 500));
        await comprobar('$vista, abajo');
        await tester.drag(find.byType(ListView).first, const Offset(0, 4000));
        await pasar(tester, const Duration(milliseconds: 500));
      }
      manejador.dispose();
    });
  }
}
