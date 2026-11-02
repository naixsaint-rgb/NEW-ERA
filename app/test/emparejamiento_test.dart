import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show QueryExecutor, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override, ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:newera/app.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/cripto/invitacion.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/circulo_repositorio.dart';
import 'package:newera/core/db/repositorios/medicacion_repositorio.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/core/plataforma/alarmas/alarmas_no_disponibles.dart';
import 'package:newera/core/plataforma/alarmas/servicio_alarmas.dart';
import 'package:newera/core/plataforma/camara/camara_simulada.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/reinicio.dart';
import 'package:newera/core/sync/foto_para_sobre.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/core/union_circulo.dart';
import 'package:newera/features/catalogo/datos/catalogo_repositorio.dart';
import 'package:newera/features/circulo/invitar_pantalla.dart';
import 'package:newera/features/perfil/perfil_pantalla.dart';
import 'package:newera/features/union/unirse_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

/// Ids y clave de prueba (no son de nadie).
const _circuloPrueba = '0f8b7a6c-1d2e-4f30-9a1b-2c3d4e5f6a7b';
const _personaPrueba = '7e6d5c4b-3a29-4180-8f7e-6d5c4b3a2918';
final _clavePrueba = ClaveCirculo.generar(Random(3));

/// Un móvil con su almacén, su base en memoria (o en archivo) y su cartero.
class _Movil {
  _Movil(this.almacen, this.contenedor, this.servicio);

  final AlmacenSeguroMemoria almacen;
  final ProviderContainer contenedor;
  final ServicioSync servicio;

  AppDatabase get db => contenedor.read(baseDatosProvider);
  ContextoApp get contexto => contenedor.read(contextoProvider);
  MedicacionRepositorio get medicacion =>
      contenedor.read(medicacionRepositorioProvider);
  CirculoRepositorio get circulo => contenedor.read(circuloRepositorioProvider);

  Future<void> cerrar() async {
    await servicio.detener();
    final base = db;
    contenedor.dispose();
    await base.close();
  }
}

