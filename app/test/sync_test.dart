import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/cifrado_sobres.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/config_sync.dart';
import 'package:newera/core/sync/evento_en_sobre.dart';
import 'package:newera/core/sync/noop_transport.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/core/sync/sobre_cifrado.dart';
import 'package:newera/core/sync/supabase_transport.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

/// Clave de prueba (no es de nadie): sale de una semilla fija.
final _claveComun = ClaveCirculo.generar(Random(7));
const _circulo = 'circulo-prueba';
const _palabra = 'girasoles';

/// Un móvil del círculo con su base en memoria y su servicio de sync.
class _Movil {
  _Movil(this.contenedor, this.servicio, this.transporte);

  final ProviderContainer contenedor;
  final ServicioSync servicio;
  final TransporteMemoria transporte;

  AppDatabase get db => contenedor.read(baseDatosProvider);
  ContextoApp get contexto => contenedor.read(contextoProvider);

  Future<String> registrarMensaje(String texto) => contenedor
      .read(eventosRepositorioProvider)
      .registrar(TipoEvento.mensajeFamilia, payload: {'texto': texto});

  Future<List<Evento>> eventos() => db.select(db.eventos).get();

  Future<void> cerrar() async {
    await servicio.detener();
    final base = db;
    contenedor.dispose();
    await base.close();
  }
}

Future<_Movil> _crearMovil(
  ServidorMemoria servidor, {
  required String dispositivo,
  String clave = '',
  bool duplicar = false,
}) async {
  final almacen = AlmacenSeguroMemoria({
    ClavesAlmacen.dispositivoId: dispositivo,
    ClavesAlmacen.circuloId: _circulo,
    ClavesAlmacen.circuloClave: clave.isEmpty ? _claveComun : clave,
    ClavesAlmacen.circuloClaveVersion: '1',
  });
  final overrides = await Arranque.iniciar(
    almacen: almacen,
    ejecutor: ejecutorEnMemoria(),
    reloj: RelojFijo(instantePrueba),
    plataforma: 'android',
    demoWeb: false,
    sembrarDemo: false,
    azar: Random(dispositivo.hashCode),
  );
  final transporte = TransporteMemoria(servidor, duplicar: duplicar);
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
  return _Movil(c, servicio, transporte);
}

