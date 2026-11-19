import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/avisos/canal_avisos.dart';
import 'package:newera/core/avisos/programador_avisos.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/db/repositorios/ubicacion_repositorio.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/core/plataforma/ubicacion/ubicador.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/features/avisos/segundo_plano.dart';
import 'package:newera/features/hoy/dominio/tomas.dart';
import 'package:newera/features/ubicacion/toma_ubicacion.dart';
import 'package:newera/features/ubicacion/ubicacion_pantalla.dart';
import 'package:newera/features/ubicacion/ubicacion_providers.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

// Coordenadas de ejemplo neutras: un punto céntrico genérico de Madrid (el
// mismo de la semilla), nunca la casa de nadie.
const _lat = 40.4168;
const _lon = -3.7038;
double _norte(double metros) => _lat + metros / 111195;

PosicionGps _pos(DateTime t, {double metros = 0, double precision = 15}) =>
    PosicionGps(
      lat: _norte(metros),
      lon: _lon,
      precision: precision,
      instante: t,
    );

final _clave = ClaveCirculo.generar(Random(33));
const _circulo = 'circulo-ubicacion';
const _persona = 'persona-ubicacion';

// ------------------------------------------------------------ Dos móviles

class _Movil {
  _Movil(this.c, this.servicio, this.reloj, this.miembro);

  final ProviderContainer c;
  final ServicioSync servicio;
  final RelojFijo reloj;
  final String? miembro;

  AppDatabase get db => c.read(baseDatosProvider);
  UbicacionRepositorio get repo => c.read(ubicacionRepositorioProvider);

  Future<List<Evento>> posiciones() => (db.select(
    db.eventos,
  )..where((e) => e.tipo.equals('ubicacion_registrada'))).get();

  Future<void> cerrar() async {
    await servicio.detener();
    final base = db;
    c.dispose();
    await base.close();
  }
}

