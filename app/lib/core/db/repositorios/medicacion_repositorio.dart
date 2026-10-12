import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
import '../base_datos.dart';
import 'circulo_repositorio.dart';
import 'eventos_repositorio.dart';

/// Datos de un medicamento nuevo con su primera pauta.
final class NuevoMedicamento {
  const NuevoMedicamento({
    required this.nombre,
    required this.nombreParaPersona,
    required this.forma,
    required this.horas,
    required this.dosis,
    this.color,
    this.fotoCaja,
    this.fotoPastilla,
    this.diasSemana = DiasSemana.todos,
    this.compartimento,
    this.comprobacion = TipoComprobacion.video,
    this.segundosVideo = 10,
  });

  final String nombre;
  final String nombreParaPersona;

  /// `redonda`, `ovalada`, `capsula` u `otra`.
  final String forma;
  final String? color;
  final FotoNueva? fotoCaja;
  final FotoNueva? fotoPastilla;
  final List<String> horas;
  final int diasSemana;
  final String dosis;
  final String? compartimento;
  final TipoComprobacion comprobacion;
  final int segundosVideo;
}

/// Horas "HH:mm" ordenadas y sin repetir.
List<String> normalizarHoras(Iterable<String> horas) =>
    (horas.toSet().toList()..sort());

/// Medicamentos, pautas (con versiones) y tomas.
class MedicacionRepositorio {
  MedicacionRepositorio({
    required this._db,
    required this._reloj,
    required this._contexto,
    required this._eventos,
    required this._circulo,
    required this._autor,
    this._uuid = const Uuid(),
  });

  final AppDatabase _db;
  final Reloj _reloj;
  final ContextoApp _contexto;
  final EventosRepositorio _eventos;
  final CirculoRepositorio _circulo;
  final String Function() _autor;
  final Uuid _uuid;

  int get _ahoraMs => _reloj.ahora().millisecondsSinceEpoch;

  Stream<List<Medicamento>> observarMedicamentos() {
    final q = _db.select(_db.medicamentos)
      ..where((m) => m.personaId.equals(_contexto.personaId))
      ..orderBy([
        (m) => OrderingTerm.asc(m.creadoEn),
        (m) => OrderingTerm.asc(m.nombre),
      ]);
    return q.watch();
  }

  Stream<List<Pauta>> observarPautas() {
    final q = _db.select(_db.pautas)
      ..where((p) => p.personaId.equals(_contexto.personaId))
      ..orderBy([
        (p) => OrderingTerm.asc(p.pautaId),
        (p) => OrderingTerm.asc(p.version),
      ]);
    return q.watch();
  }

