import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
import '../../i18n/fechas.dart';
import '../../sync/fichas.dart';
import '../base_datos.dart';
import 'circulo_repositorio.dart';
import 'eventos_repositorio.dart';

/// Momento de una comida: lo que se guarda en `Comidas.momento`.
abstract final class MomentoComida {
  static const desayuno = 'desayuno';
  static const comida = 'comida';
  static const merienda = 'merienda';
  static const cena = 'cena';

  /// Otra comida fuera de las cuatro (no cuenta en «N de 4»).
  static const otro = 'otro';

  /// Las cuatro comidas del día, en orden.
  static const principales = [desayuno, comida, merienda, cena];

  /// Los valores que se admiten.
  static const valores = [...principales, otro];
}

/// Cuánto comió: lo que se guarda en `Comidas.cuanto`.
abstract final class CuantoComio {
  static const todo = 'todo';
  static const mitad = 'mitad';
  static const poco = 'poco';
  static const nada = 'nada';

  /// Orden en el selector.
  static const valores = [todo, mitad, poco, nada];
}

/// Datos de una comida (nueva o editada).
final class DatosComida {
  const DatosComida({
    required this.momento,
    this.cuanto = CuantoComio.todo,
    required this.ocurridaEn,
    this.nota,
    this.fotoId,
    this.fotoNueva,
  });

  final String momento;
  final String cuanto;

  /// Cuándo fue (instante UTC).
  final DateTime ocurridaEn;
  final String? nota;

  /// La foto que ya tiene (al editar); nula si no tiene o se quita.
  final String? fotoId;

  /// Una foto nueva (hecha o elegida ahora): sustituye a [fotoId].
  final FotoNueva? fotoNueva;
}

