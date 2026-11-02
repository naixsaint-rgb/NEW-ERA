import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
import '../../plataforma/audio/archivos_voz.dart';
import '../../sync/fichas.dart';
import '../base_datos.dart';
import 'eventos_repositorio.dart';

/// Para qué se usa una frase. El juego es fijo (semana 2 del plan v3); el
/// guion completo de 30 a 60 frases llega después.
enum UsoFrase {
  /// "`alias`, es la hora de tu pastilla": pantalla de toma y alarma.
  toma('toma'),

  /// "Muy bien": al confirmar la toma.
  muyBien('muy_bien'),

  /// Las tres preguntas de control, en orden.
  comoEstas('como_estas'),
  teDuele('te_duele'),
  queHaras('que_haras');

  const UsoFrase(this.nombre);
  final String nombre;

  static UsoFrase? desdeNombre(String? nombre) {
    for (final u in values) {
      if (u.nombre == nombre) return u;
    }
    return null;
  }
}

/// Una frase que puede sonar: su audio y de quién es la voz.
typedef FraseSonora = ({
  String ruta,
  String vozId,
  String fraseId,
  String miembroId,
  String nombre,
});

/// Qué pasó al aprobar una frase.
enum AprobacionFrase {
  /// Aprobada; sale por el cartero con su audio.
  conAudio,

  /// Aprobada, pero el audio no cabe en un sobre: sale sin él (`omitidas`).
  sinAudio,

  /// No existe o no tiene audio.
  nada,
}

/// Frase que suena para [uso]: la de [vozPreferida] (la de la pauta) si está
/// activa y tiene esa frase aprobada; si no, la de la primera voz activa del
/// círculo que la tenga, por el orden de los familiares ([miembros], ya
/// ordenados) y, en cada familiar, la voz más reciente. De cada voz, la frase
/// aprobada más reciente. Nula si no hay ninguna: entonces no suena nada.
FraseSonora? elegirFrase({
  required UsoFrase uso,
  required String? vozPreferida,
  required List<Voz> voces,
  required List<Frase> frases,
  required List<Miembro> miembros,
}) {
  final activas = [
    for (final v in voces)
      if (v.retiradaEn == null) v,
  ];
  if (activas.isEmpty) return null;
  final nombres = {for (final m in miembros) m.id: m.nombre};
  final orden = <Voz>[];
  final preferida = activas.where((v) => v.id == vozPreferida).firstOrNull;
  if (preferida != null) orden.add(preferida);
  for (final m in miembros) {
    final suyas = [
      for (final v in activas)
        if (v.miembroId == m.id && v.id != vozPreferida) v,
    ]..sort((a, b) => b.creadaEn.compareTo(a.creadaEn));
    orden.addAll(suyas);
  }
  for (final voz in orden) {
    Frase? mejor;
    for (final f in frases) {
      if (f.vozId != voz.id || f.uso != uso.nombre || !f.aprobada) continue;
      if (f.audioRuta == null) continue;
      if (mejor == null || f.creadaEn > mejor.creadaEn) mejor = f;
    }
    if (mejor != null) {
      return (
        ruta: mejor.audioRuta!,
        vozId: voz.id,
        fraseId: mejor.id,
        miembroId: voz.miembroId,
        nombre: nombres[voz.miembroId] ?? '',
      );
    }
  }
  return null;
}

/// Voces grabadas por la familia, sus frases y el consentimiento de cada
/// familiar.
///
/// - Antes de la primera grabación de un familiar se guarda su
///   consentimiento (`consentimientos`, `sobre = 'voz'`) con el texto que vio,
///   y se crea su voz (`tipo = 'grabada'`).
/// - Una frase por voz y uso: grabar otra vez sustituye el audio y la deja sin
///   aprobar. Solo las aprobadas suenan y salen por el cartero.
/// - Retirar una voz (`retirada_en`) la quita de todas partes: deja de sonar,
///   se borran sus audios y el cambio viaja a los demás móviles.
class VocesRepositorio {
  VocesRepositorio({
    required this._db,
    required this._reloj,
    required this._contexto,
    required this._eventos,
    required this._archivos,
    this._uuid = const Uuid(),
  });

  final AppDatabase _db;
  final Reloj _reloj;
  final ContextoApp _contexto;
  final EventosRepositorio _eventos;
  final ArchivosVoz _archivos;
  final Uuid _uuid;

  late final PublicadorFichas _fichas = PublicadorFichas(
    db: _db,
    eventos: _eventos,
    contexto: _contexto,
    archivos: _archivos,
  );

