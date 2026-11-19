import 'dart:math';

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, Value, driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/avisos/canal_avisos.dart';
import 'package:newera/core/avisos/envio_avisos.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/circulo_repositorio.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/features/circulo/miembro_form_pantalla.dart';
import 'package:newera/features/persona_inicio/llamadas.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

final _clave = ClaveCirculo.generar(Random(11));
const _circulo = 'circulo-prueba';

/// Un móvil del círculo (base en memoria, cartero en memoria) con su familiar.
class _Movil {
  _Movil(this.c, this.servicio, this.reloj);

  final ProviderContainer c;
  final ServicioSync servicio;
  final RelojFijo reloj;

  AppDatabase get db => c.read(baseDatosProvider);
  CirculoRepositorio get repo => c.read(circuloRepositorioProvider);

  Future<List<Miembro>> miembros() => repo.observarMiembros().first;

  Future<Miembro> porNombre(String nombre) async =>
      (await db.select(db.miembros).get()).firstWhere(
        (m) => m.nombre == nombre,
      );

  Future<void> cerrar() async {
    await servicio.detener();
    final base = db;
    c.dispose();
    await base.close();
  }
}

Future<_Movil> _crearMovil(ServidorMemoria servidor, String dispositivo) async {
  final reloj = RelojFijo(instantePrueba);
  final almacen = AlmacenSeguroMemoria({
    ClavesAlmacen.dispositivoId: dispositivo,
    ClavesAlmacen.circuloId: _circulo,
    ClavesAlmacen.circuloClave: _clave,
    ClavesAlmacen.circuloClaveVersion: '1',
  });
  final overrides = await Arranque.iniciar(
    almacen: almacen,
    ejecutor: ejecutorEnMemoria(),
    reloj: reloj,
    plataforma: 'android',
    demoWeb: false,
    sembrarDemo: false,
    azar: Random(dispositivo.hashCode),
  );
  final transporte = TransporteMemoria(servidor);
  final c = ProviderContainer(
    overrides: [
      ...overrides,
      syncTransportProvider.overrideWithValue(transporte),
    ],
  );
  final servicio = ServicioSync(
    db: c.read(baseDatosProvider),
    transporte: transporte,
    llaves: () => c.read(llavesCirculoProvider.future),
    contexto: c.read(contextoProvider),
    reloj: c.read(relojProvider),
    pausaNuevos: const Duration(milliseconds: 1),
    esperaMinima: const Duration(milliseconds: 10),
    esperaMaxima: const Duration(milliseconds: 50),
  );
  final m = _Movil(c, servicio, reloj);
  await m.repo.asegurarDispositivo(PerfilApp.familia);
  return m;
}

