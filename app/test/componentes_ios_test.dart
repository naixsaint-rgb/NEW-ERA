import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/tema/colores.dart';
import 'package:newera/core/tema/tema_familia.dart';
import 'package:newera/l10n/app_localizations.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:newera/shared/ios/ios.dart';
import 'package:newera/shared/pictogramas/pastilla_pictograma.dart';

const _delegados = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Monta [hijo] con el tema de la familia (claro u oscuro) y los textos.
Future<void> _montar(
  WidgetTester tester,
  Widget hijo, {
  bool oscuro = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: oscuro ? temaFamiliaOscuro() : temaFamilia(),
        locale: const Locale('es', 'ES'),
        supportedLocales: const [Locale('es', 'ES')],
        localizationsDelegates: _delegados,
        home: Scaffold(
          body: Center(
            child: Padding(padding: const EdgeInsets.all(20), child: hijo),
          ),
        ),
      ),
    ),
  );
}

Medicamento _medicamento({String? fotoPastillaId}) => Medicamento(
  id: 'm1',
  personaId: 'p1',
  nombre: 'Medicamento A (ejemplo)',
  nombreParaPersona: 'Cápsula roja',
  forma: 'capsula',
  color: 'rojo',
  fotoPastillaId: fotoPastillaId,
  creadoEn: 0,
);

