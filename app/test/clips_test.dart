import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/cifrado_sobres.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/eventos_repositorio.dart';
import 'package:newera/core/plataforma/camara/archivos_clip.dart';
import 'package:newera/core/plataforma/camara/camara_comprobacion.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/clips.dart';
import 'package:newera/core/sync/config_sync.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/core/sync/supabase_transport.dart';
import 'package:newera/core/sync/trozo_cifrado.dart';
import 'package:newera/features/hoy/vistas/fila_clip.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

/// Clave de prueba (no es de nadie): sale de una semilla fija.
final _clave = ClaveCirculo.generar(Random(11));
const _circulo = 'circulo-clips';

/// Bytes de prueba que no se repiten por trozos (así un trozo cambiado de
/// sitio se nota).
Uint8List _bytes(int n, {int semilla = 1}) {
  final azar = Random(semilla);
  return Uint8List.fromList(List.generate(n, (_) => azar.nextInt(256)));
}

/// Un móvil del círculo con su base, su cola de clips y su servicio de sync.
class _Movil {
  _Movil(this.contenedor, this.servicio, this.transporte, this.archivos);

  final ProviderContainer contenedor;
  final ServicioSync servicio;
  final TransporteMemoria transporte;
  final ArchivosClipMemoria archivos;

  AppDatabase get db => contenedor.read(baseDatosProvider);
  ClipsCartero get clips => contenedor.read(clipsProvider);

  Future<List<Evento>> eventos() => db.select(db.eventos).get();

