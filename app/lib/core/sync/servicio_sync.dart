import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import '../contexto.dart';
import '../cripto/cifrado_sobres.dart';
import '../db/base_datos.dart';
import 'evento_en_sobre.dart';
import 'noop_transport.dart';
import 'reintentos.dart';
import 'sobre_cifrado.dart';
import 'sync_transport.dart';

/// Lleva los eventos de este móvil al servidor, cifrados, y trae los de los
/// demás móviles del círculo.
///
/// - Envío: al arrancar, cada vez que hay eventos nuevos y al volver a primer
///   plano ([sincronizarAhora]). Sin red, reintenta con espera creciente.
///   `sobres_enviados` dice qué está ya en el servidor.
/// - Recepción: pide al transporte lo que haya después del último sobre
///   guardado (`sync_estado`), lo descifra y lo inserta en `eventos` si el ulid
///   no estaba. Solo inserta: los disparadores de solo inserción se respetan.
///
/// Con [NoopTransport] o sin clave del círculo (demo web) no hace nada.
final class ServicioSync {
  ServicioSync({
    required this._db,
    required this._transporte,
    required Future<LlavesCirculo?> Function() llaves,
    required this._contexto,
    required this._reloj,
    this.tamLote = 50,
    this.pausaNuevos = const Duration(milliseconds: 500),
    this.esperaMinima = const Duration(seconds: 5),
    this.esperaMaxima = const Duration(minutes: 5),
    Random? azar,
  }) : _leerLlaves = llaves,
       _azar = azar ?? Random();

  /// Clave de `sync_estado` con el último `sobres.id` guardado.
  static const claveCursor = 'sobres.ultimo_recibido';

  final int tamLote;
  final Duration pausaNuevos;
  final Duration esperaMinima;
  final Duration esperaMaxima;

  final AppDatabase _db;
  final SyncTransport _transporte;
  final Future<LlavesCirculo?> Function() _leerLlaves;
  final ContextoApp _contexto;
  final Reloj _reloj;
  final Random _azar;

  LlavesCirculo? _llaves;
  bool _iniciado = false;
  bool _activo = false;
  bool _detenido = false;

  StreamSubscription<Object?>? _vigilancia;
  StreamSubscription<SobreCifrado>? _recepcion;
  int _generacion = 0;
  Future<void> _cola = Future<void>.value();
  Timer? _empujeProgramado;
  Timer? _escuchaProgramada;
  bool _empujando = false;
  bool _empujarOtraVez = false;
  int _fallosEnvio = 0;
  int _fallosRecepcion = 0;

  /// Está conectado al transporte y escuchando.
  bool get activo => _activo && !_detenido;

  /// Conecta, empieza a recibir y vigila los eventos nuevos para enviarlos.
  /// Nunca lanza: sin red o sin configuración, la app sigue en local.
  Future<void> iniciar() async {
    if (_iniciado || _detenido || _transporte is NoopTransport) return;
    _iniciado = true;
    try {
      if (await _llavesCirculo() == null || _detenido) return;
      await _transporte.conectar();
      if (_transporte.estado == EstadoTransporte.sinConfigurar || _detenido) {
        return;
      }
      _activo = true;
      await _escuchar();
      // Cualquier cambio en `eventos` (y la primera lectura) lanza un envío.
      final cuenta = _db.selectOnly(_db.eventos)
        ..addColumns([_db.eventos.ulid.count()]);
      _vigilancia = cuenta.watchSingle().listen(
        (_) => _programarEmpuje(pausaNuevos),
        onError: (Object _) {},
      );
    } catch (_) {
      // Nunca rompe el arranque.
    }
  }

  /// Al volver a primer plano: envía ya lo pendiente y, si la recepción se
  /// cortó, la reabre.
  Future<void> sincronizarAhora() async {
    if (!activo) return;
    _fallosEnvio = 0;
    _programarEmpuje(Duration.zero);
    if (_recepcion == null) {
      _escuchaProgramada?.cancel();
      await _escuchar();
    }
  }