/// Comidas y vasos de agua de la persona. Son fichas: cada cambio deja
/// `ficha_creada`/`ficha_modificada` con la fila entera para los demás
/// móviles y gana el más reciente. Borrar es baja lógica (`baja_en`).
///
/// Cada vaso es una fila de `vasos: 1`: sumar crea una, restar da de baja la
/// última del día, y dos móviles que suman a la vez suman los dos.
class AlimentacionRepositorio {
  AlimentacionRepositorio({
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

  /// Quién anota (el familiar de este móvil).
  final String Function() _autor;
  final Uuid _uuid;

  late final PublicadorFichas _fichas = PublicadorFichas(
    db: _db,
    eventos: _eventos,
    contexto: _contexto,
  );

  int get _ahoraMs => _reloj.ahora().millisecondsSinceEpoch;

  static String? _limpio(String? t) {
    final s = (t ?? '').trim();
    return s.isEmpty ? null : s;
  }

  // ------------------------------------------------------------- Comidas

  /// Comidas sin borrar desde [desde] (por defecto, todas), de la más
  /// antigua a la más reciente.
  Stream<List<Comida>> observarComidas({DateTime? desde}) =>
      (_db.select(_db.comidas)
            ..where(
              (c) =>
                  c.personaId.equals(_contexto.personaId) &
                  c.bajaEn.isNull() &
                  (desde == null
                      ? const Constant(true)
                      : c.ocurridaEn.isBiggerOrEqualValue(
                          desde.millisecondsSinceEpoch,
                        )),
            )
            ..orderBy([(c) => OrderingTerm.asc(c.ocurridaEn)]))
          .watch();

  Future<Comida?> comida(String id) => (_db.select(
    _db.comidas,
  )..where((c) => c.id.equals(id))).getSingleOrNull();

  void _validarComida(DatosComida d) {
    if (!MomentoComida.valores.contains(d.momento)) {
      throw ArgumentError('momento_no_valido');
    }
    if (!CuantoComio.valores.contains(d.cuanto)) {
      throw ArgumentError('cuanto_no_valido');
    }
  }

  Future<String?> _fotoDe(DatosComida d) async {
    final nueva = d.fotoNueva;
    return nueva == null ? d.fotoId : _circulo.guardarFoto(nueva);
  }

  Future<String> crearComida(DatosComida d) async {
    _validarComida(d);
    final fotoId = await _fotoDe(d);
    return _db.transaction(() async {
      final id = _uuid.v4();
      await _db
          .into(_db.comidas)
          .insert(
            ComidasCompanion.insert(
              id: id,
              personaId: _contexto.personaId,
              momento: d.momento,
              cuanto: d.cuanto,
              fotoId: Value(fotoId),
              nota: Value(_limpio(d.nota)),
              ocurridaEn: d.ocurridaEn.millisecondsSinceEpoch,
              registradaPor: _autor(),
            ),
          );
      await _fichas.creada(TipoFicha.comida, id);
      return id;
    });
  }

  /// Cambia todos los datos de la comida [id]. Sin cambios, no hace nada.
  Future<void> editarComida(String id, DatosComida d) async {
    _validarComida(d);
    final fotoId = await _fotoDe(d);
    await _db.transaction(() async {
      final c = await comida(id);
      if (c == null || c.bajaEn != null) return;
      final nota = _limpio(d.nota);
      final cuando = d.ocurridaEn.millisecondsSinceEpoch;
      if (c.momento == d.momento &&
          c.cuanto == d.cuanto &&
          c.ocurridaEn == cuando &&
          c.nota == nota &&
          c.fotoId == fotoId) {
        return;
      }
      await (_db.update(_db.comidas)..where((t) => t.id.equals(id))).write(
        ComidasCompanion(
          momento: Value(d.momento),
          cuanto: Value(d.cuanto),
          ocurridaEn: Value(cuando),
          nota: Value(nota),
          fotoId: Value(fotoId),
        ),
      );
      await _fichas.modificada(
        TipoFicha.comida,
        id,
        tabla: 'comidas',
        antes: {
          'momento': c.momento,
          'cuanto': c.cuanto,
          'ocurrida_en': c.ocurridaEn,
          'nota': c.nota,
          'foto_id': c.fotoId,
        },
        despues: {
          'momento': d.momento,
          'cuanto': d.cuanto,
          'ocurrida_en': cuando,
          'nota': nota,
          'foto_id': fotoId,
        },
      );
    });
  }

  /// Baja lógica: la fila se conserva con `baja_en`.
  Future<void> borrarComida(String id) => _db.transaction(() async {
    final c = await comida(id);
    if (c == null || c.bajaEn != null) return;
    final baja = _ahoraMs;
    await (_db.update(_db.comidas)..where((t) => t.id.equals(id))).write(
      ComidasCompanion(bajaEn: Value(baja)),
    );
    await _fichas.modificada(
      TipoFicha.comida,
      id,
      tabla: 'comidas',
      antes: {'baja_en': null},
      despues: {'baja_en': baja},
    );
  });

  // ------------------------------------------------------------- Vasos

  /// Vasos sin quitar desde [desde] (por defecto, todos), del más antiguo
  /// al más reciente.
  Stream<List<Hidratacion>> observarVasos({DateTime? desde}) =>
      (_db.select(_db.hidrataciones)
            ..where(
              (h) =>
                  h.personaId.equals(_contexto.personaId) &
                  h.bajaEn.isNull() &
                  (desde == null
                      ? const Constant(true)
                      : h.ocurridaEn.isBiggerOrEqualValue(
                          desde.millisecondsSinceEpoch,
                        )),
            )
            ..orderBy([(h) => OrderingTerm.asc(h.ocurridaEn)]))
          .watch();

  /// Suma un vaso ahora.
  Future<String> sumarVaso() => _db.transaction(() async {
    final id = _uuid.v4();
    await _db
        .into(_db.hidrataciones)
        .insert(
          HidratacionesCompanion.insert(
            id: id,
            personaId: _contexto.personaId,
            ocurridaEn: _ahoraMs,
            registradaPor: _autor(),
          ),
        );
    await _fichas.creada(TipoFicha.hidratacion, id);
    return id;
  });

  /// Quita el último vaso de hoy (baja lógica). Devuelve `false` si hoy no
  /// hay ninguno.
  Future<bool> restarVaso() => _db.transaction(() async {
    final ahora = _reloj.ahora();
    final zona = _contexto.zonaHoraria;
    final desde = inicioDelDia(ahora, zona).millisecondsSinceEpoch;
    final ultimo =
        await (_db.select(_db.hidrataciones)
              ..where(
                (h) =>
                    h.personaId.equals(_contexto.personaId) &
                    h.bajaEn.isNull() &
                    h.ocurridaEn.isBiggerOrEqualValue(desde),
              )
              ..orderBy([
                (h) => OrderingTerm.desc(h.ocurridaEn),
                (h) => OrderingTerm.desc(h.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (ultimo == null) return false;
    final baja = _ahoraMs;
    await (_db.update(_db.hidrataciones)..where((h) => h.id.equals(ultimo.id)))
        .write(HidratacionesCompanion(bajaEn: Value(baja)));
    await _fichas.modificada(
      TipoFicha.hidratacion,
      ultimo.id,
      tabla: 'hidrataciones',
      antes: {'baja_en': null},
      despues: {'baja_en': baja},
    );
    return true;
  });

  /// Inserta un vaso en un instante dado (la semilla de la demo).
  Future<String> anotarVasoEn(DateTime cuando) => _db.transaction(() async {
    final id = _uuid.v4();
    await _db
        .into(_db.hidrataciones)
        .insert(
          HidratacionesCompanion.insert(
            id: id,
            personaId: _contexto.personaId,
            ocurridaEn: cuando.millisecondsSinceEpoch,
            registradaPor: _autor(),
          ),
        );
    await _fichas.creada(TipoFicha.hidratacion, id);
    return id;
  });
}
