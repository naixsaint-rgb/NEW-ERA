import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
import '../../sync/fichas.dart';
import '../base_datos.dart';
import 'eventos_repositorio.dart';

/// Control por horas (plan v3, 2.4 bis): los ajustes del círculo y las
/// respuestas de la persona.
///
/// - Ajustes: una fila por círculo en `ajustes_control_horas`; la cambia la
///   familia y viaja como ficha `ajustes_control`. Sin fila, los valores por
///   defecto ([AjustesControl.porDefecto]).
/// - Respuestas: cada pregunta contestada en el móvil de la persona guarda su
///   `preguntas_control` y su `respuestas` (hechos de solo inserción) y deja
///   `pregunta_respondida` para la familia, todo en una transacción.
class ControlHorasRepositorio {
  ControlHorasRepositorio({
    required this._db,
    required this._reloj,
    required this._contexto,
    required this._eventos,
    required this._autor,
    this._uuid = const Uuid(),
  });

  final AppDatabase _db;
  final Reloj _reloj;
  final ContextoApp _contexto;
  final EventosRepositorio _eventos;

  /// Quién firma los cambios de ajustes (el familiar de este móvil).
  final String Function() _autor;
  final Uuid _uuid;

  late final PublicadorFichas _fichas = PublicadorFichas(
    db: _db,
    eventos: _eventos,
    contexto: _contexto,
  );

