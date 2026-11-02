import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import '../contexto.dart';
import '../db/base_datos.dart';
import '../db/repositorios/eventos_repositorio.dart';
import 'canal_avisos.dart';

/// Envía los avisos a los familiares desde el móvil de la persona y deja
/// constancia de cada uno (`aviso_enviado`, que llega a la familia por el
/// cartero).
///
/// - Destinatarios: [destinatariosDeEscalon] con los familiares del círculo y
///   su puesto (`orden_escalado`).
/// - Nunca dos avisos iguales: el mismo motivo, origen, escalón y familiar se
///   envía una sola vez. Lo dice el evento `aviso_enviado` con resultado
///   `enviado`; mientras se envía, una reserva en `sync_estado`
///   (`aviso.<clave>`, con su caducidad en ms) impide que otro hilo (la app
///   abierta y la revisión en segundo plano de Android) lo envíe a la vez.
///   La reserva se toma con un `INSERT OR IGNORE`, atómico entre conexiones.
/// - Si falla, se apunta una sola vez (`resultado: fallido`) y se puede
///   reintentar pasados [pausaTrasFallo], mientras el aviso siga tocando.
/// - Sin clave del círculo (demo web) no hay tema: no se envía ni se apunta.
final class EnvioAvisos {
  EnvioAvisos({
    required this._db,
    required this._eventos,
    required this._canal,
    required this._reloj,
    required this._contexto,
    required this._tema,
  });

  final AppDatabase _db;
  final EventosRepositorio _eventos;
  final CanalAvisos _canal;
  final Reloj _reloj;
  final ContextoApp _contexto;
  final Future<String?> Function(String miembroId) _tema;

  /// Lo que dura una reserva mientras se envía (los reintentos del canal
  /// caben de sobra).
  static const reserva = Duration(minutes: 5);

  /// Tras un fallo, cuándo se puede volver a intentar.
  static const pausaTrasFallo = Duration(minutes: 2);

  static const _prefijo = 'aviso.';

  /// Claves enviadas (o en curso) en este proceso: ahorran consultas.
  final Set<String> _hechos = {};
  final Set<String> _enCurso = {};

  /// Clave de un envío.
  static String clave(AvisoPendiente a, String miembroId) =>
      '${a.motivo.nombre}|${a.sujeto}|${a.escalon}|$miembroId';

  /// Envía [aviso] a quien le toque. Devuelve cuántos salieron ahora. Nunca
  /// lanza.
  Future<int> enviar(AvisoPendiente aviso) async {
    var n = 0;
    try {
      final destinatarios = destinatariosDeEscalon(
        await familiares(),
        aviso.escalon,
      );
      for (final m in destinatarios) {
        if (await _enviarA(aviso, m) == ResultadoAviso.enviado) n++;
      }
    } catch (_) {
      // Un aviso nunca rompe la pantalla ni la revisión.
    }
    return n;
  }

  /// Aviso de prueba al tema de [miembroId] (desde su propio móvil). No deja
  /// evento. Nulo si este móvil no tiene la clave del círculo.
  Future<ResultadoAviso?> enviarPrueba(String miembroId) async {
    final tema = await _tema(miembroId);
    if (tema == null) return null;
    return _canal.publicar(tema: tema, prioridad: TextoAviso.prioridadPrueba);
  }

  /// Familiares del círculo con su puesto, en el orden de Círculo (puesto y
  /// nombre).
  Future<List<FamiliarAviso>> familiares() async {
    final q = _db.select(_db.miembros)
      ..where((m) => m.circuloId.equals(_contexto.circuloId))
      ..orderBy([
        (m) => OrderingTerm(
          expression: m.ordenEscalado.isNull(),
          mode: OrderingMode.asc,
        ),
        (m) => OrderingTerm.asc(m.ordenEscalado),
        (m) => OrderingTerm.asc(m.nombre),
      ]);
    return [for (final m in await q.get()) (id: m.id, orden: m.ordenEscalado)];
  }