  /// Para todo y desconecta el transporte.
  Future<void> detener() async {
    _detenido = true;
    _empujeProgramado?.cancel();
    _escuchaProgramada?.cancel();
    await _vigilancia?.cancel();
    await _recepcion?.cancel();
    _recepcion = null;
    await _cola;
    await _transporte.desconectar();
  }

  // ------------------------------------------------------------------ Envío

  /// Envía los eventos que aún no están en el servidor. Devuelve cuántos
  /// quedaron aceptados en esta llamada.
  Future<int> empujar() async {
    if (_detenido || _transporte is NoopTransport) return 0;
    if (_empujando) {
      _empujarOtraVez = true;
      return 0;
    }
    _empujando = true;
    var total = 0;
    try {
      final llaves = await _llavesCirculo();
      if (llaves == null) return 0;
      do {
        _empujarOtraVez = false;
        while (!_detenido) {
          final pendientes = await _pendientes();
          if (pendientes.isEmpty) break;
          final sobres = <SobreCifrado>[];
          for (final e in pendientes) {
            sobres.add(await _cerrar(e, llaves));
          }
          final r = await _transporte.enviar(sobres);
          if (r.aceptados.isNotEmpty) await _marcarEnServidor(r.aceptados);
          total += r.aceptados.length;
          if (r.rechazados.isNotEmpty || r.aceptados.isEmpty) {
            _reintentarEnvio();
            return total;
          }
          _fallosEnvio = 0;
        }
      } while (_empujarOtraVez && !_detenido);
    } catch (_) {
      _reintentarEnvio();
    } finally {
      _empujando = false;
    }
    return total;
  }

  void _reintentarEnvio() {
    _fallosEnvio++;
    _programarEmpuje(
      esperaCreciente(
        _fallosEnvio,
        minima: esperaMinima,
        maxima: esperaMaxima,
        azar: _azar,
      ),
    );
  }

  void _programarEmpuje(Duration espera) {
    if (_detenido) return;
    _empujeProgramado?.cancel();
    _empujeProgramado = Timer(espera, () => unawaited(empujar()));
  }

  /// Eventos de este círculo que no están en `sobres_enviados`.
  Future<List<Evento>> _pendientes() async {
    final q =
        _db.select(_db.eventos).join([
            leftOuterJoin(
              _db.sobresEnviados,
              _db.sobresEnviados.ulid.equalsExp(_db.eventos.ulid),
            ),
          ])
          ..where(
            _db.sobresEnviados.ulid.isNull() &
                _db.eventos.circuloId.equals(_contexto.circuloId),
          )
          ..orderBy([OrderingTerm.asc(_db.eventos.ulid)])
          ..limit(tamLote);
    return [for (final f in await q.get()) f.readTable(_db.eventos)];
  }

  Future<SobreCifrado> _cerrar(Evento e, LlavesCirculo llaves) async {
    final sellado = await CifradoSobres.cifrar(
      EventoEnSobre.codificar(e),
      llaves: llaves,
      ulid: e.ulid,
    );
    return SobreCifrado(
      ulid: e.ulid,
      circuloId: e.circuloId,
      versionClave: llaves.version,
      nonce: sellado.nonce,
      contenido: sellado.contenido,
      remitente: _contexto.dispositivoId,
    );
  }

  Future<void> _marcarEnServidor(List<String> ulids) {
    final ahora = _reloj.ahora().millisecondsSinceEpoch;
    return _db.batch(
      (b) => b.insertAll(_db.sobresEnviados, [
        for (final u in ulids)
          SobresEnviadosCompanion.insert(ulid: u, enviadoEn: ahora),
      ], mode: InsertMode.insertOrIgnore),
    );
  }

  // ------------------------------------------------------------- Recepción

