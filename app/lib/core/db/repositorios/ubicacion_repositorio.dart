import 'package:drift/drift.dart';
import 'package:safety_core/safety_core.dart';
import 'package:uuid/uuid.dart';

import '../../contexto.dart';
import '../../plataforma/ubicacion/ubicador.dart';
import '../../sync/fichas.dart';
import '../base_datos.dart';
import 'eventos_repositorio.dart';

/// Estado del consentimiento de ubicación del círculo.
typedef ConsentimientoUbicacion = ({bool activo, Consentimiento? ultimo});

/// Ubicación del móvil de la persona (plan v3, 7.1 a 7.3).
///
/// - Consentimiento: `consentimientos` con `sobre = 'ubicacion'`, el texto
///   que vio el familiar y la fecha; viaja como ficha `consentimiento`.
///   Apagar es otra fila con `revoca_a` = la vigente. Está encendida si hay
///   alguna sin revocar ([vigente]).
/// - Posiciones: eventos `ubicacion_registrada` (cifrados por el cartero como
///   todos). Solo se guardan con el consentimiento vigente. Cada móvil borra
///   las de más de [retencionUbicacion] y, con el consentimiento apagado,
///   todas ([purgar]).
/// - Zona segura: una fila por círculo en `ajustes_ubicacion`, ficha
///   `ajustes_ubicacion` (gana la más reciente).
/// - Búsqueda («Buscarla ahora»): evento `busqueda_pedida` con su `hasta`.
class UbicacionRepositorio {
  UbicacionRepositorio({
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

  /// Quién firma los cambios (el familiar de este móvil, o la persona).
  final String Function() _autor;
  final Uuid _uuid;

  static const sobre = 'ubicacion';

  late final PublicadorFichas _fichas = PublicadorFichas(
    db: _db,
    eventos: _eventos,
    contexto: _contexto,
  );

  DateTime get _ahora => _reloj.ahora();

  // ------------------------------------------------------- Consentimiento

  SimpleSelectStatement<$ConsentimientosTable, Consentimiento>
  _consentimientos() => _db.select(_db.consentimientos)
    ..where(
      (c) => c.circuloId.equals(_contexto.circuloId) & c.sobre.equals(sobre),
    )
    ..orderBy([
      (c) => OrderingTerm.desc(c.otorgadoEn),
      (c) => OrderingTerm.desc(c.id),
    ]);

  static ConsentimientoUbicacion _estado(List<Consentimiento> filas) =>
      (activo: vigente(filas) != null, ultimo: filas.firstOrNull);

  /// El permiso vigente de [filas] (de un círculo y sobre `ubicacion`): el
  /// más reciente que no está revocado por otra fila (`revoca_a`). Así no
  /// importa el orden en que lleguen ni que dos tengan la misma hora.
  static Consentimiento? vigente(Iterable<Consentimiento> filas) {
    final revocados = {
      for (final f in filas)
        if (f.revocaA != null) f.revocaA,
    };
    Consentimiento? r;
    for (final f in filas) {
      if (f.revocaA != null || revocados.contains(f.id)) continue;
      if (r == null || f.otorgadoEn > r.otorgadoEn) r = f;
    }
    return r;
  }

  Stream<ConsentimientoUbicacion> observarConsentimiento() =>
      _consentimientos().watch().map(_estado);

  Future<ConsentimientoUbicacion> consentimiento() async =>
      _estado(await _consentimientos().get());

  Future<bool> consentimientoActivo() async => (await consentimiento()).activo;

  /// Guarda el consentimiento de [miembroId], en nombre de la persona, con
  /// el texto exacto que vio. Si ya está activo, no hace nada. Devuelve el
  /// id del consentimiento vigente.
  Future<String> otorgar({
    required String miembroId,
    required String textoMostrado,
  }) {
    if (textoMostrado.trim().isEmpty) throw ArgumentError('texto_obligatorio');
    return _db.transaction(() async {
      final ya = vigente(await _consentimientos().get());
      if (ya != null) return ya.id;
      return _insertar(miembroId, textoMostrado, null);
    });
  }

  /// Apaga la ubicación: otra fila con `revoca_a` y el texto que vio quien
  /// la apagó. Borra las posiciones de este móvil; los demás las borran al
  /// recibirla.
  Future<void> revocar({
    required String miembroId,
    required String textoMostrado,
  }) async {
    await _db.transaction(() async {
      // Se revocan todos los vigentes (dos altas a la vez en dos móviles).
      for (
        var ya = vigente(await _consentimientos().get());
        ya != null;
        ya = vigente(await _consentimientos().get())
      ) {
        await _insertar(miembroId, textoMostrado, ya.id);
      }
    });
    await purgar();
  }

  Future<String> _insertar(String miembro, String texto, String? revoca) async {
    final id = _uuid.v4();
    await _db
        .into(_db.consentimientos)
        .insert(
          ConsentimientosCompanion.insert(
            id: id,
            circuloId: _contexto.circuloId,
            otorgante: miembro,
            enNombreDe: Value(_contexto.personaId),
            sobre: sobre,
            textoMostrado: texto,
            otorgadoEn: _ahora.millisecondsSinceEpoch,
            revocaA: Value(revoca),
          ),
        );
    await _fichas.creada(TipoFicha.consentimiento, id);
    return id;
  }

  // ------------------------------------------------------- Posiciones

  /// Guarda [posicion] como `ubicacion_registrada` firmada por la persona.
  /// Sin el consentimiento vigente no guarda nada (devuelve nulo). La hora es
  /// la del sistema de ubicación (si viene del futuro, la del reloj). Con
  /// [ayuda], el ulid del `ayuda_pedida` al que acompaña.
  Future<String?> registrar(
    PosicionGps posicion, {
    required OrigenUbicacion origen,
    int? bateria,
    PermisoUbicacion? permiso,
    String? ayuda,
  }) async {
    if (!await consentimientoActivo()) return null;
    if (posicion.lat.abs() > 90 ||
        posicion.lon.abs() > 180 ||
        posicion.precision.isNaN ||
        posicion.precision < 0) {
      return null;
    }
    final ahora = _ahora;
    // Una hora en el futuro (relojes distintos) pasa a ser «ahora»; una
    // posición vieja (en caché) se queda con su hora de verdad.
    final cuando =
        posicion.instante.isAfter(ahora.add(const Duration(minutes: 1)))
        ? ahora
        : posicion.instante;
    if (ahora.difference(cuando) > retencionUbicacion) return null;
    final ulid = await _eventos.registrar(
      TipoEvento.ubicacionRegistrada,
      sujeto: _contexto.personaId,
      ocurridoEn: cuando,
      autor: _contexto.personaId,
      payload: {
        ...LecturaUbicacion.payload(
          lat: posicion.lat,
          lon: posicion.lon,
          precision: posicion.precision,
          bateria: bateria,
          origen: origen,
        ),
        if (permiso != null) 'permiso': permiso.nombre,
        'ayuda': ?ayuda,
      },
    );
    return ulid;
  }

  /// Posiciones desde [desde] (nunca de más de 7 días), de la más antigua a
  /// la más reciente.
  Stream<List<LecturaUbicacion>> observarLecturas({DateTime? desde}) {
    final limite = _ahora.subtract(retencionUbicacion);
    final d = desde == null || desde.isBefore(limite) ? limite : desde;
    final q = _db.select(_db.eventos)
      ..where(
        (e) =>
            e.tipo.equals(TipoEvento.ubicacionRegistrada.nombre) &
            e.ocurridoEn.isBiggerOrEqualValue(d.millisecondsSinceEpoch),
      )
      ..orderBy([
        (e) => OrderingTerm.asc(e.ocurridoEn),
        (e) => OrderingTerm.asc(e.ulid),
      ]);
    return q.watch().map(lecturasDe);
  }

  /// Convierte filas `ubicacion_registrada` en lecturas (las que valgan).
  static List<LecturaUbicacion> lecturasDe(Iterable<Evento> filas) => [
    for (final f in filas)
      ?LecturaUbicacion.desdePayload(
        f.ulid,
        DateTime.fromMillisecondsSinceEpoch(f.ocurridoEn, isUtc: true),
        EventosRepositorio.payloadDe(f),
      ),
  ];

  /// Permiso del sistema que tenía el móvil de la persona en su última
  /// posición (nulo si no lo dijo).
  Stream<PermisoUbicacion?> observarPermisoDelMovil() {
    final q = _db.select(_db.eventos)
      ..where((e) => e.tipo.equals(TipoEvento.ubicacionRegistrada.nombre))
      ..orderBy([
        (e) => OrderingTerm.desc(e.ocurridoEn),
        (e) => OrderingTerm.desc(e.ulid),
      ])
      ..limit(1);
    return q.watchSingleOrNull().map(
      (e) => e == null
          ? null
          : PermisoUbicacion.desdeNombre(
              EventosRepositorio.payloadDe(e)['permiso'],
            ),
    );
  }

  /// Borra las posiciones de más de [retencionUbicacion] y, si el
  /// consentimiento está apagado, todas. Devuelve cuántas borró. Nunca lanza.
  Future<int> purgar() async {
    try {
      final activo = await consentimientoActivo();
      final limite = _ahora.subtract(retencionUbicacion).millisecondsSinceEpoch;
      return await (_db.delete(_db.eventos)..where(
            (e) =>
                e.tipo.equals(TipoEvento.ubicacionRegistrada.nombre) &
                (activo
                    ? e.ocurridoEn.isSmallerThanValue(limite)
                    : const Constant(true)),
          ))
          .go();
    } catch (_) {
      return 0;
    }
  }

  // ------------------------------------------------------- Zona segura

  SimpleSelectStatement<$AjustesUbicacionTable, FilaAjustesUbicacion>
  _ajustes() =>
      _db.select(_db.ajustesUbicacion)
        ..where((a) => a.id.equals(_contexto.circuloId));

  static ZonaSegura? aZona(FilaAjustesUbicacion? f) {
    final lat = f?.zonaLat, lon = f?.zonaLon;
    if (f == null || lat == null || lon == null) return null;
    final z = ZonaSegura(lat: lat, lon: lon, radio: f.zonaRadio);
    return z.valida ? z : null;
  }

  Future<ZonaSegura?> zona() async => aZona(await _ajustes().getSingleOrNull());

  Stream<ZonaSegura?> observarZona() =>
      _ajustes().watchSingleOrNull().map(aZona);

  /// Radio guardado aunque aún no haya centro (por defecto, 200 m).
  Stream<int> observarRadio() => _ajustes().watchSingleOrNull().map(
    (f) => f?.zonaRadio ?? radioZonaPorDefecto,
  );

  /// Pone el centro de la zona en ([lat], [lon]) con [radio] (si no se da,
  /// el que ya tenía) y deja la ficha para los demás móviles.
  Future<void> guardarZona({double? lat, double? lon, int? radio}) {
    return _db.transaction(() async {
      final ya = await _ajustes().getSingleOrNull();
      final nuevoLat = lat ?? ya?.zonaLat;
      final nuevoLon = lon ?? ya?.zonaLon;
      final nuevoRadio = radio ?? ya?.zonaRadio ?? radioZonaPorDefecto;
      if (!radiosZona.contains(nuevoRadio)) {
        throw ArgumentError('radio_no_valido');
      }
      if ((nuevoLat != null && nuevoLat.abs() > 90) ||
          (nuevoLon != null && nuevoLon.abs() > 180)) {
        throw ArgumentError('centro_no_valido');
      }
      if (ya != null &&
          ya.zonaLat == nuevoLat &&
          ya.zonaLon == nuevoLon &&
          ya.zonaRadio == nuevoRadio) {
        return;
      }
      final fila = AjustesUbicacionCompanion.insert(
        id: _contexto.circuloId,
        zonaLat: Value(nuevoLat),
        zonaLon: Value(nuevoLon),
        zonaRadio: Value(nuevoRadio),
        zonaNombre: Value(ya?.zonaNombre),
        modificadoPor: _autor(),
        modificadoEn: _ahora.millisecondsSinceEpoch,
      );
      if (ya == null) {
        await _db.into(_db.ajustesUbicacion).insert(fila);
        await _fichas.creada(TipoFicha.ajustesUbicacion, _contexto.circuloId);
        return;
      }
      await (_db.update(
        _db.ajustesUbicacion,
      )..where((a) => a.id.equals(ya.id))).write(fila);
      Map<String, Object?> valores(double? la, double? lo, int r) => {
        'zona_lat': la,
        'zona_lon': lo,
        'zona_radio': r,
      };
      await _fichas.modificada(
        TipoFicha.ajustesUbicacion,
        ya.id,
        tabla: 'ajustes_ubicacion',
        antes: valores(ya.zonaLat, ya.zonaLon, ya.zonaRadio),
        despues: valores(nuevoLat, nuevoLon, nuevoRadio),
      );
    });
  }

  // ------------------------------------------------------- Búsqueda

  /// «Buscarla ahora»: el móvil de la persona toma posiciones frecuentes
  /// durante [duracionBusqueda].
  Future<String> pedirBusqueda() {
    final ahora = _ahora;
    return _eventos.registrar(
      TipoEvento.busquedaPedida,
      sujeto: _contexto.personaId,
      ocurridoEn: ahora,
      payload: {'hasta': ahora.add(duracionBusqueda).millisecondsSinceEpoch},
    );
  }

  /// Para la búsqueda antes de tiempo.
  Future<String> pararBusqueda() {
    final ahora = _ahora;
    return _eventos.registrar(
      TipoEvento.busquedaPedida,
      sujeto: _contexto.personaId,
      ocurridoEn: ahora,
      payload: {'hasta': ahora.millisecondsSinceEpoch},
    );
  }

  SimpleSelectStatement<$EventosTable, Evento> _busquedas() =>
      _db.select(_db.eventos)
        ..where(
          (e) =>
              e.tipo.equals(TipoEvento.busquedaPedida.nombre) &
              e.ocurridoEn.isBiggerOrEqualValue(
                _ahora.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
              ),
        )
        ..orderBy([(e) => OrderingTerm.asc(e.ocurridoEn)]);

  static List<BusquedaPedida> busquedasDe(Iterable<Evento> filas) => [
    for (final f in filas)
      if (EventosRepositorio.payloadDe(f)['hasta'] case final int hasta)
        BusquedaPedida(
          pedidaEn: DateTime.fromMillisecondsSinceEpoch(
            f.ocurridoEn,
            isUtc: true,
          ),
          hasta: DateTime.fromMillisecondsSinceEpoch(hasta, isUtc: true),
        ),
  ];

  /// Búsquedas de las últimas 24 horas.
  Stream<List<BusquedaPedida>> observarBusquedas() =>
      _busquedas().watch().map(busquedasDe);

  /// La búsqueda vigente ahora, o nula.
  Future<BusquedaPedida?> busqueda() async =>
      busquedaActiva(busquedasDe(await _busquedas().get()), _ahora);
}