Future<_Movil> _crearMovil(
  ServidorMemoria servidor,
  String dispositivo,
  PerfilApp perfil,
) async {
  final reloj = RelojFijo(instantePrueba);
  final almacen = AlmacenSeguroMemoria({
    ClavesAlmacen.dispositivoId: dispositivo,
    ClavesAlmacen.circuloId: _circulo,
    ClavesAlmacen.personaId: _persona,
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
  final miembro = await c
      .read(circuloRepositorioProvider)
      .asegurarDispositivo(perfil);
  return _Movil(c, servicio, reloj, miembro);
}

/// Envía lo de [a] y entrega a [b] todo lo que hay en el servidor.
Future<void> _entregar(ServidorMemoria servidor, _Movil a, _Movil b) async {
  await a.servicio.empujar();
  for (final s in [...servidor.sobres]) {
    await b.servicio.recibir(s);
  }
}

// ------------------------------------------------------------ Segundo plano

/// Base en archivo con la semilla (ubicación encendida, zona en el punto de
/// ejemplo, 200 m) para la revisión con la app cerrada.
Future<({File archivo, AlmacenSeguro almacen, RelojFijo reloj})>
_baseEnArchivo() async {
  final dir = await Directory.systemTemp.createTemp('newera_ubicacion_');
  addTearDown(() => dir.delete(recursive: true));
  final archivo = File('${dir.path}/newera.db');
  final reloj = RelojFijo(instantePrueba);
  final almacen = AlmacenSeguroMemoria({ClavesAlmacen.perfil: 'persona'});
  final overrides = await Arranque.iniciar(
    almacen: almacen,
    ejecutor: NativeDatabase(archivo),
    reloj: reloj,
    plataforma: 'android',
    demoWeb: false,
    sembrarDemo: true,
    sembrarControl: false,
    azar: Random(42),
  );
  final c = ProviderContainer(overrides: overrides);
  await c.read(baseDatosProvider).close();
  c.dispose();
  return (archivo: archivo, almacen: almacen, reloj: reloj);
}

/// Abre la base en archivo, hace [f] con su contenedor y la cierra.
Future<T> _conBase<T>(
  ({File archivo, AlmacenSeguro almacen, RelojFijo reloj}) b,
  Future<T> Function(ProviderContainer c) f,
) async {
  final overrides = await Arranque.iniciar(
    almacen: b.almacen,
    ejecutor: NativeDatabase(b.archivo),
    reloj: b.reloj,
    plataforma: 'android',
    demoWeb: false,
    sembrarDemo: false,
    azar: Random(7),
  );
  final c = ProviderContainer(overrides: overrides);
  try {
    return await f(c);
  } finally {
    await c.read(baseDatosProvider).close();
    c.dispose();
  }
}

final class _ProgramadorPrueba implements ProgramadorAvisos {
  final programados = <DateTime>[];

  @override
  bool get enSegundoPlano => true;

  @override
  Future<int> programar(Iterable<DateTime> instantes) async {
    programados.addAll(instantes);
    return instantes.length;
  }

  @override
  Future<void> soltar(int id) async {}
}

// ------------------------------------------------------------ Pantallas

Future<EntornoPrueba> _abrir(
  WidgetTester tester, {
  String ruta = Rutas.ubicacion,
  PerfilApp perfil = PerfilApp.familia,
  Brightness brillo = Brightness.light,
  Future<void> Function(EntornoPrueba e)? previo,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final entorno = await tester.runAsync(() async {
    final e = await prepararEntorno(perfil: perfil);
    if (previo != null) await previo(e);
    return e;
  });
  await montarApp(tester, entorno!, rutaInicial: ruta);
  await _esperar(tester);
  return entorno;
}

Future<void> _esperar(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
  await pasar(tester, const Duration(milliseconds: 700));
}

Finder get _lista => find
    .descendant(
      of: find.byType(ListView).last,
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _pulsar(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 200, scrollable: _lista);
  }
  await Scrollable.ensureVisible(f.evaluate().first, alignment: 0.5);
  await pasar(tester, const Duration(milliseconds: 300));
  await tester.tap(f);
  await _esperar(tester);
}

/// Repositorio de ubicación sobre la base del entorno, firmado por [autor].
UbicacionRepositorio _repo(EntornoPrueba e, {String autor = 'x'}) =>
    UbicacionRepositorio(
      db: e.db,
      reloj: e.reloj,
      contexto: e.contexto,
      eventos: EventosRepositorio(
        db: e.db,
        reloj: e.reloj,
        azar: Random(3),
        contexto: e.contexto,
        autor: () => autor,
      ),
      autor: () => autor,
    );

Future<List<Map<String, dynamic>>> _payloadsUbicacion(
  WidgetTester tester,
  EntornoPrueba e,
) async => (await tester.runAsync(
  () => (e.db.select(
    e.db.eventos,
  )..where((x) => x.tipo.equals('ubicacion_registrada'))).get(),
))!.map((x) => jsonDecode(x.payload) as Map<String, dynamic>).toList();

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    inicializarZonas();
  });

  group('repositorio y cartero', () {
    late ServidorMemoria servidor;
    late _Movil persona;
    late _Movil familia;

    setUp(() async {
      servidor = ServidorMemoria();
      persona = await _crearMovil(servidor, 'movil-persona', PerfilApp.persona);
      familia = await _crearMovil(servidor, 'movil-familia', PerfilApp.familia);
      await _entregar(servidor, persona, familia);
      await _entregar(servidor, familia, persona);
    });

    tearDown(() async {
      await persona.cerrar();
      await familia.cerrar();
    });

    Future<void> encender() async {
      await familia.repo.otorgar(
        miembroId: familia.miembro!,
        textoMostrado: 'Texto mostrado de prueba',
      );
      await _entregar(servidor, familia, persona);
    }

    test(
      'sin consentimiento no se registra nada (ni se pide la posición)',
      () async {
        final ubicador = UbicadorSimulado(siguiente: _pos(instantePrueba));
        final toma = TomaUbicacion(ubicador: ubicador, repo: persona.repo);
        expect(await toma.tomar(OrigenUbicacion.appAbierta), isNull);
        expect(
          await persona.repo.registrar(
            _pos(instantePrueba),
            origen: OrigenUbicacion.appAbierta,
          ),
          isNull,
        );
        expect(ubicador.pedidas, isEmpty);
        expect(await persona.posiciones(), isEmpty);
        // Tampoco se pide el permiso del sistema.
        final p = await toma.asegurarPermiso(
          tambienCerrada: true,
          yaPedido: (_) async => false,
          apuntar: (_) async {},
        );
        expect(p, isNull);
        expect(ubicador.permisosPedidos, 0);
      },
    );

    test('el consentimiento guarda el texto y la fecha, y viaja', () async {
      await encender();
      final c = (await familia.repo.consentimiento()).ultimo!;
      expect(c.sobre, 'ubicacion');
      expect(c.textoMostrado, 'Texto mostrado de prueba');
      expect(c.otorgadoEn, instantePrueba.millisecondsSinceEpoch);
      expect(c.otorgante, familia.miembro);
      expect(await persona.repo.consentimientoActivo(), isTrue);
    });

    test('la posición viaja cifrada al móvil de la familia', () async {
      await encender();
      final ubicador = UbicadorSimulado(
        estado: PermisoUbicacion.siempre,
        siguiente: _pos(instantePrueba, metros: 40, precision: 12),
        nivelBateria: 64,
      );
      final id = await TomaUbicacion(
        ubicador: ubicador,
        repo: persona.repo,
      ).tomar(OrigenUbicacion.appAbierta);
      expect(id, isNotNull);
      // Ningún sobre lleva la posición en claro.
      await persona.servicio.empujar();
      for (final s in servidor.sobres) {
        expect(
          utf8.decode(s.contenido, allowMalformed: true),
          isNot(contains('40.41')),
        );
      }
      await _entregar(servidor, persona, familia);
      final l = await familia.repo.observarLecturas().first;
      expect(l, hasLength(1));
      expect(l.single.id, id);
      expect(l.single.lat, closeTo(_norte(40), 1e-9));
      expect(l.single.precision, 12);
      expect(l.single.bateria, 64);
      expect(l.single.origen, OrigenUbicacion.appAbierta);
      expect(
        await familia.repo.observarPermisoDelMovil().first,
        PermisoUbicacion.siempre,
      );
      // La firma la persona.
      expect((await familia.posiciones()).single.autor, _persona);
    });

    test('retención: más de 7 días se borra y, si llega, se ignora', () async {
      await encender();
      final r = persona.repo;
      // Una de hace 8 días ni se guarda.
      expect(
        await r.registrar(
          _pos(instantePrueba.subtract(const Duration(days: 8))),
          origen: OrigenUbicacion.appAbierta,
        ),
        isNull,
      );
      final vieja = await r.registrar(
        _pos(instantePrueba.subtract(const Duration(days: 6))),
        origen: OrigenUbicacion.appAbierta,
      );
      await r.registrar(
        _pos(instantePrueba),
        origen: OrigenUbicacion.appAbierta,
      );
      expect(await persona.posiciones(), hasLength(2));
      // La familia aún no la tiene; pasan dos días.
      persona.reloj.fijar(instantePrueba.add(const Duration(days: 2)));
      familia.reloj.fijar(instantePrueba.add(const Duration(days: 2)));
      expect(await r.purgar(), 1);
      final quedan = await persona.posiciones();
      expect(quedan.map((e) => e.ulid), isNot(contains(vieja)));
      expect(quedan, hasLength(1));
      // Lo que ya estaba en el servidor llega a la familia: la vieja, no.
      await _entregar(servidor, persona, familia);
      final enFamilia = await familia.posiciones();
      expect(enFamilia, hasLength(1));
      expect(enFamilia.single.ulid, isNot(vieja));
      // Los demás eventos siguen siendo de solo inserción.
      await expectLater(
        familia.db.customStatement(
          "DELETE FROM eventos WHERE tipo <> 'ubicacion_registrada'",
        ),
        throwsA(anything),
      );
    });

    test(
      'apagar: deja de registrar y cada móvil borra sus posiciones',
      () async {
        await encender();
        await persona.repo.registrar(
          _pos(instantePrueba),
          origen: OrigenUbicacion.appAbierta,
        );
        await _entregar(servidor, persona, familia);
        expect(await familia.posiciones(), hasLength(1));
        await familia.repo.revocar(
          miembroId: familia.miembro!,
          textoMostrado: 'Apagada en la prueba',
        );
        expect(await familia.posiciones(), isEmpty);
        expect(await familia.repo.consentimientoActivo(), isFalse);
        await _entregar(servidor, familia, persona);
        expect(await persona.repo.consentimientoActivo(), isFalse);
        expect(await persona.posiciones(), isEmpty);
        expect(
          await persona.repo.registrar(
            _pos(instantePrueba),
            origen: OrigenUbicacion.appAbierta,
          ),
          isNull,
        );
      },
    );

    test('una posición tomada con la ubicación apagada no entra al volver a '
        'encenderla', () async {
      await encender();
      // El móvil de la persona se queda sin red; la familia apaga y vuelve a
      // encender. Mientras, la persona (que aún no lo sabe) toma posiciones.
      familia.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
      await familia.repo.revocar(
        miembroId: familia.miembro!,
        textoMostrado: 'Apagada en la prueba',
      );
      familia.reloj.fijar(instantePrueba.add(const Duration(minutes: 10)));
      await familia.repo.otorgar(
        miembroId: familia.miembro!,
        textoMostrado: 'Encendida otra vez',
      );
      await familia.servicio.empujar();
      final apagada = await persona.repo.registrar(
        _pos(instantePrueba.add(const Duration(minutes: 5))),
        origen: OrigenUbicacion.appAbierta,
      );
      expect(apagada, isNotNull);
      // Al volver la red, la persona envía antes de recoger.
      await _entregar(servidor, persona, familia);
      expect(await familia.posiciones(), isEmpty);
      for (final s in [...servidor.sobres]) {
        await persona.servicio.recibir(s);
      }
      expect(await persona.repo.consentimientoActivo(), isTrue);
      expect(await persona.posiciones(), isEmpty);
      // Las de después de encenderla, sí.
      persona.reloj.fijar(instantePrueba.add(const Duration(minutes: 11)));
      await persona.repo.registrar(
        _pos(instantePrueba.add(const Duration(minutes: 11))),
        origen: OrigenUbicacion.appAbierta,
      );
      await _entregar(servidor, persona, familia);
      expect(await familia.posiciones(), hasLength(1));
    });

    test(
      'la zona segura es una ficha que viaja; gana la más reciente',
      () async {
        await familia.repo.guardarZona(lat: _lat, lon: _lon);
        await _entregar(servidor, familia, persona);
        expect(
          await persona.repo.zona(),
          const ZonaSegura(lat: _lat, lon: _lon, radio: 200),
        );
        familia.reloj.fijar(instantePrueba.add(const Duration(minutes: 1)));
        await familia.repo.guardarZona(radio: 500);
        await _entregar(servidor, familia, persona);
        expect((await persona.repo.zona())?.radio, 500);
        expect(() => familia.repo.guardarZona(radio: 333), throwsArgumentError);
      },
    );

    test('modo perdida: la búsqueda llega al otro móvil y caduca a los 30 '
        'minutos', () async {
      await familia.repo.pedirBusqueda();
      await _entregar(servidor, familia, persona);
      final b = await persona.repo.busqueda();
      expect(b, isNotNull);
      expect(b!.hasta, instantePrueba.add(duracionBusqueda));
      persona.reloj.fijar(instantePrueba.add(const Duration(minutes: 29)));
      expect(await persona.repo.busqueda(), isNotNull);
      persona.reloj.fijar(instantePrueba.add(const Duration(minutes: 30)));
      expect(await persona.repo.busqueda(), isNull);
      // Pararla antes de tiempo.
      persona.reloj.fijar(instantePrueba.add(const Duration(minutes: 40)));
      familia.reloj.fijar(instantePrueba.add(const Duration(minutes: 40)));
      await familia.repo.pedirBusqueda();
      familia.reloj.fijar(instantePrueba.add(const Duration(minutes: 45)));
      await familia.repo.pararBusqueda();
      await _entregar(servidor, familia, persona);
      persona.reloj.fijar(instantePrueba.add(const Duration(minutes: 46)));
      expect(await persona.repo.busqueda(), isNull);
    });
  });

  group('segundo plano (Android, app cerrada)', () {
    Future<void> revisar(
      ({File archivo, AlmacenSeguro almacen, RelojFijo reloj}) b,
      DateTime cuando, {
      required UbicadorSimulado ubicador,
      required CanalAvisosSimulado canal,
      required _ProgramadorPrueba programador,
    }) {
      b.reloj.fijar(cuando);
      return revisionEnSegundoPlano(
        alarma: 1,
        almacen: b.almacen,
        abrir: (_) async => NativeDatabase(b.archivo),
        canal: canal,
        programador: programador,
        reloj: b.reloj,
        ubicador: ubicador,
      );
    }

    Future<List<Map<String, dynamic>>> avisosFuera(
      ({File archivo, AlmacenSeguro almacen, RelojFijo reloj}) b,
    ) => _conBase(b, (c) async {
      final db = c.read(baseDatosProvider);
      final filas = await (db.select(
        db.eventos,
      )..where((e) => e.tipo.equals('aviso_enviado'))).get();
      return [
        for (final f in filas)
          if ((jsonDecode(f.payload) as Map)['tipo'] == 'fuera_de_zona')
            {
              ...jsonDecode(f.payload) as Map<String, dynamic>,
              'sujeto': f.sujeto,
            },
      ];
    });

    test('toma su posición y avisa a todos una sola vez por salida', () async {
      final b = await _baseEnArchivo();
      final canal = CanalAvisosSimulado();
      final p = _ProgramadorPrueba();
      final t = instantePrueba.add(const Duration(minutes: 20));
      final ubicador = UbicadorSimulado(
        estado: PermisoUbicacion.siempre,
        siguiente: _pos(t, metros: 900, precision: 10),
      );
      await revisar(b, t, ubicador: ubicador, canal: canal, programador: p);
      var avisos = await avisosFuera(b);
      // A los tres familiares de la semilla, con prioridad 5.
      expect(avisos, hasLength(3));
      expect({for (final a in avisos) a['miembroId']}, hasLength(3));
      expect({for (final a in avisos) a['resultado']}, {'enviado'});
      expect(
        canal.enviados.where((x) => x.prioridad == 5).length,
        greaterThanOrEqualTo(3),
      );
      final salida = avisos.first['sujeto'];
      // La posición se guardó con su origen y la batería.
      final pos = await _conBase(
        b,
        (c) => c.read(ubicacionRepositorioProvider).observarLecturas().first,
      );
      expect(pos.last.id, salida);
      expect(pos.last.origen, OrigenUbicacion.segundoPlano);

      // Otra revisión, sigue fuera: la misma salida, ningún aviso nuevo.
      final t2 = t.add(const Duration(minutes: 5));
      ubicador.siguiente = _pos(t2, metros: 950, precision: 10);
      await revisar(b, t2, ubicador: ubicador, canal: canal, programador: p);
      expect(await avisosFuera(b), hasLength(3));

      // Vuelve a casa y sale otra vez: otra salida, otros tres avisos.
      final t3 = t2.add(const Duration(minutes: 5));
      ubicador.siguiente = _pos(t3, metros: 10, precision: 10);
      await revisar(b, t3, ubicador: ubicador, canal: canal, programador: p);
      final t4 = t3.add(const Duration(minutes: 5));
      ubicador.siguiente = _pos(t4, metros: 900, precision: 10);
      await revisar(b, t4, ubicador: ubicador, canal: canal, programador: p);
      avisos = await avisosFuera(b);
      expect(avisos, hasLength(6));
      expect({for (final a in avisos) a['sujeto']}, hasLength(2));
      expect(p.programados, isEmpty);
    });

    test('una lectura mala fuera no avisa; dos seguidas, sí', () async {
      final b = await _baseEnArchivo();
      final canal = CanalAvisosSimulado();
      final p = _ProgramadorPrueba();
      final t = instantePrueba.add(const Duration(minutes: 20));
      final ubicador = UbicadorSimulado(
        estado: PermisoUbicacion.siempre,
        siguiente: _pos(t, metros: 700, precision: 400),
      );
      await revisar(b, t, ubicador: ubicador, canal: canal, programador: p);
      expect(await avisosFuera(b), isEmpty);
      final t2 = t.add(const Duration(minutes: 10));
      ubicador.siguiente = _pos(t2, metros: 750, precision: 400);
      await revisar(b, t2, ubicador: ubicador, canal: canal, programador: p);
      expect(await avisosFuera(b), hasLength(3));
    });

    test('con búsqueda: posición precisa y otra revisión a los 5 minutos '
        'hasta que acaba', () async {
      final b = await _baseEnArchivo();
      await _conBase(
        b,
        (c) => c.read(ubicacionRepositorioProvider).pedirBusqueda(),
      );
      final canal = CanalAvisosSimulado();
      final p = _ProgramadorPrueba();
      final t = instantePrueba.add(const Duration(minutes: 2));
      final ubicador = UbicadorSimulado(
        estado: PermisoUbicacion.siempre,
        siguiente: _pos(t, metros: 20),
      );
      await revisar(b, t, ubicador: ubicador, canal: canal, programador: p);
      expect(ubicador.pedidas, [true]);
      expect(p.programados, [
        instantePrueba.add(intervaloBusquedaSegundoPlano),
      ]);
      final pos = await _conBase(
        b,
        (c) => c.read(ubicacionRepositorioProvider).observarLecturas().first,
      );
      expect(pos.last.origen, OrigenUbicacion.busqueda);
      // Pasada la media hora, ya no se programa otra.
      final fin = instantePrueba.add(const Duration(minutes: 31));
      ubicador.siguiente = _pos(fin, metros: 20);
      await revisar(b, fin, ubicador: ubicador, canal: canal, programador: p);
      expect(p.programados, hasLength(1));
      expect(ubicador.pedidas.last, isFalse);
    });

    test('con búsqueda, dos revisiones a destiempo dejan la misma siguiente '
        '(no se abren cadenas paralelas)', () async {
      final b = await _baseEnArchivo();
      await _conBase(
        b,
        (c) => c.read(ubicacionRepositorioProvider).pedirBusqueda(),
      );
      final canal = CanalAvisosSimulado();
      final p = _ProgramadorPrueba();
      final ubicador = UbicadorSimulado(estado: PermisoUbicacion.siempre);
      // La de la búsqueda (a los 5) y otra de una toma (a los 7:05).
      for (final m in [5, 7]) {
        final t = instantePrueba.add(
          Duration(minutes: m, seconds: m == 7 ? 5 : 0),
        );
        ubicador.siguiente = _pos(t, metros: 20);
        await revisar(b, t, ubicador: ubicador, canal: canal, programador: p);
      }
      expect(p.programados, [
        instantePrueba.add(const Duration(minutes: 10)),
        instantePrueba.add(const Duration(minutes: 10)),
      ]);
      // La última, a los 30 minutos; después, ninguna.
      for (final m in [29, 30]) {
        final t = instantePrueba.add(Duration(minutes: m));
        ubicador.siguiente = _pos(t, metros: 20);
        await revisar(b, t, ubicador: ubicador, canal: canal, programador: p);
      }
      expect(p.programados.skip(2), [instantePrueba.add(duracionBusqueda)]);
    });

    test('sin permiso «todo el tiempo» no hay posición (ni aviso)', () async {
      final b = await _baseEnArchivo();
      final canal = CanalAvisosSimulado();
      final p = _ProgramadorPrueba();
      final t = instantePrueba.add(const Duration(minutes: 20));
      final ubicador = UbicadorSimulado(
        estado: PermisoUbicacion.denegado,
        siguiente: _pos(t, metros: 900),
      );
      await revisar(b, t, ubicador: ubicador, canal: canal, programador: p);
      expect(await avisosFuera(b), isEmpty);
      expect(ubicador.pedidas, isEmpty);
    });
  });

  group('familia: Hoy y semáforo', () {
    test('rojo si está fuera de la zona, antes que el resto', () {
      final s = semaforoDelDia(
        const [],
        instantePrueba,
        const ConfigEscalado(),
        fueraDeZona: true,
      );
      expect(s.nivel, NivelSemaforo.rojo);
      expect(s.motivo, MotivoSemaforo.fueraDeZona);
      expect(
        semaforoDelDia(const [], instantePrueba, const ConfigEscalado()).motivo,
        isNot(MotivoSemaforo.fueraDeZona),
      );
    });

    testWidgets('la fila «En casa» abre Ubicación', (tester) async {
      await _abrir(tester, ruta: Rutas.pestana('hoy'));
      final fila = find.byKey(ClavesUi.ubicFilaHoy);
      await tester.scrollUntilVisible(fila, 300);
      expect(find.text('En casa'), findsOneWidget);
      expect(find.text('Última posición a las 11:50'), findsOneWidget);
      await Scrollable.ensureVisible(fila.evaluate().first, alignment: 0.5);
      await pasar(tester, const Duration(milliseconds: 300));
      await tester.tap(fila);
      await _esperar(tester);
      expect(find.byType(UbicacionPantalla), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fuera de casa: la fila lo dice y el semáforo pasa a rojo', (
      tester,
    ) async {
      await _abrir(
        tester,
        ruta: Rutas.pestana('hoy'),
        previo: (e) => _repo(e).registrar(
          _pos(
            instantePrueba.subtract(const Duration(minutes: 5)),
            metros: 800,
          ),
          origen: OrigenUbicacion.appAbierta,
        ),
      );
      expect(find.text('Fuera de la zona segura'), findsOneWidget);
      await tester.scrollUntilVisible(find.byKey(ClavesUi.ubicFilaHoy), 300);
      expect(find.text('Fuera de casa desde las 11:55'), findsOneWidget);
    });

    testWidgets('sin posición reciente: «Sin posición desde…»', (tester) async {
      await _abrir(
        tester,
        ruta: Rutas.pestana('hoy'),
        previo: (e) async {
          e.reloj.fijar(instantePrueba.add(const Duration(hours: 2)));
        },
      );
      await tester.scrollUntilVisible(find.byKey(ClavesUi.ubicFilaHoy), 300);
      expect(find.text('Sin posición desde las 11:50'), findsOneWidget);
    });
  });

  group('pantalla Ubicación', () {
    testWidgets('última posición, las de hoy y «Abrir en mapas» sin teselas', (
      tester,
    ) async {
      final e = await _abrir(tester);
      expect(find.text('En casa'), findsOneWidget);
      expect(find.textContaining('A las 11:50 · ± 18 m'), findsWidgets);
      expect(find.textContaining('Batería del móvil: 80 %'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.ubicAbrirMapas));
      final uri = e.enlaces.single;
      expect(uri.scheme, 'geo');
      expect(uri.toString(), startsWith('geo:40.41'));
      // Las cuatro de la semilla, en casa.
      await tester.scrollUntilVisible(
        find.text('POSICIONES DE HOY'),
        300,
        scrollable: _lista,
      );
      await tester.scrollUntilVisible(
        find.text('11:50'),
        200,
        scrollable: _lista,
      );
      expect(find.text('En casa'), findsWidgets);
    });

    test('enlaces de mapas por plataforma', () {
      expect(
        enlaceMapas(_lat, _lon, plataforma: TargetPlatform.android).toString(),
        'geo:40.416800,-3.703800?q=40.416800,-3.703800',
      );
      expect(
        enlaceMapas(_lat, _lon, plataforma: TargetPlatform.iOS).host,
        'maps.apple.com',
      );
      expect(
        enlaceMapas(_lat, _lon, plataforma: TargetPlatform.linux).host,
        'www.openstreetmap.org',
      );
    });

    testWidgets('zona segura: usar su posición actual como casa y el radio', (
      tester,
    ) async {
      final e = await _abrir(
        tester,
        previo: (e) => _repo(e).registrar(
          _pos(
            instantePrueba.subtract(const Duration(minutes: 2)),
            metros: 800,
          ),
          origen: OrigenUbicacion.appAbierta,
        ),
      );
      expect(find.text('Fuera de casa desde las 11:58'), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.ubicUsarComoCasa));
      var fila = await tester.runAsync(
        () => e.db.select(e.db.ajustesUbicacion).getSingle(),
      );
      expect(fila!.zonaLat, closeTo(_norte(800), 1e-9));
      expect(find.text('En casa'), findsWidgets);
      expect(find.textContaining('Fuera de casa'), findsNothing);
      await _pulsar(tester, find.byKey(ClavesUi.ubicRadio(500)));
      fila = await tester.runAsync(
        () => e.db.select(e.db.ajustesUbicacion).getSingle(),
      );
      expect(fila!.zonaRadio, 500);
      expect(find.text('Radio de 500 m'), findsOneWidget);
    });

    testWidgets('«Buscarla ahora», la ficha y «Llamar al 112» con '
        'confirmación', (tester) async {
      final e = await _abrir(tester);
      expect(find.byKey(ClavesUi.ubicFicha), findsNothing);
      await _pulsar(tester, find.byKey(ClavesUi.ubicBuscar));
      final pedidas = await tester.runAsync(
        () => (e.db.select(
          e.db.eventos,
        )..where((x) => x.tipo.equals('busqueda_pedida'))).get(),
      );
      expect(pedidas, hasLength(1));
      expect(
        (jsonDecode(pedidas!.single.payload) as Map)['hasta'],
        instantePrueba.add(duracionBusqueda).millisecondsSinceEpoch,
      );
      await pasar(tester, const Duration(seconds: 16));
      expect(find.text('Buscando hasta las 12:30'), findsOneWidget);
      // Con la búsqueda, la ficha para emergencias.
      await tester.scrollUntilVisible(
        find.byKey(ClavesUi.ubicLlamar112),
        200,
        scrollable: _lista,
      );
      expect(find.text('FICHA PARA EMERGENCIAS'), findsOneWidget);
      expect(find.text('Carmen'), findsWidgets);
      expect(find.textContaining('40.41'), findsWidgets);
      await _pulsar(tester, find.byKey(ClavesUi.ubicLlamar112));
      expect(find.text('¿Llamar al 112?'), findsOneWidget);
      expect(e.enlaces, isEmpty);
      await tester.tap(find.byKey(ClavesUi.ubicLlamar112Si));
      await _esperar(tester);
      expect(e.enlaces.single.toString(), 'tel:112');
      // Parar la búsqueda.
      await _pulsar(tester, find.byKey(ClavesUi.ubicPararBusqueda));
      await pasar(tester, const Duration(seconds: 16));
      expect(find.byKey(ClavesUi.ubicBuscar), findsOneWidget);
    });

    testWidgets('apagar y volver a encender con la pantalla de permiso', (
      tester,
    ) async {
      final e = await _abrir(tester);
      await _pulsar(tester, find.byKey(ClavesUi.ubicApagar));
      expect(find.text('¿Apagar la ubicación?'), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.ubicApagarSi));
      await _esperar(tester);
      expect(await _payloadsUbicacion(tester, e), isEmpty);
      expect(find.byKey(ClavesUi.ubicEncender), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.ubicEncender));
      expect(find.text('Permiso de ubicación'), findsOneWidget);
      expect(find.textContaining('Cuánto se guarda: 7 días'), findsOneWidget);
      // «Ahora no» no guarda nada.
      await _pulsar(tester, find.byKey(ClavesUi.ubicConsAhoraNo));
      expect(find.byKey(ClavesUi.ubicEncender), findsOneWidget);
      await _pulsar(tester, find.byKey(ClavesUi.ubicEncender));
      await _pulsar(tester, find.byKey(ClavesUi.ubicConsAcepto));
      final cons = await tester.runAsync(
        () =>
            (e.db.select(e.db.consentimientos)
                  ..where((c) => c.sobre.equals('ubicacion'))
                  ..orderBy([(c) => OrderingTerm.desc(c.otorgadoEn)]))
                .get(),
      );
      expect(cons, hasLength(3));
      // El alta nueva (la de la semilla es de las 00:00 y quedó revocada).
      final ultimo = cons!.firstWhere((c) => c.revocaA == null);
      expect(ultimo.textoMostrado, contains('Qué se recoge:'));
      expect(ultimo.textoMostrado, contains('Quién lo ve:'));
      expect(ultimo.otorgadoEn, instantePrueba.millisecondsSinceEpoch);
      expect(find.byType(UbicacionPantalla), findsOneWidget);
      expect(find.byKey(ClavesUi.ubicEncender), findsNothing);
    });
  });

  group('persona', () {
    testWidgets('con la app abierta pide el permiso una vez y toma una '
        'posición; al pedir ayuda, otra precisa', (tester) async {
      final e = await _abrir(
        tester,
        ruta: Rutas.persona,
        perfil: PerfilApp.persona,
        previo: (e) async {
          e.ubicador.siguiente = _pos(instantePrueba, metros: 5);
        },
      );
      await _esperar(tester);
      var p = await _payloadsUbicacion(tester, e);
      expect(p.where((x) => x['origen'] == 'app_abierta'), hasLength(5));
      // Android: además del permiso «con la app abierta», el de la app
      // cerrada, una sola vez.
      expect(e.ubicador.permisosPedidos, 1);
      await tester.tap(find.byKey(ClavesUi.necesitoAyuda));
      await _esperar(tester);
      p = await _payloadsUbicacion(tester, e);
      final ayuda = p.where((x) => x['origen'] == 'ayuda').toList();
      expect(ayuda, hasLength(1));
      expect(ayuda.single['ayuda'], isA<String>());
      expect(e.ubicador.pedidas.last, isTrue);
      // A los 5 minutos, otra.
      await tester.runAsync(() async {
        e.reloj.fijar(instantePrueba.add(const Duration(minutes: 5)));
      });
      await pasar(tester, const Duration(minutes: 5));
      await _esperar(tester);
      p = await _payloadsUbicacion(tester, e);
      expect(
        p.where((x) => x['origen'] == 'app_abierta').length,
        greaterThan(5),
      );
    });

    testWidgets('sin permiso del sistema no se guarda nada', (tester) async {
      final e = await _abrir(
        tester,
        ruta: Rutas.persona,
        perfil: PerfilApp.persona,
        previo: (e) async {
          e.ubicador
            ..estado = PermisoUbicacion.sinPreguntar
            ..alPedirPermiso = PermisoUbicacion.denegado
            ..siguiente = _pos(instantePrueba);
        },
      );
      await _esperar(tester);
      expect(e.ubicador.permisosPedidos, 1);
      expect(await _payloadsUbicacion(tester, e), hasLength(4));
    });
  });

  group('accesibilidad', () {
    for (final brillo in Brightness.values) {
      testWidgets('Ubicación en ${brillo.name}: contraste y toques', (
        tester,
      ) async {
        final manejador = tester.ensureSemantics();
        await _abrir(
          tester,
          brillo: brillo,
          previo: (e) => _repo(e).registrar(
            _pos(
              instantePrueba.subtract(const Duration(minutes: 2)),
              metros: 800,
            ),
            origen: OrigenUbicacion.appAbierta,
          ),
        );
        Future<void> comprobar() async {
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        }

        await comprobar();
        await tester.scrollUntilVisible(
          find.byKey(ClavesUi.ubicApagar),
          300,
          scrollable: _lista,
        );
        await pasar(tester, const Duration(milliseconds: 300));
        await comprobar();
        manejador.dispose();
      });
    }

    testWidgets('permiso de ubicación al 200 %: sin desbordes', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      final e = await _abrir(
        tester,
        previo: (e) async {
          await _repo(e).revocar(
            miembroId: (await e.db.select(e.db.miembros).get()).first.id,
            textoMostrado: 'Apagada',
          );
        },
      );
      expect(e.enlaces, isEmpty);
      await _pulsar(tester, find.byKey(ClavesUi.ubicEncender));
      expect(tester.takeException(), isNull);
      expect(find.byKey(ClavesUi.ubicConsTexto), findsOneWidget);
    });
  });
}
