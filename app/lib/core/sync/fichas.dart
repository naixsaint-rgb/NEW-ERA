import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import '../contexto.dart';
import '../db/base_datos.dart';
import '../db/repositorios/eventos_repositorio.dart';
import '../db/repositorios/voces_repositorio.dart';
import '../plataforma/audio/archivos_voz.dart';
import 'foto_para_sobre.dart';

/// Fichas que viajan por el cartero dentro de `ficha_creada` y
/// `ficha_modificada`: `{tipo, fila: {columnas…}, omitidas?: […]}`. Las
/// frases llevan además su audio: `audio` (base64) y `audio_ext`. Los
/// ajustes del control por horas (`ajustes_control`) son una fila por
/// círculo con el id del círculo.
enum TipoFicha {
  persona('persona'),
  miembro('miembro'),
  medicamento('medicamento'),
  pauta('pauta'),
  foto('foto'),
  consentimiento('consentimiento'),
  voz('voz'),
  frase('frase'),
  ajustesControl('ajustes_control');

  const TipoFicha(this.nombre);
  final String nombre;

  static TipoFicha? desdeNombre(Object? nombre) {
    for (final t in values) {
      if (t.nombre == nombre) return t;
    }
    return null;
  }
}

/// Fila de una ficha en el formato del sobre: nombres de columna de SQL,
/// explícitos (no dependen de los que genere drift). Las fotos, en base64.
abstract final class FilasFicha {
  static Map<String, Object?> persona(Persona p) => {
    'id': p.id,
    'circulo_id': p.circuloId,
    'alias': p.alias,
    'foto_id': p.fotoId,
    'zona_horaria': p.zonaHoraria,
    'creada_en': p.creadaEn,
  };

  static Map<String, Object?> miembro(Miembro m) => {
    'id': m.id,
    'circulo_id': m.circuloId,
    'nombre': m.nombre,
    'relacion': m.relacion,
    'telefono': m.telefono,
    'foto_id': m.fotoId,
    'rol': m.rol,
    'orden_escalado': m.ordenEscalado,
    'en_mi_gente': m.enMiGente,
    'creado_en': m.creadoEn,
  };

  static Map<String, Object?> medicamento(Medicamento m) => {
    'id': m.id,
    'persona_id': m.personaId,
    'nombre': m.nombre,
    'nombre_para_persona': m.nombreParaPersona,
    'forma': m.forma,
    'color': m.color,
    'foto_caja_id': m.fotoCajaId,
    'foto_pastilla_id': m.fotoPastillaId,
    'registro_cima': m.registroCima,
    'creado_en': m.creadoEn,
    'retirado_en': m.retiradoEn,
  };

  static Map<String, Object?> pauta(Pauta p) => {
    'id': p.id,
    'pauta_id': p.pautaId,
    'version': p.version,
    'medicamento_id': p.medicamentoId,
    'persona_id': p.personaId,
    'dosis': p.dosis,
    'horas': p.horas,
    'dias_semana': p.diasSemana,
    'compartimento': p.compartimento,
    'voz_id': p.vozId,
    'comprobacion': p.comprobacion,
    'segundos_video': p.segundosVideo,
    'zona_horaria': p.zonaHoraria,
    'vigente_desde': p.vigenteDesde,
    'activa': p.activa,
    'motivo': p.motivo,
    'creada_por': p.creadaPor,
    'creada_en': p.creadaEn,
  };

  static Map<String, Object?> foto(String id, FotoSobre f, int creadaEn) => {
    'id': id,
    'mime': f.mime,
    'creada_en': creadaEn,
    'bytes': base64Encode(f.bytes),
  };

  static Map<String, Object?> consentimiento(Consentimiento c) => {
    'id': c.id,
    'circulo_id': c.circuloId,
    'otorgante': c.otorgante,
    'en_nombre_de': c.enNombreDe,
    'sobre': c.sobre,
    'texto_mostrado': c.textoMostrado,
    'documento_foto_id': c.documentoFotoId,
    'otorgado_en': c.otorgadoEn,
    'revoca_a': c.revocaA,
  };

  static Map<String, Object?> voz(Voz v) => {
    'id': v.id,
    'miembro_id': v.miembroId,
    'tipo': v.tipo,
    'modelo': v.modelo,
    'consentimiento_id': v.consentimientoId,
    'creada_en': v.creadaEn,
    'retirada_en': v.retiradaEn,
  };

  /// Sin `audio_ruta`: la ruta es de cada móvil. El audio va aparte.
  static Map<String, Object?> frase(Frase f) => {
    'id': f.id,
    'voz_id': f.vozId,
    'texto': f.texto,
    'uso': f.uso,
    'aprobada': f.aprobada,
    'creada_en': f.creadaEn,
  };

  static Map<String, Object?> ajustesControl(FilaAjustesControl a) => {
    'id': a.id,
    'activado': a.activado,
    'desde_hora': a.desdeHora,
    'hasta_hora': a.hastaHora,
    'cada_horas': a.cadaHoras,
    'activo_desde': a.activoDesde,
    'modificado_por': a.modificadoPor,
    'modificado_en': a.modificadoEn,
  };

