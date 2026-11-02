import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

import 'config_sync.dart';
import 'reintentos.dart';
import 'sobre_cifrado.dart';
import 'sync_transport.dart';

/// Escucha los avisos del servidor en el canal [tema]. Cada elemento quiere
/// decir "puede haber sobres nuevos". Sustituible en tests.
typedef CrearAvisos = Stream<void> Function(
  SupabaseClient cliente,
  String tema,
);

/// Cartero cifrado sobre Supabase (plan gratuito), con el paquete `supabase`
/// en Dart puro: funciona igual en Android, iOS y web, no registra plugins ni
/// pide `Supabase.initialize`, y trae el protocolo de Realtime mantenido por
/// Supabase. El esquema del servidor está en `supabase/schema.sql`.
///
/// - Lectura y escritura: PostgREST sobre la tabla `sobres`, con la cabecera
///   [cabeceraToken]. Las políticas RLS solo dejan ver y dejar sobres cuyo
///   `circulo_token` coincide con ella.
/// - Avisos: Realtime Broadcast en el canal `aviso_<sha256(token)>`, que un
///   disparador del servidor toca al insertar. El aviso no lleva datos: solo
///   hace que se pida lo pendiente. Si Realtime falla, se pide cada [sondeo].
final class SupabaseTransport implements SyncTransport {
  SupabaseTransport({
    required this.config,
    required this.circuloId,
    required this._circuloToken,
    this.remitente = '',
    this._clienteHttp,
    CrearAvisos? avisos,
    this.sondeo = const Duration(minutes: 2),
    this.esperaMinima = const Duration(seconds: 2),
    this.esperaMaxima = const Duration(minutes: 5),
    this.intentos = 3,
    this.tamLote = 100,
    Random? azar,
  }) : _crearAvisos = avisos ?? avisosRealtime,
       _azar = azar ?? Random();

  static const tabla = 'sobres';
  static const cabeceraToken = 'x-circulo-token';
  static const eventoAviso = 'nuevos';

  final ConfigSync config;
  final String circuloId;
  final String remitente;
  final Duration sondeo;
  final Duration esperaMinima;
  final Duration esperaMaxima;
  final int intentos;
  final int tamLote;

  final Future<String?> Function() _circuloToken;
  final http.Client? _clienteHttp;
  final CrearAvisos _crearAvisos;
  final Random _azar;

  EstadoTransporte _estado = EstadoTransporte.desconectado;
  SupabaseClient? _cliente;
  String? _token;
  Future<void>? _conectando;

  /// Recepciones abiertas y cómo pararlas.
  final _recepciones =
      <StreamController<SobreCifrado>, Future<void> Function()>{};

  static final _tokenValido = RegExp(r'^[0-9a-f]{64}$');

  @override
  EstadoTransporte get estado => _estado;

  /// Canal de avisos del círculo con [token]: `aviso_` + SHA-256 del token en
  /// hexadecimal (el servidor calcula lo mismo en `sobres_avisar_nuevos`).
  static String temaAvisos(String token) =>
      'aviso_${crypto.sha256.convert(utf8.encode(token))}';

  /// Comprueba la configuración y prepara el cliente. No llama a la red.
  @override
  Future<void> conectar() =>
      _conectando ??= _conectar().whenComplete(() => _conectando = null);

  Future<void> _conectar() async {
    if (_cliente != null) return;
    if (!config.valida) {
      _estado = EstadoTransporte.sinConfigurar;
      return;
    }
    _estado = EstadoTransporte.conectando;
    String? token;
    try {
      token = await _circuloToken();
    } catch (_) {
      token = null;
    }
    if (token == null || !_tokenValido.hasMatch(token)) {
      _estado = EstadoTransporte.sinConfigurar;
      return;
    }
    _token = token;
    _cliente = SupabaseClient(
      config.urlLimpia,
      config.claveAnonima.trim(),
      headers: {cabeceraToken: token},
      httpClient: _clienteHttp,
      // Sin cuentas de usuario: la clave anon basta y no hay sesión que
      // refrescar.
      accessToken: () async => null,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      // Los reintentos los lleva este transporte, con espera creciente.
      postgrestOptions: const PostgrestClientOptions(
        retryEnabled: false,
        requestTimeout: Duration(seconds: 20),
      ),
    );
    _estado = EstadoTransporte.conectado;
  }

