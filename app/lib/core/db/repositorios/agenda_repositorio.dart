import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
import '../../sync/fichas.dart';
import '../base_datos.dart';
import 'eventos_repositorio.dart';

/// Tipos de cita: lo que se guarda en `Citas.tipo`.
abstract final class TipoCita {
  static const medico = 'medico';
  static const analisis = 'analisis';
  static const otra = 'otra';

  /// Orden en el selector.
  static const valores = [medico, analisis, otra];
}

/// Datos de una cita (nueva o editada).
final class DatosCita {
  const DatosCita({
    required this.titulo,
    this.tipo = TipoCita.medico,
    required this.fecha,
    required this.hora,
    this.lugar,
    this.notas,
    this.acompanaId,
  });

  final String titulo;
  final String tipo;

  /// `yyyy-MM-dd`, en la zona de la persona.
  final String fecha;

  /// `HH:mm`.
  final String hora;
  final String? lugar;
  final String? notas;
  final String? acompanaId;
}

/// Datos de un turno (nuevo o editado). Si [hasta] no es posterior a
/// [desde], el turno acaba al día siguiente.
final class DatosTurno {
  const DatosTurno({
    required this.miembroId,
    required this.fecha,
    required this.desde,
    required this.hasta,
    this.repetirSemanal = false,
    this.nota,
  });

  final String miembroId;

  /// `yyyy-MM-dd`: el día (o el primer día, si se repite).
  final String fecha;

  /// `HH:mm`.
  final String desde;

  /// `HH:mm`.
  final String hasta;
  final bool repetirSemanal;
  final String? nota;
}