  /// Descifra [sobre] y guarda su evento si el ulid no estaba. Devuelve si lo
  /// guardó. Lo que no se puede abrir (otra clave, alterado o de otro
  /// círculo) se descarta. En todos los casos avanza el cursor.
  Future<bool> recibir(SobreCifrado sobre) async {
    final llaves = await _llavesCirculo();
    if (llaves == null) return false;
    final evento = await _abrir(sobre, llaves);
    final ahora = _reloj.ahora().millisecondsSinceEpoch;
    return _db.transaction(() async {
      var guardado = false;
      if (evento != null) {
        final ya = await (_db.select(
          _db.eventos,
        )..where((t) => t.ulid.equals(evento.ulid))).getSingleOrNull();
        if (ya == null) {
          await _db.into(_db.eventos).insert(evento);
          guardado = true;
        }
        // Ya está en el servidor: no hay que reenviarlo.
        await _db
            .into(_db.sobresEnviados)
            .insert(
              SobresEnviadosCompanion.insert(
                ulid: evento.ulid,
                enviadoEn: ahora,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      final posicion = sobre.posicion;
      if (posicion != null && posicion > await ultimoRecibido()) {
        await _db
            .into(_db.syncEstado)
            .insertOnConflictUpdate(
              SyncEstadoCompanion.insert(
                clave: claveCursor,
                valor: '$posicion',
              ),
            );
      }
      return guardado;
    });
  }

  Future<Evento?> _abrir(SobreCifrado sobre, LlavesCirculo llaves) async {
    if (sobre.versionClave != llaves.version) return null;
    final claro = await CifradoSobres.descifrar(
      nonce: sobre.nonce,
      contenido: sobre.contenido,
      llaves: llaves,
      ulid: sobre.ulid,
    );
    if (claro == null) return null;
    final e = EventoEnSobre.decodificar(claro);
    if (e == null ||
        e.ulid != sobre.ulid ||
        e.circuloId != _contexto.circuloId) {
      return null;
    }
    return e;
  }

  /// Último `sobres.id` guardado (0 si ninguno).
  Future<int> ultimoRecibido() async {
    final f = await (_db.select(
      _db.syncEstado,
    )..where((t) => t.clave.equals(claveCursor))).getSingleOrNull();
    return int.tryParse(f?.valor ?? '') ?? 0;
  }

  Future<void> _escuchar() async {
    if (_detenido) return;
    await _recepcion?.cancel();
    final generacion = ++_generacion;
    final desde = await ultimoRecibido();
    if (_detenido || generacion != _generacion) return;
    _recepcion = _transporte
        .recibidos(desde: desde)
        .listen(
          (s) => _alRecibir(s, generacion),
          onError: (Object _) {},
          onDone: () {
            if (generacion != _generacion) return;
            _recepcion = null;
            _reintentarEscucha();
          },
        );
  }

  /// Los sobres se guardan de uno en uno y en orden. Si la base falla, se
  /// corta y se vuelve a pedir desde el último guardado: no se salta ninguno.
  void _alRecibir(SobreCifrado sobre, int generacion) {
    _cola = _cola.then((_) async {
      if (_detenido || generacion != _generacion) return;
      try {
        await recibir(sobre);
        _fallosRecepcion = 0;
      } catch (_) {
        _generacion++;
        await _recepcion?.cancel();
        _recepcion = null;
        _reintentarEscucha();
      }
    });
  }

  void _reintentarEscucha() {
    if (_detenido) return;
    _fallosRecepcion++;
    _escuchaProgramada?.cancel();
    _escuchaProgramada = Timer(
      esperaCreciente(
        _fallosRecepcion,
        minima: esperaMinima,
        maxima: esperaMaxima,
        azar: _azar,
      ),
      () => unawaited(_escuchar()),
    );
  }

  Future<LlavesCirculo?> _llavesCirculo() async {
    final actuales = _llaves;
    if (actuales != null) return actuales;
    try {
      return _llaves = await _leerLlaves();
    } catch (_) {
      return null;
    }
  }
}
