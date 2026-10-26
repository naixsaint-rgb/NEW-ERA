import 'dart:convert';

import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/tema/aspecto.dart';
import 'package:newera/features/hoy/hoy_pantalla.dart';
import 'package:newera/features/medicacion/detalle_medicamento_pantalla.dart';
import 'package:newera/features/resumen/dominio/resumen.dart';
import 'package:newera/features/resumen/resumen_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';

/// Hora de Madrid (UTC+2 el 13/10/2026) a UTC.
DateTime _madrid(int hora, int minuto) =>
    DateTime.utc(2026, 10, 13, hora - 2, minuto);

Future<void> _insertar(
  EntornoPrueba e, {
  required String ulid,
  required String autor,
  required String tipo,
  required DateTime cuando,
  String? sujeto,
  String? corrigeA,
  Map<String, Object?> payload = const {},
}) => e.db
    .into(e.db.eventos)
    .insert(
      EventosCompanion.insert(
        ulid: ulid,
        circuloId: e.contexto.circuloId,
        autor: autor,
        dispositivo: e.contexto.dispositivoId,
        tipo: tipo,
        sujeto: Value(sujeto),
        ocurridoEn: cuando.millisecondsSinceEpoch,
        registradoEn: cuando.millisecondsSinceEpoch,
        payload: Value(jsonEncode(payload)),
        corrigeA: Value(corrigeA),
      ),
    );

/// Monta la familia con [entorno] y abre la pestaña Resumen.
Future<void> _abrirResumen(
  WidgetTester tester,
  EntornoPrueba entorno, {
  Aspecto? aspecto,
}) async {
  await montarApp(
    tester,
    entorno,
    rutaInicial: aspecto == null ? null : '/familia/ajustes',
  );
  await pasar(tester, const Duration(seconds: 1));
  if (aspecto != null) {
    await tester.tap(find.byKey(ClavesUi.aspecto(aspecto.nombre)));
    await pasar(tester, const Duration(seconds: 1));
  }
  await tester.tap(find.byKey(ClavesUi.pestana('resumen')));
  await pasar(tester, const Duration(seconds: 1));
  expect(find.byType(ResumenPantalla), findsOneWidget);
  expect(find.byKey(ClavesUi.pantallaResumen), findsOneWidget);
}

Future<EntornoPrueba> _entorno(
  WidgetTester tester, {
  bool sembrar = true,
}) async {
  final e = await tester.runAsync(
    () => prepararEntorno(perfil: PerfilApp.familia, sembrar: sembrar),
  );
  return e!;
}