  /// Tope del audio de una frase dentro de un sobre: el mismo que el de las
  /// fotos (va en base64 dentro del evento; ver `FotoParaSobre`). A
  /// 32 kbps, 8 s son unos 34 KB.
  static const maxBytesAudio = FotoParaSobre.maxBytes;

  /// Columnas de foto (opcionales) de cada tipo.
  static const columnasFoto = <TipoFicha, List<String>>{
    TipoFicha.persona: ['foto_id'],
    TipoFicha.miembro: ['foto_id'],
    TipoFicha.medicamento: ['foto_caja_id', 'foto_pastilla_id'],
    TipoFicha.consentimiento: ['documento_foto_id'],
  };
}

typedef _FilaFicha = ({
  Map<String, Object?> fila,
  List<String> omitidas,
  Map<String, Object?> extra,
});

/// Deja los eventos de ficha de este móvil para que lleguen a los demás.
final class PublicadorFichas {
  PublicadorFichas({
    required this._db,
    required this._eventos,
    required this._contexto,
    this._archivos,
  });

  final AppDatabase _db;
  final EventosRepositorio _eventos;
  final ContextoApp _contexto;

  /// De dónde se leen los audios de las frases (sin él, salen sin audio).
  final ArchivosVoz? _archivos;

  /// `ficha_creada` con la fila [id] de [tipo] tal como está ahora. Una foto
  /// que no se puede reducir no se publica (devuelve `false`); las fichas que
  /// la usan viajan sin ella y la anotan en `omitidas`.
  Future<bool> creada(TipoFicha tipo, String id) async {
    final f = await _fila(tipo, id);
    if (f == null) return false;
    await _eventos.registrar(
      TipoEvento.fichaCreada,
      sujeto: id,
      payload: _payload(tipo, f),
    );
    return true;
  }

  /// `ficha_modificada` con antes y después (como hasta ahora) y, además, el
  /// tipo y la fila entera para los demás móviles.
  Future<void> modificada(
    TipoFicha tipo,
    String id, {
    required String tabla,
    required Map<String, Object?>? antes,
    required Map<String, Object?>? despues,
  }) async {
    final f = await _fila(tipo, id);
    await _eventos.fichaModificada(
      tabla: tabla,
      id: id,
      antes: antes,
      despues: despues,
      extra: f == null ? const {} : _payload(tipo, f),
    );
  }

  /// Publica las fichas que aún no tienen `ficha_creada` (las de antes del
  /// emparejamiento): fotos, persona, familiares, consentimientos de voz,
  /// voces, frases aprobadas, medicamentos, pautas y ajustes del control por
  /// horas, en ese orden para que al otro lado existan las referencias. En un círculo que vino de fuera, la
  /// persona sin ficha es la provisional: no se publica. Devuelve cuántas
  /// publicó.
  Future<int> pendientes() => _db.transaction(() async {
    final consulta = _db.selectOnly(_db.eventos)
      ..addColumns([_db.eventos.sujeto])
      ..where(_db.eventos.tipo.equals(TipoEvento.fichaCreada.nombre));
    final publicadas = {
      for (final f in await consulta.get()) f.read(_db.eventos.sujeto),
    };
    var n = 0;
    Future<void> una(TipoFicha tipo, String? id) async {
      if (id == null || publicadas.contains(id)) return;
      publicadas.add(id);
      if (await creada(tipo, id)) n++;
    }

    final personas = await (_db.select(
      _db.personas,
    )..where((p) => p.circuloId.equals(_contexto.circuloId))).get();
    final miembros = await (_db.select(
      _db.miembros,
    )..where((m) => m.circuloId.equals(_contexto.circuloId))).get();
    final medicamentos =
        await (_db.select(_db.medicamentos)
              ..where((m) => m.personaId.isIn([for (final p in personas) p.id]))
              ..orderBy([(m) => OrderingTerm.asc(m.creadoEn)]))
            .get();
    final pautas =
        await (_db.select(_db.pautas)
              ..where(
                (p) =>
                    p.medicamentoId.isIn([for (final m in medicamentos) m.id]),
              )
              ..orderBy([
                (p) => OrderingTerm.asc(p.pautaId),
                (p) => OrderingTerm.asc(p.version),
              ]))
            .get();

    for (final id in [
      for (final p in personas) p.fotoId,
      for (final m in miembros) m.fotoId,
      for (final m in medicamentos) ...[m.fotoCajaId, m.fotoPastillaId],
    ]) {
      await una(TipoFicha.foto, id);
    }
    if (!_contexto.circuloExterno) {
      for (final p in personas) {
        await una(TipoFicha.persona, p.id);
      }
    }
    for (final m in miembros) {
      await una(TipoFicha.miembro, m.id);
    }
    final consentimientos =
        await (_db.select(_db.consentimientos)
              ..where(
                (c) =>
                    c.circuloId.equals(_contexto.circuloId) &
                    c.sobre.equals('voz'),
              )
              ..orderBy([(c) => OrderingTerm.asc(c.otorgadoEn)]))
            .get();
    for (final c in consentimientos) {
      await una(TipoFicha.consentimiento, c.id);
    }
    final voces =
        await (_db.select(_db.voces)
              ..where((v) => v.miembroId.isIn([for (final m in miembros) m.id]))
              ..orderBy([(v) => OrderingTerm.asc(v.creadaEn)]))
            .get();
    for (final v in voces) {
      await una(TipoFicha.voz, v.id);
    }
    final frases =
        await (_db.select(_db.frases)
              ..where(
                (f) =>
                    f.vozId.isIn([for (final v in voces) v.id]) &
                    f.aprobada.equals(true),
              )
              ..orderBy([(f) => OrderingTerm.asc(f.creadaEn)]))
            .get();
    for (final f in frases) {
      await una(TipoFicha.frase, f.id);
    }
    for (final m in medicamentos) {
      await una(TipoFicha.medicamento, m.id);
    }
    for (final p in pautas) {
      await una(TipoFicha.pauta, p.id);
    }
    final ajustes = await (_db.select(
      _db.ajustesControlHoras,
    )..where((a) => a.id.equals(_contexto.circuloId))).getSingleOrNull();
    if (ajustes != null) await una(TipoFicha.ajustesControl, ajustes.id);
    return n;
  });

