import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/enrutado/rutas.dart';
import 'package:newera/features/mapa/estilo_mapa.dart';
import 'package:newera/features/mapa/gestor_mapas.dart';
import 'package:newera/features/mapa/mapa_pmtiles.dart';
import 'package:newera/features/mapa/mapa_providers.dart';
import 'package:newera/features/mapa/pmtiles_lector.dart';
import 'package:newera/features/mapa/vista_mapa.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import 'utiles/app_prueba.dart';
import 'utiles/pmtiles_prueba.dart';

// Coordenadas de ejemplo neutras: el punto céntrico genérico de Madrid de la
// semilla, nunca la casa de nadie.
const _lat = 40.4168;
const _lon = -3.7038;

final _indice = Uri.parse('https://ejemplo.invalid/mapas/indice.json');

String _sha(List<int> b) => sha256.convert(b).toString();

/// Índice con dos comunidades de ejemplo.
String _indiceJson(Map<String, Uint8List> archivos, {String? shaMalo}) =>
    jsonEncode({
      'version': 1,
      'mapas': [
        for (final e in archivos.entries)
          {
            'id': e.key,
            'nombre': 'Comunidad ${e.key.toUpperCase()}',
            'archivo': '${e.key}.pmtiles',
            'bytes': e.value.length,
            'sha256': shaMalo ?? _sha(e.value),
            'zoom_maximo': 14,
          },
      ],
    });

/// Servidor simulado: el índice y los archivos, con `Range`. Apunta cada
/// petición en [peticiones]. Con [cortarEn] la primera descarga se corta
/// tras ese número de bytes.
class _Servidor {
  _Servidor(this.archivos, {this.cortarEn, this.shaMalo});

  final Map<String, Uint8List> archivos;
  final String? shaMalo;
  int? cortarEn;
  final peticiones = <http.BaseRequest>[];

  http.Client cliente() => MockClient.streaming((req, _) async {
    peticiones.add(req);
    final nombre = req.url.pathSegments.last;
    if (nombre == 'indice.json') {
      return http.StreamedResponse(
        Stream.value(utf8.encode(_indiceJson(archivos, shaMalo: shaMalo))),
        200,
      );
    }
    final b = archivos[nombre.replaceAll('.pmtiles', '')];
    if (b == null) return http.StreamedResponse(const Stream.empty(), 404);
    final rango = req.headers['Range'];
    var desde = 0;
    if (rango != null) {
      desde = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(rango)!.group(1)!);
    }
    final resto = b.sublist(desde);
    final corte = cortarEn;
    Stream<List<int>> cuerpo;
    if (corte != null) {
      cortarEn = null;
      final c = StreamController<List<int>>();
      c.add(resto.sublist(0, corte));
      c.addError(const SocketException('corte'));
      unawaited(c.close());
      cuerpo = c.stream;
    } else {
      // En trozos pequeños, como por la red.
      cuerpo = Stream.fromIterable([
        for (var i = 0; i < resto.length; i += 512)
          resto.sublist(i, (i + 512).clamp(0, resto.length)),
      ]);
    }
    return http.StreamedResponse(
      cuerpo,
      rango == null ? 200 : 206,
      contentLength: resto.length,
    );
  });
}

Directory _temporal() {
  final d = Directory.systemTemp.createTempSync('newera_mapas_');
  addTearDown(() {
    if (d.existsSync()) d.deleteSync(recursive: true);
  });
  return d;
}

GestorMapas _gestor(Directory d, _Servidor s) => GestorMapas(
  carpeta: () async => Directory('${d.path}/mapas'),
  cliente: s.cliente,
  indice: _indice,
);

/// Deja [archivo] instalado como mapa de [id] en [d] (sin red).
void _instalar(Directory d, Uint8List archivo, {String id = 'mad'}) {
  final m = Directory('${d.path}/mapas')..createSync(recursive: true);
  File('${m.path}/$id.pmtiles').writeAsBytesSync(archivo);
  File('${m.path}/instalado.json').writeAsStringSync(
    jsonEncode({
      'id': id,
      'nombre': 'Comunidad de ejemplo',
      'archivo': '$id.pmtiles',
    }),
  );
}

/// Cuenta las conexiones HTTP que se intentan abrir (de cualquier paquete).
class _SinRed extends HttpOverrides {
  int conexiones = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    conexiones++;
    throw const SocketException('sin red en este test');
  }
}

