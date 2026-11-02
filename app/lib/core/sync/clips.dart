import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import '../cripto/cifrado_sobres.dart';
import '../db/base_datos.dart';
import '../db/repositorios/eventos_repositorio.dart';
import '../plataforma/camara/archivos_clip.dart';
import '../plataforma/camara/camara_comprobacion.dart';
import 'sync_transport.dart';
import 'trozo_cifrado.dart';

/// Cómo se parte un clip para el cartero.
///
/// Cada trozo lleva 64 KiB en claro; cifrado (más 16 bytes de etiqueta) y en
/// base64 son 87 404 caracteres, por debajo del tope de 90 000 de la tabla
/// `clips_trozos`. Un vídeo de 10 s a 15 fps y ~500 kbps ocupa menos de 1 MB:
/// 16 trozos como mucho.
abstract final class TrozosClip {
  static const tamTrozo = 64 * 1024;

  /// Un clip de más no se envía (`omitido: 'tamaño'` en su evento).
  static const maxBytes = 4 * 1024 * 1024;

  /// Trozos por petición al subir y al bajar.
  static const tamLote = 5;

  /// Número de trozos de un clip de [bytes] bytes.
  static int cuantos(int bytes) =>
      bytes <= 0 ? 1 : (bytes + tamTrozo - 1) ~/ tamTrozo;

  /// Máximo de trozos de un clip (el esquema lo comprueba igual).
  static int get maxTrozos => cuantos(maxBytes);

  static List<Uint8List> trocear(Uint8List bytes) => [
    for (var i = 0; i < cuantos(bytes.length); i++)
      Uint8List.sublistView(
        bytes,
        i * tamTrozo,
        min((i + 1) * tamTrozo, bytes.length),
      ),
  ];

  /// SHA-256 en hexadecimal (64 caracteres).
  static String sha256Hex(List<int> bytes) =>
      crypto.sha256.convert(bytes).toString();

  /// Une [trozos] y comprueba el tamaño y el hash del clip entero. Nulo si
  /// no coinciden.
  static Uint8List? recomponer(
    List<Uint8List> trozos, {
    required int bytes,
    required String sha256,
  }) {
    final b = BytesBuilder(copy: false);
    for (final t in trozos) {
      b.add(t);
    }
    final todo = b.takeBytes();
    if (todo.length != bytes || sha256Hex(todo) != sha256) return null;
    return todo;
  }
}

/// Lo que el evento `clip_grabado` cuenta de su clip (va cifrado en el
/// sobre): con esto la familia sabe qué trozos pedir y comprueba lo que baja.
final class MetaClip {
  const MetaClip({
    required this.clipId,
    required this.total,
    required this.bytes,
    required this.mime,
    required this.sha256,
    this.duracionMs = 0,
    this.tipo = 'video',
  });

  final String clipId;
  final int total;
  final int bytes;
  final String mime;

  /// SHA-256 del clip entero, en hexadecimal.
  final String sha256;
  final int duracionMs;

  /// `video` o `foto`.
  final String tipo;

  bool get esFoto => mime.startsWith('image/');

  /// Dónde se guarda en este móvil: `clips/<clipId>.<ext>`.
  String get ruta => RutasClip.de(clipId, RutasClip.extensionDe(mime)!);

  static final _ulid = RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$');
  static final _hex64 = RegExp(r'^[0-9a-f]{64}$');

  Map<String, Object?> aPayload() => {
    'tipo': tipo,
    'duracionMs': duracionMs,
    'clipId': clipId,
    'total': total,
    'bytes': bytes,
    'mime': mime,
    'sha256': sha256,
  };