/// Espera (de verdad) a que se cumpla [condicion].
Future<void> _esperarA(Future<bool> Function() condicion) async {
  final reloj = Stopwatch()..start();
  while (!await condicion()) {
    if (reloj.elapsed > const Duration(seconds: 10)) {
      fail('tiempo agotado esperando la sincronización');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

bool _contiene(List<int> pajar, List<int> aguja) {
  for (var i = 0; i + aguja.length <= pajar.length; i++) {
    var igual = true;
    for (var j = 0; j < aguja.length && igual; j++) {
      igual = pajar[i + j] == aguja[j];
    }
    if (igual) return true;
  }
  return false;
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('llaves del círculo', () {
    test('token y clave de sobres salen de la clave con HKDF', () async {
      final a = await LlavesCirculo.derivar(_claveComun);
      final b = await LlavesCirculo.derivar(_claveComun);
      final otra = await LlavesCirculo.derivar(ClaveCirculo.generar(Random(8)));
      expect(a.token, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(a.token, b.token);
      expect(a.token, isNot(_claveComun));
      expect(a.token, isNot(otra.token));
      // El token no abre sobres: la clave de los sobres es otra.
      final sellado = await CifradoSobres.cifrar(
        utf8.encode('hola'),
        llaves: a,
        ulid: 'U',
      );
      expect(
        await CifradoSobres.descifrar(
          nonce: sellado.nonce,
          contenido: sellado.contenido,
          llaves: b,
          ulid: 'U',
        ),
        utf8.encode('hola'),
      );
      expect(
        await CifradoSobres.descifrar(
          nonce: sellado.nonce,
          contenido: sellado.contenido,
          llaves: otra,
          ulid: 'U',
        ),
        isNull,
      );
      // Cambiar el ulid (dato asociado) también lo invalida.
      expect(
        await CifradoSobres.descifrar(
          nonce: sellado.nonce,
          contenido: sellado.contenido,
          llaves: a,
          ulid: 'V',
        ),
        isNull,
      );
    });

    test('sin clave en el almacén no hay llaves (demo web)', () async {
      expect(await LlavesCirculo.desdeAlmacen(AlmacenSeguroMemoria()), isNull);
      expect(
        await LlavesCirculo.desdeAlmacen(
          AlmacenSeguroMemoria({ClavesAlmacen.circuloClave: 'corta'}),
        ),
        isNull,
      );
    });
  });

  group('cartero cifrado entre dos móviles', () {
    late ServidorMemoria servidor;
    late _Movil a;
    late _Movil b;

    setUp(() async {
      servidor = ServidorMemoria();
      a = await _crearMovil(servidor, dispositivo: 'movil-a');
      b = await _crearMovil(servidor, dispositivo: 'movil-b');
    });

    tearDown(() async {
      await a.cerrar();
      await b.cerrar();
    });

    test('un evento de A llega a B con el mismo ulid y payload', () async {
      await a.servicio.iniciar();
      await b.servicio.iniciar();
      final ulid = await a.registrarMensaje('Hoy hay $_palabra en la mesa');

      await _esperarA(
        () async => (await b.eventos()).any((e) => e.ulid == ulid),
      );
      final enA = (await a.eventos()).singleWhere((e) => e.ulid == ulid);
      final enB = (await b.eventos()).singleWhere((e) => e.ulid == ulid);
      expect(enB, enA);
      expect(jsonDecode(enB.payload), {
        'texto': 'Hoy hay $_palabra en la mesa',
      });
      expect(enB.dispositivo, 'movil-a');
      expect(await b.servicio.ultimoRecibido(), greaterThan(0));

      // B no lo reenvía: ya estaba en el servidor.
      final antes = b.transporte.enviados.length;
      await b.servicio.empujar();
      expect(b.transporte.enviados.length, antes);
      expect(servidor.sobres.where((s) => s.ulid == ulid), hasLength(1));
    });

    test('el sobre no lleva el payload en claro', () async {
      await a.registrarMensaje('Recuerda regar los $_palabra');
      expect(await a.servicio.empujar(), 1);
      final sobre = servidor.sobres.single;
      final aguja = utf8.encode(_palabra);
      expect(_contiene(sobre.contenido, aguja), isFalse);
      expect(_contiene(sobre.nonce, aguja), isFalse);
      expect(
        _contiene(sobre.contenido, utf8.encode('mensaje_familia')),
        isFalse,
      );
      expect(base64Encode(sobre.contenido), isNot(contains(_palabra)));
      expect(sobre.nonce, hasLength(12));
      // El tamaño va relleno a bloques: no delata el tipo de evento.
      expect(
        (sobre.contenido.length - CifradoSobres.bytesEtiqueta) %
            EventoEnSobre.bloque,
        0,
      );
    });

    test('no se duplica si llega dos veces', () async {
      await a.registrarMensaje('Dos veces');
      await a.servicio.empujar();
      final sobre = servidor.sobres.single;

      expect(await b.servicio.recibir(sobre), isTrue);
      expect(await b.servicio.recibir(sobre), isFalse);
      expect(
        (await b.eventos()).where((e) => e.ulid == sobre.ulid),
        hasLength(1),
      );

      // A recibe su propio sobre de vuelta: tampoco se duplica.
      expect(await a.servicio.recibir(sobre), isFalse);
      expect(
        (await a.eventos()).where((e) => e.ulid == sobre.ulid),
        hasLength(1),
      );
    });

    test('un transporte que entrega dos veces no duplica', () async {
      final c = await _crearMovil(
        servidor,
        dispositivo: 'movil-c',
        duplicar: true,
      );
      addTearDown(c.cerrar);
      final ulid = await a.registrarMensaje('Repetido');
      await a.servicio.empujar();
      await c.servicio.iniciar();
      await _esperarA(() async => await c.servicio.ultimoRecibido() == 1);
      expect((await c.eventos()).where((e) => e.ulid == ulid), hasLength(1));
    });

    test('sin red se queda pendiente y se envía al volver', () async {
      servidor.caido = true;
      await a.servicio.iniciar();
      await b.servicio.iniciar();
      final ulid = await a.registrarMensaje('Sin cobertura');
      await _esperarA(() async => a.transporte.enviados.isNotEmpty);
      expect(servidor.sobres, isEmpty);
      final pendientes = await a.db.select(a.db.sobresEnviados).get();
      expect(pendientes.where((p) => p.ulid == ulid), isEmpty);

      servidor.levantar();
      await _esperarA(
        () async => (await b.eventos()).any((e) => e.ulid == ulid),
      );
      final enviados = await a.db.select(a.db.sobresEnviados).get();
      expect(enviados.map((e) => e.ulid), contains(ulid));
    });

    test('un móvil con otra clave no puede abrir el sobre', () async {
      final intruso = await _crearMovil(
        servidor,
        dispositivo: 'intruso',
        clave: ClaveCirculo.generar(Random(99)),
      );
      addTearDown(intruso.cerrar);
      final ulid = await a.registrarMensaje('Solo para la familia');
      await a.servicio.empujar();
      final sobre = servidor.sobres.single;
      expect(await intruso.servicio.recibir(sobre), isFalse);
      expect((await intruso.eventos()).where((e) => e.ulid == ulid), isEmpty);
      // Se descarta y se sigue: el cursor avanza.
      expect(await intruso.servicio.ultimoRecibido(), sobre.posicion);
    });

    test('un sobre alterado se descarta', () async {
      await a.registrarMensaje('Original');
      await a.servicio.empujar();
      final s = servidor.sobres.single;
      final contenido = Uint8List.fromList(s.contenido)..[0] ^= 1;
      final alterado = SobreCifrado(
        ulid: s.ulid,
        circuloId: s.circuloId,
        versionClave: s.versionClave,
        nonce: s.nonce,
        contenido: contenido,
        posicion: s.posicion,
      );
      expect(await b.servicio.recibir(alterado), isFalse);
      expect((await b.eventos()).where((e) => e.ulid == s.ulid), isEmpty);
    });
  });

  group('configuración', () {
    late ProviderContainer c;
    late AppDatabase db;

    Future<void> preparar(List<Override> extra) async {
      final overrides = await Arranque.iniciar(
        almacen: AlmacenSeguroMemoria(),
        ejecutor: ejecutorEnMemoria(),
        reloj: RelojFijo(instantePrueba),
        plataforma: 'android',
        demoWeb: false,
        sembrarDemo: false,
      );
      c = ProviderContainer(overrides: [...overrides, ...extra]);
      db = c.read(baseDatosProvider);
    }

    tearDown(() async {
      c.dispose();
      await db.close();
    });

    test('vacía: NoopTransport, sin servicio y sin escrituras', () async {
      // En los tests no hay --dart-define: la de la compilación está vacía.
      await preparar(const []);
      expect(c.read(configSyncProvider).configurada, isFalse);
      expect(c.read(syncTransportProvider), isA<NoopTransport>());
      expect(c.read(servicioSyncProvider), isNull);

      final eventosAntes = await db.select(db.eventos).get();
      // Un servicio con Noop tampoco hace nada.
      final servicio = ServicioSync(
        db: db,
        transporte: const NoopTransport(),
        llaves: () => c.read(llavesCirculoProvider.future),
        contexto: c.read(contextoProvider),
        reloj: c.read(relojProvider),
      );
      await servicio.iniciar();
      expect(await servicio.empujar(), 0);
      expect(servicio.activo, isFalse);
      await servicio.detener();
      expect(await db.select(db.eventos).get(), eventosAntes);
      expect(await db.select(db.sobresEnviados).get(), isEmpty);
      expect(await db.select(db.syncEstado).get(), isEmpty);
    });

    test('con URL y clave: SupabaseTransport (sin tocar la red)', () async {
      await preparar([
        configSyncProvider.overrideWithValue(
          const ConfigSync(
            url: 'https://ejemplo.supabase.co',
            claveAnonima: 'clave-de-prueba',
          ),
        ),
      ]);
      expect(c.read(syncTransportProvider), isA<SupabaseTransport>());
      expect(c.read(servicioSyncProvider), isNotNull);
      final llaves = await c.read(llavesCirculoProvider.future);
      expect(llaves, isNotNull);
    });
  });

  testWidgets('la app sin servidor no escribe nada de sync', (tester) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!);
    await pasar(tester, const Duration(seconds: 1));
    final db = entorno.db;
    final enviados = await tester.runAsync(
      () => db.select(db.sobresEnviados).get(),
    );
    final estado = await tester.runAsync(() => db.select(db.syncEstado).get());
    expect(enviados, isEmpty);
    expect(estado, isEmpty);
  });

  test(
    'migración 1→2: abre una base del esquema 1 sin tocar los hechos',
    () async {
      final dir = await Directory.systemTemp.createTemp('newera_migracion_');
      addTearDown(() => dir.delete(recursive: true));
      final archivo = File('${dir.path}/v1.db');

      // Base del esquema 1: la de ahora sin las tablas nuevas y con
      // user_version = 1.
      final v1 = AppDatabase(NativeDatabase(archivo));
      await v1
          .into(v1.circulos)
          .insert(
            CirculosCompanion.insert(id: 'c1', nombre: 'Familia', creadoEn: 1),
          );
      await v1
          .into(v1.eventos)
          .insert(
            EventosCompanion.insert(
              ulid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
              circuloId: 'c1',
              autor: 'a',
              dispositivo: 'd',
              tipo: 'ayuda_pedida',
              ocurridoEn: 1,
              registradoEn: 1,
            ),
          );
      await v1.customStatement('DROP TABLE sobres_enviados');
      await v1.customStatement('DROP TABLE sync_estado');
      await v1.customStatement('PRAGMA user_version = 1');
      await v1.close();

      final v2 = AppDatabase(NativeDatabase(archivo));
      addTearDown(v2.close);
      final version = await v2.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 2);
      expect(await v2.select(v2.eventos).get(), hasLength(1));
      expect(await v2.select(v2.sobresEnviados).get(), isEmpty);
      await v2
          .into(v2.syncEstado)
          .insert(SyncEstadoCompanion.insert(clave: 'k', valor: '1'));
      await v2
          .into(v2.sobresEnviados)
          .insert(
            SobresEnviadosCompanion.insert(
              ulid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
              enviadoEn: 2,
            ),
          );
      // Los disparadores de solo inserción siguen ahí.
      await expectLater(
        v2.customStatement("UPDATE eventos SET tipo = 'otro'"),
        throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
      );
    },
  );
}