Future<_Movil> _arrancar(
  ServidorMemoria servidor,
  AlmacenSeguroMemoria almacen, {
  QueryExecutor? ejecutor,
  Future<void> Function()? borrarBase,
  int semilla = 1,
}) async {
  final overrides = await Arranque.iniciar(
    almacen: almacen,
    ejecutor: ejecutor ?? ejecutorEnMemoria(),
    reloj: RelojFijo(instantePrueba),
    plataforma: 'android',
    demoWeb: false,
    sembrarDemo: false,
    azar: Random(semilla),
    borrarBase: borrarBase,
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
  return _Movil(almacen, c, servicio);
}

/// A crea su círculo (perfil familia); B arranca por su cuenta y después se
/// une con el código de A (la base de B se recrea).
Future<(_Movil, _Movil, String)> _emparejar(
  ServidorMemoria servidor, {
  QueryExecutor? ejecutorB,
  Future<void> Function()? borrarBaseB,
}) async {
  final a = await _arrancar(
    servidor,
    AlmacenSeguroMemoria({
      ClavesAlmacen.dispositivoId: 'movil-a',
      ClavesAlmacen.perfil: 'familia',
    }),
  );
  final codigo = await a.contenedor.read(invitacionProvider.future);
  final almacenB = AlmacenSeguroMemoria({
    ClavesAlmacen.dispositivoId: 'movil-b',
    ClavesAlmacen.perfil: 'persona',
  });
  final antes = await _arrancar(servidor, almacenB, semilla: 2);
  expect(antes.contexto.circuloId, isNot(a.contexto.circuloId));
  await UnionCirculo.preparar(almacenB, Invitacion.leer(codigo!)!);
  await antes.cerrar();
  final b = await _arrancar(
    servidor,
    almacenB,
    ejecutor: ejecutorB,
    borrarBase: borrarBaseB,
    semilla: 3,
  );
  return (a, b, codigo);
}

/// Espera (de verdad) a que [proveedor] tenga un valor que cumpla
/// [condicion] y lo devuelve.
Future<T> _esperarValor<T>(
  ProviderContainer c,
  ProviderListenable<AsyncValue<T>> proveedor,
  bool Function(T) condicion,
) async {
  final sub = c.listen(proveedor, (_, _) {}, fireImmediately: true);
  final reloj = Stopwatch()..start();
  try {
    while (true) {
      final v = sub.read().value;
      if (v != null && condicion(v)) return v;
      if (reloj.elapsed > const Duration(seconds: 10)) {
        fail('tiempo agotado esperando la sincronización');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  } finally {
    sub.close();
  }
}

/// JPEG de 1200x900 con un degradado (no es de nadie).
Uint8List _fotoDePrueba() {
  final imagen = img.Image(width: 1200, height: 900);
  for (final p in imagen) {
    p
      ..r = p.x * 255 ~/ 1200
      ..g = p.y * 255 ~/ 900
      ..b = 140;
  }
  return img.encodeJpg(imagen, quality: 90);
}

/// Alarmas del sistema de mentira: apunta lo que se programa.
class _AlarmasFalsas implements ServicioAlarmas {
  final programadas = <String>[];

  @override
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  }) async => programadas.add(idToma);

  @override
  Future<bool> cancelar(String idToma) async => true;

  @override
  Future<EstadoAlarmas> estado() async => EstadoAlarmas(
    disponible: true,
    autorizacion: AutorizacionAlarma.autorizada,
    programadas: [...programadas],
    implementado: true,
  );

  @override
  Stream<String> sonando() => const Stream.empty();
}

NuevoMedicamento _medicamento() => NuevoMedicamento(
  nombre: 'Medicamento Z (ejemplo)',
  nombreParaPersona: 'Pastilla de prueba',
  forma: 'redonda',
  color: 'blanco',
  horas: const ['21:00', '09:00'],
  dosis: '1 comprimido',
  fotoCaja: FotoNueva(_fotoDePrueba()),
);

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('código de invitación', () {
    final invitacion = Invitacion(
      circuloId: _circuloPrueba,
      personaId: _personaPrueba,
      claveHex: _clavePrueba,
    );

    test('ida y vuelta, también en minúsculas y con espacios', () {
      final texto = invitacion.codificar();
      expect(texto, startsWith('${Invitacion.prefijo}-'));
      expect(texto, matches(RegExp(r'^NEWERA1(-[0-9A-HJKMNP-TV-Z]{4}){28}$')));
      expect(Invitacion.leer(texto), invitacion);
      expect(
        Invitacion.leer('  ${texto.toLowerCase().replaceAll('-', ' ')}\n'),
        invitacion,
      );
      // O, I y L se leen como 0, 1 y 1 (base 32 de Crockford).
      final conLetras = texto
          .replaceFirst('0', 'O', Invitacion.prefijo.length)
          .replaceFirst('1', 'I', Invitacion.prefijo.length);
      expect(Invitacion.leer(conLetras), invitacion);
    });

    test('un carácter cambiado no pasa, en ninguna posición', () {
      final texto = invitacion.codificar();
      const alfabeto = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
      var probados = 0;
      for (var i = Invitacion.prefijo.length; i < texto.length; i++) {
        final ch = texto[i];
        if (ch == '-') continue;
        final otro = alfabeto[(alfabeto.indexOf(ch) + 7) % alfabeto.length];
        final cambiado = texto.replaceRange(i, i + 1, otro);
        expect(Invitacion.leer(cambiado), isNull, reason: 'posición $i');
        probados++;
      }
      expect(probados, 112);
      expect(Invitacion.leer(texto.substring(0, texto.length - 1)), isNull);
      expect(Invitacion.leer('${texto}A'), isNull);
      expect(Invitacion.leer(texto.replaceFirst('NEWERA1', 'NEWERA2')), isNull);
      expect(Invitacion.leer('hola'), isNull);
      expect(Invitacion.leer(''), isNull);
    });

    test('solo con ids UUID y clave de 64 hexadecimales', () {
      expect(
        () => Invitacion(
          circuloId: 'circulo-prueba',
          personaId: _personaPrueba,
          claveHex: _clavePrueba,
        ).codificar(),
        throwsArgumentError,
      );
      expect(
        () => const Invitacion(
          circuloId: _circuloPrueba,
          personaId: _personaPrueba,
          claveHex: 'corta',
        ).codificar(),
        throwsArgumentError,
      );
    });
  });

  group('emparejamiento entre dos móviles', () {
    late ServidorMemoria servidor;
    final abiertos = <_Movil>[];

    setUp(() => servidor = ServidorMemoria());
    tearDown(() async {
      for (final m in abiertos) {
        await m.cerrar();
      }
      abiertos.clear();
    });

    test(
      'B se une con el código de A: adopta círculo, persona y clave',
      () async {
        var borrada = false;
        final (a, b, _) = await _emparejar(
          servidor,
          borrarBaseB: () async => borrada = true,
        );
        abiertos.addAll([a, b]);
        expect(borrada, isTrue, reason: 'la base de B iba con la clave vieja');
        expect(b.contexto.circuloId, a.contexto.circuloId);
        expect(b.contexto.personaId, a.contexto.personaId);
        expect(b.contexto.dispositivoId, 'movil-b');
        expect(b.contexto.circuloExterno, isTrue);
        expect(a.contexto.circuloExterno, isFalse);
        expect(
          await b.almacen.leer(ClavesAlmacen.circuloClave),
          await a.almacen.leer(ClavesAlmacen.circuloClave),
        );
        expect(await b.almacen.leer(ClavesAlmacen.circuloExterno), '1');
        expect(await b.almacen.leer(ClavesAlmacen.unionPendiente), isNull);
        // Vuelve a "¿De quién es este móvil?".
        expect(await b.almacen.leer(ClavesAlmacen.perfil), isNull);
        expect(b.contenedor.read(sesionInicialProvider).perfil, isNull);
        // Mismo token ante el servidor: ven los mismos sobres.
        final llavesA = await a.contenedor.read(llavesCirculoProvider.future);
        final llavesB = await b.contenedor.read(llavesCirculoProvider.future);
        expect(llavesB!.token, llavesA!.token);
        // Filas mínimas y provisionales, sin eventos que las publiquen.
        expect(
          (await b.db.select(b.db.circulos).getSingle()).id,
          a.contexto.circuloId,
        );
        expect(
          (await b.db.select(b.db.personas).getSingle()).id,
          a.contexto.personaId,
        );
        expect(await b.db.select(b.db.eventos).get(), isEmpty);
        expect(await b.servicio.ultimoRecibido(), 0);
      },
    );

    test('A crea un medicamento con pauta y foto: B lo ve, y luego el cambio de pauta', () async {
      final (a, b, _) = await _emparejar(servidor);
      abiertos.addAll([a, b]);
      await a.circulo.cambiarAlias('Carmen');
      final medicamentoId = await a.medicacion.crear(_medicamento());
      await a.servicio.iniciar();
      await b.servicio.iniciar();

      final meds = await _esperarValor(
        b.contenedor,
        medicamentosProvider,
        (l) => l.isNotEmpty,
      );
      final enA = await a.medicacion.medicamento(medicamentoId);
      final enB = meds.single;
      expect(enB.id, medicamentoId);
      expect(enB.nombreParaPersona, 'Pastilla de prueba');
      expect(enB.personaId, a.contexto.personaId);
      expect(enB.fotoCajaId, enA!.fotoCajaId);
      expect(enB.fotoCajaId, isNotNull);

      final bytes = await b.contenedor.read(
        fotoProvider(enB.fotoCajaId!).future,
      );
      final foto = img.decodeImage(bytes!)!;
      expect(max(foto.width, foto.height), FotoParaSobre.ladoMayor);
      expect(bytes.length, lessThanOrEqualTo(FotoParaSobre.maxBytes));

      final pautas = await _esperarValor(
        b.contenedor,
        pautasProvider,
        (l) => l.isNotEmpty,
      );
      expect(pautas.single.horas, '["09:00","21:00"]');
      expect(pautas.single.medicamentoId, medicamentoId);

      // La persona provisional de B pasa a ser la de A.
      final persona = await _esperarValor(
        b.contenedor,
        personaProvider,
        (p) => p?.alias == 'Carmen',
      );
      expect(persona!.id, a.contexto.personaId);

      // Cambio de pauta en A: llega la versión 2.
      await a.medicacion.cambiarPauta(
        pautaId: pautas.single.pautaId,
        motivo: 'Prueba',
        horas: const ['10:00'],
        diasSemana: DiasSemana.todos,
        dosis: '1 comprimido',
        comprobacion: TipoComprobacion.video,
        segundosVideo: 10,
      );
      final versiones = await _esperarValor(
        b.contenedor,
        pautasProvider,
        (l) => l.length == 2,
      );
      expect(versiones.last.version, 2);
      expect(versiones.last.horas, '["10:00"]');
      expect(versiones.last.motivo, 'Prueba');

      // Los eventos también llegan (y B no reenvía la persona provisional).
      final eventosB = await b.db.select(b.db.eventos).get();
      expect(
        eventosB.where((e) => e.tipo == 'medicamento_creado'),
        hasLength(1),
      );
      expect(
        eventosB.where(
          (e) => e.dispositivo == 'movil-b' && e.tipo == 'ficha_creada',
        ),
        isEmpty,
      );
    });

    test(
      'B elige familia: crea su propio familiar, no otro Responsable',
      () async {
        final (a, b, _) = await _emparejar(servidor);
        abiertos.addAll([a, b]);
        await a.servicio.iniciar();
        await b.servicio.iniciar();
        await _esperarValor(
          b.contenedor,
          miembrosProvider,
          (l) => l.any((m) => m.rol == 'responsable'),
        );
        final propio = await b.circulo.asegurarDispositivo(PerfilApp.familia);
        final enA = await _esperarValor(
          a.contenedor,
          miembrosProvider,
          (l) => l.length == 2,
        );
        expect(enA.where((m) => m.rol == 'responsable'), hasLength(1));
        final nuevo = enA.singleWhere((m) => m.id == propio);
        expect(nuevo.rol, 'cuidador');
        expect(nuevo.ordenEscalado, isNull);
        expect(nuevo.enMiGente, isFalse);
        // Elegir otra vez no crea otro.
        expect(await b.circulo.asegurarDispositivo(PerfilApp.familia), propio);
      },
    );

    test('un segundo arranque de B no crea un círculo nuevo', () async {
      final dir = await Directory.systemTemp.createTemp('newera_union_');
      addTearDown(() => dir.delete(recursive: true));
      final archivo = File('${dir.path}/b.db');
      final (a, b, _) = await _emparejar(
        servidor,
        ejecutorB: NativeDatabase(archivo),
        borrarBaseB: () async {
          if (await archivo.exists()) await archivo.delete();
        },
      );
      abiertos.add(a);
      await a.servicio.iniciar();
      await b.servicio.iniciar();
      await _esperarValor(b.contenedor, miembrosProvider, (l) => l.isNotEmpty);
      final clave = await b.almacen.leer(ClavesAlmacen.circuloClave);
      await b.cerrar();

      final otra = await _arrancar(
        servidor,
        b.almacen,
        ejecutor: NativeDatabase(archivo),
        semilla: 4,
      );
      abiertos.add(otra);
      expect(otra.contexto.circuloId, a.contexto.circuloId);
      expect(otra.contexto.personaId, a.contexto.personaId);
      expect(otra.contexto.circuloExterno, isTrue);
      expect(await otra.almacen.leer(ClavesAlmacen.circuloClave), clave);
      expect(await otra.db.select(otra.db.circulos).get(), hasLength(1));
      expect(await otra.db.select(otra.db.personas).get(), hasLength(1));
      // Lo recibido sigue ahí y el cursor no vuelve a 0.
      expect(await otra.db.select(otra.db.miembros).get(), isNotEmpty);
      expect(await otra.servicio.ultimoRecibido(), greaterThan(0));
    });

    test('datos propios: solo cuentan los que se perderían', () async {
      final m = await _arrancar(
        servidor,
        AlmacenSeguroMemoria({ClavesAlmacen.perfil: 'familia'}),
      );
      abiertos.add(m);
      // Recién instalado y con perfil elegido: nada que perder.
      await m.contenedor
          .read(sesionProvider.notifier)
          .elegirPerfil(PerfilApp.familia);
      expect(await UnionCirculo.hayDatosPropios(m.db), isFalse);
      await m.medicacion.crear(_medicamento());
      expect(await UnionCirculo.hayDatosPropios(m.db), isTrue);
    });
  });

  group('pantallas', () {
    Future<void> abrirUnirse(WidgetTester tester, EntornoPrueba entorno) async {
      await montarApp(
        tester,
        entorno,
        rutaInicial: Rutas.perfil,
        extra: [lectorQrDisponibleProvider.overrideWithValue(false)],
      );
      await pasar(tester, const Duration(milliseconds: 500));
      await tester.ensureVisible(find.byKey(ClavesUi.unirTarjeta));
      await tester.tap(find.byKey(ClavesUi.unirTarjeta));
      await pasar(tester, const Duration(milliseconds: 500));
      expect(find.byType(UnirsePantalla), findsOneWidget);
    }

    void portapapeles(WidgetTester tester, String texto, List<String> copias) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (llamada) async {
          if (llamada.method == 'Clipboard.getData') return {'text': texto};
          if (llamada.method == 'Clipboard.setData') {
            copias.add((llamada.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
    }

    final codigo = Invitacion(
      circuloId: _circuloPrueba,
      personaId: _personaPrueba,
      claveHex: _clavePrueba,
    ).codificar();

    testWidgets('el perfil muestra la tercera tarjeta, unirse a una familia', (
      tester,
    ) async {
      final entorno = await tester.runAsync(
        () => prepararEntorno(sembrar: false),
      );
      await montarApp(tester, entorno!);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byType(PerfilPantalla), findsOneWidget);
      expect(
        find.text('Este móvil se une a una familia que ya usa la app'),
        findsOneWidget,
      );
      expect(find.byKey(ClavesUi.unirTarjeta), findsOneWidget);
    });

    testWidgets('en la demo web no hay tarjeta de unirse', (tester) async {
      final entorno = await tester.runAsync(
        () => prepararEntorno(sembrar: false, demoWeb: true),
      );
      await montarApp(tester, entorno!);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byType(PerfilPantalla), findsOneWidget);
      expect(find.byKey(ClavesUi.unirTarjeta), findsNothing);
    });

    testWidgets('unirse acepta un código pegado (sin cámara)', (tester) async {
      final entorno = await tester.runAsync(
        () => prepararEntorno(sembrar: false),
      );
      var reinicios = 0;
      await montarApp(
        tester,
        entorno!,
        rutaInicial: Rutas.unirse,
        extra: [
          lectorQrDisponibleProvider.overrideWithValue(false),
          reiniciarAppProvider.overrideWithValue(() async => reinicios++),
        ],
      );
      await pasar(tester, const Duration(milliseconds: 500));
      expect(find.byType(UnirsePantalla), findsOneWidget);
      expect(find.byKey(ClavesUi.unirLeerQr), findsNothing);
      portapapeles(tester, codigo, []);

      await tester.tap(find.byKey(ClavesUi.unirPegar));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await pasar(tester, const Duration(milliseconds: 300));
      expect(find.text(codigo), findsOneWidget);

      await tester.tap(find.byKey(ClavesUi.unirAceptar));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await pasar(tester, const Duration(milliseconds: 500));
      // Sin datos propios: no pregunta.
      expect(find.byKey(ClavesUi.unirConfirmar), findsNothing);
      expect(reinicios, 1);
      final pendiente = await tester.runAsync(
        () => entorno.almacen.leer(ClavesAlmacen.unionPendiente),
      );
      expect(Invitacion.leer(pendiente!)!.circuloId, _circuloPrueba);
    });

    testWidgets('un código mal escrito se avisa y no se guarda', (
      tester,
    ) async {
      final entorno = await tester.runAsync(
        () => prepararEntorno(sembrar: false),
      );
      await abrirUnirse(tester, entorno!);
      final malo = codigo.replaceRange(20, 21, codigo[20] == 'A' ? 'B' : 'A');
      await tester.enterText(find.byKey(ClavesUi.unirCodigo), malo);
      await tester.tap(find.byKey(ClavesUi.unirAceptar));
      await pasar(tester, const Duration(milliseconds: 300));
      expect(
        find.text(
          'El código no es válido. Revisa que esté completo o vuelve a leer el QR.',
        ),
        findsOneWidget,
      );
      final pendiente = await tester.runAsync(
        () => entorno.almacen.leer(ClavesAlmacen.unionPendiente),
      );
      expect(pendiente, isNull);
    });

    testWidgets('con datos en el móvil pide confirmar antes de borrarlos', (
      tester,
    ) async {
      final entorno = await tester.runAsync(() => prepararEntorno());
      var reinicios = 0;
      await montarApp(
        tester,
        entorno!,
        rutaInicial: Rutas.unirse,
        extra: [
          lectorQrDisponibleProvider.overrideWithValue(false),
          reiniciarAppProvider.overrideWithValue(() async => reinicios++),
        ],
      );
      await pasar(tester, const Duration(milliseconds: 500));
      await tester.enterText(find.byKey(ClavesUi.unirCodigo), codigo);
      await tester.tap(find.byKey(ClavesUi.unirAceptar));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await pasar(tester, const Duration(milliseconds: 500));
      expect(
        find.text(
          'Se borrarán los datos de este móvil y se usarán los de la familia.',
        ),
        findsOneWidget,
      );
      expect(reinicios, 0);
      await tester.tap(find.byKey(ClavesUi.unirConfirmar));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await pasar(tester, const Duration(milliseconds: 500));
      expect(reinicios, 1);
      final pendiente = await tester.runAsync(
        () => entorno.almacen.leer(ClavesAlmacen.unionPendiente),
      );
      expect(pendiente, isNotNull);
    });

    testWidgets('Círculo › Invitar otro móvil: QR y código del círculo', (
      tester,
    ) async {
      final entorno = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia, sembrar: false),
      );
      await montarApp(tester, entorno!, rutaInicial: Rutas.pestana('circulo'));
      await pasar(tester, const Duration(milliseconds: 500));
      await tester.tap(find.byKey(ClavesUi.circInvitar));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byType(InvitarPantalla), findsOneWidget);
      expect(
        find.text(
          'Enséñale este código al otro móvil. Solo en persona: lleva la clave '
          'de vuestros datos.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(ClavesUi.circQr), findsOneWidget);
      final texto = tester.widget<Text>(find.byKey(ClavesUi.circCodigo)).data!;
      final leida = Invitacion.leer(texto)!;
      expect(leida.circuloId, entorno.contexto.circuloId);
      expect(leida.personaId, entorno.contexto.personaId);

      final copias = <String>[];
      portapapeles(tester, '', copias);
      await tester.ensureVisible(find.byKey(ClavesUi.circCopiar));
      await pasar(tester, const Duration(milliseconds: 300));
      await tester.tap(find.byKey(ClavesUi.circCopiar));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await pasar(tester, const Duration(milliseconds: 300));
      expect(copias, [texto]);
      expect(find.text('Código copiado'), findsOneWidget);
    });

    for (final oscuro in [false, true]) {
      final modo = oscuro ? 'oscuro' : 'claro';
      for (final ruta in [Rutas.unirse, Rutas.circuloInvitar]) {
        testWidgets('$ruta en $modo: contraste y zonas táctiles', (
          tester,
        ) async {
          if (oscuro) {
            tester.platformDispatcher.platformBrightnessTestValue =
                Brightness.dark;
            addTearDown(tester.platformDispatcher.clearAllTestValues);
          }
          final manejador = tester.ensureSemantics();
          final entorno = await tester.runAsync(
            () => prepararEntorno(
              perfil: ruta == Rutas.unirse ? null : PerfilApp.familia,
              sembrar: false,
            ),
          );
          await montarApp(
            tester,
            entorno!,
            rutaInicial: ruta,
            extra: [lectorQrDisponibleProvider.overrideWithValue(true)],
          );
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 300)),
          );
          await pasar(tester, const Duration(seconds: 1));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          manejador.dispose();
        });
      }
    }

    testWidgets(
      'en el móvil de la persona, una pauta que llega programa su alarma',
      (tester) async {
        final alarmas = _AlarmasFalsas();
        final entorno = await tester.runAsync(
          () => prepararEntorno(
            perfil: PerfilApp.persona,
            sembrar: false,
            alarmas: alarmas,
          ),
        );
        await montarApp(tester, entorno!);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await pasar(tester, const Duration(milliseconds: 500));
        expect(alarmas.programadas, isEmpty);

        // Como si llegara por el cartero: aparece un medicamento con su pauta.
        final contenedor = ProviderScope.containerOf(
          tester.element(find.byType(NewEraApp)),
        );
        await tester.runAsync(
          () => contenedor
              .read(medicacionRepositorioProvider)
              .crear(_medicamento()),
        );
        for (var i = 0; i < 20 && alarmas.programadas.isEmpty; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(alarmas.programadas, isNotEmpty);
      },
    );

    testWidgets(
      'al unirse, la app se reinicia con el círculo de la invitación',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        final almacen = AlmacenSeguroMemoria();
        final catalogo = await tester.runAsync(
          () => const CatalogoRepositorio().cargar(),
        );
        Future<List<Override>> iniciar() async => [
          ...await Arranque.iniciar(
            almacen: almacen,
            ejecutor: ejecutorEnMemoria(),
            reloj: RelojFijo(instantePrueba),
            plataforma: 'android',
            demoWeb: false,
            sembrarDemo: false,
            azar: Random(9),
          ),
          catalogoProvider.overrideWith((ref) => catalogo!),
          camaraProvider.overrideWithValue(const CamaraSimulada()),
          servicioAlarmasProvider.overrideWithValue(
            const AlarmasNoDisponibles(),
          ),
          lectorQrDisponibleProvider.overrideWithValue(false),
        ];
        final iniciales = await tester.runAsync(iniciar);
        await tester.pumpWidget(
          RaizReiniciable(
            overrides: iniciales!,
            iniciar: iniciar,
            app: const NewEraApp(),
          ),
        );
        await pasar(tester, const Duration(milliseconds: 500));
        ContextoApp contextoActual() =>
            ProviderScope.containerOf(tester.element(find.byType(NewEraApp)))
                .read(contextoProvider);
        final antes = contextoActual();
        expect(antes.circuloId, isNot(_circuloPrueba));

        await tester.tap(find.byKey(ClavesUi.unirTarjeta));
        await pasar(tester, const Duration(milliseconds: 500));
        await tester.enterText(find.byKey(ClavesUi.unirCodigo), codigo);
        await tester.tap(find.byKey(ClavesUi.unirAceptar));
        // Mientras se reinicia, la app vieja ya no está montada.
        bool reiniciada() =>
            find.byType(NewEraApp).evaluate().isNotEmpty &&
            contextoActual().circuloId == _circuloPrueba;
        for (var i = 0; i < 40 && !reiniciada(); i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
        await pasar(tester, const Duration(milliseconds: 500));
        final despues = contextoActual();
        expect(despues.circuloId, _circuloPrueba);
        expect(despues.personaId, _personaPrueba);
        expect(despues.circuloExterno, isTrue);
        expect(despues.dispositivoId, antes.dispositivoId);
        // De vuelta a "¿De quién es este móvil?".
        expect(find.byType(PerfilPantalla), findsOneWidget);
      },
    );
  });
}
