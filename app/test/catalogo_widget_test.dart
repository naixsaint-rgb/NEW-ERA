import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/tema/colores.dart';
import 'package:newera/features/catalogo/etiqueta_direccion.dart';
import 'package:newera/features/catalogo/datos/catalogo_repositorio.dart';
import 'package:newera/features/catalogo/dominio/filtro.dart';
import 'package:newera/shared/claves_ui.dart';

import 'utiles/app_prueba.dart';

Finder get _filas => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('fila_'),
);

double _contraste(Color a, Color b) {
  final la = a.computeLuminance() + 0.05;
  final lb = b.computeLuminance() + 0.05;
  return la > lb ? la / lb : lb / la;
}

void main() {
  testWidgets('el catálogo filtra y abre una ficha con enlace', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/ideas');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pasar(tester, const Duration(seconds: 1));

    expect(find.textContaining('Nadie hace de juez'), findsOneWidget);
    expect(find.textContaining('647'), findsWidgets); // "N de 647"

    await tester.enterText(find.byKey(ClavesUi.buscadorCatalogo), 'MIND');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('647 de 647'), findsNothing);

    final catalogo = await tester.runAsync(
      () => const CatalogoRepositorio().cargar(),
    );
    final coincidencias = filtrarFilas(
      catalogo!.filas,
      const FiltroCatalogo(texto: 'MIND'),
    );
    expect(coincidencias, isNotEmpty);
    final fila = find.byKey(ClavesUi.filaCatalogo(coincidencias.first.id));
    await tester.scrollUntilVisible(
      fila,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(_filas, findsWidgets);
    await tester.tap(fila);
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('Ficha'), findsOneWidget);
    expect(find.text('Intervención (grupo)'), findsOneWidget);
    final boton = find.byKey(ClavesUi.enlaceFicha);
    await tester.scrollUntilVisible(
      boton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(boton, findsOneWidget);
    await tester.tap(boton);
    await pasar(tester, const Duration(milliseconds: 500));
    expect(entorno.enlaces, hasLength(1));
    expect(entorno.enlaces.single.toString(), startsWith('http'));
  });

  testWidgets('la tabla resumen es ordenable por n y filtra la lista', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/ideas/resumen');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pasar(tester, const Duration(seconds: 1));

    expect(find.byType(DataTable), findsOneWidget);
    await tester.ensureVisible(find.text('n').first);
    await tester.pump();
    await tester.tap(find.text('n').first);
    await pasar(tester, const Duration(milliseconds: 500));
    final tabla = tester.widget<DataTable>(find.byType(DataTable));
    expect(tabla.sortColumnIndex, 2);

    final catalogo = await tester.runAsync(
      () => const CatalogoRepositorio().cargar(),
    );
    final grupo = catalogo!.indice.grupos.first.grupo;
    expect(find.text(grupo), findsOneWidget);
    await tester.ensureVisible(find.text(grupo));
    await tester.pump();
    await tester.tap(find.text(grupo));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Grupo: $grupo'), findsOneWidget);
  });

  testWidgets('el dosier muestra sus 9 apartados', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(
      tester,
      entorno!,
      rutaInicial: '/familia/ideas/tema/cobre_metales',
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('Cobre, zinc y metales'), findsOneWidget);
    expect(find.text('Tesis'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ideas para la app'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ideas para la app'), findsOneWidget);
  });

  test('los colores de la dirección llegan a 4,5:1 en claro y en oscuro', () {
    const direcciones = [
      'mejora',
      'empeora',
      'mixto',
      'no aplica',
      'sin cambio',
    ];
    for (final c in [ColoresApp.claro, ColoresApp.oscuro]) {
      for (final d in direcciones) {
        expect(
          _contraste(EtiquetaDireccion.colorDe(d, c), c.tarjeta),
          greaterThanOrEqualTo(4.5),
          reason: '$d en ${c == ColoresApp.claro ? 'claro' : 'oscuro'}',
        );
      }
    }
  });

  testWidgets('Ideas y tablas en oscuro: contraste del texto', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final manejador = tester.ensureSemantics();
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/ideas');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    await tester.scrollUntilVisible(
      find.byType(EtiquetaDireccion),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.byType(EtiquetaDireccion), findsWidgets);
    for (final e in tester.widgetList<EtiquetaDireccion>(
      find.byType(EtiquetaDireccion),
    )) {
      final texto = tester.widget<Text>(
        find.descendant(of: find.byWidget(e), matching: find.byType(Text)),
      );
      expect(
        _contraste(texto.style!.color!, ColoresOscuro.tarjeta),
        greaterThanOrEqualTo(4.5),
        reason: '${e.direccion}',
      );
    }
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    manejador.dispose();
  });
}
