import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:safety_core/safety_core.dart';

import '../sync/reintentos.dart';

/// Lo que ve el servicio de avisos: siempre lo mismo, sin datos de nadie.
abstract final class TextoAviso {
  /// Cuerpo del aviso.
  static const cuerpo = 'NEW-ERA: hay un aviso. Abre la app.';

  /// Cabecera `Title`.
  static const titulo = 'NEW-ERA';

  /// Cabecera `Tags`: la misma en todos (una campana).
  static const etiquetas = 'bell';

  /// Cabecera `Click`: al tocar el aviso se abre la app en Hoy.
  static const enlace = 'newera://hoy';

  /// Prioridad del aviso de prueba.
  static const prioridadPrueba = 4;
}

/// Por dónde salen los avisos a los móviles de la familia.
abstract interface class CanalAvisos {
  /// Nombre guardado en `aviso_enviado` (`canal`).
  String get nombre;

  /// Publica el aviso fijo ([TextoAviso]) en [tema] con [prioridad] (1 a 5).
  /// Nunca lanza: devuelve cómo acabó.
  Future<ResultadoAviso> publicar({
    required String tema,
    required int prioridad,
  });
}

/// ntfy.sh (https://docs.ntfy.sh/publish/): `POST https://ntfy.sh/<tema>`
/// con el cuerpo y las cabeceras `Title`, `Priority`, `Tags` y `Click`. Sin
/// cuenta ni coste.
///
/// - Un envío cada vez (cola): nunca hay ráfagas.
/// - Reintentos con espera creciente ([esperaCreciente]) si no hay red o el
///   servidor falla (5xx, 408).
/// - 429 (demasiadas peticiones): ntfy.sh deja 60 de golpe y repone una cada
///   5 segundos; se espera lo que diga `Retry-After` o, si no lo dice, de 5
///   segundos en adelante, y se reintenta.
/// - Otros 4xx (tema o cabeceras no válidos): no se reintenta.
final class CanalNtfy implements CanalAvisos {
  CanalNtfy({
    http.Client? cliente,
    this.servidor = 'https://ntfy.sh',
    this.intentos = 4,
    this.esperaMinima = const Duration(seconds: 2),
    this.esperaMaxima = const Duration(seconds: 60),
    this.esperaLimite = const Duration(seconds: 5),
    this.tiempoMaximo = const Duration(seconds: 15),
    Future<void> Function(Duration)? esperar,
    Random? azar,
  }) : _cliente = cliente ?? http.Client(),
       _esperar = esperar ?? ((d) => Future<void>.delayed(d)),
       _azar = azar ?? Random();

  final http.Client _cliente;
  final String servidor;
  final int intentos;
  final Duration esperaMinima;
  final Duration esperaMaxima;

  /// Espera mínima tras un 429 sin `Retry-After`.
  final Duration esperaLimite;

  /// Tiempo máximo de cada petición.
  final Duration tiempoMaximo;
  final Future<void> Function(Duration) _esperar;
  final Random _azar;

  Future<void> _cola = Future<void>.value();

  static final _temaValido = RegExp(r'^[-_A-Za-z0-9]{1,64}$');

  @override
  String get nombre => 'ntfy';

  @override
  Future<ResultadoAviso> publicar({
    required String tema,
    required int prioridad,
  }) {
    final hecho = Completer<ResultadoAviso>();
    _cola = _cola.then((_) async {
      try {
        hecho.complete(await _publicar(tema, prioridad));
      } catch (_) {
        hecho.complete(ResultadoAviso.fallido);
      }
    });
    return hecho.future;
  }

  Future<ResultadoAviso> _publicar(String tema, int prioridad) async {
    if (!_temaValido.hasMatch(tema)) return ResultadoAviso.fallido;
    final uri = Uri.parse('$servidor/$tema');
    final cabeceras = {
      'Title': TextoAviso.titulo,
      'Priority': '${prioridad.clamp(1, 5)}',
      'Tags': TextoAviso.etiquetas,
      'Click': TextoAviso.enlace,
      'Content-Type': 'text/plain; charset=utf-8',
    };
    for (var n = 1; ; n++) {
      Duration espera;
      try {
        final r = await _cliente
            .post(uri, headers: cabeceras, body: TextoAviso.cuerpo)
            .timeout(tiempoMaximo);
        final codigo = r.statusCode;
        if (codigo >= 200 && codigo < 300) return ResultadoAviso.enviado;
        if (codigo == 429) {
          final pedida = int.tryParse(r.headers['retry-after'] ?? '');
          final base = esperaCreciente(
            n,
            minima: esperaLimite,
            maxima: esperaMaxima,
            azar: _azar,
          );
          espera = pedida != null && pedida > 0
              ? Duration(seconds: min(pedida, esperaMaxima.inSeconds))
              : base;
        } else if (codigo == 408 || codigo >= 500) {
          espera = esperaCreciente(
            n,
            minima: esperaMinima,
            maxima: esperaMaxima,
            azar: _azar,
          );
        } else {
          return ResultadoAviso.fallido;
        }
      } catch (_) {
        // Sin red, sin respuesta a tiempo o conexión cortada.
        espera = esperaCreciente(
          n,
          minima: esperaMinima,
          maxima: esperaMaxima,
          azar: _azar,
        );
      }
      if (n >= intentos) return ResultadoAviso.fallido;
      await _esperar(espera);
    }
  }
}

/// Canal de la demo web y de los tests: no sale nada a la red. Apunta cada
/// envío y responde con [respuestas] (en orden; después, [porDefecto]).
final class CanalAvisosSimulado implements CanalAvisos {
  CanalAvisosSimulado({
    List<ResultadoAviso>? respuestas,
    this.porDefecto = ResultadoAviso.enviado,
  }) : _respuestas = [...?respuestas];

  final List<ResultadoAviso> _respuestas;
  final ResultadoAviso porDefecto;

  /// Envíos apuntados, en orden.
  final List<({String tema, int prioridad})> enviados = [];

  @override
  String get nombre => 'ntfy';

  @override
  Future<ResultadoAviso> publicar({
    required String tema,
    required int prioridad,
  }) async {
    enviados.add((tema: tema, prioridad: prioridad));
    return _respuestas.isEmpty ? porDefecto : _respuestas.removeAt(0);
  }
}