void main() {
  group('lector PMTiles', () {
    test('id de tesela en la curva de Hilbert (valores de la espec)', () {
      expect(idTesela(0, 0, 0), 0);
      expect(idTesela(1, 0, 0), 1);
      expect(idTesela(1, 0, 1), 2);
      expect(idTesela(1, 1, 1), 3);
      expect(idTesela(1, 1, 0), 4);
      expect(idTesela(2, 0, 0), 5);
      // Todos distintos y seguidos en cada nivel.
      for (final z in [2, 3, 5]) {
        final n = 1 << z;
        final ids = {
          for (var x = 0; x < n; x++)
            for (var y = 0; y < n; y++) idTesela(z, x, y),
        };
        final base = ((1 << (2 * z)) - 1) ~/ 3;
        expect(ids, {for (var i = 0; i < n * n; i++) base + i});
      }
    });

    test('lee cabecera, teselas y metadatos del archivo', () async {
      final d = _temporal();
      final f = File('${d.path}/a.pmtiles')..writeAsBytesSync(pmtilesEjemplo());
      final l = await LectorPmtiles.abrir(f);
      addTearDown(l.cerrar);
      expect(l.cabecera.vectorial, isTrue);
      expect(l.cabecera.zoomMinimo, 0);
      expect(l.cabecera.zoomMaximo, 14);
      expect(l.cabecera.contiene(_lat, _lon), isTrue);
      expect(l.cabecera.contiene(41.5, 2.1), isFalse);
      final (x, y) = teselaDe(_lat, _lon, 14);
      expect(await l.tesela(14, x, y), teselaMvtPrueba());
      expect(await l.tesela(0, 0, 0), teselaMvtPrueba());
      expect(await l.tesela(14, x + 5, y), isNull);
      expect(await l.tesela(12, 0, 0), isNull);
      // Muchas lecturas a la vez no se pisan.
      final todas = await Future.wait([
        for (var i = 0; i < 20; i++)
          l.tesela(
            13,
            teselaDe(_lat, _lon, 13).$1,
            teselaDe(_lat, _lon, 13).$2,
          ),
      ]);
      expect(todas.every((t) => t != null), isTrue);
      expect(await l.metadatos(), {'attribution': 'prueba'});
      // La tesela se puede leer como MVT.
      final mvt = vtr.VectorTileReader().read(teselaMvtPrueba());
      expect(mvt.layers.map((c) => c.name), ['earth', 'roads']);
    });

    test('un archivo que no es PMTiles se rechaza', () async {
      final d = _temporal();
      final f = File('${d.path}/b.pmtiles')
        ..writeAsBytesSync(List.filled(200, 7));
      await expectLater(LectorPmtiles.abrir(f), throwsFormatException);
    });

    test(
      'el estilo claro y el oscuro se leen y usan la fuente del archivo',
      () {
        for (final oscuro in [false, true]) {
          final t = vtr.ThemeReader().read(estiloMapa(oscuro: oscuro));
          expect(t.tileSources, {fuenteMapa});
          expect(t.layers.length, greaterThan(8));
        }
      },
    );
  });

  group('gestor de descargas', () {
    final a = pmtilesEjemplo();
    final b = pmtilesEjemplo(lat: 40.42, lon: -3.70);

    test('lista: nombre, tamaño, sha256 y URL junto al índice', () async {
      final s = _Servidor({'mad': a, 'otra': b});
      final g = _gestor(_temporal(), s);
      final lista = await g.lista();
      expect(lista.map((m) => m.id), ['mad', 'otra']);
      expect(lista.first.bytes, a.length);
      expect(lista.first.sha256, _sha(a));
      expect(
        lista.first.url.toString(),
        'https://ejemplo.invalid/mapas/mad.pmtiles',
      );
      expect(await g.instalado(), isNull);
    });

    test('un índice con nombres de archivo raros se rechaza', () async {
      final s = _Servidor({'../x': a});
      await expectLater(
        _gestor(_temporal(), s).lista(),
        throwsA(
          isA<ErrorMapa>().having(
            (e) => e.motivo,
            'motivo',
            MotivoErrorMapa.indice,
          ),
        ),
      );
    });

    test('descarga con progreso, comprueba sha256 e instala', () async {
      final d = _temporal();
      final s = _Servidor({'mad': a});
      final g = _gestor(d, s);
      final m = (await g.lista()).single;
      final pasos = await g.descargar(m).toList();
      expect(pasos.first.recibidos, 0);
      expect(pasos.where((p) => p.comprobando), hasLength(1));
      expect(pasos.last.fraccion, 1);
      final recibidos = [for (final p in pasos) p.recibidos];
      expect(recibidos, orderedEquals([...recibidos]..sort()));
      final i = (await g.instalado())!;
      expect(i.id, 'mad');
      expect(i.archivo.readAsBytesSync(), a);
      expect(File('${i.archivo.path}.part').existsSync(), isFalse);
    });

    test('se corta y se reanuda desde donde se quedó (Range)', () async {
      final d = _temporal();
      final s = _Servidor({'mad': a}, cortarEn: 700);
      final g = _gestor(d, s);
      final m = (await g.lista()).single;
      await expectLater(
        g.descargar(m).toList(),
        throwsA(
          isA<ErrorMapa>().having(
            (e) => e.motivo,
            'motivo',
            MotivoErrorMapa.red,
          ),
        ),
      );
      expect(await g.parcial(m), 700);
      expect(await g.instalado(), isNull);
      await g.descargar(m).toList();
      expect(s.peticiones.last.headers['Range'], 'bytes=700-');
      expect((await g.instalado())!.archivo.readAsBytesSync(), a);
    });

    test('pausar (cancelar) deja lo bajado para seguir después', () async {
      final d = _temporal();
      final s = _Servidor({'mad': a});
      final g = _gestor(d, s);
      final m = (await g.lista()).single;
      final hecho = Completer<void>();
      late StreamSubscription<ProgresoMapa> sub;
      sub = g.descargar(m).listen((p) {
        if (p.recibidos >= 512 && !hecho.isCompleted) {
          hecho.complete();
          unawaited(sub.cancel());
        }
      });
      await hecho.future;
      await sub.cancel();
      final parcial = await g.parcial(m);
      expect(parcial, greaterThan(0));
      expect(parcial, lessThan(a.length));
      await g.descargar(m).toList();
      expect(s.peticiones.last.headers['Range'], 'bytes=$parcial-');
      expect((await g.instalado())!.archivo.readAsBytesSync(), a);
    });

    test('sha256 incorrecto: se borra lo bajado y no se instala', () async {
      final d = _temporal();
      final s = _Servidor({'mad': a}, shaMalo: 'f' * 64);
      final g = _gestor(d, s);
      final m = (await g.lista()).single;
      await expectLater(
        g.descargar(m).toList(),
        throwsA(
          isA<ErrorMapa>().having(
            (e) => e.motivo,
            'motivo',
            MotivoErrorMapa.huella,
          ),
        ),
      );
      expect(await g.parcial(m), 0);
      expect(await g.instalado(), isNull);
    });

    test(
      'cambiar de comunidad sustituye el mapa; borrar lo quita todo',
      () async {
        final d = _temporal();
        final s = _Servidor({'mad': a, 'otra': b});
        final g = _gestor(d, s);
        final lista = await g.lista();
        await g.descargar(lista[0]).toList();
        final primero = (await g.instalado())!.archivo;
        await g.descargar(lista[1]).toList();
        expect((await g.instalado())!.id, 'otra');
        expect(primero.existsSync(), isFalse);
        await g.borrar();
        expect(await g.instalado(), isNull);
        final quedan = Directory('${d.path}/mapas').listSync();
        expect(quedan, isEmpty);
      },
    );

    test('sin conexión: error de red al pedir la lista', () async {
      final g = GestorMapas(
        carpeta: () async => Directory('${_temporal().path}/mapas'),
        cliente: () =>
            MockClient((_) async => throw const SocketException('x')),
        indice: _indice,
      );
      await expectLater(
        g.lista(),
        throwsA(
          isA<ErrorMapa>().having(
            (e) => e.motivo,
            'motivo',
            MotivoErrorMapa.red,
          ),
        ),
      );
    });
  });

  group('pantallas', () {
    late Directory dir;
    late _Servidor servidor;

    Future<EntornoPrueba> abrir(
      WidgetTester tester, {
      String ruta = Rutas.ubicacion,
      Uint8List? instalado,
      bool conMapa = true,
      Brightness brillo = Brightness.light,
      String? shaMalo,
    }) async {
      tester.platformDispatcher.platformBrightnessTestValue = brillo;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      dir = _temporal();
      servidor = _Servidor({'mad': pmtilesEjemplo()}, shaMalo: shaMalo);
      if (instalado != null) _instalar(dir, instalado);
      final e = await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      );
      await montarApp(
        tester,
        e!,
        rutaInicial: ruta,
        extra: [
          gestorMapasProvider.overrideWithValue(_gestor(dir, servidor)),
          if (!conMapa) constructorMapaProvider.overrideWithValue(null),
        ],
      );
      await esperar(tester);
      return e;
    }

    testWidgets('sin mapa: la pantalla de siempre y la fila de descarga', (
      tester,
    ) async {
      await abrir(tester);
      expect(find.byKey(ClavesUi.ubicEstado), findsOneWidget);
      expect(find.byKey(ClavesUi.ubicAbrirMapas), findsOneWidget);
      expect(find.byKey(ClavesUi.mapaDescargar), findsOneWidget);
      expect(find.text('Descargar el mapa de tu zona'), findsOneWidget);
      expect(find.byType(FlutterMap), findsNothing);
    });

    testWidgets(
      'sin dibujo de mapa (web): con mapa guardado tampoco se pinta',
      (tester) async {
        await abrir(tester, instalado: pmtilesEjemplo(), conMapa: false);
        expect(find.byType(FlutterMap), findsNothing);
        expect(find.byKey(ClavesUi.mapaDescargar), findsOneWidget);
        expect(find.byKey(ClavesUi.ubicAbrirMapas), findsOneWidget);
      },
    );

    testWidgets(
      'lista de comunidades, descarga con progreso y mapa en Ubicación',
      (tester) async {
        await abrir(tester);
        await tester.tap(find.byKey(ClavesUi.mapaDescargar));
        await esperar(tester);
        expect(find.text('Mapa de tu zona'), findsWidgets);
        expect(find.text('Comunidad MAD'), findsOneWidget);
        await tester.tap(find.byKey(ClavesUi.mapaZona('mad')));
        await tester.pump();
        expect(find.byKey(ClavesUi.mapaProgreso), findsOneWidget);
        await hasta(tester, find.text('Este es el mapa guardado'));
        expect(find.text('Este es el mapa guardado'), findsOneWidget);
        expect(find.byKey(ClavesUi.mapaBorrar), findsOneWidget);
        final instalado = File('${dir.path}/mapas/mad.pmtiles');
        expect(instalado.existsSync(), isTrue);
        // Borrar.
        await tester.tap(find.byKey(ClavesUi.mapaBorrar));
        await esperar(tester);
        await tester.tap(find.byKey(ClavesUi.mapaBorrarSi));
        await esperar(tester);
        await hasta(tester, find.byKey(ClavesUi.mapaBorrar), ausente: true);
        expect(instalado.existsSync(), isFalse);
        expect(find.byKey(ClavesUi.mapaBorrar), findsNothing);
      },
    );

    testWidgets('sha256 incorrecto: aviso y nada instalado', (tester) async {
      await abrir(tester, ruta: Rutas.ubicacionMapa, shaMalo: '0' * 64);
      await hasta(tester, find.byKey(ClavesUi.mapaZona('mad')));
      await tester.tap(find.byKey(ClavesUi.mapaZona('mad')));
      await hasta(tester, find.textContaining('no coincide con el publicado'));
      expect(
        find.textContaining('no coincide con el publicado'),
        findsOneWidget,
      );
      expect(File('${dir.path}/mapas/mad.pmtiles').existsSync(), isFalse);
      expect(find.byKey(ClavesUi.mapaBorrar), findsNothing);
    });

    testWidgets('con un PMTiles mínimo se montan las capas y la atribución', (
      tester,
    ) async {
      final e = await abrir(tester, instalado: pmtilesEjemplo());
      await esperarMapa(tester);
      expect(find.byType(FlutterMap), findsOneWidget);
      // Zona «Casa» y precisión (círculos), rastro (línea) y puntos.
      expect(find.byType(CircleLayer), findsNWidgets(2));
      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.text('© OpenStreetMap'), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.mapaAtribucion));
      await esperar(tester);
      expect(e.enlaces.single, urlLicenciaOsm);
      // Recorrido: últimas 6 h o todo hoy.
      await tester.tap(find.byKey(ClavesUi.mapaRastro(24)));
      await esperar(tester);
      expect(find.byType(PolylineLayer), findsOneWidget);
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(500);
      await tester.pump();
      expect(find.byKey(ClavesUi.mapaInstaladoFila), findsOneWidget);
      expect(find.byKey(ClavesUi.mapaDescargar), findsNothing);
      await soltarMapa(tester);
    });

    testWidgets('pulsación larga en el mapa fija «Casa»', (tester) async {
      final e = await abrir(tester, instalado: pmtilesEjemplo());
      await esperarMapa(tester);
      final mapa = find.byType(FlutterMap);
      await tester.longPressAt(tester.getCenter(mapa) + const Offset(60, 0));
      await esperar(tester);
      expect(find.text('¿Poner aquí la casa?'), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.mapaFijarCasaSi));
      await esperar(tester);
      final fila = await tester.runAsync(
        () => e.db.select(e.db.ajustesUbicacion).getSingle(),
      );
      expect(fila!.zonaLat, closeTo(_lat, 0.01));
      expect(fila.zonaLon, greaterThan(_lon));
      await soltarMapa(tester);
    });

    testWidgets('mover el mapa no hace peticiones de red', (tester) async {
      final sinRed = _SinRed();
      final antes = HttpOverrides.current;
      HttpOverrides.global = sinRed;
      addTearDown(() => HttpOverrides.global = antes);
      await abrir(tester, instalado: pmtilesEjemplo());
      await esperarMapa(tester);
      final estado = tester.state<MapaPmtilesState>(find.byType(MapaPmtiles));
      final centro = estado.control.camera.center;
      final mapa = find.byType(FlutterMap);
      await tester.drag(mapa, const Offset(-120, 80));
      await esperarMapa(tester);
      await tester.timedDrag(
        mapa,
        const Offset(90, -60),
        const Duration(milliseconds: 300),
      );
      await esperarMapa(tester);
      expect(estado.control.camera.center, isNot(centro));
      await tester.tap(find.byKey(ClavesUi.mapaCentrarCasa));
      await esperarMapa(tester);
      await tester.tap(find.byKey(ClavesUi.mapaCentrarElla));
      await esperarMapa(tester);
      expect(estado.control.camera.center.latitude, closeTo(_lat, 0.01));
      expect(estado.proveedor!.lecturas, greaterThan(0));
      expect(sinRed.conexiones, 0);
      expect(servidor.peticiones, isEmpty);
      await soltarMapa(tester);
    });

    for (final brillo in Brightness.values) {
      testWidgets('mapa en ${brillo.name}: contraste y toques', (tester) async {
        final manejador = tester.ensureSemantics();
        await abrir(tester, instalado: pmtilesEjemplo(), brillo: brillo);
        await esperarMapa(tester);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        expect(find.bySemanticsLabel(RegExp('OpenStreetMap')), findsWidgets);
        manejador.dispose();
        await soltarMapa(tester);
      });
    }

    testWidgets('pantalla de mapas: contraste y toques', (tester) async {
      final manejador = tester.ensureSemantics();
      await abrir(
        tester,
        ruta: Rutas.ubicacionMapa,
        instalado: pmtilesEjemplo(),
      );
      await hasta(tester, find.text('Comunidad MAD'));
      expect(find.text('Comunidad MAD'), findsOneWidget);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      manejador.dispose();
    });
  });
}

Future<void> esperar(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
  await pasar(tester, const Duration(milliseconds: 700));
}

/// Deja que el lector abra el archivo y que el mapa pida y pinte teselas.
Future<void> esperarMapa(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// El mapa deja un temporizador de 3 s al montarse: se deja pasar.
Future<void> soltarMapa(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 4));
}

/// Avanza (E/S real y reloj de prueba) hasta que aparece [f] (o desaparece con [ausente]).
Future<void> hasta(
  WidgetTester tester,
  Finder f, {
  bool ausente = false,
}) async {
  for (var i = 0; i < 300 && f.evaluate().isEmpty != ausente; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}