  /// El clip de un payload de `clip_grabado`, o nulo si no lo trae (eventos
  /// de antes de esta versión, clip omitido) o no cuadra.
  static MetaClip? dePayload(Map<String, Object?> p) {
    final clipId = p['clipId'];
    final total = p['total'];
    final bytes = p['bytes'];
    final mime = p['mime'];
    final sha = p['sha256'];
    final duracion = p['duracionMs'];
    if (p['omitido'] != null ||
        clipId is! String ||
        !_ulid.hasMatch(clipId) ||
        total is! int ||
        bytes is! int ||
        bytes < 1 ||
        bytes > TrozosClip.maxBytes ||
        total != TrozosClip.cuantos(bytes) ||
        mime is! String ||
        RutasClip.extensionDe(mime) == null ||
        sha is! String ||
        !_hex64.hasMatch(sha)) {
      return null;
    }
    return MetaClip(
      clipId: clipId,
      total: total,
      bytes: bytes,
      mime: mime,
      sha256: sha,
      duracionMs: duracion is num ? duracion.toInt() : 0,
      tipo: p['tipo'] is String ? p['tipo']! as String : 'video',
    );
  }

  static MetaClip? deEvento(Evento e) =>
      dePayload(EventosRepositorio.payloadDe(e));
}

/// Resultado de bajar un clip.
sealed class ResultadoBajada {
  const ResultadoBajada();
}

/// Está en este móvil, en [ruta] (relativa a [ArchivosClip]).
final class ClipListo extends ResultadoBajada {
  const ClipListo(this.ruta, this.mime);

  final String ruta;
  final String mime;
}

/// El servidor ya no lo tiene (pasaron 7 días) o nunca llegó entero.
final class ClipNoDisponible extends ResultadoBajada {
  const ClipNoDisponible();
}

/// No se pudo bajar ahora (sin red, sin servidor) o lo bajado no cuadra.
final class ClipNoSeBaja extends ResultadoBajada {
  const ClipNoSeBaja();
}

/// Vídeos y fotos de comprobación por el cartero cifrado (tabla
/// `clips_trozos`; ver `supabase/schema.sql`).
///
/// - Persona: [registrarGrabado] calcula tamaño y SHA-256, guarda el evento
///   `clip_grabado` con esos datos y deja el clip en `clips_pendientes`.
///   [subirPendientes] lo cifra por trozos y lo sube; mientras tanto el
///   sobre del evento no sale (lo retiene `ServicioSync`). Al subir el último
///   trozo se borra la fila y el archivo: ella no lo ve.
/// - Familia: [bajar] solo cuando alguien toca el clip; lo descifra, lo
///   comprueba con el hash del evento y lo deja en `Documentos/clips/`.
/// - [limpiar] borra los clips de más de 7 días que no esperan a subir.
final class ClipsCartero {
  ClipsCartero({
    required this._db,
    required this._eventos,
    required this._transporte,
    required Future<LlavesCirculo?> Function() llaves,
    required this._archivos,
    required this._reloj,
    required this._azar,
  }) : _leerLlaves = llaves;

  final AppDatabase _db;
  final EventosRepositorio _eventos;
  final SyncTransport _transporte;
  final Future<LlavesCirculo?> Function() _leerLlaves;
  final ArchivosClip _archivos;
  final Reloj _reloj;
  final Random _azar;

  bool _subiendo = false;
  final _bajando = <String, Future<ResultadoBajada>>{};

  ArchivosClip get archivos => _archivos;

  // --------------------------------------------------------------- Persona