  Future<Medicamento?> medicamento(String id) => (_db.select(
    _db.medicamentos,
  )..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<Pauta?> pautaDeVersion(String versionId) => (_db.select(
    _db.pautas,
  )..where((p) => p.id.equals(versionId))).getSingleOrNull();

  /// Última versión de cada pauta de un medicamento.
  Future<List<Pauta>> versionesDeMedicamento(String medicamentoId) =>
      (_db.select(_db.pautas)
            ..where((p) => p.medicamentoId.equals(medicamentoId))
            ..orderBy([(p) => OrderingTerm.desc(p.version)]))
          .get();

  /// En una transacción: fotos, medicamento, pauta v1 y `medicamento_creado`.
  Future<String> crear(NuevoMedicamento d, {DateTime? vigenteDesde}) =>
      _db.transaction(() async {
        final medicamentoId = _uuid.v4();
        final pautaId = _uuid.v4();
        final ahora = _ahoraMs;
        final fotoCajaId = d.fotoCaja == null
            ? null
            : await _circulo.guardarFoto(d.fotoCaja!);
        final fotoPastillaId = d.fotoPastilla == null
            ? null
            : await _circulo.guardarFoto(d.fotoPastilla!);
        await _db
            .into(_db.medicamentos)
            .insert(
              MedicamentosCompanion.insert(
                id: medicamentoId,
                personaId: _contexto.personaId,
                nombre: d.nombre,
                nombreParaPersona: d.nombreParaPersona,
                forma: d.forma,
                color: Value(d.color),
                fotoCajaId: Value(fotoCajaId),
                fotoPastillaId: Value(fotoPastillaId),
                creadoEn: ahora,
              ),
            );
        await _insertarPauta(
          pautaId: pautaId,
          version: 1,
          medicamentoId: medicamentoId,
          dosis: d.dosis,
          horas: d.horas,
          diasSemana: d.diasSemana,
          compartimento: d.compartimento,
          comprobacion: d.comprobacion,
          segundosVideo: d.segundosVideo,
          vigenteDesde: (vigenteDesde ?? _reloj.ahora()).millisecondsSinceEpoch,
          activa: true,
          motivo: null,
        );
        await _eventos.registrar(
          TipoEvento.medicamentoCreado,
          sujeto: medicamentoId,
          payload: {'nombre': d.nombre, 'pautaId': pautaId},
        );
        return medicamentoId;
      });

  Future<void> _insertarPauta({
    required String pautaId,
    required int version,
    required String medicamentoId,
    required String dosis,
    required List<String> horas,
    required int diasSemana,
    required String? compartimento,
    required TipoComprobacion comprobacion,
    required int segundosVideo,
    required int vigenteDesde,
    required bool activa,
    required String? motivo,
    String? vozId,
  }) async {
    await _db
        .into(_db.pautas)
        .insert(
          PautasCompanion.insert(
            id: _uuid.v4(),
            pautaId: pautaId,
            version: version,
            medicamentoId: medicamentoId,
            personaId: _contexto.personaId,
            dosis: dosis,
            horas: jsonEncode(normalizarHoras(horas)),
            diasSemana: Value(diasSemana),
            compartimento: Value(compartimento),
            vozId: Value(vozId),
            comprobacion: Value(comprobacion.nombre),
            segundosVideo: Value(segundosVideo),
            zonaHoraria: _contexto.zonaHoraria,
            vigenteDesde: vigenteDesde,
            activa: activa,
            motivo: Value(motivo),
            creadaPor: _autor(),
            creadaEn: _ahoraMs,
          ),
        );
  }

  Future<Pauta?> _ultimaVersion(String pautaId) =>
      (_db.select(_db.pautas)
            ..where((p) => p.pautaId.equals(pautaId))
            ..orderBy([(p) => OrderingTerm.desc(p.version)])
            ..limit(1))
          .getSingleOrNull();

  /// Cambia la pauta creando otra versión (`vigente_desde = ahora`). El
  /// [motivo] es obligatorio.
  Future<void> cambiarPauta({
    required String pautaId,
    required String motivo,
    required List<String> horas,
    required int diasSemana,
    required String dosis,
    String? compartimento,
    required TipoComprobacion comprobacion,
    required int segundosVideo,
  }) {
    if (motivo.trim().isEmpty) {
      throw ArgumentError('motivo_obligatorio');
    }
    return _db.transaction(() async {
      final ultima = await _ultimaVersion(pautaId);
      if (ultima == null) throw StateError('pauta_inexistente');
      await _insertarPauta(
        pautaId: pautaId,
        version: ultima.version + 1,
        medicamentoId: ultima.medicamentoId,
        dosis: dosis,
        horas: horas,
        diasSemana: diasSemana,
        compartimento: compartimento,
        comprobacion: comprobacion,
        segundosVideo: segundosVideo,
        vigenteDesde: _ahoraMs,
        activa: true,
        motivo: motivo.trim(),
        vozId: ultima.vozId,
      );
    });
  }

  /// Suspende la pauta: otra versión con `activa = false`.
  Future<void> suspender({required String pautaId, required String motivo}) {
    if (motivo.trim().isEmpty) {
      throw ArgumentError('motivo_obligatorio');
    }
    return _db.transaction(() async {
      final u = await _ultimaVersion(pautaId);
      if (u == null) throw StateError('pauta_inexistente');
      await _insertarPauta(
        pautaId: pautaId,
        version: u.version + 1,
        medicamentoId: u.medicamentoId,
        dosis: u.dosis,
        horas: _decodificarHoras(u.horas),
        diasSemana: u.diasSemana,
        compartimento: u.compartimento,
        comprobacion: TipoComprobacion.desdeNombre(u.comprobacion),
        segundosVideo: u.segundosVideo,
        vigenteDesde: _ahoraMs,
        activa: false,
        motivo: motivo.trim(),
        vozId: u.vozId,
      );
    });
  }

  /// `INSERT OR IGNORE` de la toma al programar su alarma o con su primer evento.
  Future<void> asegurarToma(TomaPrevista t) => _db
      .into(_db.tomas)
      .insert(
        TomasCompanion.insert(
          id: t.id,
          pautaVersionId: t.pautaVersionId,
          personaId: _contexto.personaId,
          previstaPara: t.previstaPara.millisecondsSinceEpoch,
          fechaLocal: t.fechaLocal,
          horaLocal: t.horaLocal,
          creadaEn: _ahoraMs,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  static List<String> _decodificarHoras(String json) => [
    for (final h in jsonDecode(json) as List<dynamic>) h as String,
  ];

  /// Pauta de base de datos a versión de dominio.
  static PautaVersion aVersion(Pauta p) => PautaVersion(
    id: p.id,
    pautaId: p.pautaId,
    version: p.version,
    medicamentoId: p.medicamentoId,
    horas: _decodificarHoras(p.horas),
    zonaHoraria: p.zonaHoraria,
    vigenteDesde: DateTime.fromMillisecondsSinceEpoch(
      p.vigenteDesde,
      isUtc: true,
    ),
    activa: p.activa,
    diasSemana: p.diasSemana,
    comprobacion: TipoComprobacion.desdeNombre(p.comprobacion),
  );

  static List<String> horasDe(Pauta p) => _decodificarHoras(p.horas);
}