  int get _ahoraMs => _reloj.ahora().millisecondsSinceEpoch;

  /// Voces de los familiares de este círculo.
  Stream<List<Voz>> observarVoces() {
    final q = _db.select(_db.voces).join([
      innerJoin(_db.miembros, _db.miembros.id.equalsExp(_db.voces.miembroId)),
    ])..where(_db.miembros.circuloId.equals(_contexto.circuloId));
    return q.watch().map(
      (filas) => [for (final f in filas) f.readTable(_db.voces)],
    );
  }

  /// Frases de esas voces.
  Stream<List<Frase>> observarFrases() {
    final q = _db.select(_db.frases).join([
      innerJoin(_db.voces, _db.voces.id.equalsExp(_db.frases.vozId)),
      innerJoin(_db.miembros, _db.miembros.id.equalsExp(_db.voces.miembroId)),
    ])..where(_db.miembros.circuloId.equals(_contexto.circuloId));
    return q.watch().map(
      (filas) => [for (final f in filas) f.readTable(_db.frases)],
    );
  }

  Future<Voz?> voz(String id) =>
      (_db.select(_db.voces)..where((v) => v.id.equals(id))).getSingleOrNull();

  Future<Frase?> frase(String id) =>
      (_db.select(_db.frases)..where((f) => f.id.equals(id))).getSingleOrNull();

  /// Voz grabada activa (sin retirar) de [miembroId], la más reciente.
  Future<Voz?> vozActiva(String miembroId) =>
      (_db.select(_db.voces)
            ..where(
              (v) =>
                  v.miembroId.equals(miembroId) &
                  v.tipo.equals('grabada') &
                  v.retiradaEn.isNull(),
            )
            ..orderBy([(v) => OrderingTerm.desc(v.creadaEn)])
            ..limit(1))
          .getSingleOrNull();

  /// Guarda el consentimiento de [miembroId] con el texto exacto que vio y
  /// crea su voz grabada. Si ya tiene una activa, la devuelve sin crear otra.
  /// Deja `ficha_creada` del consentimiento y de la voz para los demás
  /// móviles. Devuelve el id de la voz.
  Future<String> otorgarConsentimiento({
    required String miembroId,
    required String textoMostrado,
  }) {
    if (textoMostrado.trim().isEmpty) {
      throw ArgumentError('texto_obligatorio');
    }
    return _db.transaction(() async {
      final ya = await vozActiva(miembroId);
      if (ya != null) return ya.id;
      final consentimientoId = _uuid.v4();
      final vozId = _uuid.v4();
      final ahora = _ahoraMs;
      await _db
          .into(_db.consentimientos)
          .insert(
            ConsentimientosCompanion.insert(
              id: consentimientoId,
              circuloId: _contexto.circuloId,
              otorgante: miembroId,
              sobre: 'voz',
              textoMostrado: textoMostrado,
              otorgadoEn: ahora,
            ),
          );
      await _db
          .into(_db.voces)
          .insert(
            VocesCompanion.insert(
              id: vozId,
              miembroId: miembroId,
              tipo: 'grabada',
              consentimientoId: Value(consentimientoId),
              creadaEn: ahora,
            ),
          );
      await _fichas.creada(TipoFicha.consentimiento, consentimientoId);
      await _fichas.creada(TipoFicha.voz, vozId);
      return vozId;
    });
  }

  /// Ruta nueva para grabar la frase [uso] de [vozId]. Cada toma va a su
  /// propio archivo: la anterior se borra al guardar la nueva.
  String rutaNueva(String vozId, UsoFrase uso) => RutasVoz.de(
    '$vozId-${uso.nombre}-$_ahoraMs-${_uuid.v4().substring(0, 8)}',
  );

  /// Guarda lo grabado en [ruta] como la frase [uso] de [vozId] (sin
  /// aprobar). Devuelve el id de la frase.
  Future<String> guardarGrabacion({
    required String vozId,
    required UsoFrase uso,
    required String texto,
    required String ruta,
  }) async {
    final viejas = <String>[];
    final id = await _db.transaction(() async {
      final v = await voz(vozId);
      if (v == null || v.retiradaEn != null) {
        throw StateError('voz_no_activa');
      }
      final actual =
          await (_db.select(_db.frases)
                ..where((f) => f.vozId.equals(vozId) & f.uso.equals(uso.nombre))
                ..orderBy([(f) => OrderingTerm.desc(f.creadaEn)])
                ..limit(1))
              .getSingleOrNull();
      if (actual == null) {
        final id = _uuid.v4();
        await _db
            .into(_db.frases)
            .insert(
              FrasesCompanion.insert(
                id: id,
                vozId: vozId,
                texto: texto,
                uso: uso.nombre,
                audioRuta: Value(ruta),
                aprobada: false,
                creadaEn: _ahoraMs,
              ),
            );
        return id;
      }
      final vieja = actual.audioRuta;
      if (vieja != null && vieja != ruta) viejas.add(vieja);
      await (_db.update(
        _db.frases,
      )..where((f) => f.id.equals(actual.id))).write(
        FrasesCompanion(
          texto: Value(texto),
          audioRuta: Value(ruta),
          aprobada: const Value(false),
          creadaEn: Value(_ahoraMs),
        ),
      );
      return actual.id;
    });
    for (final r in viejas) {
      await _archivos.borrar(r);
    }
    return id;
  }