  /// Guarda el `clip_grabado` de [clip] (grabado para la toma [tomaId]) y,
  /// si cabe, lo deja en la cola de subida. Devuelve el ulid del evento.
  ///
  /// - Más de [TrozosClip.maxBytes]: el evento lleva `omitido: 'tamaño'` y
  ///   el clip no viaja (se borra a los 7 días con [limpiar]).
  /// - Si el archivo no está o está vacío: `clip_fallido` (`error`).
  Future<String> registrarGrabado({
    required String tomaId,
    required ClipGrabado clip,
  }) async {
    final bytes = await _archivos.leer(clip.ruta);
    if (bytes == null || bytes.isEmpty) {
      return _eventos.registrar(
        TipoEvento.clipFallido,
        sujeto: tomaId,
        payload: {'motivo': MotivoClipFallido.error.nombre},
      );
    }
    final mime = RutasClip.mimeDe(clip.ruta);
    if (bytes.length > TrozosClip.maxBytes) {
      return _eventos.registrar(
        TipoEvento.clipGrabado,
        sujeto: tomaId,
        payload: {
          'tipo': clip.tipo.nombre,
          'duracionMs': clip.duracionMs,
          'bytes': bytes.length,
          'mime': mime,
          'omitido': 'tamaño',
        },
      );
    }
    final meta = MetaClip(
      clipId: Ulid.generar(_reloj, _azar),
      total: TrozosClip.cuantos(bytes.length),
      bytes: bytes.length,
      mime: mime,
      sha256: TrozosClip.sha256Hex(bytes),
      duracionMs: clip.duracionMs,
      tipo: clip.tipo.nombre,
    );
    // Con el nombre del clip: la grabación de otra toma nunca lo pisa.
    final ruta = await _archivos.mover(clip.ruta, meta.ruta)
        ? meta.ruta
        : clip.ruta;
    return _db.transaction(() async {
      final ulid = await _eventos.registrar(
        TipoEvento.clipGrabado,
        sujeto: tomaId,
        payload: meta.aPayload(),
      );
      await _db
          .into(_db.clipsPendientes)
          .insert(
            ClipsPendientesCompanion.insert(
              clipId: meta.clipId,
              eventoUlid: ulid,
              ruta: ruta,
              mime: mime,
              total: meta.total,
              bytes: meta.bytes,
              sha256: meta.sha256,
              creadoEn: _reloj.ahora().millisecondsSinceEpoch,
            ),
          );
      return ulid;
    });
  }

  /// Clips que esperan a subir, del más antiguo al más reciente.
  Future<List<ClipPendiente>> pendientes() => (_db.select(
    _db.clipsPendientes,
  )..orderBy([(t) => OrderingTerm.asc(t.creadoEn)])).get();

  /// Sube los clips pendientes. Devuelve `true` si no queda ninguno.
  ///
  /// Reanudable: antes de subir pregunta qué trozos tiene ya el servidor y
  /// solo manda los que faltan (cada vez con nonce nuevo; los que ya estaban
  /// no se tocan). Al estar todos, borra la fila (el sobre del evento queda
  /// libre para salir) y después el archivo.
  Future<bool> subirPendientes() async {
    if (_subiendo) return false;
    _subiendo = true;
    try {
      final llaves = await _llaves();
      if (llaves == null) return false;
      var todos = true;
      for (final p in await pendientes()) {
        if (!await _subir(p, llaves)) todos = false;
      }
      return todos;
    } catch (_) {
      return false;
    } finally {
      _subiendo = false;
    }
  }

  Future<bool> _subir(ClipPendiente p, LlavesCirculo llaves) async {
    final Set<int> enServidor;
    try {
      enServidor = await _transporte.trozosEnServidor(p.clipId);
    } catch (_) {
      return false;
    }
    if (_completo(enServidor, p.total)) {
      await _terminar(p);
      return true;
    }
    final bytes = await _archivos.leer(p.ruta);
    if (bytes == null ||
        bytes.length != p.bytes ||
        TrozosClip.sha256Hex(bytes) != p.sha256) {
      // El archivo se perdió o cambió: no hay nada que mandar. El evento sale
      // igual y la familia verá que el vídeo no está disponible.
      await _terminar(p);
      return true;
    }
    final trozos = TrozosClip.trocear(bytes);
    final faltan = [
      for (var n = 0; n < p.total; n++)
        if (!enServidor.contains(n)) n,
    ];
    for (var i = 0; i < faltan.length; i += TrozosClip.tamLote) {
      final lote = faltan.sublist(
        i,
        min(i + TrozosClip.tamLote, faltan.length),
      );
      final cifrados = <TrozoCifrado>[];
      for (final n in lote) {
        final sellado = await CifradoClips.cifrar(
          trozos[n],
          llaves: llaves,
          clipId: p.clipId,
          n: n,
          total: p.total,
        );
        cifrados.add(
          TrozoCifrado(
            clipId: p.clipId,
            n: n,
            total: p.total,
            nonce: sellado.nonce,
            contenido: sellado.contenido,
          ),
        );
      }
      final subidos = await _transporte.subirTrozos(p.clipId, cifrados);
      if (!lote.every(subidos.contains)) return false;
    }
    await _terminar(p);
    return true;
  }