  static Map<String, Object?> _payload(TipoFicha tipo, _FilaFicha f) => {
    'tipo': tipo.nombre,
    'fila': f.fila,
    if (f.omitidas.isNotEmpty) 'omitidas': f.omitidas,
    ...f.extra,
  };

  Future<_FilaFicha?> _fila(TipoFicha tipo, String id) async {
    final Map<String, Object?> fila;
    final omitidas = <String>[];
    final extra = <String, Object?>{};
    switch (tipo) {
      case TipoFicha.foto:
        final f = await (_db.select(
          _db.fotos,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        final reducida = f == null
            ? null
            : FotoParaSobre.reducir(f.bytes, f.mime);
        if (f == null || reducida == null) return null;
        return (
          fila: FilasFicha.foto(id, reducida, f.creadaEn),
          omitidas: const <String>[],
          extra: const <String, Object?>{},
        );
      case TipoFicha.persona:
        final p = await (_db.select(
          _db.personas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (p == null) return null;
        fila = FilasFicha.persona(p);
      case TipoFicha.miembro:
        final m = await (_db.select(
          _db.miembros,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (m == null) return null;
        fila = FilasFicha.miembro(m);
      case TipoFicha.medicamento:
        final m = await (_db.select(
          _db.medicamentos,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (m == null) return null;
        fila = FilasFicha.medicamento(m);
      case TipoFicha.pauta:
        final p = await (_db.select(
          _db.pautas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (p == null) return null;
        fila = FilasFicha.pauta(p);
      case TipoFicha.consentimiento:
        final c = await (_db.select(
          _db.consentimientos,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (c == null) return null;
        fila = FilasFicha.consentimiento(c);
      case TipoFicha.voz:
        final v = await (_db.select(
          _db.voces,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (v == null) return null;
        fila = FilasFicha.voz(v);
      case TipoFicha.frase:
        final f = await (_db.select(
          _db.frases,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (f == null) return null;
        fila = FilasFicha.frase(f);
        final ruta = f.audioRuta;
        final bytes = ruta == null ? null : await _archivos?.leer(ruta);
        if (ruta != null &&
            bytes != null &&
            bytes.isNotEmpty &&
            bytes.length <= FilasFicha.maxBytesAudio) {
          extra['audio'] = base64Encode(bytes);
          extra['audio_ext'] = ruta.substring(ruta.lastIndexOf('.') + 1);
        } else {
          // No cabe en un sobre (o no está): la frase viaja sin audio.
          omitidas.add('audio');
        }
      case TipoFicha.ajustesControl:
        final a = await (_db.select(
          _db.ajustesControlHoras,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        if (a == null) return null;
        fila = FilasFicha.ajustesControl(a);
    }
    for (final columna in FilasFicha.columnasFoto[tipo] ?? const <String>[]) {
      final fotoId = fila[columna];
      if (fotoId is String && !await publicada(fotoId)) {
        fila[columna] = null;
        omitidas.add(columna);
      }
    }
    return (fila: fila, omitidas: omitidas, extra: extra);
  }

  /// Ya salió una `ficha_creada` con este id.
  Future<bool> publicada(String id) async =>
      await (_db.select(_db.eventos)
            ..where(
              (e) =>
                  e.sujeto.equals(id) &
                  e.tipo.equals(TipoEvento.fichaCreada.nombre),
            )
            ..limit(1))
          .getSingleOrNull() !=
      null;
}

enum _Resultado {
  /// Está tal cual en la base (o ya estaba).
  aplicada,

  /// Está, pero le falta alguna foto que aún no ha llegado.
  incompleta,

  /// No se pudo guardar: falta una referencia obligatoria (p. ej. la pauta
  /// llegó antes que su medicamento).
  pendiente,

  /// No vale (formato, otro círculo, versión de pauta repetida…).
  descartada,
}

/// Lee los campos de una fila recibida; si falta uno obligatorio o tiene otro
/// tipo, [valida] pasa a `false`.
final class _Campos {
  _Campos(this._m);

  final Map<String, dynamic> _m;
  bool valida = true;

  String txt(String k) {
    final v = _m[k];
    if (v is String) return v;
    valida = false;
    return '';
  }

  String? txtONulo(String k) {
    final v = _m[k];
    if (v == null || v is String) return v as String?;
    valida = false;
    return null;
  }

  int ent(String k) {
    final v = _m[k];
    if (v is int) return v;
    valida = false;
    return 0;
  }

  int? entONulo(String k) {
    final v = _m[k];
    if (v == null || v is int) return v as int?;
    valida = false;
    return null;
  }

  bool logico(String k) {
    final v = _m[k];
    if (v is bool) return v;
    valida = false;
    return false;
  }
}

/// Convierte en filas las fichas que llegan por el cartero.
///
/// - Inserta la fila si no existe (idempotente por id; las pautas, por id de
///   versión). Fotos y pautas son hechos de solo inserción: nunca se cambian.
/// - Persona, familiar y medicamento admiten cambios: `ficha_modificada` los
///   actualiza si no hay otra ficha de esa fila más reciente (gana el cambio
///   más nuevo, llegue en el orden que llegue). Una `ficha_creada` sobre una
///   fila que ya existe solo la pisa si es la primera para ese id (la fila
///   provisional del emparejamiento).
/// - Si falta una referencia obligatoria, la ficha queda pendiente en
///   `sync_estado` y se repasa cada vez que se aplica otra. Si falta una foto,
///   la fila se guarda sin ella y se completa cuando llegue.
/// - Voces y frases: la voz espera a su familiar y a su consentimiento; la
///   frase, a su voz. El audio de la frase se guarda en la carpeta de voces
///   de este móvil ([ArchivosVoz]) y la fila, con su ruta local. Una voz
///   retirada no vuelve atrás: sus audios se borran y sus frases dejan de
///   sonar.
/// - Ajustes del control por horas: una fila por círculo (su id es el del
///   círculo). Gana el cambio más reciente (`modificado_en`), llegue en el
///   orden que llegue; los valores fuera de rango se descartan.
/// - Nunca lanza: un sobre raro no puede atascar la recepción.
final class MaterializadorFichas {
  MaterializadorFichas(this._db, this._contexto, [this._archivos]);

  final AppDatabase _db;
  final ContextoApp _contexto;

  /// Dónde se guardan los audios recibidos (sin él, las frases se guardan
  /// sin audio).
  final ArchivosVoz? _archivos;

  /// Ids que pueden formar parte del nombre de un archivo.
  static final _idSeguro = RegExp(r'^[A-Za-z0-9-]{1,64}$');
  static final _extSegura = RegExp(r'^[a-z0-9]{1,5}$');

  /// Clave de `sync_estado` con las fichas pendientes: `p:<ulid>` (sin
  /// guardar) o `i:<ulid>` (guardada sin alguna foto).
  static const clavePendientes = 'fichas.pendientes';
  static const maxPendientes = 500;

  static bool esFicha(String tipo) =>
      tipo == TipoEvento.fichaCreada.nombre ||
      tipo == TipoEvento.fichaModificada.nombre;

  /// [e] acaba de guardarse en `eventos`, dentro de la misma transacción.
  Future<void> alRecibir(Evento e) async {
    if (!esFicha(e.tipo)) return;
    try {
      final r = await _aplicar(e, soloFotos: false);
      if (r == _Resultado.descartada) return;
      final antes = await pendientes();
      var lista = antes;
      if (lista.isNotEmpty &&
          (r == _Resultado.aplicada || r == _Resultado.incompleta)) {
        lista = await _repasar(lista);
      }
      if (r == _Resultado.pendiente) lista = [...lista, 'p:${e.ulid}'];
      if (r == _Resultado.incompleta) lista = [...lista, 'i:${e.ulid}'];
      if (lista.length > maxPendientes) {
        lista = lista.sublist(lista.length - maxPendientes);
      }
      if (!_mismas(antes, lista)) await _guardar(lista);
    } catch (_) {
      // Se queda el evento; la ficha no se aplica.
    }
  }

  /// Fichas pendientes (ver [clavePendientes]).
  Future<List<String>> pendientes() async {
    final f = await (_db.select(
      _db.syncEstado,
    )..where((t) => t.clave.equals(clavePendientes))).getSingleOrNull();
    if (f == null) return const [];
    try {
      return [
        for (final x in jsonDecode(f.valor) as List<dynamic>) x as String,
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> _guardar(List<String> lista) async {
    if (lista.isEmpty) {
      await (_db.delete(
        _db.syncEstado,
      )..where((t) => t.clave.equals(clavePendientes))).go();
      return;
    }
    await _db
        .into(_db.syncEstado)
        .insertOnConflictUpdate(
          SyncEstadoCompanion.insert(
            clave: clavePendientes,
            valor: jsonEncode(lista),
          ),
        );
  }

  static bool _mismas(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<List<String>> _repasar(List<String> lista) async {
    var quedan = lista;
    var avance = true;
    while (avance && quedan.isNotEmpty) {
      avance = false;
      final siguen = <String>[];
      for (final entrada in quedan) {
        if (entrada.length < 3) continue;
        final soloFotos = entrada.startsWith('i:');
        final ulid = entrada.substring(2);
        final e = await (_db.select(
          _db.eventos,
        )..where((t) => t.ulid.equals(ulid))).getSingleOrNull();
        if (e == null) continue;
        final r = await _aplicar(e, soloFotos: soloFotos);
        switch (r) {
          case _Resultado.aplicada:
            avance = true;
          case _Resultado.descartada:
            break;
          case _Resultado.pendiente:
            siguen.add('p:$ulid');
          case _Resultado.incompleta:
            if (!soloFotos) avance = true;
            siguen.add('i:$ulid');
        }
      }
      quedan = siguen;
    }
    return quedan;
  }

  Future<_Resultado> _aplicar(Evento e, {required bool soloFotos}) async {
    final payload = EventosRepositorio.payloadDe(e);
    final tipo = TipoFicha.desdeNombre(payload['tipo']);
    final fila = payload['fila'];
    if (tipo == null || fila is! Map<String, dynamic>) {
      return _Resultado.descartada;
    }
    final id = fila['id'];
    if (id is! String || id != e.sujeto) return _Resultado.descartada;
    final creada = e.tipo == TipoEvento.fichaCreada.nombre;
    final c = _Campos(fila);
    return switch (tipo) {
      TipoFicha.foto => _foto(id, c),
      TipoFicha.pauta => _pauta(id, c),
      TipoFicha.persona => _persona(e, id, c, creada, soloFotos),
      TipoFicha.miembro => _miembro(e, id, c, creada, soloFotos),
      TipoFicha.medicamento => _medicamento(e, id, c, creada, soloFotos),
      TipoFicha.consentimiento => _consentimiento(id, c),
      TipoFicha.voz => _voz(e, id, c, creada),
      TipoFicha.frase => _frase(e, id, c, creada, payload),
      TipoFicha.ajustesControl => _ajustesControl(id, c),
    };
  }

  // ------------------------------------------------------- Hechos

  Future<_Resultado> _foto(String id, _Campos c) async {
    if (await _existe(_db.fotos, id)) return _Resultado.aplicada;
    final mime = c.txt('mime');
    final creadaEn = c.ent('creada_en');
    final b64 = c.txt('bytes');
    if (!c.valida) return _Resultado.descartada;
    final Uint8List bytes;
    try {
      bytes = base64Decode(b64);
    } catch (_) {
      return _Resultado.descartada;
    }
    await _db
        .into(_db.fotos)
        .insert(
          FotosCompanion.insert(
            id: id,
            bytes: bytes,
            mime: mime,
            creadaEn: creadaEn,
          ),
        );
    return _Resultado.aplicada;
  }

  Future<_Resultado> _pauta(String id, _Campos c) async {
    if (await _existe(_db.pautas, id)) return _Resultado.aplicada;
    final fila = PautasCompanion.insert(
      id: id,
      pautaId: c.txt('pauta_id'),
      version: c.ent('version'),
      medicamentoId: c.txt('medicamento_id'),
      personaId: c.txt('persona_id'),
      dosis: c.txt('dosis'),
      horas: c.txt('horas'),
      diasSemana: Value(c.ent('dias_semana')),
      compartimento: Value(c.txtONulo('compartimento')),
      vozId: Value(c.txtONulo('voz_id')),
      comprobacion: Value(c.txt('comprobacion')),
      segundosVideo: Value(c.ent('segundos_video')),
      zonaHoraria: c.txt('zona_horaria'),
      vigenteDesde: c.ent('vigente_desde'),
      activa: c.logico('activa'),
      motivo: Value(c.txtONulo('motivo')),
      creadaPor: c.txt('creada_por'),
      creadaEn: c.ent('creada_en'),
    );
    if (!c.valida) return _Resultado.descartada;
    // Otra versión con el mismo número (cambios a la vez en dos móviles): se
    // queda la que ya estaba.
    final repetida =
        await (_db.select(_db.pautas)
              ..where(
                (p) =>
                    p.pautaId.equals(fila.pautaId.value) &
                    p.version.equals(fila.version.value),
              )
              ..limit(1))
            .getSingleOrNull();
    if (repetida != null) return _Resultado.descartada;
    if (!await _existe(_db.medicamentos, fila.medicamentoId.value) ||
        !await _existe(_db.personas, fila.personaId.value)) {
      return _Resultado.pendiente;
    }
    // Una pauta nunca espera a su voz: si aún no ha llegado, se guarda sin
    // ella y la toma usa la primera voz del círculo.
    final voz = fila.vozId.value;
    final sinVoz = voz != null && !await _existe(_db.voces, voz);
    await _db
        .into(_db.pautas)
        .insert(sinVoz ? fila.copyWith(vozId: const Value(null)) : fila);
    return _Resultado.aplicada;
  }

  /// Consentimiento: hecho de solo inserción.
  Future<_Resultado> _consentimiento(String id, _Campos c) async {
    if (await _existe(_db.consentimientos, id)) return _Resultado.aplicada;
    final circulo = c.txt('circulo_id');
    var foto = c.txtONulo('documento_foto_id');
    final fila = ConsentimientosCompanion.insert(
      id: id,
      circuloId: circulo,
      otorgante: c.txt('otorgante'),
      enNombreDe: Value(c.txtONulo('en_nombre_de')),
      sobre: c.txt('sobre'),
      textoMostrado: c.txt('texto_mostrado'),
      otorgadoEn: c.ent('otorgado_en'),
      revocaA: Value(c.txtONulo('revoca_a')),
    );
    if (!c.valida || circulo != _contexto.circuloId) {
      return _Resultado.descartada;
    }
    if (!await _existe(_db.circulos, circulo)) return _Resultado.pendiente;
    // Es un hecho: no se puede completar después. Sin la foto del documento,
    // se guarda sin ella.
    if (foto != null && !await _existe(_db.fotos, foto)) foto = null;
    await _db
        .into(_db.consentimientos)
        .insert(fila.copyWith(documentoFotoId: Value(foto)));
    return _Resultado.aplicada;
  }

  // ------------------------------------------------------- Fichas

  /// Ajustes del control por horas: gana el más reciente.
  Future<_Resultado> _ajustesControl(String id, _Campos c) async {
    final fila = AjustesControlHorasCompanion.insert(
      id: id,
      activado: c.logico('activado'),
      desdeHora: c.ent('desde_hora'),
      hastaHora: c.ent('hasta_hora'),
      cadaHoras: c.ent('cada_horas'),
      activoDesde: Value(c.entONulo('activo_desde')),
      modificadoPor: c.txt('modificado_por'),
      modificadoEn: c.ent('modificado_en'),
    );
    if (!c.valida || id != _contexto.circuloId) return _Resultado.descartada;
    final valores = AjustesControl(
      desde: fila.desdeHora.value,
      hasta: fila.hastaHora.value,
      cadaHoras: fila.cadaHoras.value,
    );
    if (!valores.valido) return _Resultado.descartada;
    if (!await _existe(_db.circulos, id)) return _Resultado.pendiente;
    final ya = await (_db.select(
      _db.ajustesControlHoras,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (ya == null) {
      await _db.into(_db.ajustesControlHoras).insert(fila);
    } else if (fila.modificadoEn.value >= ya.modificadoEn) {
      await (_db.update(
        _db.ajustesControlHoras,
      )..where((t) => t.id.equals(id))).write(fila);
    }
    return _Resultado.aplicada;
  }

  Future<_Resultado> _voz(Evento e, String id, _Campos c, bool creada) async {
    final miembro = c.txt('miembro_id');
    final consentimiento = c.txtONulo('consentimiento_id');
    final retiradaEn = c.entONulo('retirada_en');
    final fila = VocesCompanion(
      id: Value(id),
      miembroId: Value(miembro),
      tipo: Value(c.txt('tipo')),
      modelo: Value(c.txtONulo('modelo')),
      consentimientoId: Value(consentimiento),
      creadaEn: Value(c.ent('creada_en')),
    );
    if (!c.valida) return _Resultado.descartada;
    if (!await _existe(_db.miembros, miembro) ||
        (consentimiento != null &&
            !await _existe(_db.consentimientos, consentimiento))) {
      return _Resultado.pendiente;
    }
    final ya = await (_db.select(
      _db.voces,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    // Retirar no tiene vuelta atrás.
    final retirada = ya?.retiradaEn ?? retiradaEn;
    final completa = fila.copyWith(retiradaEn: Value(retirada));
    if (ya == null) {
      await _db.into(_db.voces).insert(completa);
    } else if (!creada || await _primeraAlta(e)) {
      await (_db.update(
        _db.voces,
      )..where((t) => t.id.equals(id))).write(completa);
    } else {
      return _Resultado.aplicada;
    }
    if (retirada != null) {
      for (final ruta in await VocesRepositorio.quitarAudios(_db, id)) {
        await _archivos?.borrar(ruta);
      }
    }
    return _Resultado.aplicada;
  }

  Future<_Resultado> _frase(
    Evento e,
    String id,
    _Campos c,
    bool creada,
    Map<String, Object?> payload,
  ) async {
    final vozId = c.txt('voz_id');
    final creadaEn = c.ent('creada_en');
    final fila = FrasesCompanion(
      id: Value(id),
      vozId: Value(vozId),
      texto: Value(c.txt('texto')),
      uso: Value(c.txt('uso')),
      aprobada: Value(c.logico('aprobada')),
      creadaEn: Value(creadaEn),
    );
    if (!c.valida || !_idSeguro.hasMatch(id)) return _Resultado.descartada;
    final voz = await (_db.select(
      _db.voces,
    )..where((t) => t.id.equals(vozId))).getSingleOrNull();
    if (voz == null) return _Resultado.pendiente;
    final ya = await (_db.select(
      _db.frases,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (ya != null && creada && !await _primeraAlta(e)) {
      return _Resultado.aplicada;
    }
    // El audio de esta toma de la frase, si viene y la voz sigue activa. Si
    // no viene (no cabía), la frase se queda sin audio: el de una toma
    // anterior ya no es el aprobado.
    String? ruta;
    final archivos = _archivos;
    final b64 = payload['audio'];
    if (archivos != null && voz.retiradaEn == null && b64 is String) {
      try {
        final bytes = base64Decode(b64);
        final pedida = payload['audio_ext'];
        final ext = pedida is String && _extSegura.hasMatch(pedida)
            ? pedida
            : RutasVoz.extension;
        if (bytes.isNotEmpty) {
          final destino = RutasVoz.de('$id-$creadaEn', ext: ext);
          await archivos.escribir(destino, bytes);
          ruta = destino;
        }
      } catch (_) {
        ruta = null;
      }
    }
    final completa = fila.copyWith(audioRuta: Value(ruta));
    if (ya == null) {
      await _db.into(_db.frases).insert(completa);
    } else {
      await (_db.update(
        _db.frases,
      )..where((t) => t.id.equals(id))).write(completa);
      final vieja = ya.audioRuta;
      if (vieja != null && vieja != ruta) await archivos?.borrar(vieja);
    }
    return _Resultado.aplicada;
  }

  Future<_Resultado> _persona(
    Evento e,
    String id,
    _Campos c,
    bool creada,
    bool soloFotos,
  ) async {
    final circulo = c.txt('circulo_id');
    final foto = c.txtONulo('foto_id');
    final fila = PersonasCompanion(
      id: Value(id),
      circuloId: Value(circulo),
      alias: Value(c.txt('alias')),
      zonaHoraria: Value(c.txt('zona_horaria')),
      creadaEn: Value(c.ent('creada_en')),
    );
    if (!c.valida || circulo != _contexto.circuloId) {
      return _Resultado.descartada;
    }
    return _mutable(
      e: e,
      tabla: _db.personas,
      id: id,
      creada: creada,
      soloFotos: soloFotos,
      fotos: {'foto_id': foto},
      requisitos: () => _existe(_db.circulos, circulo),
      guardar: (insertar, faltan) async {
        final completa = fila.copyWith(
          fotoId: Value(faltan.contains('foto_id') ? null : foto),
        );
        if (insertar) {
          await _db.into(_db.personas).insert(completa);
        } else {
          await (_db.update(
            _db.personas,
          )..where((t) => t.id.equals(id))).write(completa);
        }
      },
    );
  }

  Future<_Resultado> _miembro(
    Evento e,
    String id,
    _Campos c,
    bool creada,
    bool soloFotos,
  ) async {
    final circulo = c.txt('circulo_id');
    final foto = c.txtONulo('foto_id');
    final fila = MiembrosCompanion(
      id: Value(id),
      circuloId: Value(circulo),
      nombre: Value(c.txt('nombre')),
      relacion: Value(c.txt('relacion')),
      telefono: Value(c.txtONulo('telefono')),
      rol: Value(c.txt('rol')),
      ordenEscalado: Value(c.entONulo('orden_escalado')),
      enMiGente: Value(c.logico('en_mi_gente')),
      creadoEn: Value(c.ent('creado_en')),
    );
    if (!c.valida || circulo != _contexto.circuloId) {
      return _Resultado.descartada;
    }
    return _mutable(
      e: e,
      tabla: _db.miembros,
      id: id,
      creada: creada,
      soloFotos: soloFotos,
      fotos: {'foto_id': foto},
      requisitos: () => _existe(_db.circulos, circulo),
      guardar: (insertar, faltan) async {
        final completa = fila.copyWith(
          fotoId: Value(faltan.contains('foto_id') ? null : foto),
        );
        if (insertar) {
          await _db.into(_db.miembros).insert(completa);
        } else {
          await (_db.update(
            _db.miembros,
          )..where((t) => t.id.equals(id))).write(completa);
        }
      },
    );
  }

  Future<_Resultado> _medicamento(
    Evento e,
    String id,
    _Campos c,
    bool creada,
    bool soloFotos,
  ) async {
    final persona = c.txt('persona_id');
    final caja = c.txtONulo('foto_caja_id');
    final pastilla = c.txtONulo('foto_pastilla_id');
    final fila = MedicamentosCompanion(
      id: Value(id),
      personaId: Value(persona),
      nombre: Value(c.txt('nombre')),
      nombreParaPersona: Value(c.txt('nombre_para_persona')),
      forma: Value(c.txt('forma')),
      color: Value(c.txtONulo('color')),
      registroCima: Value(c.txtONulo('registro_cima')),
      creadoEn: Value(c.ent('creado_en')),
      retiradoEn: Value(c.entONulo('retirado_en')),
    );
    if (!c.valida) return _Resultado.descartada;
    return _mutable(
      e: e,
      tabla: _db.medicamentos,
      id: id,
      creada: creada,
      soloFotos: soloFotos,
      fotos: {'foto_caja_id': caja, 'foto_pastilla_id': pastilla},
      requisitos: () => _existe(_db.personas, persona),
      guardar: (insertar, faltan) async {
        final completa = fila.copyWith(
          fotoCajaId: Value(faltan.contains('foto_caja_id') ? null : caja),
          fotoPastillaId: Value(
            faltan.contains('foto_pastilla_id') ? null : pastilla,
          ),
        );
        if (insertar) {
          await _db.into(_db.medicamentos).insert(completa);
        } else {
          await (_db.update(
            _db.medicamentos,
          )..where((t) => t.id.equals(id))).write(completa);
        }
      },
    );
  }

  /// Lo común de las fichas que admiten cambios.
  Future<_Resultado> _mutable({
    required Evento e,
    required TableInfo<Table, dynamic> tabla,
    required String id,
    required bool creada,
    required bool soloFotos,
    required Map<String, String?> fotos,
    required Future<bool> Function() requisitos,
    required Future<void> Function(bool insertar, Set<String> faltan) guardar,
  }) async {
    final ya = await _existe(tabla, id);
    final faltan = <String>{};
    for (final MapEntry(key: columna, value: foto) in fotos.entries) {
      if (foto != null && !await _existe(_db.fotos, foto)) faltan.add(columna);
    }
    if (soloFotos && ya) {
      // Repaso: solo se completan las fotos que faltaban, sin tocar el resto
      // (puede haber llegado después un cambio más nuevo).
      for (final MapEntry(key: columna, value: foto) in fotos.entries) {
        if (foto == null || faltan.contains(columna)) continue;
        await _db.customUpdate(
          'UPDATE ${tabla.actualTableName} SET $columna = ? '
          'WHERE id = ? AND $columna IS NULL',
          variables: [Variable<String>(foto), Variable<String>(id)],
          updates: {tabla},
          updateKind: UpdateKind.update,
        );
      }
      return faltan.isEmpty ? _Resultado.aplicada : _Resultado.incompleta;
    }
    if (!await requisitos()) return _Resultado.pendiente;
    if (!ya) {
      await guardar(true, faltan);
    } else if (creada ? await _primeraAlta(e) : !await _hayFichaMasNueva(e)) {
      await guardar(false, faltan);
    } else {
      return _Resultado.aplicada;
    }
    return faltan.isEmpty ? _Resultado.aplicada : _Resultado.incompleta;
  }

  /// Hay otra ficha (creada o modificada) de la misma fila más reciente que
  /// [e] (`ocurrido_en` y, si empatan, ulid), recibida o hecha en este
  /// móvil: un cambio que llega tarde no pisa a uno más nuevo (p. ej. el
  /// puesto de aviso de un familiar cambiado desde dos móviles).
  Future<bool> _hayFichaMasNueva(Evento e) async =>
      await (_db.select(_db.eventos)
            ..where(
              (t) =>
                  t.sujeto.equals(e.sujeto ?? '') &
                  t.tipo.isIn([
                    TipoEvento.fichaCreada.nombre,
                    TipoEvento.fichaModificada.nombre,
                  ]) &
                  (t.ocurridoEn.isBiggerThanValue(e.ocurridoEn) |
                      (t.ocurridoEn.equals(e.ocurridoEn) &
                          t.ulid.isBiggerThanValue(e.ulid))),
            )
            ..limit(1))
          .getSingleOrNull() !=
      null;

  /// No hay otra `ficha_creada` anterior con el mismo id.
  Future<bool> _primeraAlta(Evento e) async =>
      await (_db.select(_db.eventos)
            ..where(
              (t) =>
                  t.sujeto.equals(e.sujeto ?? '') &
                  t.tipo.equals(TipoEvento.fichaCreada.nombre) &
                  t.ulid.isSmallerThanValue(e.ulid),
            )
            ..limit(1))
          .getSingleOrNull() ==
      null;

  Future<bool> _existe(TableInfo<Table, dynamic> tabla, String id) async {
    final r = await _db
        .customSelect(
          'SELECT 1 FROM ${tabla.actualTableName} WHERE id = ? LIMIT 1',
          variables: [Variable<String>(id)],
          readsFrom: {tabla},
        )
        .getSingleOrNull();
    return r != null;
  }
}
