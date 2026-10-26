import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import '../../contexto.dart';
import '../base_datos.dart';

/// Hechos de solo inserción: cada cosa que pasa es un evento.
class EventosRepositorio {
  EventosRepositorio({
    required this._db,
    required this._reloj,
    required this._azar,
    required this._contexto,
    required this._autor,
  });

  final AppDatabase _db;
  final Reloj _reloj;
  final Random _azar;
  final ContextoApp _contexto;
  final String Function() _autor;

  /// Tipos que intervienen en el estado de una toma.
  static const tiposDeToma = [
    'toma_confirmada',
    'clip_grabado',
    'clip_fallido',
    'toma_cerrada_por_familiar',
    'anulacion',
  ];

  /// Inserta un evento. Dentro de una transacción de la base se une a ella.
  Future<String> registrar(
    TipoEvento tipo, {
    String? sujeto,
    Map<String, Object?> payload = const {},
    DateTime? ocurridoEn,
    String? corrigeA,
    String? autor,
  }) async {
    final ahora = _reloj.ahora();
    final ulid = Ulid.generar(_reloj, _azar);
    await _db
        .into(_db.eventos)
        .insert(
          EventosCompanion.insert(
            ulid: ulid,
            circuloId: _contexto.circuloId,
            autor: autor ?? _autor(),
            dispositivo: _contexto.dispositivoId,
            tipo: tipo.nombre,
            sujeto: Value(sujeto),
            ocurridoEn: (ocurridoEn ?? ahora).millisecondsSinceEpoch,
            registradoEn: ahora.millisecondsSinceEpoch,
            payload: Value(jsonEncode(payload)),
            corrigeA: Value(corrigeA),
          ),
        );
    return ulid;
  }

  /// `ficha_modificada` {tabla, id, antes, despues}: se escribe en la misma
  /// transacción que el cambio de la ficha.
  Future<void> fichaModificada({
    required String tabla,
    required String id,
    required Map<String, Object?>? antes,
    required Map<String, Object?>? despues,
  }) => registrar(
    TipoEvento.fichaModificada,
    sujeto: id,
    payload: {'tabla': tabla, 'id': id, 'antes': antes, 'despues': despues},
  );

  /// Eventos que cuentan para el estado de las tomas desde [desde].
  Stream<List<Evento>> observarEventosDeToma(DateTime desde) {
    final q = _db.select(_db.eventos)
      ..where(
        (e) =>
            e.tipo.isIn(tiposDeToma) &
            e.ocurridoEn.isBiggerOrEqualValue(desde.millisecondsSinceEpoch),
      )
      ..orderBy([
        (e) => OrderingTerm.asc(e.ocurridoEn),
        (e) => OrderingTerm.asc(e.ulid),
      ]);
    return q.watch();
  }

  /// Último `mensaje_familia`.
  Stream<Evento?> observarUltimoMensaje() {
    final q = _db.select(_db.eventos)
      ..where((e) => e.tipo.equals(TipoEvento.mensajeFamilia.nombre))
      ..orderBy([
        (e) => OrderingTerm.desc(e.ocurridoEn),
        (e) => OrderingTerm.desc(e.ulid),
      ])
      ..limit(1);
    return q.watchSingleOrNull();
  }

  /// Eventos de una clase, del más reciente al más antiguo.
  Future<List<Evento>> listarPorTipo(TipoEvento tipo, {int limite = 50}) {
    final q = _db.select(_db.eventos)
      ..where((e) => e.tipo.equals(tipo.nombre))
      ..orderBy([(e) => OrderingTerm.desc(e.ocurridoEn)])
      ..limit(limite);
    return q.get();
  }

  /// Convierte las filas en eventos de dominio para [estadoDeToma].
  static List<EventoToma> aEventosToma(Iterable<Evento> filas) => [
    for (final f in filas)
      if (TipoEvento.desdeNombre(f.tipo) case final tipo?)
        EventoToma(
          ulid: f.ulid,
          tipo: tipo,
          ocurridoEn: DateTime.fromMillisecondsSinceEpoch(
            f.ocurridoEn,
            isUtc: true,
          ),
          sujeto: f.sujeto,
          corrigeA: f.corrigeA,
          payload: _decodificar(f.payload),
        ),
  ];

  static Map<String, Object?> _decodificar(String json) {
    try {
      final d = jsonDecode(json);
      if (d is Map<String, dynamic>) return d;
    } catch (_) {}
    return const {};
  }

  static Map<String, Object?> payloadDe(Evento e) => _decodificar(e.payload);

  /// Eventos desde [desde] (incluido), del más antiguo al más reciente.
  /// Con [tipos], solo esos tipos (nombres guardados, p. ej. `ayuda_pedida`).
  Stream<List<Evento>> observarEventosDesde(
    DateTime desde, {
    Set<String>? tipos,
  }) {
    final q = _db.select(_db.eventos)
      ..where((e) {
        final reciente = e.ocurridoEn.isBiggerOrEqualValue(
          desde.millisecondsSinceEpoch,
        );
        return tipos == null ? reciente : reciente & e.tipo.isIn(tipos);
      })
      ..orderBy([
        (e) => OrderingTerm.asc(e.ocurridoEn),
        (e) => OrderingTerm.asc(e.ulid),
      ]);
    return q.watch();
  }

  /// Último evento de alguno de los [tipos], opcionalmente de un [autor].
  Stream<Evento?> observarUltimoEvento({
    required Set<String> tipos,
    String? autor,
  }) {
    final q = _db.select(_db.eventos)
      ..where(
        (e) => autor == null
            ? e.tipo.isIn(tipos)
            : e.tipo.isIn(tipos) & e.autor.equals(autor),
      )
      ..orderBy([
        (e) => OrderingTerm.desc(e.ocurridoEn),
        (e) => OrderingTerm.desc(e.ulid),
      ])
      ..limit(1);
    return q.watchSingleOrNull();
  }
}
