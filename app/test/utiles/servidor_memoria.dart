import 'dart:async';

import 'package:newera/core/sync/sobre_cifrado.dart';
import 'package:newera/core/sync/sync_transport.dart';

/// Hace de Supabase en los tests: guarda sobres en orden, idempotente por
/// ulid, y avisa a los transportes cuando llega algo.
class ServidorMemoria {
  final List<SobreCifrado> sobres = [];
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
}