void main() {
  group('SelectorSegmentos', () {
    testWidgets('cambia de segmento con su clave y no repite el elegido', (
      tester,
    ) async {
      var elegido = 'hoy';
      final cambios = <String>[];
      await _montar(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SelectorSegmentos<String>(
            valores: const ['ayer', 'hoy', 'manana', 'semana'],
            etiqueta: (v) => 'Etiqueta $v',
            seleccionado: elegido,
            clave: ClavesUi.segmento,
            alCambiar: (v) {
              cambios.add(v);
              setState(() => elegido = v);
            },
          ),
        ),
      );
      for (final v in ['ayer', 'hoy', 'manana', 'semana']) {
        expect(find.byKey(ClavesUi.segmento(v)), findsOneWidget, reason: v);
      }
      expect(find.byType(CupertinoSlidingSegmentedControl<String>), findsOne);

      await tester.tap(find.byKey(ClavesUi.segmento('semana')));
      await tester.pumpAndSettle();
      expect(cambios, ['semana']);
      expect(elegido, 'semana');

      await tester.tap(find.byKey(ClavesUi.segmento('semana')));
      await tester.pumpAndSettle();
      expect(cambios, ['semana'], reason: 'ya estaba elegido');

      // Cada segmento mide al menos 48 de alto (zona táctil de Android).
      expect(
        tester.getSize(find.byKey(ClavesUi.segmento('ayer'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('CeldaDia', () {
    test('colores de cada estado (claro y oscuro)', () {
      const c = ColoresApp.claro;
      expect(CeldaDia.coloresDe(EstadoCelda.completa, c).fondo, c.verde);
      expect(CeldaDia.coloresDe(EstadoCelda.completa, c).texto, Colores.blanco);
      expect(
        CeldaDia.coloresDe(EstadoCelda.parcial, c).fondo,
        Colores.naranjaRelleno,
      );
      expect(CeldaDia.coloresDe(EstadoCelda.parcial, c).texto, Colores.texto);
      expect(CeldaDia.coloresDe(EstadoCelda.fallida, c).fondo, c.rojo);
      expect(CeldaDia.coloresDe(EstadoCelda.hoy, c).fondo, Colores.azulClaro);
      expect(CeldaDia.coloresDe(EstadoCelda.hoy, c).borde, Colores.azul);
      expect(CeldaDia.coloresDe(EstadoCelda.futura, c).fondo, c.rellenoSuave);
      expect(
        CeldaDia.coloresDe(EstadoCelda.vacia, c).fondo,
        Colors.transparent,
      );
      // De noche, texto negro sobre los rellenos vivos.
      const o = ColoresApp.oscuro;
      expect(
        CeldaDia.coloresDe(EstadoCelda.completa, o).texto,
        ColoresOscuro.sobreRelleno,
      );
      expect(CeldaDia.coloresDe(EstadoCelda.hoy, o).texto, ColoresOscuro.texto);
    });

    testWidgets('pinta su texto o su hijo y se lee con su etiqueta', (
      tester,
    ) async {
      final manejador = tester.ensureSemantics();
      await _montar(
        tester,
        const Row(
          children: [
            Expanded(
              child: CeldaDia(estado: EstadoCelda.parcial, texto: '4/5'),
            ),
            SizedBox(width: 6),
            Expanded(
              child: CeldaDia(
                estado: EstadoCelda.completa,
                hijo: Icon(CupertinoIcons.checkmark_alt),
                etiquetaSemantica: 'Lunes 09:00: tomada',
              ),
            ),
            SizedBox(width: 6),
            Expanded(child: CeldaDia(estado: EstadoCelda.vacia)),
          ],
        ),
      );
      expect(find.text('4/5'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.checkmark_alt), findsOneWidget);
      expect(find.bySemanticsLabel('Lunes 09:00: tomada'), findsOneWidget);
      expect(tester.getSize(find.byType(CeldaDia).first).height, 36);
      expect(tester.takeException(), isNull);
      manejador.dispose();
    });
  });

  group('IndicadorAnillo', () {
    testWidgets('pinta sin excepción y recorta la fracción a 0–1', (
      tester,
    ) async {
      for (final (fraccion, esperada) in [
        (-1.0, 0.0),
        (0.0, 0.0),
        (0.6, 0.6),
        (1.0, 1.0),
        (2.0, 1.0),
        (double.nan, 0.0),
      ]) {
        await _montar(
          tester,
          IndicadorAnillo(
            fraccion,
            etiquetaSemantica: '3 de 5 tomas hechas',
            child: const Text('3'),
          ),
          oscuro: fraccion > 1,
        );
        expect(tester.takeException(), isNull, reason: '$fraccion');
        final pintura = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(IndicadorAnillo),
            matching: find.byType(CustomPaint),
          ),
        );
        expect(
          (pintura.painter! as PintorAnillo).fraccion,
          esperada,
          reason: '$fraccion',
        );
      }
      expect(find.bySemanticsLabel('3 de 5 tomas hechas'), findsOneWidget);
      expect(tester.getSize(find.byType(IndicadorAnillo)), const Size(56, 56));
    });
  });

  group('FilaLista', () {
    testWidgets('onTap, chevron y fila apagada', (tester) async {
      var pulsada = 0;
      await _montar(
        tester,
        GrupoLista(
          children: [
            FilaLista(
              key: const ValueKey('fila'),
              leading: const IconoCuadrado(CupertinoIcons.calendar),
              titulo: 'Calendario',
              subtitulo: 'Citas y recordatorios',
              detalle: 'Hoy',
              onTap: () => pulsada++,
            ),
            const FilaLista(
              key: ValueKey('apagada'),
              titulo: 'Llega en la semana 5',
              apagada: true,
            ),
          ],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('fila')));
      await tester.pump();
      expect(pulsada, 1);
      expect(
        tester.getSize(find.byKey(const ValueKey('fila'))).height,
        greaterThanOrEqualTo(56),
      );
      // Chevron solo en la fila que se puede pulsar.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('fila')),
          matching: find.byIcon(CupertinoIcons.chevron_forward),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('apagada')),
          matching: find.byIcon(CupertinoIcons.chevron_forward),
        ),
        findsNothing,
      );
      final apagada = tester.widget<Text>(find.text('Llega en la semana 5'));
      expect(apagada.style?.color, ColoresApp.claro.textoSecundario);
    });
  });

  group('FotoPastilla', () {
    testWidgets('pictograma sobre la mesa; insignia solo con foto', (
      tester,
    ) async {
      await _montar(tester, FotoPastilla(_medicamento(), insigniaCamara: true));
      expect(find.byType(PastillaPictograma), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.camera_fill), findsNothing);
      expect(
        find.bySemanticsLabel('Foto de la pastilla: Cápsula roja'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        ProviderScope(
          key: const ValueKey('con_foto'),
          overrides: [fotoProvider.overrideWith((ref, id) async => null)],
          child: MaterialApp(
            theme: temaFamilia(),
            locale: const Locale('es', 'ES'),
            supportedLocales: const [Locale('es', 'ES')],
            localizationsDelegates: _delegados,
            home: Center(
              child: FotoPastilla(
                _medicamento(fotoPastillaId: 'f1'),
                tamano: 72,
                insigniaCamara: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.camera_fill), findsOneWidget);
      expect(tester.getSize(find.byType(FotoPastilla)), const Size(72, 72));
      expect(tester.takeException(), isNull);
    });
  });

  group('BotonMas', () {
    testWidgets('lleva su clave, muestra las iniciales y abre /familia/mas', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: Rutas.pestana('hoy'),
        routes: [
          GoRoute(
            path: Rutas.pestana('hoy'),
            builder: (_, _) => const Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: BotonMas(iniciales: 'L'),
              ),
            ),
          ),
          GoRoute(
            path: Rutas.mas,
            builder: (_, _) => const Scaffold(body: Text('pantalla mas')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: temaFamilia(),
          locale: const Locale('es', 'ES'),
          supportedLocales: const [Locale('es', 'ES')],
          localizationsDelegates: _delegados,
        ),
      );
      await tester.pumpAndSettle();
      final boton = find.byKey(ClavesUi.pestana('mas'));
      expect(boton, findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(tester.getSize(boton), const Size(48, 48));

      await tester.tap(boton);
      await tester.pumpAndSettle();
      expect(find.text('pantalla mas'), findsOneWidget);
      expect(router.state.matchedLocation, Rutas.mas);
    });

    testWidgets('sin iniciales pinta el icono de persona', (tester) async {
      await _montar(tester, BotonMas(alPulsar: () {}));
      expect(find.byIcon(CupertinoIcons.person_fill), findsOneWidget);
    });
  });

  testWidgets('BarraPestanas: la activa en azul y avisa del índice', (
    tester,
  ) async {
    final elegidas = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: temaFamilia(),
        home: Scaffold(
          bottomNavigationBar: BarraPestanas(
            seleccionada: 1,
            alElegir: elegidas.add,
            elementos: const [
              ElementoBarra(
                icono: CupertinoIcons.house_fill,
                etiqueta: 'Uno',
                clave: ValueKey('uno'),
              ),
              ElementoBarra(
                icono: CupertinoIcons.heart_fill,
                etiqueta: 'Dos',
                clave: ValueKey('dos'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('uno')));
    expect(elegidas, [0]);
    final activa = tester.widget<Icon>(find.byIcon(CupertinoIcons.heart_fill));
    final inactiva = tester.widget<Icon>(
      find.byIcon(CupertinoIcons.house_fill),
    );
    expect(activa.color, Colores.azul);
    expect(inactiva.color, Colores.textoSecundario);
  });

  group('texto al 200 %', () {
    testWidgets('el selector encoge las etiquetas en vez de partirlas', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      const etiquetas = {
        'ayer': 'Ayer',
        'hoy': 'Hoy',
        'manana': 'Mañana',
        'semana': 'Semana',
        'auto': 'Automático',
        'noche': 'Oscuro',
      };
      await _montar(
        tester,
        SelectorSegmentos<String>(
          valores: etiquetas.keys.toList(),
          etiqueta: (v) => etiquetas[v]!,
          seleccionado: 'hoy',
          clave: ClavesUi.segmento,
          alCambiar: (_) {},
        ),
      );
      expect(tester.takeException(), isNull);
      for (final e in etiquetas.entries) {
        final segmento = find.byKey(ClavesUi.segmento(e.key));
        final texto = find.descendant(
          of: segmento,
          matching: find.text(e.value),
        );
        expect(texto, findsOneWidget, reason: e.value);
        final t = tester.widget<Text>(texto);
        expect(t.maxLines, 1);
        expect(t.softWrap, isFalse);
        // La etiqueta cabe dentro de su segmento (encoge, no se recorta).
        final caja = find.descendant(
          of: segmento,
          matching: find.byType(FittedBox),
        );
        expect(caja, findsOneWidget, reason: e.value);
        expect(
          tester.getSize(caja).width,
          lessThanOrEqualTo(tester.getSize(segmento).width),
          reason: e.value,
        );
        expect(
          tester.getSize(segmento).height,
          greaterThanOrEqualTo(48),
          reason: e.value,
        );
      }
    });

    testWidgets('la cabecera limita la escala del título a 1,5', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await _montar(tester, const CabeceraGrande(titulo: 'Medicación'));
      expect(tester.takeException(), isNull);
      expect(find.text('Medicación'), findsOneWidget);
      final texto = find.text('Medicación');
      final escala = MediaQuery.textScalerOf(tester.element(texto));
      expect(escala.scale(10), closeTo(15, 0.001));
      expect(tester.widget<Text>(texto).maxLines, 2);
    });
  });

  group('IconoCuadrado', () {
    double contraste(Color a, Color b) {
      final la = a.computeLuminance() + 0.05;
      final lb = b.computeLuminance() + 0.05;
      return la > lb ? la / lb : lb / la;
    }

    test('símbolo blanco u oscuro según el fondo, siempre el más legible', () {
      expect(IconoCuadrado.simboloSobre(Colores.azul), Colores.blanco);
      expect(IconoCuadrado.simboloSobre(Colores.verde), Colores.blanco);
      // El índigo de la noche (#8E8AFF) no admite blanco (2,9:1).
      expect(IconoCuadrado.simboloSobre(ColoresOscuro.indigo), Colores.texto);
      expect(
        contraste(
          ColoresOscuro.indigo,
          IconoCuadrado.simboloSobre(ColoresOscuro.indigo),
        ),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('sin color, el símbolo se elige por el fondo', (tester) async {
      await _montar(
        tester,
        const IconoCuadrado(
          CupertinoIcons.doc_text_fill,
          fondo: ColoresOscuro.indigo,
        ),
        oscuro: true,
      );
      expect(tester.widget<Icon>(find.byType(Icon)).color, Colores.texto);
      await _montar(
        tester,
        const IconoCuadrado(CupertinoIcons.doc_text_fill, fondo: Colores.verde),
      );
      expect(tester.widget<Icon>(find.byType(Icon)).color, Colores.blanco);
      // Con color explícito, se respeta.
      await _montar(
        tester,
        const IconoCuadrado(
          CupertinoIcons.doc_text_fill,
          fondo: Colores.verde,
          color: Colores.texto,
        ),
      );
      expect(tester.widget<Icon>(find.byType(Icon)).color, Colores.texto);
    });
  });
}