  static AjustesControl aAjustes(FilaAjustesControl? f) => f == null
      ? AjustesControl.porDefecto
      : AjustesControl(
          activado: f.activado,
          desde: f.desdeHora,
          hasta: f.hastaHora,
          cadaHoras: f.cadaHoras,
          activoDesde: f.activoDesde == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  f.activoDesde!,
                  isUtc: true,
                ),
        );

  SimpleSelectStatement<$AjustesControlHorasTable, FilaAjustesControl>
  _consulta() =>
      _db.select(_db.ajustesControlHoras)
        ..where((a) => a.id.equals(_contexto.circuloId));

  /// Ajustes vigentes del círculo.
  Future<AjustesControl> ajustes() async =>
      aAjustes(await _consulta().getSingleOrNull());

  Stream<AjustesControl> observarAjustes() =>
      _consulta().watchSingleOrNull().map(aAjustes);

  /// Guarda los ajustes que elige la familia y deja la ficha para los demás
  /// móviles. Al activar (o al cambiar algo estando desactivado y volver a
  /// activar) apunta desde cuándo: las rondas de antes no se esperan. No
  /// hace nada si no cambia nada; lanza [ArgumentError] si no son válidos.
  Future<void> guardarAjustes(AjustesControl nuevos) {
    if (!nuevos.valido) throw ArgumentError('ajustes_no_validos');
    return _db.transaction(() async {
      final ya = await _consulta().getSingleOrNull();
      final antes = aAjustes(ya);
      final ahora = _reloj.ahora().millisecondsSinceEpoch;
      // Desactivado → activado: empieza ahora. Si no, se conserva.
      final activoDesde = nuevos.activado && !antes.activado
          ? ahora
          : ya?.activoDesde;
      if (ya != null &&
          ya.activado == nuevos.activado &&
          ya.desdeHora == nuevos.desde &&
          ya.hastaHora == nuevos.hasta &&
          ya.cadaHoras == nuevos.cadaHoras) {
        return;
      }
      if (ya == null && nuevos == AjustesControl.porDefecto) return;
      final fila = AjustesControlHorasCompanion.insert(
        id: _contexto.circuloId,
        activado: nuevos.activado,
        desdeHora: nuevos.desde,
        hastaHora: nuevos.hasta,
        cadaHoras: nuevos.cadaHoras,
        activoDesde: Value(activoDesde),
        modificadoPor: _autor(),
        modificadoEn: ahora,
      );
      if (ya == null) {
        await _db.into(_db.ajustesControlHoras).insert(fila);
        await _fichas.creada(TipoFicha.ajustesControl, _contexto.circuloId);
        return;
      }
      await (_db.update(
        _db.ajustesControlHoras,
      )..where((a) => a.id.equals(ya.id))).write(fila);
      Map<String, Object?> valores(FilaAjustesControl? f) => {
        'activado': f?.activado,
        'desde_hora': f?.desdeHora,
        'hasta_hora': f?.hastaHora,
        'cada_horas': f?.cadaHoras,
      };
      await _fichas.modificada(
        TipoFicha.ajustesControl,
        ya.id,
        tabla: 'ajustes_control_horas',
        antes: valores(ya),
        despues: {
          'activado': nuevos.activado,
          'desde_hora': nuevos.desde,
          'hasta_hora': nuevos.hasta,
          'cada_horas': nuevos.cadaHoras,
        },
      );
    });
  }

  /// Guarda la respuesta [valor] a la pregunta [tipo] de la ronda [ronda]:
  /// la pregunta (con su [texto], la frase que sonó y cuándo se mostró), la
  /// respuesta y `pregunta_respondida` con el tiempo que tardó. Devuelve el
  /// ulid del evento.
  Future<String> responder({
    required String ronda,
    required TipoPreguntaControl tipo,
    required String valor,
    required String texto,
    required DateTime mostradaEn,
    String? fraseId,
  }) => _db.transaction(() async {
    final ahora = _reloj.ahora();
    final preguntaId = _uuid.v4();
    final persona = _contexto.personaId;
    // La frase puede no estar en este móvil (llegó sin audio y se retiró):
    // la pregunta se guarda sin ella.
    final frase = fraseId == null
        ? null
        : await (_db.select(
            _db.frases,
          )..where((f) => f.id.equals(fraseId))).getSingleOrNull();
    await _db
        .into(_db.preguntasControl)
        .insert(
          PreguntasControlCompanion.insert(
            id: preguntaId,
            personaId: persona,
            tipo: tipo.nombre,
            texto: texto,
            fraseId: Value(frase?.id),
            lanzadaEn: mostradaEn.millisecondsSinceEpoch,
            origen: 'movil',
          ),
        );
    await _db
        .into(_db.respuestas)
        .insert(
          RespuestasCompanion.insert(
            id: _uuid.v4(),
            preguntaId: preguntaId,
            valor: valor,
            respondidaEn: ahora.millisecondsSinceEpoch,
            origen: 'movil',
          ),
        );
    final tiempo = ahora.difference(mostradaEn).inMilliseconds;
    return _eventos.registrar(
      TipoEvento.preguntaRespondida,
      sujeto: ronda,
      payload: {
        'ronda': ronda,
        'tipo': tipo.nombre,
        'respuesta': valor,
        'tiempo_ms': tiempo < 0 ? 0 : tiempo,
        'origen': 'movil',
        'pregunta_id': preguntaId,
      },
      ocurridoEn: ahora,
      autor: persona,
    );
  });

  /// `true` si ya hay alguna respuesta de la ronda [ronda].
  Future<bool> contestada(String ronda) async =>
      await (_db.select(_db.eventos)
            ..where(
              (e) =>
                  e.tipo.equals(TipoEvento.preguntaRespondida.nombre) &
                  e.sujeto.equals(ronda),
            )
            ..limit(1))
          .getSingleOrNull() !=
      null;

  /// Primer `perfil_elegido` con el perfil persona: desde entonces hay un
  /// móvil de la persona que hace las rondas. Nulo si aún no hay ninguno.
  Stream<DateTime?> observarPrimerMovilPersona() {
    final q = _db.select(_db.eventos)
      ..where(
        (e) =>
            e.tipo.equals(TipoEvento.perfilElegido.nombre) &
            e.payload.like('%"perfil":"persona"%'),
      )
      ..orderBy([
        (e) => OrderingTerm.asc(e.ocurridoEn),
        (e) => OrderingTerm.asc(e.ulid),
      ])
      ..limit(1);
    return q.watchSingleOrNull().map(
      (e) => e == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(e.ocurridoEn, isUtc: true),
    );
  }
}