/// Citas y turnos de la familia. Son fichas: cada cambio deja
/// `ficha_creada`/`ficha_modificada` con la fila entera para los demás
/// móviles y gana el más reciente. Borrar es baja lógica (`baja_en`).
class AgendaRepositorio {
  AgendaRepositorio({
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

  /// Quién firma los cambios (el familiar de este móvil).
  final String Function() _autor;
  final Uuid _uuid;

  late final PublicadorFichas _fichas = PublicadorFichas(
    db: _db,
    eventos: _eventos,
    contexto: _contexto,
  );

  int get _ahoraMs => _reloj.ahora().millisecondsSinceEpoch;

  static final _fecha = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final _hora = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  static String? _limpio(String? t) {
    final s = (t ?? '').trim();
    return s.isEmpty ? null : s;
  }

  static bool _fechaValida(String f) {
    if (!_fecha.hasMatch(f)) return false;
    final d = DateTime.tryParse('${f}T00:00:00Z');
    return d != null && d.toIso8601String().startsWith(f);
  }

  // ------------------------------------------------------------- Citas

  Stream<List<Cita>> observarCitas() =>
      (_db.select(_db.citas)
            ..where(
              (c) =>
                  c.circuloId.equals(_contexto.circuloId) & c.bajaEn.isNull(),
            )
            ..orderBy([
              (c) => OrderingTerm.asc(c.fecha),
              (c) => OrderingTerm.asc(c.hora),
            ]))
          .watch();

  Future<Cita?> cita(String id) =>
      (_db.select(_db.citas)..where((c) => c.id.equals(id))).getSingleOrNull();

  void _validarCita(DatosCita d) {
    if (d.titulo.trim().isEmpty) throw ArgumentError('titulo_vacio');
    if (!TipoCita.valores.contains(d.tipo)) {
      throw ArgumentError('tipo_no_valido');
    }
    if (!_fechaValida(d.fecha)) throw ArgumentError('fecha_no_valida');
    if (!_hora.hasMatch(d.hora)) throw ArgumentError('hora_no_valida');
  }

  Future<String> crearCita(DatosCita d) async {
    _validarCita(d);
    return _db.transaction(() async {
      final id = _uuid.v4();
      final ahora = _ahoraMs;
      final autor = _autor();
      await _db
          .into(_db.citas)
          .insert(
            CitasCompanion.insert(
              id: id,
              circuloId: _contexto.circuloId,
              titulo: d.titulo.trim(),
              tipo: d.tipo,
              fecha: d.fecha,
              hora: d.hora,
              lugar: Value(_limpio(d.lugar)),
              notas: Value(_limpio(d.notas)),
              acompanaId: Value(d.acompanaId),
              creadaPor: autor,
              creadaEn: ahora,
              modificadaPor: autor,
              modificadaEn: ahora,
            ),
          );
      await _fichas.creada(TipoFicha.cita, id);
      return id;
    });
  }

  /// Cambia todos los datos de la cita [id]. Sin cambios, no hace nada.
  Future<void> editarCita(String id, DatosCita d) async {
    _validarCita(d);
    await _db.transaction(() async {
      final c = await cita(id);
      if (c == null || c.bajaEn != null) return;
      final nueva = (
        titulo: d.titulo.trim(),
        lugar: _limpio(d.lugar),
        notas: _limpio(d.notas),
      );
      if (c.titulo == nueva.titulo &&
          c.tipo == d.tipo &&
          c.fecha == d.fecha &&
          c.hora == d.hora &&
          c.lugar == nueva.lugar &&
          c.notas == nueva.notas &&
          c.acompanaId == d.acompanaId) {
        return;
      }
      await (_db.update(_db.citas)..where((t) => t.id.equals(id))).write(
        CitasCompanion(
          titulo: Value(nueva.titulo),
          tipo: Value(d.tipo),
          fecha: Value(d.fecha),
          hora: Value(d.hora),
          lugar: Value(nueva.lugar),
          notas: Value(nueva.notas),
          acompanaId: Value(d.acompanaId),
          modificadaPor: Value(_autor()),
          modificadaEn: Value(_ahoraMs),
        ),
      );
      await _fichas.modificada(
        TipoFicha.cita,
        id,
        tabla: 'citas',
        antes: {
          'titulo': c.titulo,
          'tipo': c.tipo,
          'fecha': c.fecha,
          'hora': c.hora,
          'lugar': c.lugar,
          'notas': c.notas,
          'acompana_id': c.acompanaId,
        },
        despues: {
          'titulo': nueva.titulo,
          'tipo': d.tipo,
          'fecha': d.fecha,
          'hora': d.hora,
          'lugar': nueva.lugar,
          'notas': nueva.notas,
          'acompana_id': d.acompanaId,
        },
      );
    });
  }

  /// Baja lógica: la fila se conserva con `baja_en`.
  Future<void> borrarCita(String id) => _db.transaction(() async {
    final c = await cita(id);
    if (c == null || c.bajaEn != null) return;
    final ahora = _ahoraMs;
    await (_db.update(_db.citas)..where((t) => t.id.equals(id))).write(
      CitasCompanion(
        bajaEn: Value(ahora),
        modificadaPor: Value(_autor()),
        modificadaEn: Value(ahora),
      ),
    );
    await _fichas.modificada(
      TipoFicha.cita,
      id,
      tabla: 'citas',
      antes: {'baja_en': null},
      despues: {'baja_en': ahora},
    );
  });

  // ------------------------------------------------------------- Turnos

  Stream<List<Turno>> observarTurnos() =>
      (_db.select(_db.turnos)
            ..where(
              (t) =>
                  t.circuloId.equals(_contexto.circuloId) & t.bajaEn.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm.asc(t.fecha),
              (t) => OrderingTerm.asc(t.desdeHora),
            ]))
          .watch();

  Future<Turno?> turno(String id) =>
      (_db.select(_db.turnos)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> _validarTurno(DatosTurno d) async {
    if (!_fechaValida(d.fecha)) throw ArgumentError('fecha_no_valida');
    if (!_hora.hasMatch(d.desde) || !_hora.hasMatch(d.hasta)) {
      throw ArgumentError('hora_no_valida');
    }
    if (d.desde == d.hasta) throw ArgumentError('turno_sin_duracion');
    final m = await (_db.select(
      _db.miembros,
    )..where((x) => x.id.equals(d.miembroId))).getSingleOrNull();
    if (m == null || m.bajaEn != null) throw ArgumentError('miembro_no_valido');
  }

  Future<String> crearTurno(DatosTurno d) async {
    await _validarTurno(d);
    return _db.transaction(() async {
      final id = _uuid.v4();
      final ahora = _ahoraMs;
      final autor = _autor();
      await _db
          .into(_db.turnos)
          .insert(
            TurnosCompanion.insert(
              id: id,
              circuloId: _contexto.circuloId,
              miembroId: d.miembroId,
              fecha: d.fecha,
              desdeHora: d.desde,
              hastaHora: d.hasta,
              repetirSemanal: Value(d.repetirSemanal),
              nota: Value(_limpio(d.nota)),
              creadoPor: autor,
              creadoEn: ahora,
              modificadoPor: autor,
              modificadoEn: ahora,
            ),
          );
      await _fichas.creada(TipoFicha.turno, id);
      return id;
    });
  }

  Future<void> editarTurno(String id, DatosTurno d) async {
    await _validarTurno(d);
    await _db.transaction(() async {
      final t = await turno(id);
      if (t == null || t.bajaEn != null) return;
      final nota = _limpio(d.nota);
      if (t.miembroId == d.miembroId &&
          t.fecha == d.fecha &&
          t.desdeHora == d.desde &&
          t.hastaHora == d.hasta &&
          t.repetirSemanal == d.repetirSemanal &&
          t.nota == nota) {
        return;
      }
      await (_db.update(_db.turnos)..where((x) => x.id.equals(id))).write(
        TurnosCompanion(
          miembroId: Value(d.miembroId),
          fecha: Value(d.fecha),
          desdeHora: Value(d.desde),
          hastaHora: Value(d.hasta),
          repetirSemanal: Value(d.repetirSemanal),
          nota: Value(nota),
          modificadoPor: Value(_autor()),
          modificadoEn: Value(_ahoraMs),
        ),
      );
      await _fichas.modificada(
        TipoFicha.turno,
        id,
        tabla: 'turnos',
        antes: {
          'miembro_id': t.miembroId,
          'fecha': t.fecha,
          'desde_hora': t.desdeHora,
          'hasta_hora': t.hastaHora,
          'repetir_semanal': t.repetirSemanal,
          'nota': t.nota,
        },
        despues: {
          'miembro_id': d.miembroId,
          'fecha': d.fecha,
          'desde_hora': d.desde,
          'hasta_hora': d.hasta,
          'repetir_semanal': d.repetirSemanal,
          'nota': nota,
        },
      );
    });
  }

  Future<void> borrarTurno(String id) => _db.transaction(() async {
    final t = await turno(id);
    if (t == null || t.bajaEn != null) return;
    final ahora = _ahoraMs;
    await (_db.update(_db.turnos)..where((x) => x.id.equals(id))).write(
      TurnosCompanion(
        bajaEn: Value(ahora),
        modificadoPor: Value(_autor()),
        modificadoEn: Value(ahora),
      ),
    );
    await _fichas.modificada(
      TipoFicha.turno,
      id,
      tabla: 'turnos',
      antes: {'baja_en': null},
      despues: {'baja_en': ahora},
    );
  });
}
