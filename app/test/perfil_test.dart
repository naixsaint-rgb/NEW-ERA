import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/enrutado/router.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/shared/claves_ui.dart';

import 'utiles/app_prueba.dart';

void main() {
  test('redirección por perfil', () {
    const sinPerfil = Sesion();
    const persona = Sesion(perfil: PerfilApp.persona);
    const familia = Sesion(perfil: PerfilApp.familia);
    expect(redirigirSegunPerfil(sinPerfil, '/'), '/perfil');
    expect(redirigirSegunPerfil(sinPerfil, '/persona'), '/perfil');
    expect(redirigirSegunPerfil(sinPerfil, '/perfil'), isNull);
    expect(redirigirSegunPerfil(persona, '/'), '/persona');
    expect(redirigirSegunPerfil(familia, '/'), '/familia/hoy');
    expect(redirigirSegunPerfil(persona, '/familia/ideas'), '/persona');
    expect(redirigirSegunPerfil(familia, '/persona'), '/familia/hoy');
    // La familia puede probar la pantalla de toma.
    expect(redirigirSegunPerfil(familia, '/persona/toma/x'), isNull);
    expect(redirigirSegunPerfil(familia, '/familia'), '/familia/hoy');
  });

  testWidgets('sin perfil se pregunta de quién es el móvil y se registra', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(sembrar: false),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));

    expect(find.text('¿De quién es este móvil?'), findsOneWidget);
    expect(find.text('De la persona'), findsOneWidget);
    expect(find.text('De un familiar o cuidador'), findsOneWidget);

    await tester.tap(find.text('De un familiar o cuidador'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byKey(ClavesUi.semaforo), findsOneWidget);

    final eventos = await tester.runAsync(
      () => entorno.db.select(entorno.db.eventos).get(),
    );
    final elegido = eventos!.where((e) => e.tipo == 'perfil_elegido').toList();
    expect(elegido, hasLength(1));
    expect(elegido.single.payload, contains('familia'));
    final miembros = await tester.runAsync(
      () => entorno.db.select(entorno.db.miembros).get(),
    );
    expect(miembros!.single.nombre, 'Responsable');
    expect(miembros.single.ordenEscalado, 1);
    final dispositivos = await tester.runAsync(
      () => entorno.db.select(entorno.db.dispositivos).get(),
    );
    expect(dispositivos!.single.perfil, 'familia');
  });

  testWidgets('el banner de la demo web avisa y permite cambiar de perfil', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.persona, demoWeb: true),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));
    expect(
      find.text(
        'Demo con datos de ejemplo, sin cifrar.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cambiar perfil'));
    await pasar(tester, const Duration(seconds: 1));
    expect(find.text('¿De quién es este móvil?'), findsOneWidget);
  });
}