  /// Graba (de mentira) un clip de [bytes] para la toma [tomaId] y lo
  /// registra como la pantalla de toma.
  Future<String> grabar(String tomaId, Uint8List bytes, {String ext = 'mp4'}) {
    final ruta = RutasClip.de(tomaId, ext);
    archivos.archivos[ruta] = bytes;
    return clips.registrarGrabado(
      tomaId: tomaId,
      clip: ClipGrabado(
        tipo: ext == 'jpg' ? TipoComprobacion.foto : TipoComprobacion.video,
        ruta: ruta,
        duracionMs: 10000,
      ),
    );
  }

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
}) async {
  final almacen = AlmacenSeguroMemoria({
    ClavesAlmacen.dispositivoId: dispositivo,
    ClavesAlmacen.circuloId: _circulo,
    ClavesAlmacen.circuloClave: _clave,
    ClavesAlmacen.circuloClaveVersion: '1',
  });
  final reloj = RelojFijo(instantePrueba);
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
  final archivos = ArchivosClipMemoria(ahora: reloj.ahora);
  final c = ProviderContainer(
    overrides: [
      ...overrides,
      syncTransportProvider.overrideWithValue(transporte),
      archivosClipProvider.overrideWithValue(archivos),
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
    clips: c.read(clipsProvider),
  );
  return _Movil(c, servicio, transporte, archivos);
}

/// Espera (de verdad) a que se cumpla [condicion].
Future<void> _esperarA(Future<bool> Function() condicion) async {
  final reloj = Stopwatch()..start();
  while (!await condicion()) {
    if (reloj.elapsed > const Duration(seconds: 10)) {
      fail('tiempo agotado esperando');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Future<List<TrozoCifrado>> _cifrarTodo(
  Uint8List bytes,
  LlavesCirculo llaves,
  String clipId,
) async {
  final trozos = TrozosClip.trocear(bytes);
  return [
    for (var n = 0; n < trozos.length; n++)
      await () async {
        final s = await CifradoClips.cifrar(
          trozos[n],
          llaves: llaves,
          clipId: clipId,
          n: n,
          total: trozos.length,
        );
        return TrozoCifrado(
          clipId: clipId,
          n: n,
          total: trozos.length,
          nonce: s.nonce,
          contenido: s.contenido,
        );
      }(),
  ];
}

const _clipA = '01HZY3NDEKTSV4RRFFQ69G5FAV';
const _clipB = '01HZY3NDEKTSV4RRFFQ69G5FAW';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('trozos', () {
    test('trocear y recomponer con el hash del clip entero', () {
      final bytes = _bytes(3 * TrozosClip.tamTrozo + 123);
      final trozos = TrozosClip.trocear(bytes);
      expect(TrozosClip.cuantos(bytes.length), 4);
      expect(trozos, hasLength(4));
      expect(
        [for (final t in trozos) t.length],
        [TrozosClip.tamTrozo, TrozosClip.tamTrozo, TrozosClip.tamTrozo, 123],
      );
      final sha = TrozosClip.sha256Hex(bytes);
      expect(sha, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(
        TrozosClip.recomponer(trozos, bytes: bytes.length, sha256: sha),
        bytes,
      );
      // Un byte cambiado, dos trozos cambiados de sitio o uno de menos: no.
      final tocado = Uint8List.fromList(trozos[1])..[7] ^= 1;
      expect(
        TrozosClip.recomponer(
          [trozos[0], tocado, trozos[2], trozos[3]],
          bytes: bytes.length,
          sha256: sha,
        ),
        isNull,
      );
      expect(
        TrozosClip.recomponer(
          [trozos[1], trozos[0], trozos[2], trozos[3]],
          bytes: bytes.length,
          sha256: sha,
        ),
        isNull,
      );
      expect(
        TrozosClip.recomponer(
          trozos.sublist(0, 3),
          bytes: bytes.length,
          sha256: sha,
        ),
        isNull,
      );
      // Tamaño justo: 64 KiB son un trozo; uno más, dos.
      expect(TrozosClip.cuantos(TrozosClip.tamTrozo), 1);
      expect(TrozosClip.cuantos(TrozosClip.tamTrozo + 1), 2);
      expect(TrozosClip.maxTrozos, 64);
    });

    test('un trozo cifrado de 64 KiB cabe en la columna (90 000)', () async {
      final llaves = await LlavesCirculo.derivar(_clave);
      final s = await CifradoClips.cifrar(
        _bytes(TrozosClip.tamTrozo),
        llaves: llaves,
        clipId: _clipA,
        n: 0,
        total: 1,
      );
      expect(base64Encode(s.contenido).length, 87404);
      expect(base64Encode(s.nonce), matches(RegExp(r'^[A-Za-z0-9+/]{16}$')));
    });

    test('el cifrado por trozo no deja reordenar ni mezclar trozos', () async {
      final llaves = await LlavesCirculo.derivar(_clave);
      final otra = await LlavesCirculo.derivar(ClaveCirculo.generar(Random(3)));
      final claro = _bytes(1000);
      final s = await CifradoClips.cifrar(
        claro,
        llaves: llaves,
        clipId: _clipA,
        n: 1,
        total: 3,
      );
      Future<Uint8List?> abrir({
        LlavesCirculo? con,
        String clipId = _clipA,
        int n = 1,
        int total = 3,
      }) => CifradoClips.descifrar(
        nonce: s.nonce,
        contenido: s.contenido,
        llaves: con ?? llaves,
        clipId: clipId,
        n: n,
        total: total,
      );
      expect(await abrir(), claro);
      // Otra posición (reorden), otro clip (mezcla), otro total (quitar los
      // últimos) u otra clave: no se abre.
      expect(await abrir(n: 0), isNull);
      expect(await abrir(n: 2), isNull);
      expect(await abrir(clipId: _clipB), isNull);
      expect(await abrir(total: 2), isNull);
      expect(await abrir(con: otra), isNull);
      // La clave de los clips no es la de los sobres (etiqueta HKDF propia).
      expect(
        await CifradoSobres.descifrar(
          nonce: s.nonce,
          contenido: s.contenido,
          llaves: llaves,
          ulid: _clipA,
        ),
        isNull,
      );
      // Un bit cambiado tampoco.
      final tocado = Uint8List.fromList(s.contenido)..[3] ^= 1;
      expect(
        await CifradoClips.descifrar(
          nonce: s.nonce,
          contenido: tocado,
          llaves: llaves,
          clipId: _clipA,
          n: 1,
          total: 3,
        ),
        isNull,
      );
      // Nonce nuevo cada vez: el mismo trozo no sale igual dos veces.
      final otraVez = await CifradoClips.cifrar(
        claro,
        llaves: llaves,
        clipId: _clipA,
        n: 1,
        total: 3,
      );
      expect(otraVez.nonce, isNot(s.nonce));
      expect(otraVez.contenido, isNot(s.contenido));
    });

    test('el payload del clip se valida antes de pedir nada', () {
      final bueno = MetaClip(
        clipId: _clipA,
        total: 2,
        bytes: TrozosClip.tamTrozo + 1,
        mime: 'video/mp4',
        sha256: 'a' * 64,
        duracionMs: 10000,
      );
      expect(MetaClip.dePayload(bueno.aPayload())?.ruta, 'clips/$_clipA.mp4');
      for (final malo in <Map<String, Object?>>[
        {...bueno.aPayload(), 'clipId': '../../etc/passwd'},
        {...bueno.aPayload(), 'total': 3},
        {...bueno.aPayload(), 'bytes': TrozosClip.maxBytes + 1, 'total': 65},
        {...bueno.aPayload(), 'mime': 'text/html'},
        {...bueno.aPayload(), 'sha256': 'xyz'},
        {...bueno.aPayload(), 'omitido': 'tamaño'},
        {'tipo': 'video', 'ruta': '', 'duracionMs': 10000},
      ]) {
        expect(MetaClip.dePayload(malo), isNull, reason: '$malo');
      }
    });
  });

  group('cartero de clips entre la persona y la familia', () {
    late ServidorMemoria servidor;
    late _Movil persona;
    late _Movil familia;

    setUp(() async {
      servidor = ServidorMemoria();
      persona = await _crearMovil(servidor, dispositivo: 'movil-persona');
      familia = await _crearMovil(servidor, dispositivo: 'movil-familia');
    });

    tearDown(() async {
      await persona.cerrar();
      await familia.cerrar();
    });

    test('subida idempotente y reanudable: el sobre sale al final y la persona '
        'borra el archivo', () async {
      final video = _bytes(10 * TrozosClip.tamTrozo - 5000, semilla: 4);
      final ulid = await persona.grabar('toma-1', video);
      final evento = (await persona.eventos()).singleWhere(
        (e) => e.ulid == ulid,
      );
      final meta = MetaClip.deEvento(evento)!;
      expect(meta.total, 10);
      expect(meta.bytes, video.length);
      expect(meta.sha256, TrozosClip.sha256Hex(video));
      expect(meta.mime, 'video/mp4');
      // El archivo ya lleva el nombre del clip y espera en la cola.
      expect(persona.archivos.archivos.keys, ['clips/${meta.clipId}.mp4']);
      expect(await persona.clips.pendientes(), hasLength(1));

      // El servidor se cae a mitad: tras 7 trozos.
      servidor.caerTrasTrozos = 7;
      await persona.servicio.empujar();
      expect(servidor.trozos[meta.clipId]!.keys.toSet(), {
        for (var n = 0; n < 7; n++) n,
      });
      // El `clip_grabado` espera a su clip.
      expect(servidor.sobres.any((s) => s.ulid == ulid), isFalse);
      expect(await persona.clips.pendientes(), hasLength(1));
      expect(persona.archivos.archivos, hasLength(1));

      // Con el servidor aceptando sobres pero no trozos, los demás eventos
      // salen y el `clip_grabado` sigue esperando.
      servidor.caerTrasTrozos = null;
      servidor.caido = false;
      servidor.rechazarTrozos = true;
      await persona.servicio.empujar();
      expect(servidor.sobres, isNotEmpty);
      expect(servidor.sobres.any((s) => s.ulid == ulid), isFalse);
      expect(servidor.trozos[meta.clipId], hasLength(7));

      // Vuelve la red: sigue donde se quedó, sin repetir trozos.
      servidor.rechazarTrozos = false;
      servidor.levantar();
      await persona.servicio.empujar();
      await _esperarA(() async => servidor.sobres.any((s) => s.ulid == ulid));
      expect(servidor.trozos[meta.clipId], hasLength(10));
      expect(servidor.trozosInsertados, 10);
      expect(
        servidor.lotesTrozos.every((n) => n <= TrozosClip.tamLote),
        isTrue,
      );
      await _esperarA(() async => (await persona.clips.pendientes()).isEmpty);
      expect(persona.archivos.archivos, isEmpty);

      // Volver a empujar no sube nada más.
      final lotes = servidor.lotesTrozos.length;
      await persona.servicio.empujar();
      expect(servidor.lotesTrozos.length, lotes);
      expect(servidor.sobres.where((s) => s.ulid == ulid), hasLength(1));

      // El servidor no ve el clip en claro.
      final trozos = servidor.trozos[meta.clipId]!.values;
      final aguja = video.sublist(1000, 1032);
      for (final t in trozos) {
        expect(base64Encode(t.contenido), isNot(contains(base64Encode(aguja))));
      }
    });

    test('un clip que no sube no retrasa los demás eventos', () async {
      final clip = await persona.grabar(
        'toma-9',
        _bytes(3 * TrozosClip.tamTrozo, semilla: 9),
      );
      final ayuda = await persona.contenedor
          .read(eventosRepositorioProvider)
          .registrar(TipoEvento.ayudaPedida);
      // La red se cae en cuanto empieza a subir el clip.
      servidor.caerTrasTrozos = 0;
      await persona.servicio.empujar();
      expect(servidor.sobres.any((s) => s.ulid == ayuda), isTrue);
      expect(servidor.sobres.any((s) => s.ulid == clip), isFalse);
      expect(await persona.clips.pendientes(), hasLength(1));
    });

    test(
      'si el servidor ya tiene todos los trozos, no se suben otra vez',
      () async {
        final video = _bytes(3 * TrozosClip.tamTrozo, semilla: 5);
        final ulid = await persona.grabar('toma-2', video);
        final meta = MetaClip.deEvento(
          (await persona.eventos()).singleWhere((e) => e.ulid == ulid),
        )!;
        final llaves = (await persona.contenedor.read(
          llavesCirculoProvider.future,
        ))!;
        // Subidos en otra vuelta que se cortó antes de borrar la fila.
        servidor.guardarTrozos(await _cifrarTodo(video, llaves, meta.clipId));
        final lotes = servidor.lotesTrozos.length;
        await persona.servicio.empujar();
        expect(servidor.lotesTrozos.length, lotes);
        expect(servidor.sobres.any((s) => s.ulid == ulid), isTrue);
        expect(persona.archivos.archivos, isEmpty);
      },
    );

    test(
      'descarga perezosa: solo baja al pedirlo, comprueba y guarda',
      () async {
        final video = _bytes(7 * TrozosClip.tamTrozo + 77, semilla: 6);
        final ulid = await persona.grabar('toma-3', video);
        await persona.servicio.empujar();
        await familia.servicio.iniciar();
        await _esperarA(
          () async => (await familia.eventos()).any((e) => e.ulid == ulid),
        );
        // Ha llegado el aviso del clip, pero no se ha bajado nada.
        expect(familia.transporte.bajadas, 0);
        expect(familia.archivos.archivos, isEmpty);

        final evento = (await familia.eventos()).singleWhere(
          (e) => e.ulid == ulid,
        );
        final meta = MetaClip.deEvento(evento)!;
        final avances = <int>[];
        final r = await familia.clips.bajar(
          meta,
          progreso: (hechos, total) {
            expect(total, 8);
            avances.add(hechos);
          },
        );
        expect(r, isA<ClipListo>());
        expect((r as ClipListo).ruta, 'clips/${meta.clipId}.mp4');
        expect(familia.archivos.archivos[r.ruta], video);
        expect(avances.first, 0);
        expect(avances.last, 8);
        // Lotes de 5: dos peticiones.
        expect(familia.transporte.bajadas, 2);

        // La segunda vez está en el móvil: no pide nada.
        expect(await familia.clips.bajar(meta), isA<ClipListo>());
        expect(familia.transporte.bajadas, 2);
      },
    );

    test(
      '«ya no disponible» cuando el servidor lo ha borrado; sin red, error',
      () async {
        final video = _bytes(2 * TrozosClip.tamTrozo, semilla: 7);
        final ulid = await persona.grabar('toma-4', video);
        await persona.servicio.empujar();
        final meta = MetaClip.deEvento(
          (await persona.eventos()).singleWhere((e) => e.ulid == ulid),
        )!;

        servidor.caido = true;
        expect(await familia.clips.bajar(meta), isA<ClipNoSeBaja>());
        servidor.caido = false;

        // Faltan los últimos (borrado a medias): tampoco está disponible.
        servidor.trozos[meta.clipId]!.remove(1);
        expect(await familia.clips.bajar(meta), isA<ClipNoDisponible>());

        servidor.caducar(meta.clipId);
        expect(await familia.clips.bajar(meta), isA<ClipNoDisponible>());
        expect(familia.archivos.archivos, isEmpty);
      },
    );

    test('un trozo cambiado de sitio o de otro clip no se acepta', () async {
      final video = _bytes(3 * TrozosClip.tamTrozo, semilla: 8);
      final ulid = await persona.grabar('toma-5', video);
      await persona.servicio.empujar();
      final meta = MetaClip.deEvento(
        (await persona.eventos()).singleWhere((e) => e.ulid == ulid),
      )!;
      final delClip = servidor.trozos[meta.clipId]!;
      final t0 = delClip[0]!;
      final t1 = delClip[1]!;
      // El servidor cambia el orden de dos trozos.
      delClip[0] = TrozoCifrado(
        clipId: t0.clipId,
        n: 0,
        total: t0.total,
        nonce: t1.nonce,
        contenido: t1.contenido,
      );
      delClip[1] = TrozoCifrado(
        clipId: t1.clipId,
        n: 1,
        total: t1.total,
        nonce: t0.nonce,
        contenido: t0.contenido,
      );
      expect(await familia.clips.bajar(meta), isA<ClipNoSeBaja>());
      expect(familia.archivos.archivos, isEmpty);

      // Un trozo de otro clip del mismo círculo, con su número.
      final llaves = (await persona.contenedor.read(
        llavesCirculoProvider.future,
      ))!;
      final ajeno = (await _cifrarTodo(
        _bytes(3 * TrozosClip.tamTrozo),
        llaves,
        _clipB,
      ))[0];
      delClip[0] = TrozoCifrado(
        clipId: meta.clipId,
        n: 0,
        total: meta.total,
        nonce: ajeno.nonce,
        contenido: ajeno.contenido,
      );
      delClip[1] = t1;
      expect(await familia.clips.bajar(meta), isA<ClipNoSeBaja>());
    });

    test('más de 4 MB: no viaja y el evento lo anota', () async {
      final grande = _bytes(TrozosClip.maxBytes + 1, semilla: 9);
      final ulid = await persona.grabar('toma-6', grande);
      final evento = (await persona.eventos()).singleWhere(
        (e) => e.ulid == ulid,
      );
      final p = EventosRepositorio.payloadDe(evento);
      expect(evento.tipo, 'clip_grabado');
      expect(p['omitido'], 'tamaño');
      expect(p['bytes'], TrozosClip.maxBytes + 1);
      expect(p.containsKey('clipId'), isFalse);
      expect(MetaClip.deEvento(evento), isNull);
      expect(await persona.clips.pendientes(), isEmpty);
      // El evento sale enseguida y no se sube ningún trozo.
      await persona.servicio.empujar();
      expect(servidor.sobres.any((s) => s.ulid == ulid), isTrue);
      expect(servidor.trozos, isEmpty);
      // Justo 4 MB sí viaja (64 trozos).
      final justo = _bytes(TrozosClip.maxBytes, semilla: 10);
      final otro = await persona.grabar('toma-7', justo);
      final meta = MetaClip.deEvento(
        (await persona.eventos()).singleWhere((e) => e.ulid == otro),
      );
      expect(meta?.total, 64);
    });

    test('limpieza: a los 7 días se borra lo que no espera a subir', () async {
      final ahora = instantePrueba;
      final viejo = RutasClip.de('viejo', 'mp4');
      final nuevo = RutasClip.de('nuevo', 'mp4');
      persona.archivos.archivos[viejo] = _bytes(10);
      persona.archivos.modificados[viejo] = ahora.subtract(
        const Duration(days: 8),
      );
      persona.archivos.archivos[nuevo] = _bytes(10);
      persona.archivos.modificados[nuevo] = ahora.subtract(
        const Duration(days: 6),
      );
      // Un clip que espera a subir desde hace 9 días (sin red) no se borra.
      servidor.caido = true;
      await persona.grabar('toma-8', _bytes(100));
      final pendiente = (await persona.clips.pendientes()).single.ruta;
      persona.archivos.modificados[pendiente] = ahora.subtract(
        const Duration(days: 9),
      );
      expect(await persona.clips.limpiar(), 1);
      expect(persona.archivos.archivos.keys.toSet(), {nuevo, pendiente});
    });

    test('un archivo que falta no bloquea el evento', () async {
      final ulid = await persona.grabar('toma-9', _bytes(5000));
      persona.archivos.archivos.clear();
      await persona.servicio.empujar();
      expect(servidor.sobres.any((s) => s.ulid == ulid), isTrue);
      expect(await persona.clips.pendientes(), isEmpty);
    });

    test('la cola sobrevive a un cierre: otro servicio la retoma', () async {
      servidor.caido = true;
      final ulid = await persona.grabar('toma-10', _bytes(3000));
      await persona.servicio.detener();
      servidor.caido = false;
      final otro = ServicioSync(
        db: persona.db,
        transporte: persona.transporte,
        llaves: () => persona.contenedor.read(llavesCirculoProvider.future),
        contexto: persona.contenedor.read(contextoProvider),
        reloj: persona.contenedor.read(relojProvider),
        clips: persona.clips,
      );
      await otro.empujar();
      expect(servidor.sobres.any((s) => s.ulid == ulid), isTrue);
      expect(persona.archivos.archivos, isEmpty);
      await otro.detener();
    });
  });

  test('migración 2→3: crea la cola de clips sin tocar los hechos', () async {
    final dir = await Directory.systemTemp.createTemp('newera_migracion3_');
    addTearDown(() => dir.delete(recursive: true));
    final archivo = File('${dir.path}/v2.db');
    final v2 = AppDatabase(NativeDatabase(archivo));
    await v2
        .into(v2.circulos)
        .insert(
          CirculosCompanion.insert(id: 'c1', nombre: 'Familia', creadoEn: 1),
        );
    await v2
        .into(v2.eventos)
        .insert(
          EventosCompanion.insert(
            ulid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
            circuloId: 'c1',
            autor: 'a',
            dispositivo: 'd',
            tipo: 'clip_grabado',
            ocurridoEn: 1,
            registradoEn: 1,
          ),
        );
    await v2.customStatement('DROP TABLE clips_pendientes');
    await v2.customStatement('PRAGMA user_version = 2');
    await v2.close();

    final v3 = AppDatabase(NativeDatabase(archivo));
    addTearDown(v3.close);
    final version = await v3.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
    expect(await v3.select(v3.eventos).get(), hasLength(1));
    expect(await v3.select(v3.clipsPendientes).get(), isEmpty);
    await v3
        .into(v3.clipsPendientes)
        .insert(
          ClipsPendientesCompanion.insert(
            clipId: _clipA,
            eventoUlid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
            ruta: 'clips/$_clipA.mp4',
            mime: 'video/mp4',
            total: 1,
            bytes: 10,
            sha256: 'a' * 64,
            creadoEn: 1,
          ),
        );
    // La cola se puede vaciar; los hechos siguen siendo de solo inserción.
    await v3.delete(v3.clipsPendientes).go();
    await expectLater(
      v3.customStatement("DELETE FROM eventos"),
      throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
    );
  });

  group('SupabaseTransport: trozos', () {
    test('lotes de 5 con ignore-duplicates y lectura por páginas', () async {
      final peticiones = <http.Request>[];
      final filas = <Map<String, Object?>>[];
      final cliente = MockClient((r) async {
        peticiones.add(r);
        http.Response json(Object cuerpo, [int estado = 200]) => http.Response(
          jsonEncode(cuerpo),
          estado,
          request: r,
          headers: {'content-type': 'application/json'},
        );
        if (r.url.path != '/rest/v1/clips_trozos') return json([], 404);
        if (r.method == 'POST') {
          for (final f in (jsonDecode(r.body) as List).cast<Map>()) {
            if (!filas.any(
              (x) => x['clip_id'] == f['clip_id'] && x['n'] == f['n'],
            )) {
              filas.add(f.cast<String, Object?>());
            }
          }
          return http.Response('', 201, request: r);
        }
        final q = r.url.queryParameters;
        var vistas = filas.where(
          (f) => f['circulo_token'] == r.headers['x-circulo-token'],
        );
        if (q['clip_id'] case final c?) {
          vistas = vistas.where((f) => 'eq.${f['clip_id']}' == c);
        }
        if (q['n'] case final n?) {
          final desde = int.parse(n.substring(4));
          vistas = vistas.where((f) => (f['n']! as int) >= desde);
        }
        final lista = vistas.toList()
          ..sort((a, b) => (a['n']! as int).compareTo(b['n']! as int));
        final limite = int.tryParse(q['limit'] ?? '') ?? lista.length;
        final cols = q['select']!.split(',').map((c) => c.trim());
        return json([
          for (final f in lista.take(limite)) {for (final c in cols) c: f[c]},
        ]);
      });
      final t = SupabaseTransport(
        config: const ConfigSync(
          url: 'https://ejemplo.supabase.co',
          claveAnonima: 'anon',
        ),
        circuloId: 'c1',
        circuloToken: () async => 'a' * 64,
        clienteHttp: cliente,
        avisos: (_, _) => const Stream.empty(),
        esperaMinima: const Duration(milliseconds: 1),
        esperaMaxima: const Duration(milliseconds: 2),
      );
      final trozos = [
        for (var n = 0; n < 12; n++)
          TrozoCifrado(
            clipId: _clipA,
            n: n,
            total: 12,
            nonce: Uint8List(12),
            contenido: Uint8List.fromList([n, 1, 2, 3]),
          ),
      ];
      expect(await t.subirTrozos(_clipA, trozos), {
        for (var n = 0; n < 12; n++) n,
      });
      final posts = peticiones.where((p) => p.method == 'POST').toList();
      expect(
        [for (final p in posts) (jsonDecode(p.body) as List).length],
        [5, 5, 2],
      );
      for (final p in posts) {
        expect(p.url.queryParameters['on_conflict'], 'clip_id,n');
        expect(
          p.headers['Prefer'] ?? p.headers['prefer'],
          contains('resolution=ignore-duplicates'),
        );
        expect(p.headers['x-circulo-token'], 'a' * 64);
      }
      // Reenviar no duplica.
      expect(await t.subirTrozos(_clipA, trozos.sublist(0, 3)), {0, 1, 2});
      expect(filas, hasLength(12));
      expect(await t.trozosEnServidor(_clipA), hasLength(12));

      final pagina = await t.bajarTrozos(_clipA, desde: 5, limite: 5);
      expect([for (final x in pagina) x.n], [5, 6, 7, 8, 9]);
      expect(pagina.first.contenido, [5, 1, 2, 3]);
      expect(await t.bajarTrozos(_clipB), isEmpty);
      await t.desconectar();
    });
  });

  group('Hoy (familia): «Ver vídeo»', () {
    Future<(EntornoPrueba, ServidorMemoria, MetaClip)> preparar(
      WidgetTester tester, {
      bool subir = true,
    }) async {
      final r = await tester.runAsync(() async {
        final entorno = await prepararEntorno(perfil: PerfilApp.familia);
        final servidor = ServidorMemoria();
        final llaves = (await LlavesCirculo.desdeAlmacen(entorno.almacen))!;
        final video = _bytes(6 * TrozosClip.tamTrozo + 10, semilla: 12);
        final id = await entorno.idToma(
          'Pastilla blanca pequeña',
          '20261013',
          '0900',
        );
        final meta = MetaClip(
          clipId: _clipA,
          total: TrozosClip.cuantos(video.length),
          bytes: video.length,
          mime: 'video/mp4',
          sha256: TrozosClip.sha256Hex(video),
          duracionMs: 9000,
        );
        if (subir) {
          servidor.guardarTrozos(await _cifrarTodo(video, llaves, _clipA));
        }
        final eventos = EventosRepositorio(
          db: entorno.db,
          reloj: entorno.reloj,
          azar: Random(5),
          contexto: entorno.contexto,
          autor: () => entorno.contexto.personaId,
        );
        await eventos.registrar(
          TipoEvento.clipGrabado,
          sujeto: id,
          payload: meta.aPayload(),
          ocurridoEn: instantePrueba.subtract(const Duration(minutes: 50)),
        );
        return (entorno, servidor, meta);
      });
      return r!;
    }

    testWidgets('baja, descifra y abre el visor', (tester) async {
      final (entorno, servidor, meta) = await preparar(tester);
      final transporte = TransporteMemoria(servidor);
      await montarApp(
        tester,
        entorno,
        rutaInicial: '/familia/hoy',
        extra: [syncTransportProvider.overrideWithValue(transporte)],
      );
      await pasar(tester, const Duration(seconds: 1));
      final ver = find.text('Ver vídeo');
      await tester.scrollUntilVisible(ver, 300);
      await tester.ensureVisible(ver);
      await pasar(tester, const Duration(milliseconds: 300));
      expect(ver, findsOneWidget);
      expect(find.text('Vídeo de la toma de las 09:00 · 9 s'), findsOneWidget);
      expect(transporte.bajadas, 0);
      await tester.tap(ver);
      for (
        var i = 0;
        i < 10 && find.byType(VisorClipPantalla).evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      await pasar(tester, const Duration(milliseconds: 600));
      expect(find.byType(VisorClipPantalla), findsOneWidget);
      expect(
        find.text('Demo: aquí se vería el vídeo de la toma'),
        findsOneWidget,
      );
      expect(transporte.bajadas, 2);
      expect(entorno.archivosClip.archivos.keys, ['clips/${meta.clipId}.mp4']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('si el servidor ya no lo tiene, lo dice', (tester) async {
      final (entorno, servidor, _) = await preparar(tester, subir: false);
      await montarApp(
        tester,
        entorno,
        rutaInicial: '/familia/hoy',
        extra: [
          syncTransportProvider.overrideWithValue(TransporteMemoria(servidor)),
        ],
      );
      await pasar(tester, const Duration(seconds: 1));
      final ver = find.text('Ver vídeo');
      await tester.scrollUntilVisible(ver, 300);
      await tester.ensureVisible(ver);
      await pasar(tester, const Duration(milliseconds: 300));
      await tester.tap(ver);
      for (
        var i = 0;
        i < 10 &&
            find.text('Este vídeo ya no está disponible').evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Este vídeo ya no está disponible'), findsOneWidget);
      expect(find.text('Ver vídeo'), findsNothing);
      expect(find.byType(VisorClipPantalla), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
