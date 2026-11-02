import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
import '../../sync/fichas.dart';
import '../base_datos.dart';
import 'eventos_repositorio.dart';

/// Foto lista para guardar (ya reducida: 1280 px de ancho y calidad 80).
final class FotoNueva {
  const FotoNueva(this.bytes, {this.mime = 'image/jpeg'});

  final Uint8List bytes;
  final String mime;
}

/// Datos de un familiar nuevo.
final class NuevoMiembro {
  const NuevoMiembro({
    required this.nombre,
    required this.relacion,
    this.telefono,
    this.rol = 'cuidador',
    this.ordenEscalado,
    this.enMiGente = true,
    this.foto,
  });

  final String nombre;
  final String relacion;
  final String? telefono;
  final String rol;
  final int? ordenEscalado;
  final bool enMiGente;
  final FotoNueva? foto;
}

/// Círculo, persona, familiares, dispositivo y fotos.
class CirculoRepositorio {
  CirculoRepositorio({
    required this._db,
    required this._reloj,
    required this._contexto,
    required this._eventos,
    this._uuid = const Uuid(),
  });

  final AppDatabase _db;
  final Reloj _reloj;
  final ContextoApp _contexto;
  final EventosRepositorio _eventos;
  final Uuid _uuid;

  /// Deja `ficha_creada`/`ficha_modificada` con la fila para los demás móviles.
  late final PublicadorFichas _fichas = PublicadorFichas(
    db: _db,
    eventos: _eventos,
    contexto: _contexto,
  );

  int get _ahoraMs => _reloj.ahora().millisecondsSinceEpoch;

  /// Crea el círculo y la persona si faltan. En un círculo que vino de otro
  /// móvil son filas provisionales (alias "Persona") que no se publican: la
  /// ficha de verdad llega por el cartero y las sustituye.
  Future<void> asegurarBase({String nombreCirculo = 'Mi familia'}) =>
      _db.transaction(() async {
        final c = await (_db.select(
          _db.circulos,
        )..where((t) => t.id.equals(_contexto.circuloId))).getSingleOrNull();
        if (c == null) {
          await _db
              .into(_db.circulos)
              .insert(
                CirculosCompanion.insert(
                  id: _contexto.circuloId,
                  nombre: nombreCirculo,
                  creadoEn: _ahoraMs,
                ),
              );
        }
        final p = await (_db.select(
          _db.personas,
        )..where((t) => t.id.equals(_contexto.personaId))).getSingleOrNull();
        if (p == null) {
          await _db
              .into(_db.personas)
              .insert(
                PersonasCompanion.insert(
                  id: _contexto.personaId,
                  circuloId: _contexto.circuloId,
                  alias: 'Persona',
                  zonaHoraria: Value(_contexto.zonaHoraria),
                  creadaEn: _ahoraMs,
                ),
              );
          if (!_contexto.circuloExterno) {
            await _fichas.creada(TipoFicha.persona, _contexto.personaId);
          }
        }
      });

  /// Registra este dispositivo con su [perfil] (o actualiza el perfil) y, en
  /// perfil familia, localiza o crea al miembro "Responsable". Devuelve el id
  /// del miembro, si lo hay.
  ///
  /// En un móvil que se unió a un círculo de fuera, el perfil familia es otro
  /// familiar: usa el miembro de este móvil o crea uno ("Familiar", cuidador,
  /// sin orden de aviso ni sitio en "Mi gente"), nunca otro "Responsable".
  Future<String?> asegurarDispositivo(PerfilApp perfil) => _db.transaction(
    () async {
      String? miembroId;
      if (perfil == PerfilApp.familia && _contexto.circuloExterno) {
        miembroId = await _miembroDeEsteMovil();
        if (miembroId == null) {
          miembroId = _uuid.v4();
          await _db
              .into(_db.miembros)
              .insert(
                MiembrosCompanion.insert(
                  id: miembroId,
                  circuloId: _contexto.circuloId,
                  nombre: 'Familiar',
                  relacion: 'Familiar',
                  rol: 'cuidador',
                  enMiGente: const Value(false),
                  creadoEn: _ahoraMs,
                ),
              );
          await _fichas.creada(TipoFicha.miembro, miembroId);
        }
      } else if (perfil == PerfilApp.familia) {
        final responsable =
            await (_db.select(_db.miembros)
                  ..where(
                    (m) =>
                        m.circuloId.equals(_contexto.circuloId) &
                        m.rol.equals('responsable'),
                  )
                  ..orderBy([(m) => OrderingTerm.asc(m.ordenEscalado)])
                  ..limit(1))
                .getSingleOrNull();
        if (responsable != null) {
          miembroId = responsable.id;
        } else {
          miembroId = _uuid.v4();
          await _db
              .into(_db.miembros)
              .insert(
                MiembrosCompanion.insert(
                  id: miembroId,
                  circuloId: _contexto.circuloId,
                  nombre: 'Responsable',
                  relacion: 'Familiar',
                  rol: 'responsable',
                  ordenEscalado: const Value(1),
                  creadoEn: _ahoraMs,
                ),
              );
          await _fichas.creada(TipoFicha.miembro, miembroId);
        }
      }
      final d = await (_db.select(
        _db.dispositivos,
      )..where((t) => t.id.equals(_contexto.dispositivoId))).getSingleOrNull();
      if (d == null) {
        await _db
            .into(_db.dispositivos)
            .insert(
              DispositivosCompanion.insert(
                id: _contexto.dispositivoId,
                circuloId: _contexto.circuloId,
                perfil: perfil.nombre,
                plataforma: _contexto.plataforma,
                miembroId: Value(miembroId),
                registradoEn: _ahoraMs,
              ),
            );
      } else if (d.perfil != perfil.nombre || d.miembroId != miembroId) {
        await (_db.update(
          _db.dispositivos,
        )..where((t) => t.id.equals(d.id))).write(
          DispositivosCompanion(
            perfil: Value(perfil.nombre),
            miembroId: Value(miembroId),
          ),
        );
        await _eventos.fichaModificada(
          tabla: 'dispositivos',
          id: d.id,
          antes: {'perfil': d.perfil, 'miembro_id': d.miembroId},
          despues: {'perfil': perfil.nombre, 'miembro_id': miembroId},
        );
      }
      return miembroId;
    },
  );

