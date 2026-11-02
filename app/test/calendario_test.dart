import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/tema/colores.dart';
import 'package:newera/features/calendario/calendario_pantalla.dart';
import 'package:newera/features/calendario/dominio/calendario.dart';
import 'package:newera/features/hoy/dominio/tomas.dart';
import 'package:newera/features/hoy/vistas/piezas_hoy.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';

/// Monta la familia en Hoy y abre Calendario desde la barra inferior.
Future<void> _abrir(
  WidgetTester tester, {
  Brightness brillo = Brightness.light,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final entorno = await tester.runAsync(
    () => prepararEntorno(perfil: PerfilApp.familia),
  );
  await montarApp(tester, entorno!);
  await pasar(tester, const Duration(seconds: 1));
  await tester.tap(find.byKey(ClavesUi.pestana('calendario')));
  await pasar(tester, const Duration(seconds: 1));
  expect(find.byKey(ClavesUi.pantallaCalendario), findsOneWidget);
}

Finder _dia(String fecha) => find.byKey(ClavesUi.diaCalendario(fecha));

CeldaDiaCalendario _celda(WidgetTester tester, String fecha) =>
    tester.widget<CeldaDiaCalendario>(_dia(fecha));

Future<void> _pulsar(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await pasar(tester, const Duration(milliseconds: 600));
}

TomaVista _toma(EstadoToma estado, [String hora = '09:00']) => TomaVista(
  toma: TomaPrevista(
    id: 'p_20261013_${hora.replaceAll(':', '')}',
    pautaId: 'p',
    pautaVersionId: 'v',
    medicamentoId: 'm',
    previstaPara: DateTime.utc(2026, 10, 13, 7),
    fechaLocal: '2026-10-13',
    horaLocal: hora,
  ),
  estado: estado,
  eventos: const [],
);

void main() {
  group('dominio', () {
    test('MesCalendario: días, huecos y filas con el lunes primero', () {
      const oct = MesCalendario(2026, 10);
      expect(oct.diasEnMes, 31);
      // El 1 de octubre de 2026 es jueves: tres huecos (L, M y X).
      expect(oct.huecosAntes, 3);
      expect(oct.filas, 5);
      expect(oct.fecha(7), '2026-10-07');
      const nov = MesCalendario(2026, 11);
      expect(nov.diasEnMes, 30);
      expect(nov.huecosAntes, 6); // domingo
      expect(nov.filas, 6);
      expect(const MesCalendario(2028, 2).diasEnMes, 29);
      expect(const MesCalendario(2027, 2).diasEnMes, 28);
      expect(
        const MesCalendario(2026, 12).siguiente,
        const MesCalendario(2027, 1),
      );
      expect(
        const MesCalendario(2026, 1).anterior,
        const MesCalendario(2025, 12),
      );
      expect(oct.anterior.siguiente, oct);
      // Madrid en octubre: UTC+2 (hasta el 25) y UTC+1 en noviembre.
      expect(oct.inicio('Europe/Madrid'), DateTime.utc(2026, 9, 30, 22));
      expect(oct.fin('Europe/Madrid'), DateTime.utc(2026, 10, 31, 23));
      expect(
        MesCalendario.de(DateTime.utc(2026, 10, 31, 23, 30), 'Europe/Madrid'),
        nov,
      );
    });

    test('estadoDelDia: verde, naranja, rojo, gris y sin punto', () {
      final hecha = _toma(EstadoToma.confirmada);
      final sinVideo = _toma(EstadoToma.confirmadaSinVideo, '14:00');
      final cerrada = _toma(EstadoToma.cerradaPorFamiliar, '21:00');
      final noConf = _toma(EstadoToma.noConfirmada, '14:00');
      final prevista = _toma(EstadoToma.prevista, '21:00');
      expect(estadoDelDia(const []), EstadoDiaCalendario.sinTomas);
      expect(
        estadoDelDia([hecha, sinVideo, cerrada]),
        EstadoDiaCalendario.completo,
      );
      expect(estadoDelDia([hecha, noConf]), EstadoDiaCalendario.parcial);
      expect(estadoDelDia([hecha, prevista]), EstadoDiaCalendario.parcial);
      expect(estadoDelDia([noConf, prevista]), EstadoDiaCalendario.sinHechas);
      expect(estadoDelDia([noConf]), EstadoDiaCalendario.sinHechas);
      expect(estadoDelDia([prevista, prevista]), EstadoDiaCalendario.previstas);
    });
  });

  testWidgets('abre en octubre de 2026 con el 13 marcado como hoy', (
    tester,
  ) async {
    await _abrir(tester);
    expect(find.text('Octubre de 2026'), findsOneWidget);
    expect(find.text('TOMAS Y HECHOS'), findsOneWidget);
    expect(find.text('Calendario'), findsWidgets);
    for (final inicial in ['L', 'M', 'X', 'J', 'V', 'S', 'D']) {
      expect(find.text(inicial), findsWidgets, reason: inicial);
    }

    // Treinta y un días, solo uno es hoy y es el elegido.
    expect(find.byType(CeldaDiaCalendario), findsNWidgets(31));
    final hoy = [
      for (final c in tester.widgetList<CeldaDiaCalendario>(
        find.byType(CeldaDiaCalendario),
      ))
        if (c.esHoy) c.dia,
    ];
    expect(hoy, [13]);
    expect(_celda(tester, '2026-10-13').seleccionado, isTrue);
    expect(_celda(tester, '2026-10-12').seleccionado, isFalse);
    expect(
      find.bySemanticsLabel(RegExp('Martes 13 de octubre, hoy')),
      findsOneWidget,
    );

    // Lunes primero: el 1 (jueves) cae en la cuarta columna, igual que el
    // 8; el 5 (lunes), en la primera, y el 4 (domingo), en la última.
    final x1 = tester.getCenter(_dia('2026-10-01')).dx;
    expect(tester.getCenter(_dia('2026-10-08')).dx, closeTo(x1, 0.5));
    expect(
      tester.getCenter(_dia('2026-10-05')).dx,
      lessThan(tester.getCenter(_dia('2026-10-06')).dx),
    );
    expect(
      tester.getCenter(_dia('2026-10-04')).dx,
      greaterThan(tester.getCenter(_dia('2026-10-03')).dx),
    );
    expect(x1, greaterThan(tester.getCenter(_dia('2026-10-05')).dx));

    // Puntos de estado (de las tomas reales de la semilla): las del 10 y el
    // 11 nadie las confirmó; el 12 y el 13 van a medias; después, previstas.
    expect(_celda(tester, '2026-10-09').estado, EstadoDiaCalendario.sinTomas);
    expect(_celda(tester, '2026-10-10').estado, EstadoDiaCalendario.sinHechas);
    expect(_celda(tester, '2026-10-11').estado, EstadoDiaCalendario.sinHechas);
    expect(_celda(tester, '2026-10-12').estado, EstadoDiaCalendario.parcial);
    expect(_celda(tester, '2026-10-13').estado, EstadoDiaCalendario.parcial);
    expect(_celda(tester, '2026-10-14').estado, EstadoDiaCalendario.previstas);
    expect(_celda(tester, '2026-10-31').estado, EstadoDiaCalendario.previstas);

    // Zonas táctiles de 44 o más (flechas y casillas).
    for (final f in [
      find.byKey(ClavesUi.mesAnterior),
      find.byKey(ClavesUi.mesSiguiente),
      _dia('2026-10-13'),
      _dia('2026-10-31'),
    ]) {
      final t = tester.getSize(f);
      expect(t.width, greaterThanOrEqualTo(44));
      expect(t.height, greaterThanOrEqualTo(44));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('el día 13 lista tres tomas: 09:00 confirmada, 14:00 y 21:00 '
      'previstas', (tester) async {
    await _abrir(tester);
    expect(find.text('Martes 13 de octubre'), findsOneWidget);
    expect(find.byType(FilaTomaHoy), findsNWidgets(3));
    final horas = [
      for (final f in tester.widgetList<FilaTomaHoy>(find.byType(FilaTomaHoy)))
        f.toma.toma.horaLocal,
    ];
    expect(horas, ['09:00', '14:00', '21:00']);
    final estados = [
      for (final f in tester.widgetList<FilaTomaHoy>(find.byType(FilaTomaHoy)))
        f.toma.estado,
    ];
    expect(estados, [
      EstadoToma.confirmada,
      EstadoToma.prevista,
      EstadoToma.prevista,
    ]);
    expect(find.text('Confirmada'), findsOneWidget);
    expect(find.text('Prevista'), findsNWidgets(2));
    expect(find.text('Pastilla blanca pequeña'), findsOneWidget);
    expect(find.text('Cápsula roja'), findsOneWidget);
    expect(find.text('Comprimido amarillo'), findsOneWidget);
    expect(find.text('Confirmada por Carmen, desde el móvil'), findsOneWidget);

    // Hechos de ese día que no son de toma: el mensaje de la familia y los
    // tres medicamentos dados de alta, cada uno con su hora.
    await tester.scrollUntilVisible(find.text('HECHOS DEL DÍA'), 300);
    expect(find.text('Mensaje a Carmen'), findsOneWidget);
    expect(
      find.text('Hola, Carmen. Esta tarde te llamamos. Un abrazo grande.'),
      findsOneWidget,
    );
    expect(find.text('11:00'), findsOneWidget);
    expect(find.text('Medicamento creado'), findsNWidgets(3));
    expect(find.text('Medicamento B (ejemplo)'), findsOneWidget);
    expect(find.text('12:00'), findsNWidgets(3));

    // El pie apagado, sin inventar turnos ni citas.
    await tester.scrollUntilVisible(
      find.text('Turnos de la familia y citas'),
      300,
    );
    expect(find.text('Llega en la semana 13'), findsOneWidget);
    expect(find.text('Sin tomas ni hechos ese día'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('al pulsar el 12 aparece la toma de las 21:00 como no '
      'confirmada', (tester) async {
    await _abrir(tester);
    await _pulsar(tester, _dia('2026-10-12'));

    expect(_celda(tester, '2026-10-12').seleccionado, isTrue);
    expect(_celda(tester, '2026-10-13').seleccionado, isFalse);
    expect(find.text('Lunes 12 de octubre'), findsOneWidget);
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
    expect(find.text('Confirmada sin vídeo'), findsOneWidget);
    expect(find.text('Confirmada'), findsOneWidget);
    // Ese día no hubo más hechos.
    expect(find.text('HECHOS DEL DÍA'), findsNothing);

    // Un día sin tomas ni hechos lo dice con una fila apagada.
    await _pulsar(tester, _dia('2026-10-09'));
    expect(find.text('Viernes 9 de octubre'), findsOneWidget);
    expect(find.byType(FilaTomaHoy), findsNothing);
    expect(find.text('Sin tomas ni hechos ese día'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('las flechas cambian de mes sin excepción', (tester) async {
    await _abrir(tester);
    await _pulsar(tester, find.byKey(ClavesUi.mesSiguiente));
    expect(find.text('Noviembre de 2026'), findsOneWidget);
    expect(find.byType(CeldaDiaCalendario), findsNWidgets(30));
    // En otro mes se elige el día 1 (domingo), con sus tomas previstas.
    expect(find.text('Domingo 1 de noviembre'), findsOneWidget);
    expect(_celda(tester, '2026-11-01').seleccionado, isTrue);
    expect(_celda(tester, '2026-11-01').esHoy, isFalse);
    expect(_celda(tester, '2026-11-01').estado, EstadoDiaCalendario.previstas);
    expect(find.byType(FilaTomaHoy), findsNWidgets(3));
    expect(find.text('Prevista'), findsNWidgets(3));
    // El domingo cae en la última columna.
    expect(
      tester.getCenter(_dia('2026-11-01')).dx,
      greaterThan(tester.getCenter(_dia('2026-11-02')).dx),
    );

    await _pulsar(tester, find.byKey(ClavesUi.mesAnterior));
    expect(find.text('Octubre de 2026'), findsOneWidget);
    // De vuelta al mes de hoy, vuelve a elegirse hoy.
    expect(find.text('Martes 13 de octubre'), findsOneWidget);
    expect(_celda(tester, '2026-10-13').seleccionado, isTrue);

    // Antes de que hubiera pautas no hay tomas ni puntos.
    await _pulsar(tester, find.byKey(ClavesUi.mesAnterior));
    expect(find.text('Septiembre de 2026'), findsOneWidget);
    expect(find.byType(CeldaDiaCalendario), findsNWidgets(30));
    expect(find.text('Sin tomas ni hechos ese día'), findsOneWidget);
    expect(_celda(tester, '2026-09-30').estado, EstadoDiaCalendario.sinTomas);

    // Atrás hasta el año anterior y otra vez adelante.
    for (var i = 0; i < 9; i++) {
      await _pulsar(tester, find.byKey(ClavesUi.mesAnterior));
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Diciembre de 2025'), findsOneWidget);
    for (var i = 0; i < 12; i++) {
      await _pulsar(tester, find.byKey(ClavesUi.mesSiguiente));
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Diciembre de 2026'), findsOneWidget);
    expect(find.byType(CeldaDiaCalendario), findsNWidgets(31));
  });

  testWidgets('el día elegido cambia con el mes pero hoy sigue marcado', (
    tester,
  ) async {
    await _abrir(tester);
    await _pulsar(tester, _dia('2026-10-20'));
    expect(find.text('Martes 20 de octubre'), findsOneWidget);
    expect(_celda(tester, '2026-10-20').seleccionado, isTrue);
    // El 13 sigue siendo hoy aunque ya no sea el elegido.
    expect(_celda(tester, '2026-10-13').esHoy, isTrue);
    expect(_celda(tester, '2026-10-13').seleccionado, isFalse);
    expect(find.text('Prevista'), findsNWidgets(3));
  });

  for (final oscuro in [false, true]) {
    for (final dia in [null, '2026-10-12']) {
      testWidgets(
        'contraste y objetivos táctiles en ${oscuro ? 'oscuro' : 'claro'}'
        '${dia == null ? '' : ' con el $dia elegido'}',
        (tester) async {
          final manejador = tester.ensureSemantics();
          await _abrir(
            tester,
            brillo: oscuro ? Brightness.dark : Brightness.light,
          );
          expect(
            Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
            oscuro ? Brightness.dark : Brightness.light,
          );
          if (dia != null) await _pulsar(tester, _dia(dia));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(tester.takeException(), isNull);
          manejador.dispose();
        },
      );
    }
  }

  testWidgets('los colores de los puntos salen del tema, claro y oscuro', (
    tester,
  ) async {
    for (final c in [ColoresApp.claro, ColoresApp.oscuro]) {
      expect(colorDePunto(EstadoDiaCalendario.sinTomas, c), isNull);
      expect(colorDePunto(EstadoDiaCalendario.completo, c), c.verde);
      expect(colorDePunto(EstadoDiaCalendario.parcial, c), c.naranjaRelleno);
      expect(colorDePunto(EstadoDiaCalendario.sinHechas, c), c.rojo);
      expect(colorDePunto(EstadoDiaCalendario.previstas, c), c.textoSecundario);
    }
  });

  testWidgets('con la letra al 200 % no lanza excepción', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await _abrir(tester);
    expect(tester.takeException(), isNull);
    await _pulsar(tester, _dia('2026-10-12'));
    expect(tester.takeException(), isNull);
    await _pulsar(tester, _dia('2026-10-13'));
    expect(tester.takeException(), isNull);
    await _pulsar(tester, find.byKey(ClavesUi.mesSiguiente));
    expect(tester.takeException(), isNull);
    await _pulsar(tester, find.byKey(ClavesUi.mesAnterior));
    await tester.scrollUntilVisible(
      find.text('Turnos de la familia y citas'),
      300,
    );
    expect(tester.takeException(), isNull);
  });
}