/// Lleva a [b] todo lo que [a] dejó en el cartero.
Future<void> _entregar(
  ServidorMemoria servidor,
  _Movil a,
  _Movil b, {
  bool alReves = false,
}) async {
  await a.servicio.empujar();
  final sobres = [...servidor.sobres];
  for (final s in alReves ? sobres.reversed : sobres) {
    await b.servicio.recibir(s);
  }
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('círculo: repositorio y cartero', () {
    late ServidorMemoria servidor;
    late _Movil a;
    late _Movil b;

    setUp(() async {
      servidor = ServidorMemoria();
      a = await _crearMovil(servidor, 'movil-a');
      b = await _crearMovil(servidor, 'movil-b');
    });

    tearDown(() async {
      await a.cerrar();
      await b.cerrar();
    });

    test('añadir: guarda el papel estable y el teléfono limpio', () async {
      final id = await a.repo.crearMiembro(
        const NuevoMiembro(
          nombre: '  Javier  ',
          relacion: 'hijo',
          telefono: '000 000 002',
        ),
      );
      final m = (await a.miembros()).firstWhere((x) => x.id == id);
      expect(m.nombre, 'Javier');
      expect(m.relacion, 'hijo');
      expect(m.telefono, '000000002');
      expect(m.bajaEn, isNull);
      await expectLater(
        a.repo.crearMiembro(const NuevoMiembro(nombre: '  ', relacion: 'otro')),
        throwsArgumentError,
      );
    });

    test('un familiar añadido en A llega a B con sus campos', () async {
      final id = await a.repo.crearMiembro(
        const NuevoMiembro(
          nombre: 'Marta',
          relacion: 'cuidadora',
          telefono: '000000003',
        ),
      );
      await _entregar(servidor, a, b);
      final enB = (await b.miembros()).firstWhere((m) => m.id == id);
      expect(enB.nombre, 'Marta');
      expect(enB.relacion, 'cuidadora');
      expect(enB.telefono, '000000003');
    });

    test('editar y renombrar el propio: viaja como ficha modificada', () async {
      final propio = (await a.repo.miembroDeEsteMovil())!;
      await a.repo.editarMiembro(
        propio,
        nombre: 'Lucía',
        relacion: 'hija',
        telefono: '000000001',
      );
      final fichas =
          await (a.db.select(a.db.eventos)..where(
                (e) =>
                    e.tipo.equals('ficha_modificada') & e.sujeto.equals(propio),
              ))
              .get();
      final p = EventosRepositorio.payloadDe(fichas.last);
      expect((p['fila'] as Map)['nombre'], 'Lucía');
      expect(p['antes'], containsPair('nombre', 'Responsable'));
      await _entregar(servidor, a, b);
      final enB = (await b.miembros()).firstWhere((m) => m.id == propio);
      expect(enB.nombre, 'Lucía');
      expect(enB.relacion, 'hija');
      await expectLater(
        a.repo.editarMiembro(propio, nombre: ' ', relacion: 'hija'),
        throwsArgumentError,
      );
    });

    test('dos cambios del mismo familiar: gana el más reciente', () async {
      final id = await a.repo.crearMiembro(
        const NuevoMiembro(nombre: 'Javier', relacion: 'hijo'),
      );
      await _entregar(servidor, a, b);
      // B cambia antes (a las 12:00:05) y A después (12:00:10), pero el
      // cambio de A llega primero a B.
      b.reloj.fijar(instantePrueba.add(const Duration(seconds: 5)));
      await b.repo.editarMiembro(id, nombre: 'Javier de B', relacion: 'hijo');
      a.reloj.fijar(instantePrueba.add(const Duration(seconds: 10)));
      await a.repo.editarMiembro(id, nombre: 'Javier de A', relacion: 'hijo');
      await _entregar(servidor, a, b);
      await _entregar(servidor, b, a);
      expect((await a.porNombre('Javier de A')).id, id);
      expect((await b.porNombre('Javier de A')).id, id);
      expect(
        (await a.db.select(a.db.miembros).get()).where((m) => m.id == id),
        hasLength(1),
      );
    });

    test('quitar: baja lógica, ya no sale en listas ni en B', () async {
      final id = await a.repo.crearMiembro(
        const NuevoMiembro(nombre: 'Marta', relacion: 'otro'),
      );
      await _entregar(servidor, a, b);
      expect((await b.miembros()).map((m) => m.id), contains(id));
      a.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
      await a.repo.quitarMiembro(id);
      // La fila se conserva, con su marca de baja.
      final fila = (await a.db.select(a.db.miembros).get()).firstWhere(
        (m) => m.id == id,
      );
      expect(
        fila.bajaEn,
        instantePrueba.add(const Duration(minutes: 1)).millisecondsSinceEpoch,
      );
      expect((await a.miembros()).map((m) => m.id), isNot(contains(id)));
      await _entregar(servidor, a, b);
      expect((await b.miembros()).map((m) => m.id), isNot(contains(id)));
      expect(
        (await b.db.select(b.db.miembros).get())
            .firstWhere((m) => m.id == id)
            .bajaEn,
        fila.bajaEn,
      );
    });

    test('no se puede quitar el familiar de este móvil', () async {
      final propio = (await a.repo.miembroDeEsteMovil())!;
      await expectLater(a.repo.quitarMiembro(propio), throwsStateError);
      expect((await a.miembros()).map((m) => m.id), contains(propio));
      expect((await a.porNombre('Responsable')).bajaEn, isNull);
    });

    test('un familiar de baja no recibe avisos ni sale para llamar', () async {
      final uno = await a.repo.crearMiembro(
        const NuevoMiembro(
          nombre: 'Javier',
          relacion: 'hijo',
          telefono: '000000002',
          ordenEscalado: 2,
        ),
      );
      final dos = await a.repo.crearMiembro(
        const NuevoMiembro(
          nombre: 'Marta',
          relacion: 'otro',
          telefono: '000000003',
          ordenEscalado: 3,
        ),
      );
      final envio = EnvioAvisos(
        db: a.db,
        eventos: a.c.read(eventosRepositorioProvider),
        canal: CanalAvisosSimulado(),
        reloj: a.reloj,
        contexto: a.c.read(contextoProvider),
        tema: (id) async => 'tema-$id',
      );
      expect(destinatariosDeEscalon(await envio.familiares(), 2), [uno]);

      await a.repo.quitarMiembro(uno);
      final familiares = await envio.familiares();
      expect(familiares.map((f) => f.id), isNot(contains(uno)));
      // El aviso del segundo escalón pasa al siguiente puesto.
      expect(destinatariosDeEscalon(familiares, 2), [dos]);
      // Y a las llamadas de la persona.
      final lista = await a.miembros();
      expect(familiaresPorOrden(lista).map((m) => m.id), contains(dos));
      expect(familiaresPorOrden(lista).map((m) => m.id), isNot(contains(uno)));
    });
  });

  group('círculo: pantallas', () {
    Future<EntornoPrueba> montar(
      WidgetTester tester,
      String ruta, {
      String? propioSinNombre,
    }) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      if (propioSinNombre != null) {
        await tester.runAsync(
          () =>
              (e.db.update(e.db.miembros)
                    ..where((m) => m.nombre.equals(propioSinNombre)))
                  .write(const MiembrosCompanion(nombre: Value('Familiar'))),
        );
      }
      await montarApp(tester, e, rutaInicial: ruta);
      await _reposar(tester);
      return e;
    }

    testWidgets('añadir un familiar: nombre, papel y teléfono', (tester) async {
      final e = await montar(tester, Rutas.pestana('circulo'));
      expect(find.text('Familiar de prueba'), findsNothing);
      await tester.tap(find.byKey(ClavesUi.circAnadir));
      await _reposar(tester);
      expect(find.byType(MiembroFormPantalla), findsOneWidget);

      // Sin nombre no guarda.
      await _tocar(tester, ClavesUi.circGuardar);
      expect(find.text('Escribe un nombre.'), findsOneWidget);
      await tester.enterText(
        find.byKey(ClavesUi.circNombre),
        'Familiar de prueba',
      );
      await tester.enterText(find.byKey(ClavesUi.circTelefono), '123');
      await _tocar(tester, ClavesUi.circGuardar);
      expect(
        find.text('El teléfono debe tener entre 6 y 15 cifras.'),
        findsOneWidget,
      );
      await tester.enterText(find.byKey(ClavesUi.circTelefono), '000 000 004');
      await _tocar(tester, ClavesUi.circPapel('cuidador'));
      await _tocar(tester, ClavesUi.circGuardar);
      await _reposar(tester);

      final fila = (await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.nombre.equals('Familiar de prueba'))).getSingle(),
      ))!;
      expect(fila.relacion, 'cuidador');
      expect(fila.telefono, '000000004');
      expect(find.byType(MiembroFormPantalla), findsNothing);
      expect(find.text('Familiar de prueba'), findsOneWidget);
      expect(find.textContaining('Cuidador'), findsWidgets);
      final fichas = await tester.runAsync(
        () => (e.db.select(
          e.db.eventos,
        )..where((x) => x.sujeto.equals(fila.id))).get(),
      );
      expect(fichas!.map((x) => x.tipo), contains('ficha_creada'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('editar y renombrar un familiar', (tester) async {
      final e = await montar(tester, Rutas.pestana('circulo'));
      final javier = (await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.nombre.equals('Javier'))).getSingle(),
      ))!;
      await tester.tap(find.byKey(ClavesUi.circFamiliar(javier.id)));
      await _reposar(tester);
      await tester.tap(find.byKey(ClavesUi.circEditar));
      await _reposar(tester);
      expect(find.widgetWithText(TextField, 'Javier'), findsOneWidget);
      await tester.enterText(find.byKey(ClavesUi.circNombre), 'Javier Prueba');
      await _tocar(tester, ClavesUi.circPapel('marido'));
      await _tocar(tester, ClavesUi.circGuardar);
      await _reposar(tester);

      final fila = (await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.id.equals(javier.id))).getSingle(),
      ))!;
      expect(fila.nombre, 'Javier Prueba');
      expect(fila.relacion, 'marido');
      final fichas = await tester.runAsync(
        () =>
            (e.db.select(e.db.eventos)..where(
                  (x) =>
                      x.tipo.equals('ficha_modificada') &
                      x.sujeto.equals(javier.id),
                ))
                .get(),
      );
      final p = EventosRepositorio.payloadDe(fichas!.last);
      expect((p['fila'] as Map)['nombre'], 'Javier Prueba');
      expect(tester.takeException(), isNull);
    });

    testWidgets('el propio móvil se puede editar pero no quitar', (
      tester,
    ) async {
      final e = await montar(tester, Rutas.pestana('circulo'));
      final lucia = (await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.nombre.equals('Lucía'))).getSingle(),
      ))!;
      await tester.tap(find.byKey(ClavesUi.circFamiliar(lucia.id)));
      await _reposar(tester);
      expect(find.byKey(ClavesUi.circEditar), findsOneWidget);
      expect(find.byKey(ClavesUi.circQuitar), findsNothing);
      expect(
        find.text('No puedes quitar el familiar de este móvil.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('quitar: pide confirmación y avisa de la clave', (
      tester,
    ) async {
      final e = await montar(tester, Rutas.pestana('circulo'));
      final marta = (await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.nombre.equals('Marta'))).getSingle(),
      ))!;
      expect(find.text('Marta'), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.circFamiliar(marta.id)));
      await _reposar(tester);
      await tester.tap(find.byKey(ClavesUi.circQuitar));
      await _reposar(tester);
      expect(find.text('¿Quitar a Marta del círculo?'), findsOneWidget);
      expect(
        find.textContaining('no le retira todavía la clave del círculo'),
        findsOneWidget,
      );
      // Cancelar no cambia nada.
      await tester.tap(find.text('Cancelar'));
      await _reposar(tester);
      var fila = (await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.id.equals(marta.id))).getSingle(),
      ))!;
      expect(fila.bajaEn, isNull);

      await tester.tap(find.byKey(ClavesUi.circQuitar));
      await _reposar(tester);
      await tester.tap(find.byKey(ClavesUi.circQuitarConfirmar));
      await _reposar(tester);
      fila = (await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.id.equals(marta.id))).getSingle(),
      ))!;
      expect(fila.bajaEn, e.reloj.ahora().millisecondsSinceEpoch);
      // Vuelve a Círculo y Marta ya no está.
      expect(find.byKey(ClavesUi.circFamiliar(marta.id)), findsNothing);
      expect(find.text('Marta'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un móvil que aún es «Familiar» ve «Pon tu nombre»', (
      tester,
    ) async {
      final e = await montar(
        tester,
        Rutas.pestana('circulo'),
        propioSinNombre: 'Lucía',
      );
      expect(find.byKey(ClavesUi.circPonNombre), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.circPonNombre));
      await _reposar(tester);
      // El nombre provisional no se ofrece como si fuera el nombre.
      expect(
        tester
            .widget<TextField>(find.byKey(ClavesUi.circNombre))
            .controller!
            .text,
        isEmpty,
      );
      await tester.enterText(find.byKey(ClavesUi.circNombre), 'Lucía');
      await _tocar(tester, ClavesUi.circGuardar);
      await _reposar(tester);
      expect(find.byKey(ClavesUi.circPonNombre), findsNothing);
      final n = await tester.runAsync(
        () => (e.db.select(
          e.db.miembros,
        )..where((m) => m.nombre.equals('Lucía'))).get(),
      );
      expect(n, hasLength(1));
    });

    for (final ruta in ['nuevo', 'familiar', 'circulo']) {
      testWidgets('accesibilidad ($ruta): 200 % sin excepciones y toques 44+', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        final manejador = tester.ensureSemantics();
        final entorno = (await tester.runAsync(
          () => prepararEntorno(perfil: PerfilApp.familia),
        ))!;
        final marta = (await tester.runAsync(
          () => (entorno.db.select(
            entorno.db.miembros,
          )..where((m) => m.nombre.equals('Marta'))).getSingle(),
        ))!;
        final destino = switch (ruta) {
          'nuevo' => Rutas.circuloNuevo,
          'familiar' => Rutas.familiar(marta.id),
          _ => Rutas.pestana('circulo'),
        };
        await montarApp(tester, entorno, rutaInicial: destino);
        await _reposar(tester);
        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        manejador.dispose();
      });
    }

    testWidgets('formulario en oscuro: contraste del texto', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final manejador = tester.ensureSemantics();
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      await montarApp(tester, e, rutaInicial: Rutas.circuloNuevo);
      await _reposar(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      manejador.dispose();
    });
  });
}

Future<void> _reposar(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
  await pasar(tester, const Duration(seconds: 1));
}

/// Lleva a la vista el widget con [clave] y lo toca.
Future<void> _tocar(WidgetTester tester, Key clave) async {
  await tester.scrollUntilVisible(
    find.byKey(clave),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
  await tester.tap(find.byKey(clave));
  await _reposar(tester);
}