  Future<ResultadoAviso?> _enviarA(AvisoPendiente a, String miembroId) async {
    final k = clave(a, miembroId);
    if (_hechos.contains(k) || _enCurso.contains(k)) return null;
    _enCurso.add(k);
    try {
      if (await _yaEnviado(a, miembroId)) {
        _hechos.add(k);
        return null;
      }
      if (!await _reservar(k)) return null;
      // Otro hilo pudo acabar justo antes de la reserva.
      if (await _yaEnviado(a, miembroId)) {
        _hechos.add(k);
        await _soltar(k);
        return null;
      }
      final tema = await _tema(miembroId);
      if (tema == null) {
        await _soltar(k);
        return null;
      }
      final r = await _canal.publicar(
        tema: tema,
        prioridad: a.motivo.prioridad,
      );
      if (r == ResultadoAviso.enviado) {
        await _apuntar(a, miembroId, r);
        _hechos.add(k);
        await _soltar(k);
      } else {
        if (!await _yaFallo(a, miembroId)) await _apuntar(a, miembroId, r);
        await _pausar(k);
      }
      return r;
    } finally {
      _enCurso.remove(k);
    }
  }

  Future<void> _apuntar(AvisoPendiente a, String miembroId, ResultadoAviso r) =>
      _eventos.registrar(
        TipoEvento.avisoEnviado,
        sujeto: a.sujeto,
        payload: {
          'tipo': a.motivo.nombre,
          'miembroId': miembroId,
          'canal': _canal.nombre,
          'resultado': r.nombre,
          if (a.escalon > 0) 'escalon': a.escalon,
        },
        autor: _contexto.personaId,
      );

  Future<List<Map<String, Object?>>> _apuntados(String sujeto) async {
    final filas =
        await (_db.select(_db.eventos)..where(
              (e) =>
                  e.tipo.equals(TipoEvento.avisoEnviado.nombre) &
                  e.sujeto.equals(sujeto),
            ))
            .get();
    return [for (final f in filas) EventosRepositorio.payloadDe(f)];
  }

  bool _es(Map<String, Object?> p, AvisoPendiente a, String miembroId) =>
      p['tipo'] == a.motivo.nombre &&
      p['miembroId'] == miembroId &&
      (p['escalon'] ?? 0) == a.escalon;

  Future<bool> _yaEnviado(AvisoPendiente a, String miembroId) async =>
      (await _apuntados(a.sujeto)).any(
        (p) =>
            _es(p, a, miembroId) &&
            p['resultado'] == ResultadoAviso.enviado.nombre,
      );

  Future<bool> _yaFallo(AvisoPendiente a, String miembroId) async =>
      (await _apuntados(a.sujeto)).any(
        (p) =>
            _es(p, a, miembroId) &&
            p['resultado'] == ResultadoAviso.fallido.nombre,
      );

  int get _ahoraMs => _reloj.ahora().millisecondsSinceEpoch;

  /// Toma la reserva de [k] si nadie la tiene (o caducó). Borra de paso las
  /// reservas caducadas.
  Future<bool> _reservar(String k) async {
    final ahora = _ahoraMs;
    await _db.customUpdate(
      "DELETE FROM sync_estado WHERE clave LIKE '$_prefijo%' "
      'AND CAST(valor AS INTEGER) <= ?',
      variables: [Variable.withInt(ahora)],
    );
    final n = await _db.customUpdate(
      'INSERT OR IGNORE INTO sync_estado (clave, valor) VALUES (?, ?)',
      variables: [
        Variable.withString('$_prefijo$k'),
        Variable.withString('${ahora + reserva.inMilliseconds}'),
      ],
    );
    return n == 1;
  }

  Future<void> _soltar(String k) => _db.customUpdate(
    'DELETE FROM sync_estado WHERE clave = ?',
    variables: [Variable.withString('$_prefijo$k')],
  );

  /// Tras un fallo, la reserva se queda hasta [pausaTrasFallo].
  Future<void> _pausar(String k) => _db.customUpdate(
    'UPDATE sync_estado SET valor = ? WHERE clave = ?',
    variables: [
      Variable.withString('${_ahoraMs + pausaTrasFallo.inMilliseconds}'),
      Variable.withString('$_prefijo$k'),
    ],
  );
}