  /// Inserta en lotes de [tamLote] ignorando los ulid repetidos y después
  /// pregunta cuáles de ellos están ya en el servidor para este círculo: esos
  /// son los aceptados, aunque ya estuvieran de un envío anterior.
  @override
  Future<ResultadoEnvio> enviar(List<SobreCifrado> sobres) async {
    if (sobres.isEmpty) return const ResultadoEnvio();
    await conectar();
    final cliente = _cliente;
    final token = _token;
    if (cliente == null || token == null) {
      return ResultadoEnvio(rechazados: [for (final s in sobres) s.ulid]);
    }
    final aceptados = <String>[];
    final rechazados = <String>[];
    for (var i = 0; i < sobres.length; i += tamLote) {
      final lote = sobres.sublist(i, min(i + tamLote, sobres.length));
      final ulids = [for (final s in lote) s.ulid];
      try {
        final enServidor = await conReintentos(
          () => _enviarLote(cliente, token, lote),
          intentos: intentos,
          minima: esperaMinima,
          maxima: esperaMaxima,
          azar: _azar,
        );
        for (final u in ulids) {
          (enServidor.contains(u) ? aceptados : rechazados).add(u);
        }
      } catch (_) {
        rechazados.addAll(ulids);
      }
    }
    return ResultadoEnvio(aceptados: aceptados, rechazados: rechazados);
  }

  Future<Set<String>> _enviarLote(
    SupabaseClient cliente,
    String token,
    List<SobreCifrado> lote,
  ) async {
    try {
      await _insertar(cliente, token, lote);
    } on PostgrestException {
      // El servidor (no la red) rechazó el lote entero, por ejemplo por un
      // sobre fuera de formato: se prueba de uno en uno para que los buenos
      // no queden esperando por él. Los que fallen salen como rechazados.
      if (lote.length > 1) {
        for (final s in lote) {
          try {
            await _insertar(cliente, token, [s]);
          } on PostgrestException {
            // Queda rechazado.
          }
        }
      }
    }
    final filas = await cliente
        .from(tabla)
        .select('ulid')
        .eq('circulo_token', token)
        .inFilter('ulid', [for (final s in lote) s.ulid]);
    return {for (final f in filas) f['ulid'] as String};
  }

  /// `INSERT ... ON CONFLICT (ulid) DO NOTHING` vía PostgREST.
  Future<void> _insertar(
    SupabaseClient cliente,
    String token,
    List<SobreCifrado> sobres,
  ) => cliente
      .from(tabla)
      .upsert(
        [
          for (final s in sobres)
            {
              'ulid': s.ulid,
              'circulo_token': token,
              'remitente': s.remitente.isEmpty ? remitente : s.remitente,
              'version_clave': s.versionClave,
              'nonce': base64Encode(s.nonce),
              'contenido': base64Encode(s.contenido),
            },
        ],
        onConflict: 'ulid',
        ignoreDuplicates: true,
      );

