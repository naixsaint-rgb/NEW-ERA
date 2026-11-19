import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
import '../../plataforma/audio/grabadora.dart';
import '../../sync/fichas.dart';
import '../base_datos.dart';
import 'eventos_repositorio.dart';

/// Preguntas, notas y marca de grabación de las consultas con el médico
/// (las citas son de [AgendaRepositorio]). Son fichas: cada cambio deja
/// `ficha_creada`/`ficha_modificada` con la fila entera para los demás
/// móviles y gana el más reciente. Borrar es baja lógica (`baja_en`).
///
/// El audio de una grabación NO viaja: se queda en el móvil de quien grabó
/// (`consultas/<id de la cita>.m4a`); lo que viaja es la marca.
class ConsultasRepositorio {
  ConsultasRepositorio({
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

  /// Largo máximo de una pregunta y de una nota.
  static const maxPregunta = 300;
  static const maxNota = 2000;

  /// Grabación más larga que se admite: 60 minutos.
  static const maxSegundosGrabacion = FormatoConsulta.segundosMaximos;

  late final PublicadorFichas _fichas = PublicadorFichas(
    db: _db,
    eventos: _eventos,
    contexto: _contexto,
  );

  /// Orden de inserción: desempata las que se apuntaron en el mismo
  /// milisegundo.
  static const _orden = CustomExpression<int>('rowid');

  int get _ahoraMs => _reloj.ahora().millisecondsSinceEpoch;

  Future<void> _citaVigente(String citaId) async {
    final c =
        await (_db.select(_db.citas)..where(
              (t) =>
                  t.id.equals(citaId) &
                  t.circuloId.equals(_contexto.circuloId) &
                  t.bajaEn.isNull(),
            ))
            .getSingleOrNull();
    if (c == null) throw ArgumentError('cita_no_valida');
  }

  static String _texto(String t, int max, String error) {
    final s = t.trim();
    if (s.isEmpty) throw ArgumentError('texto_vacio');
    if (s.length > max) throw ArgumentError(error);
    return s;
  }

  // ------------------------------------------------------------- Preguntas

  /// Preguntas sin borrar de la cita [citaId], de la más antigua a la más
  /// reciente.
  Stream<List<PreguntaConsulta>> observarPreguntas(String citaId) =>
      (_db.select(_db.preguntasConsulta)
            ..where((p) => p.citaId.equals(citaId) & p.bajaEn.isNull())
            ..orderBy([
              (p) => OrderingTerm.asc(p.creadaEn),
              (p) => OrderingTerm.asc(_orden),
            ]))
          .watch();

  /// Todas las preguntas sin borrar (para contarlas por cita en la lista).
  Stream<List<PreguntaConsulta>> observarTodasLasPreguntas() =>
      (_db.select(_db.preguntasConsulta)
            ..where((p) => p.bajaEn.isNull())
            ..orderBy([
              (p) => OrderingTerm.asc(p.creadaEn),
              (p) => OrderingTerm.asc(_orden),
            ]))
          .watch();

  Future<PreguntaConsulta?> pregunta(String id) => (_db.select(
    _db.preguntasConsulta,
  )..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<String> crearPregunta(String citaId, String texto) async {
    final limpio = _texto(texto, maxPregunta, 'pregunta_larga');
    await _citaVigente(citaId);
    return _db.transaction(() async {
      final id = _uuid.v4();
      final ahora = _ahoraMs;
      final autor = _autor();
      await _db
          .into(_db.preguntasConsulta)
          .insert(
            PreguntasConsultaCompanion.insert(
              id: id,
              citaId: citaId,
              texto: limpio,
              creadaPor: autor,
              creadaEn: ahora,
              modificadaPor: autor,
              modificadaEn: ahora,
            ),
          );
      await _fichas.creada(TipoFicha.preguntaConsulta, id);
      return id;
    });
  }

  /// Cambia el texto de la pregunta [id]. Sin cambios, no hace nada.
  Future<void> editarPregunta(String id, String texto) async {
    final limpio = _texto(texto, maxPregunta, 'pregunta_larga');
    await _db.transaction(() async {
      final p = await pregunta(id);
      if (p == null || p.bajaEn != null || p.texto == limpio) return;
      await (_db.update(
        _db.preguntasConsulta,
      )..where((t) => t.id.equals(id))).write(
        PreguntasConsultaCompanion(
          texto: Value(limpio),
          modificadaPor: Value(_autor()),
          modificadaEn: Value(_ahoraMs),
        ),
      );
      await _fichas.modificada(
        TipoFicha.preguntaConsulta,
        id,
        tabla: 'preguntas_consulta',
        antes: {'texto': p.texto},
        despues: {'texto': limpio},
      );
    });
  }

  /// Marca (o desmarca) la pregunta [id] como preguntada.
  Future<void> marcarPreguntada(String id, bool preguntada) =>
      _db.transaction(() async {
        final p = await pregunta(id);
        if (p == null || p.bajaEn != null || p.preguntada == preguntada) {
          return;
        }
        await (_db.update(
          _db.preguntasConsulta,
        )..where((t) => t.id.equals(id))).write(
          PreguntasConsultaCompanion(
            preguntada: Value(preguntada),
            modificadaPor: Value(_autor()),
            modificadaEn: Value(_ahoraMs),
          ),
        );
        await _fichas.modificada(
          TipoFicha.preguntaConsulta,
          id,
          tabla: 'preguntas_consulta',
          antes: {'preguntada': p.preguntada},
          despues: {'preguntada': preguntada},
        );
      });

  /// Baja lógica: la fila se conserva con `baja_en`.
  Future<void> borrarPregunta(String id) => _db.transaction(() async {
    final p = await pregunta(id);
    if (p == null || p.bajaEn != null) return;
    final ahora = _ahoraMs;
    await (_db.update(
      _db.preguntasConsulta,
    )..where((t) => t.id.equals(id))).write(
      PreguntasConsultaCompanion(
        bajaEn: Value(ahora),
        modificadaPor: Value(_autor()),
        modificadaEn: Value(ahora),
      ),
    );
    await _fichas.modificada(
      TipoFicha.preguntaConsulta,
      id,
      tabla: 'preguntas_consulta',
      antes: {'baja_en': null},
      despues: {'baja_en': ahora},
    );
  });

  // ------------------------------------------------------------- Notas

  /// Notas sin borrar de la cita [citaId], de la más antigua a la más
  /// reciente.
  Stream<List<NotaConsulta>> observarNotas(String citaId) =>
      (_db.select(_db.notasConsulta)
            ..where((n) => n.citaId.equals(citaId) & n.bajaEn.isNull())
            ..orderBy([
              (n) => OrderingTerm.asc(n.creadaEn),
              (n) => OrderingTerm.asc(_orden),
            ]))
          .watch();

  Future<NotaConsulta?> nota(String id) => (_db.select(
    _db.notasConsulta,
  )..where((n) => n.id.equals(id))).getSingleOrNull();

  Future<String> crearNota(String citaId, String texto) async {
    final limpio = _texto(texto, maxNota, 'nota_larga');
    await _citaVigente(citaId);
    return _db.transaction(() async {
      final id = _uuid.v4();
      final ahora = _ahoraMs;
      final autor = _autor();
      await _db
          .into(_db.notasConsulta)
          .insert(
            NotasConsultaCompanion.insert(
              id: id,
              citaId: citaId,
              texto: limpio,
              creadaPor: autor,
              creadaEn: ahora,
              modificadaPor: autor,
              modificadaEn: ahora,
            ),
          );
      await _fichas.creada(TipoFicha.notaConsulta, id);
      return id;
    });
  }

  Future<void> editarNota(String id, String texto) async {
    final limpio = _texto(texto, maxNota, 'nota_larga');
    await _db.transaction(() async {
      final n = await nota(id);
      if (n == null || n.bajaEn != null || n.texto == limpio) return;
      await (_db.update(
        _db.notasConsulta,
      )..where((t) => t.id.equals(id))).write(
        NotasConsultaCompanion(
          texto: Value(limpio),
          modificadaPor: Value(_autor()),
          modificadaEn: Value(_ahoraMs),
        ),
      );
      await _fichas.modificada(
        TipoFicha.notaConsulta,
        id,
        tabla: 'notas_consulta',
        antes: {'texto': n.texto},
        despues: {'texto': limpio},
      );
    });
  }

  Future<void> borrarNota(String id) => _db.transaction(() async {
    final n = await nota(id);
    if (n == null || n.bajaEn != null) return;
    final ahora = _ahoraMs;
    await (_db.update(_db.notasConsulta)..where((t) => t.id.equals(id))).write(
      NotasConsultaCompanion(
        bajaEn: Value(ahora),
        modificadaPor: Value(_autor()),
        modificadaEn: Value(ahora),
      ),
    );
    await _fichas.modificada(
      TipoFicha.notaConsulta,
      id,
      tabla: 'notas_consulta',
      antes: {'baja_en': null},
      despues: {'baja_en': ahora},
    );
  });

  // ------------------------------------------------------------- Grabación

  /// La marca de grabación de la cita [citaId], o nula si no hay (o se
  /// borró).
  Stream<GrabacionConsulta?> observarGrabacion(String citaId) => (_db.select(
    _db.grabacionesConsulta,
  )..where((g) => g.id.equals(citaId) & g.bajaEn.isNull())).watchSingleOrNull();

  /// Todas las marcas de grabación vigentes (para la lista).
  Stream<List<GrabacionConsulta>> observarGrabaciones() => (_db.select(
    _db.grabacionesConsulta,
  )..where((g) => g.bajaEn.isNull())).watch();

  Future<GrabacionConsulta?> grabacion(String citaId) => (_db.select(
    _db.grabacionesConsulta,
  )..where((g) => g.id.equals(citaId))).getSingleOrNull();

  /// Deja la marca de que este móvil tiene la grabación de la cita [citaId]
  /// ([segundos] de audio). Si ya hay una marca vigente de otro móvil, lanza
  /// `grabacion_existente`: antes hay que borrar aquella.
  Future<void> marcarGrabacion(String citaId, int segundos) async {
    if (segundos < 0 || segundos > maxSegundosGrabacion) {
      throw ArgumentError('segundos_no_validos');
    }
    await _citaVigente(citaId);
    await _db.transaction(() async {
      final ya = await grabacion(citaId);
      final ahora = _ahoraMs;
      final autor = _autor();
      if (ya == null) {
        await _db
            .into(_db.grabacionesConsulta)
            .insert(
              GrabacionesConsultaCompanion.insert(
                id: citaId,
                grabadaPor: autor,
                grabadaEn: ahora,
                segundos: segundos,
              ),
            );
        await _fichas.creada(TipoFicha.grabacionConsulta, citaId);
        return;
      }
      if (ya.bajaEn == null) throw StateError('grabacion_existente');
      await (_db.update(
        _db.grabacionesConsulta,
      )..where((t) => t.id.equals(citaId))).write(
        GrabacionesConsultaCompanion(
          grabadaPor: Value(autor),
          grabadaEn: Value(ahora),
          segundos: Value(segundos),
          bajaEn: const Value(null),
        ),
      );
      await _fichas.modificada(
        TipoFicha.grabacionConsulta,
        citaId,
        tabla: 'grabaciones_consulta',
        antes: {'baja_en': ya.bajaEn},
        despues: {
          'grabada_por': autor,
          'grabada_en': ahora,
          'segundos': segundos,
          'baja_en': null,
        },
      );
    });
  }

  /// Quita la marca de la grabación de [citaId] (baja lógica). El audio lo
  /// borra quien llama, en su móvil.
  Future<void> quitarGrabacion(String citaId) => _db.transaction(() async {
    final g = await grabacion(citaId);
    if (g == null || g.bajaEn != null) return;
    final ahora = _ahoraMs;
    await (_db.update(_db.grabacionesConsulta)
          ..where((t) => t.id.equals(citaId)))
        .write(GrabacionesConsultaCompanion(bajaEn: Value(ahora)));
    await _fichas.modificada(
      TipoFicha.grabacionConsulta,
      citaId,
      tabla: 'grabaciones_consulta',
      antes: {'baja_en': null},
      despues: {'baja_en': ahora},
    );
  });
}
