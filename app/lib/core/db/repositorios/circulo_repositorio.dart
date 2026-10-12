import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
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

  int get _ahoraMs => _reloj.ahora().millisecondsSinceEpoch;

  /// Crea el círculo y la persona si faltan.
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
        }
      });

  /// Registra este dispositivo con su [perfil] (o actualiza el perfil) y, en
  /// perfil familia, localiza o crea al miembro "Responsable". Devuelve el id
  /// del miembro, si lo hay.
  Future<String?> asegurarDispositivo(PerfilApp perfil) => _db.transaction(
    () async {
      String? miembroId;
      if (perfil == PerfilApp.familia) {
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
    await _eventos.fichaModificada(
      tabla: 'personas',
      id: p.id,
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
    return id;
  });

  /// Guarda una foto (hecho de solo inserción) y devuelve su id.
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
    return id;
  }

  Future<Foto?> foto(String id) =>
      (_db.select(_db.fotos)..where((t) => t.id.equals(id))).getSingleOrNull();
}