  static bool _completo(Set<int> enServidor, int total) {
    for (var n = 0; n < total; n++) {
      if (!enServidor.contains(n)) return false;
    }
    return true;
  }

  Future<void> _terminar(ClipPendiente p) async {
    await (_db.delete(
      _db.clipsPendientes,
    )..where((t) => t.clipId.equals(p.clipId))).go();
    await _archivos.borrar(p.ruta);
  }

  // ---------------------------------------------------------------- Familia

  /// Baja, descifra y comprueba el clip de [meta], avisando con [progreso]
  /// (trozos hechos, total). Si ya está en este móvil, no baja nada. Dos
  /// llamadas a la vez para el mismo clip comparten la bajada.
  Future<ResultadoBajada> bajar(
    MetaClip meta, {
    void Function(int hechos, int total)? progreso,
  }) {
    final enCurso = _bajando[meta.clipId];
    if (enCurso != null) return enCurso;
    // Sin `=>`: `remove` devuelve este mismo futuro y `whenComplete` lo
    // esperaría (se esperaría a sí mismo).
    final f = _bajar(meta, progreso).whenComplete(() {
      _bajando.remove(meta.clipId);
    });
    return _bajando[meta.clipId] = f;
  }

  Future<ResultadoBajada> _bajar(
    MetaClip meta,
    void Function(int hechos, int total)? progreso,
  ) async {
    try {
      final ruta = meta.ruta;
      if (await _archivos.existe(ruta)) return ClipListo(ruta, meta.mime);
      final llaves = await _llaves();
      if (llaves == null) return const ClipNoSeBaja();
      final claros = <Uint8List>[];
      progreso?.call(0, meta.total);
      while (claros.length < meta.total) {
        final desde = claros.length;
        final pagina = await _transporte.bajarTrozos(
          meta.clipId,
          desde: desde,
          limite: TrozosClip.tamLote,
        );
        if (pagina.isEmpty) return const ClipNoDisponible();
        for (final t in pagina) {
          if (claros.length >= meta.total) break;
          if (t.n != claros.length) {
            // Falta un trozo (el servidor lo borró o nunca llegó).
            return const ClipNoDisponible();
          }
          if (t.clipId != meta.clipId || t.total != meta.total) {
            return const ClipNoSeBaja();
          }
          final claro = await CifradoClips.descifrar(
            nonce: t.nonce,
            contenido: t.contenido,
            llaves: llaves,
            clipId: meta.clipId,
            n: t.n,
            total: meta.total,
          );
          if (claro == null) return const ClipNoSeBaja();
          claros.add(claro);
        }
        progreso?.call(claros.length, meta.total);
        if (pagina.length < TrozosClip.tamLote && claros.length < meta.total) {
          return const ClipNoDisponible();
        }
      }
      final bytes = TrozosClip.recomponer(
        claros,
        bytes: meta.bytes,
        sha256: meta.sha256,
      );
      if (bytes == null) return const ClipNoSeBaja();
      await _archivos.escribir(ruta, bytes);
      return ClipListo(ruta, meta.mime);
    } catch (_) {
      return const ClipNoSeBaja();
    }
  }

  // ------------------------------------------------------------- Limpieza

  /// Borra los clips de este móvil de más de [RutasClip.caducidad] que no
  /// esperan a subir. Devuelve cuántos borró. Nunca lanza.
  Future<int> limpiar() async {
    try {
      final limite = _reloj.ahora().subtract(RutasClip.caducidad);
      final esperan = {for (final p in await pendientes()) p.ruta};
      var borrados = 0;
      for (final a in await _archivos.listar()) {
        if (esperan.contains(a.ruta) || !a.modificado.isBefore(limite)) {
          continue;
        }
        await _archivos.borrar(a.ruta);
        borrados++;
      }
      return borrados;
    } catch (_) {
      return 0;
    }
  }

  Future<LlavesCirculo?> _llaves() async {
    try {
      return await _leerLlaves();
    } catch (_) {
      return null;
    }
  }
}