  @override
  Stream<SobreCifrado> recibidos({int desde = 0}) {
    late final StreamController<SobreCifrado> salida;
    var cursor = desde;
    var trayendo = false;
    var otraVez = false;
    var fallos = 0;
    Timer? reloj;
    Timer? reintento;
    StreamSubscription<void>? avisos;

    Future<void> traer() async {
      if (salida.isClosed) return;
      if (trayendo) {
        otraVez = true;
        return;
      }
      trayendo = true;
      try {
        do {
          otraVez = false;
          while (!salida.isClosed) {
            final pagina = await _pagina(cursor);
            for (final s in pagina.sobres) {
              if (salida.isClosed) return;
              salida.add(s);
            }
            if (pagina.ultimo > cursor) cursor = pagina.ultimo;
            if (pagina.filas < tamLote) break;
          }
        } while (otraVez && !salida.isClosed);
        fallos = 0;
      } catch (_) {
        // Sin red o servidor caído: se vuelve a intentar, cada vez más tarde.
        fallos++;
        reintento?.cancel();
        if (!salida.isClosed) {
          reintento = Timer(
            esperaCreciente(
              fallos,
              minima: esperaMinima,
              maxima: esperaMaxima,
              azar: _azar,
            ),
            () => unawaited(traer()),
          );
        }
      } finally {
        trayendo = false;
      }
    }

    Future<void> parar() async {
      reloj?.cancel();
      reintento?.cancel();
      await avisos?.cancel();
      _recepciones.remove(salida);
    }

    salida = StreamController<SobreCifrado>(
      onListen: () async {
        _recepciones[salida] = parar;
        await conectar();
        final cliente = _cliente;
        final token = _token;
        if (cliente == null || token == null) {
          await parar();
          await salida.close();
          return;
        }
        if (salida.isClosed) return;
        try {
          avisos = _crearAvisos(
            cliente,
            temaAvisos(token),
          ).listen((_) => unawaited(traer()), onError: (_) {});
        } catch (_) {
          // Sin avisos queda el sondeo.
        }
        reloj = Timer.periodic(sondeo, (_) => unawaited(traer()));
        unawaited(traer());
      },
      onCancel: parar,
    );
    return salida.stream;
  }

  Future<({List<SobreCifrado> sobres, int ultimo, int filas})> _pagina(
    int desde,
  ) async {
    final cliente = _cliente;
    final token = _token;
    if (cliente == null || token == null) {
      throw StateError('transporte_desconectado');
    }
    final filas = await cliente
        .from(tabla)
        .select('id, ulid, remitente, version_clave, nonce, contenido')
        .eq('circulo_token', token)
        .gt('id', desde)
        .order('id', ascending: true)
        .limit(tamLote);
    final sobres = <SobreCifrado>[];
    var ultimo = desde;
    for (final f in filas) {
      final id = (f['id'] as num).toInt();
      if (id > ultimo) ultimo = id;
      try {
        sobres.add(
          SobreCifrado(
            ulid: f['ulid'] as String,
            circuloId: circuloId,
            versionClave: (f['version_clave'] as num).toInt(),
            nonce: base64Decode(f['nonce'] as String),
            contenido: base64Decode(f['contenido'] as String),
            remitente: f['remitente'] as String? ?? '',
            posicion: id,
          ),
        );
      } catch (_) {
        // Fila ilegible: se salta (descifrarla tampoco sería posible).
      }
    }
    return (sobres: sobres, ultimo: ultimo, filas: filas.length);
  }

  @override
  Future<void> desconectar() async {
    for (final MapEntry(key: salida, value: parar) in [
      ..._recepciones.entries,
    ]) {
      await parar();
      await salida.close();
    }
    _recepciones.clear();
    final cliente = _cliente;
    _cliente = null;
    _token = null;
    if (cliente != null) {
      try {
        await cliente.removeAllChannels();
      } catch (_) {}
      await cliente.dispose();
    }
    if (_estado != EstadoTransporte.sinConfigurar) {
      _estado = EstadoTransporte.desconectado;
    }
  }

  /// Avisos por Realtime Broadcast (canal público, sin datos). Al
  /// (re)suscribirse también avisa, para recoger lo que llegó sin conexión.
  static Stream<void> avisosRealtime(SupabaseClient cliente, String tema) {
    RealtimeChannel? canal;
    late final StreamController<void> c;
    c = StreamController<void>(
      onListen: () {
        canal = cliente
            .channel(tema)
            .onBroadcast(
              event: eventoAviso,
              callback: (_) {
                if (!c.isClosed) c.add(null);
              },
            )
            .subscribe((estado, _) {
              if (estado == RealtimeSubscribeStatus.subscribed && !c.isClosed) {
                c.add(null);
              }
            });
      },
      onCancel: () async {
        final k = canal;
        canal = null;
        if (k != null) {
          try {
            await cliente.removeChannel(k);
          } catch (_) {}
        }
      },
    );
    return c.stream;
  }
}
