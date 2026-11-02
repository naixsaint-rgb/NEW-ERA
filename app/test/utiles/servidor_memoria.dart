import 'dart:async';

import 'package:newera/core/sync/sobre_cifrado.dart';
import 'package:newera/core/sync/sync_transport.dart';
import 'package:newera/core/sync/trozo_cifrado.dart';

/// Hace de Supabase en los tests: guarda sobres en orden, idempotente por
/// ulid, y avisa a los transportes cuando llega algo. Guarda también los
/// trozos de los clips (tabla `clips_trozos`), idempotente por (clip, n).
class ServidorMemoria {
  final List<SobreCifrado> sobres = [];

  /// Trozos por clip y número.
  final Map<String, Map<int, TrozoCifrado>> trozos = {};

  /// Filas de trozos insertadas de verdad (sin contar las repetidas).
  int trozosInsertados = 0;

  /// Peticiones de subida de trozos (cada una, un lote).
  final List<int> lotesTrozos = [];

  /// Si no es nulo, tras aceptar este número de trozos más el servidor se
  /// cae (para probar una subida cortada a medias).
  int? caerTrasTrozos;

  /// Rechaza los trozos pero acepta los sobres.
  bool rechazarTrozos = false;
  final _avisos = StreamController<void>.broadcast(sync: true);
  int _id = 0;

  /// Sin red: los envíos fallan y no se entrega nada.
  bool caido = false;

  ResultadoEnvio guardar(List<SobreCifrado> lote) {
    if (caido) throw StateError('sin_red');
    final aceptados = <String>[];
    for (final s in lote) {
      if (!sobres.any((x) => x.ulid == s.ulid)) {
        sobres.add(
          SobreCifrado(
            ulid: s.ulid,
            circuloId: s.circuloId,
            versionClave: s.versionClave,
            nonce: s.nonce,
            contenido: s.contenido,
            remitente: s.remitente,
            posicion: ++_id,
          ),
        );
      }
      aceptados.add(s.ulid);
    }
    _avisos.add(null);
    return ResultadoEnvio(aceptados: aceptados);
  }

  void guardarTrozos(List<TrozoCifrado> lote) {
    if (caido || rechazarTrozos) throw StateError('sin_red');
    lotesTrozos.add(lote.length);
    for (final t in lote) {
      final restantes = caerTrasTrozos;
      if (restantes != null) {
        if (restantes <= 0) {
          caido = true;
          throw StateError('sin_red');
        }
        caerTrasTrozos = restantes - 1;
      }
      final delClip = trozos.putIfAbsent(t.clipId, () => {});
      if (!delClip.containsKey(t.n)) {
        delClip[t.n] = t;
        trozosInsertados++;
      }
    }
  }

  Set<int> trozosDe(String clipId) {
    if (caido) throw StateError('sin_red');
    return {...?trozos[clipId]?.keys};
  }

  /// Como la limpieza de los 7 días del servidor.
  void caducar(String clipId) => trozos.remove(clipId);

  List<SobreCifrado> despuesDe(int posicion) => [
    for (final s in sobres)
      if (s.posicion! > posicion) s,
  ];

  /// Vuelve la red y avisa.
  void levantar() {
    caido = false;
    _avisos.add(null);
  }

  Stream<void> get avisos => _avisos.stream;
}

/// Transporte que habla con un [ServidorMemoria].
class TransporteMemoria implements SyncTransport {
  TransporteMemoria(this.servidor, {this.duplicar = false});

  final ServidorMemoria servidor;

  /// Entrega cada sobre dos veces (para probar la idempotencia).
  final bool duplicar;

  /// Todo lo que este transporte ha intentado enviar.
  final List<SobreCifrado> enviados = [];

  /// Peticiones de bajada de trozos.
  int bajadas = 0;

  EstadoTransporte _estado = EstadoTransporte.desconectado;
  final _abiertos = <StreamController<SobreCifrado>>{};

  @override
  EstadoTransporte get estado => _estado;

  @override
  Future<void> conectar() async => _estado = EstadoTransporte.conectado;

  @override
  Future<ResultadoEnvio> enviar(List<SobreCifrado> sobres) async {
    enviados.addAll(sobres);
    try {
      return servidor.guardar(sobres);
    } catch (_) {
      return ResultadoEnvio(rechazados: [for (final s in sobres) s.ulid]);
    }
  }

  @override
  Stream<SobreCifrado> recibidos({int desde = 0}) {
    var cursor = desde;
    late final StreamController<SobreCifrado> c;
    StreamSubscription<void>? sub;
    void volcar() {
      if (servidor.caido || c.isClosed) return;
      for (final s in servidor.despuesDe(cursor)) {
        c.add(s);
        if (duplicar) c.add(s);
        cursor = s.posicion!;
      }
    }

    c = StreamController<SobreCifrado>(
      onListen: () {
        sub = servidor.avisos.listen((_) => volcar());
        volcar();
      },
      onCancel: () {
        _abiertos.remove(c);
        return sub?.cancel();
      },
    );
    _abiertos.add(c);
    return c.stream;
  }

  @override
  Future<void> desconectar() async {
    for (final c in [..._abiertos]) {
      await c.close();
    }
    _abiertos.clear();
    _estado = EstadoTransporte.desconectado;
  }

  @override
  Future<Set<int>> subirTrozos(String clipId, List<TrozoCifrado> trozos) async {
    for (var i = 0; i < trozos.length; i += 5) {
      final lote = trozos.sublist(
        i,
        i + 5 < trozos.length ? i + 5 : trozos.length,
      );
      try {
        servidor.guardarTrozos(lote);
      } catch (_) {
        break;
      }
    }
    try {
      return servidor.trozosDe(clipId).intersection({
        for (final t in trozos) t.n,
      });
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<Set<int>> trozosEnServidor(String clipId) async =>
      servidor.trozosDe(clipId);

  @override
  Future<List<TrozoCifrado>> bajarTrozos(
    String clipId, {
    int desde = 0,
    int limite = 5,
  }) async {
    bajadas++;
    if (servidor.caido) throw StateError('sin_red');
    final delClip = servidor.trozos[clipId] ?? const {};
    final ns = delClip.keys.where((n) => n >= desde).toList()..sort();
    return [for (final n in ns.take(limite)) delClip[n]!];
  }
}