  /// Miembro con el que se registró antes este dispositivo, si sigue existiendo.
  Future<String?> _miembroDeEsteMovil() async {
    final d = await (_db.select(
      _db.dispositivos,
    )..where((t) => t.id.equals(_contexto.dispositivoId))).getSingleOrNull();
    final id = d?.miembroId;
    if (id == null) return null;
    final m = await (_db.select(
      _db.miembros,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return m?.id;
  }

  Future<Persona?> persona() => (_db.select(
    _db.personas,
  )..where((t) => t.id.equals(_contexto.personaId))).getSingleOrNull();

  Stream<Persona?> observarPersona() => (_db.select(
    _db.personas,
  )..where((t) => t.id.equals(_contexto.personaId))).watchSingleOrNull();

  /// Cambia el alias de la persona (ficha: deja `ficha_modificada`).
  Future<void> cambiarAlias(String alias) => _db.transaction(() async {
    final p = await persona();
    if (p == null || p.alias == alias) return;
    await (_db.update(_db.personas)..where((t) => t.id.equals(p.id))).write(
      PersonasCompanion(alias: Value(alias)),
    );
    await _fichas.modificada(
      TipoFicha.persona,
      p.id,
      tabla: 'personas',
      antes: {'alias': p.alias},
      despues: {'alias': alias},
    );
  });

  /// Familiares por orden de escalado (los sin orden, al final).
  Stream<List<Miembro>> observarMiembros() {
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
    return q.watch();
  }

  /// Cambia el puesto de [miembroId] en el orden de aviso (nulo: sin
  /// puesto). Ficha: deja `ficha_modificada` con la fila para los demás
  /// móviles, también el de la persona, que es el que avisa.
  Future<void> cambiarOrdenEscalado(String miembroId, int? orden) {
    if (orden != null && orden < 1) throw ArgumentError('orden_no_valido');
    return _db.transaction(() async {
      final m = await (_db.select(
        _db.miembros,
      )..where((t) => t.id.equals(miembroId))).getSingleOrNull();
      if (m == null || m.ordenEscalado == orden) return;
      await (_db.update(_db.miembros)..where((t) => t.id.equals(m.id))).write(
        MiembrosCompanion(ordenEscalado: Value(orden)),
      );
      await _fichas.modificada(
        TipoFicha.miembro,
        m.id,
        tabla: 'miembros',
        antes: {'orden_escalado': m.ordenEscalado},
        despues: {'orden_escalado': orden},
      );
    });
  }

  Future<String> crearMiembro(NuevoMiembro d) => _db.transaction(() async {
    final id = _uuid.v4();
    final fotoId = d.foto == null ? null : await guardarFoto(d.foto!);
    await _db
        .into(_db.miembros)
        .insert(
          MiembrosCompanion.insert(
            id: id,
            circuloId: _contexto.circuloId,
            nombre: d.nombre,
            relacion: d.relacion,
            telefono: Value(d.telefono),
            fotoId: Value(fotoId),
            rol: d.rol,
            ordenEscalado: Value(d.ordenEscalado),
            enMiGente: Value(d.enMiGente),
            creadoEn: _ahoraMs,
          ),
        );
    await _fichas.creada(TipoFicha.miembro, id);
    return id;
  });

  /// Guarda una foto (hecho de solo inserción) y devuelve su id. Para los
  /// demás móviles sale reducida (512 px, JPEG 80); si no se puede reducir,
  /// no sale y las fichas que la usan lo anotan.
  Future<String> guardarFoto(FotoNueva f) async {
    final id = _uuid.v4();
    await _db
        .into(_db.fotos)
        .insert(
          FotosCompanion.insert(
            id: id,
            bytes: f.bytes,
            mime: f.mime,
            creadaEn: _ahoraMs,
          ),
        );
    await _fichas.creada(TipoFicha.foto, id);
    return id;
  }

  Future<Foto?> foto(String id) =>
      (_db.select(_db.fotos)..where((t) => t.id.equals(id))).getSingleOrNull();
}
