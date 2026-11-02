import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';

import '../contexto.dart';
import '../db/base_datos.dart';
import '../db/repositorios/eventos_repositorio.dart';
import 'foto_para_sobre.dart';

/// Fichas que viajan por el cartero dentro de `ficha_creada` y
/// `ficha_modificada`: `{tipo, fila: {columnas…}, omitidas?: […]}`.
enum TipoFicha {
  persona('persona'),
  miembro('miembro'),
  medicamento('medicamento'),
  pauta('pauta'),
  foto('foto');

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

  /// Columnas de foto (opcionales) de cada tipo.
  static const columnasFoto = <TipoFicha, List<String>>{
    TipoFicha.persona: ['foto_id'],
    TipoFicha.miembro: ['foto_id'],
    TipoFicha.medicamento: ['foto_caja_id', 'foto_pastilla_id'],
  };
}

/// Deja los eventos de ficha de este móvil para que lleguen a los demás.
final class PublicadorFichas {
  PublicadorFichas({
    required this._db,
    required this._eventos,
    required this._contexto,
  });

  final AppDatabase _db;
  final EventosRepositorio _eventos;
  final ContextoApp _contexto;

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
  /// emparejamiento): fotos, persona, familiares, medicamentos y pautas, en
  /// ese orden para que al otro lado existan las referencias. En un círculo
  /// que vino de fuera, la persona sin ficha es la provisional: no se publica.
  /// Devuelve cuántas publicó.
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
    for (final m in medicamentos) {
      await una(TipoFicha.medicamento, m.id);
    }
    for (final p in pautas) {
      await una(TipoFicha.pauta, p.id);
    }
    return n;
  });

  static Map<String, Object?> _payload(
    TipoFicha tipo,
    ({Map<String, Object?> fila, List<String> omitidas}) f,
  ) => {
    'tipo': tipo.nombre,
    'fila': f.fila,
    if (f.omitidas.isNotEmpty) 'omitidas': f.omitidas,
  };

  Future<({Map<String, Object?> fila, List<String> omitidas})?> _fila(
    TipoFicha tipo,
    String id,
  ) async {
    final Map<String, Object?> fila;
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
    }
    final omitidas = <String>[];
    for (final columna in FilasFicha.columnasFoto[tipo] ?? const <String>[]) {
      final fotoId = fila[columna];
      if (fotoId is String && !await _publicada(fotoId)) {
        fila[columna] = null;
        omitidas.add(columna);
      }
    }
    return (fila: fila, omitidas: omitidas);
  }

  Future<bool> _publicada(String id) async =>
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
///   actualiza. Una `ficha_creada` sobre una fila que ya existe solo la pisa
///   si es la primera para ese id (la fila provisional del emparejamiento).
/// - Si falta una referencia obligatoria, la ficha queda pendiente en
///   `sync_estado` y se repasa cada vez que se aplica otra. Si falta una foto,
///   la fila se guarda sin ella y se completa cuando llegue.
/// - Nunca lanza: un sobre raro no puede atascar la recepción.
final class MaterializadorFichas {
  MaterializadorFichas(this._db, this._contexto);

  final AppDatabase _db;
  final ContextoApp _contexto;

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
    // Las voces aún no viajan.
    final voz = fila.vozId.value;
    final sinVoz = voz != null && !await _existe(_db.voces, voz);
    await _db
        .into(_db.pautas)
        .insert(sinVoz ? fila.copyWith(vozId: const Value(null)) : fila);
    return _Resultado.aplicada;
  }

  // ------------------------------------------------------- Fichas

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
    } else if (!creada || await _primeraAlta(e)) {
      await guardar(false, faltan);
    } else {
      return _Resultado.aplicada;
    }
    return faltan.isEmpty ? _Resultado.aplicada : _Resultado.incompleta;
  }

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