  /// Aprueba la frase y la publica: `ficha_creada` la primera vez y
  /// `ficha_modificada` después (al aprobar una toma nueva). El audio va en
  /// base64 si cabe en un sobre; si no, sale sin él y lo anota.
  Future<AprobacionFrase> aprobar(String fraseId) => _db.transaction(() async {
    final f = await frase(fraseId);
    final ruta = f?.audioRuta;
    if (f == null || ruta == null) return AprobacionFrase.nada;
    if (!f.aprobada) {
      await (_db.update(_db.frases)..where((t) => t.id.equals(fraseId))).write(
        const FrasesCompanion(aprobada: Value(true)),
      );
    }
    final bytes = await _archivos.leer(ruta);
    final cabe =
        bytes != null &&
        bytes.isNotEmpty &&
        bytes.length <= FilasFicha.maxBytesAudio;
    if (await _fichas.publicada(fraseId)) {
      await _fichas.modificada(
        TipoFicha.frase,
        fraseId,
        tabla: 'frases',
        antes: {'aprobada': f.aprobada},
        despues: {'aprobada': true},
      );
    } else {
      await _fichas.creada(TipoFicha.frase, fraseId);
    }
    return cabe ? AprobacionFrase.conAudio : AprobacionFrase.sinAudio;
  });

  /// Retira la voz: deja de sonar, se borran sus audios de este móvil y
  /// sale `ficha_modificada` para que los demás hagan lo mismo.
  Future<void> retirar(String vozId) async {
    final borrar = await _db.transaction(() async {
      final v = await voz(vozId);
      if (v == null || v.retiradaEn != null) return const <String>[];
      final ahora = _ahoraMs;
      await (_db.update(_db.voces)..where((t) => t.id.equals(vozId))).write(
        VocesCompanion(retiradaEn: Value(ahora)),
      );
      final rutas = await quitarAudios(_db, vozId);
      await _fichas.modificada(
        TipoFicha.voz,
        vozId,
        tabla: 'voces',
        antes: {'retirada_en': null},
        despues: {'retirada_en': ahora},
      );
      return rutas;
    });
    for (final r in borrar) {
      await _archivos.borrar(r);
    }
  }

  /// Deja sin audio las frases de [vozId] y devuelve las rutas que tenían
  /// (para borrarlas fuera de la transacción).
  static Future<List<String>> quitarAudios(AppDatabase db, String vozId) async {
    final frases = await (db.select(
      db.frases,
    )..where((f) => f.vozId.equals(vozId) & f.audioRuta.isNotNull())).get();
    if (frases.isEmpty) return const [];
    await (db.update(db.frases)..where((f) => f.vozId.equals(vozId))).write(
      const FrasesCompanion(audioRuta: Value(null)),
    );
    return [for (final f in frases) f.audioRuta!];
  }

  /// Frase de [uso] que suena con la voz [vozPreferida] (o la primera del
  /// círculo), si su audio está en este móvil.
  Future<FraseSonora?> fraseSonora(UsoFrase uso, {String? vozPreferida}) async {
    final voces = await observarVoces().first;
    final frases = await observarFrases().first;
    final miembros =
        await (_db.select(_db.miembros)
              ..where((m) => m.circuloId.equals(_contexto.circuloId))
              ..orderBy([
                (m) => OrderingTerm(
                  expression: m.ordenEscalado.isNull(),
                  mode: OrderingMode.asc,
                ),
                (m) => OrderingTerm.asc(m.ordenEscalado),
                (m) => OrderingTerm.asc(m.nombre),
              ]))
            .get();
    final f = elegirFrase(
      uso: uso,
      vozPreferida: vozPreferida,
      voces: voces,
      frases: frases,
      miembros: miembros,
    );
    if (f == null || !await _archivos.existe(f.ruta)) return null;
    return f;
  }
}