void main() {
  testWidgets(
    'Resumen con la semilla: estado, tomas, señal, mensaje y próxima',
    (tester) async {
      final entorno = await _entorno(tester);
      await _abrirResumen(tester, entorno);

      // Cabecera: fecha larga y título.
      expect(find.text('MARTES 13 DE OCTUBRE'), findsOneWidget);
      expect(find.text('Resumen'), findsWidgets);

      // Tarjeta héroe: hoy 09:00 confirmada con clip → verde.
      expect(find.text('Carmen está bien'), findsOneWidget);
      expect(
        find.text(
          'Toma confirmada a las 09:02: pastilla blanca pequeña · Carmen, móvil',
        ),
        findsOneWidget,
      );
      // Último evento de la persona hoy: el clip, 12 s después de confirmar.
      expect(find.text('Última señal 09:02'), findsOneWidget);

      // Rejilla.
      expect(find.byKey(ClavesUi.anilloTomas), findsOneWidget);
      expect(find.text('1 de 3'), findsOneWidget);
      expect(find.text('siguiente 14:00'), findsOneWidget);
      expect(find.text('Tomas'), findsOneWidget);
      expect(find.text('Vídeos'), findsOneWidget);
      expect(find.text('Avisos'), findsOneWidget);
      expect(find.text('Mensaje'), findsOneWidget);
      // Un clip hoy, ningún aviso.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.textContaining('Un abrazo grande'), findsOneWidget);
      expect(find.text('De Lucía · 11:00'), findsOneWidget);

      // Reloj: sin cifras inventadas.
      expect(
        find.text('Pulso, pasos y sueño llegan con el reloj'),
        findsOneWidget,
      );
      expect(find.text('Llega en la semana 6'), findsOneWidget);

      // Próxima toma: 14:00, cápsula roja, aviso a Familiar 1 a los 5 min.
      expect(find.text('PRÓXIMA TOMA'), findsOneWidget);
      expect(find.text('14:00 · Mediodía'), findsOneWidget);
      expect(find.text('Cápsula roja'), findsOneWidget);
      expect(
        find.text('Si no la toma, aviso a Lucía a las 14:05'),
        findsOneWidget,
      );

      // Control por horas: franja 09–21 vacía y aviso.
      expect(find.text('Control por horas'), findsOneWidget);
      expect(find.text('9 a 21 h'), findsOneWidget);
      expect(find.text('09'), findsOneWidget);
      expect(find.text('Llega en la semana 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Avisos: ayuda y llamadas de hoy, y la señal más reciente', (
    tester,
  ) async {
    final entorno = await _entorno(tester);
    await tester.runAsync(() async {
      final persona = entorno.contexto.personaId;
      await _insertar(
        entorno,
        ulid: '01K00000000000000000000001',
        autor: persona,
        tipo: 'ayuda_pedida',
        cuando: _madrid(11, 30),
      );
      await _insertar(
        entorno,
        ulid: '01K00000000000000000000002',
        autor: persona,
        tipo: 'llamada_iniciada',
        cuando: _madrid(11, 40),
        payload: const {'a': 'Lucía'},
      );
      // De ayer: no cuenta como aviso de hoy.
      await _insertar(
        entorno,
        ulid: '01J00000000000000000000003',
        autor: persona,
        tipo: 'ayuda_pedida',
        cuando: _madrid(11, 40).subtract(const Duration(days: 1)),
      );
    });
    await _abrirResumen(tester, entorno);

    expect(find.text('2'), findsOneWidget);
    expect(find.text('Última señal 11:40'), findsOneWidget);
    expect(find.text('Carmen está bien'), findsOneWidget);
  });

  testWidgets('Un clip anulado deja la toma sin vídeo: necesita un vistazo', (
    tester,
  ) async {
    final entorno = await _entorno(tester);
    await tester.runAsync(() async {
      final id = await entorno.idToma(
        'Pastilla blanca pequeña',
        '20261013',
        '0900',
      );
      final clip =
          await (entorno.db.select(entorno.db.eventos)..where(
                (e) => e.tipo.equals('clip_grabado') & e.sujeto.equals(id),
              ))
              .getSingle();
      await _insertar(
        entorno,
        ulid: '01K00000000000000000000009',
        autor: entorno.contexto.personaId,
        tipo: 'anulacion',
        cuando: _madrid(11, 0),
        sujeto: id,
        corrigeA: clip.ulid,
      );
    });
    await _abrirResumen(tester, entorno);

    expect(find.text('Carmen necesita un vistazo'), findsOneWidget);
    expect(find.text('Carmen está bien'), findsNothing);
    // Confirmada sin vídeo: cuenta como hecha, pero no hay clips.
    expect(find.text('1 de 3'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('Una toma sin confirmar a tiempo: necesita atención', (
    tester,
  ) async {
    final entorno = await _entorno(tester);
    // La de las 14:00 lleva 35 minutos sin confirmar.
    entorno.reloj.fijar(_madrid(14, 35));
    await _abrirResumen(tester, entorno);

    expect(find.text('Carmen necesita atención'), findsOneWidget);
    expect(find.text('1 de 3'), findsOneWidget);
    // Sigue siendo lo próximo que hay que mirar.
    expect(find.text('siguiente 14:00'), findsOneWidget);
  });

  testWidgets('Sin datos: nada inventado', (tester) async {
    final entorno = await _entorno(tester, sembrar: false);
    await _abrirResumen(tester, entorno);

    expect(find.textContaining('Última señal'), findsNothing);
    expect(find.text('Sin tomas aún'), findsOneWidget);
    expect(find.text('Sin mensajes'), findsOneWidget);
    expect(find.text('Sin tomas hoy'), findsOneWidget);
    expect(find.text('sin más tomas'), findsOneWidget);
    expect(find.text('Ahora no hay más pastillas.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('La tarjeta de próxima toma abre el medicamento y Vídeos, Hoy', (
    tester,
  ) async {
    final entorno = await _entorno(tester);
    await _abrirResumen(tester, entorno);

    await tester.ensureVisible(find.text('Cápsula roja'));
    await tester.pump();
    await tester.tap(find.text('Cápsula roja'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byType(DetalleMedicamentoPantalla), findsOneWidget);

    await tester.tap(find.byKey(ClavesUi.pestana('resumen')));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byType(ResumenPantalla), findsOneWidget);
    await tester.ensureVisible(find.text('Vídeos'));
    await tester.pump();
    await tester.tap(find.text('Vídeos'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byType(HoyPantalla), findsOneWidget);
  });

  testWidgets('Con el texto al 200 % no se desborda', (tester) async {
    final entorno = await _entorno(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await _abrirResumen(tester, entorno);
    expect(tester.takeException(), isNull);
  });

  for (final aspecto in [Aspecto.claro, Aspecto.oscuro]) {
    testWidgets('Resumen en ${aspecto.nombre}: contraste y zonas táctiles', (
      tester,
    ) async {
      final manejador = tester.ensureSemantics();
      final entorno = await _entorno(tester);
      await _abrirResumen(tester, entorno, aspecto: aspecto);
      expect(
        Theme.of(tester.element(find.byType(ResumenPantalla))).brightness,
        aspecto == Aspecto.oscuro ? Brightness.dark : Brightness.light,
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      // Y lo que queda debajo: próxima toma y control por horas.
      await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
      await pasar(tester, const Duration(milliseconds: 500));
      expect(find.text('Llega en la semana 5'), findsOneWidget);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      manejador.dispose();
    });
  }

  group('dominio', () {
    test('primerFamiliar: el de menor orden de escalado', () {
      Miembro m(String id, int? orden) => Miembro(
        id: id,
        circuloId: 'c',
        nombre: id,
        relacion: 'r',
        rol: 'apoyo',
        ordenEscalado: orden,
        enMiGente: true,
        creadoEn: 0,
      );
      expect(primerFamiliar(const []), isNull);
      expect(primerFamiliar([m('a', null)]), isNull);
      expect(primerFamiliar([m('a', 3), m('b', 1), m('c', 2)])?.id, 'b');
    });

    test('minutosAvisoFamiliar1: 5 por defecto; nulo si no hay paso', () {
      expect(minutosAvisoFamiliar1(const ConfigEscalado()), 5);
      expect(
        minutosAvisoFamiliar1(
          const ConfigEscalado(
            pasos: [
              PasoEscalado(0, AccionEscalado.aviso),
              PasoEscalado(8, AccionEscalado.avisarFamiliar1),
            ],
          ),
        ),
        8,
      );
      expect(
        minutosAvisoFamiliar1(
          const ConfigEscalado(pasos: [PasoEscalado(0, AccionEscalado.aviso)]),
        ),
        isNull,
      );
    });
  });
}
