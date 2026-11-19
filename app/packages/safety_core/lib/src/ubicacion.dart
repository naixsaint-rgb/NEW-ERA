import 'dart:math' as math;

/// Ubicación del móvil de la persona y zona segura (plan v3, 7.1 a 7.3).
/// Lógica pura: la app lee las posiciones (`ubicacion_registrada`) y la zona
/// del círculo, y aquí se decide si está dentro, fuera o sin posición.

/// Cuánto se guarda una posición en cada móvil. Pasado ese tiempo se borra
/// (o, si llega por el cartero, se ignora).
const retencionUbicacion = Duration(days: 7);

/// Cada cuánto se toma una posición con la app de la persona abierta.
const intervaloUbicacion = Duration(minutes: 5);

/// Con la búsqueda activa («Buscarla ahora»), cada cuánto con la app
/// abierta.
const intervaloBusqueda = Duration(minutes: 1);

/// Lo que dura una búsqueda pedida por la familia.
const duracionBusqueda = Duration(minutes: 30);

/// Sin una posición en este tiempo, la familia ve «Sin posición desde…».
const sinPosicionTras = Duration(minutes: 90);

/// Radios que se ofrecen para la zona segura (metros).
const radiosZona = [100, 200, 500];

/// Radio por defecto (metros).
const radioZonaPorDefecto = 200;

/// Una lectura con precisión peor que esta (metros) no cuenta para nada:
/// es una lectura mala.
const precisionInservible = 1000.0;

/// Una lectura con precisión igual o mejor que esta (metros) es «buena»:
/// basta una sola, claramente fuera, para dar la salida.
const precisionBuena = 50.0;

/// De dónde sale una posición.
enum OrigenUbicacion {
  /// Con la app de la persona abierta, cada [intervaloUbicacion].
  appAbierta('app_abierta'),

  /// Revisión con la app cerrada (Android).
  segundoPlano('segundo_plano'),

  /// Al sonar una toma o una ronda.
  alarma('alarma'),

  /// Al pedir ayuda.
  ayuda('ayuda'),

  /// Búsqueda pedida por la familia.
  busqueda('busqueda');

  const OrigenUbicacion(this.nombre);
  final String nombre;

  static OrigenUbicacion? desdeNombre(Object? nombre) {
    for (final o in values) {
      if (o.nombre == nombre) return o;
    }
    return null;
  }
}

/// Una posición del móvil de la persona.
final class LecturaUbicacion {
  const LecturaUbicacion({
    required this.id,
    required this.lat,
    required this.lon,
    required this.precision,
    required this.instante,
    this.bateria,
    this.origen,
  });

  /// Ulid del evento `ubicacion_registrada`.
  final String id;
  final double lat;
  final double lon;

  /// Radio de error en metros (el que da el sistema).
  final double precision;
  final DateTime instante;

  /// Batería del móvil (0 a 100), si se pudo leer.
  final int? bateria;
  final OrigenUbicacion? origen;

  /// Lectura desde el payload de un `ubicacion_registrada`; nula si falta
  /// algo o está fuera de rango.
  static LecturaUbicacion? desdePayload(
    String id,
    DateTime instante,
    Map<String, Object?> p,
  ) {
    final lat = p['lat'], lon = p['lon'], prec = p['precision'];
    if (lat is! num || lon is! num || prec is! num) return null;
    if (lat.abs() > 90 || lon.abs() > 180 || prec < 0 || prec.isNaN) {
      return null;
    }
    final bat = p['bateria'];
    return LecturaUbicacion(
      id: id,
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      precision: prec.toDouble(),
      instante: instante,
      bateria: bat is int && bat >= 0 && bat <= 100 ? bat : null,
      origen: OrigenUbicacion.desdeNombre(p['origen']),
    );
  }

  /// Payload del evento `ubicacion_registrada`.
  static Map<String, Object?> payload({
    required double lat,
    required double lon,
    required double precision,
    required OrigenUbicacion origen,
    int? bateria,
  }) => {
    'lat': lat,
    'lon': lon,
    'precision': precision,
    'bateria': ?bateria,
    'origen': origen.nombre,
  };
}

/// Zona segura del círculo («Casa»): centro y radio en metros.
final class ZonaSegura {
  const ZonaSegura({
    required this.lat,
    required this.lon,
    this.radio = radioZonaPorDefecto,
  });

  final double lat;
  final double lon;
  final int radio;

  /// Margen por fuera del radio que hay que pasar para contar como fuera
  /// (histéresis): para volver basta con estar dentro del radio.
  double get histeresis => math.max(25, radio * 0.15);

  bool get valida =>
      lat.abs() <= 90 && lon.abs() <= 180 && radio >= 50 && radio <= 5000;

  @override
  bool operator ==(Object other) =>
      other is ZonaSegura &&
      other.lat == lat &&
      other.lon == lon &&
      other.radio == radio;

  @override
  int get hashCode => Object.hash(lat, lon, radio);
}

/// Distancia en metros entre dos puntos (haversine, radio medio de la
/// Tierra).
double distanciaMetros(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  double rad(double g) => g * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}

/// Dónde está respecto a la zona.
enum EstadoZona {
  /// Sin zona elegida o sin ninguna lectura que valga.
  desconocido,
  dentro,
  fuera,
}

/// Lo que ve la familia: estado, desde cuándo está fuera (y qué lectura dio
/// la salida), la última lectura y si es reciente.
final class SituacionZona {
  const SituacionZona({
    required this.estado,
    this.ultima,
    this.reciente = false,
    this.salida,
    this.fueraDesde,
    this.salidaConfirmadaEn,
  });

  final EstadoZona estado;

  /// Última lectura (valga o no para la zona), si hay.
  final LecturaUbicacion? ultima;

  /// La última lectura tiene menos de [sinPosicionTras].
  final bool reciente;

  /// Con [EstadoZona.fuera]: id de la lectura que abrió la salida (una por
  /// salida: es el origen del aviso `fuera_de_zona`).
  final String? salida;

  /// Con [EstadoZona.fuera]: hora de esa lectura.
  final DateTime? fueraDesde;

  /// Con [EstadoZona.fuera]: hora de la lectura que confirmó la salida (la
  /// misma o la segunda seguida). Es cuando toca avisar.
  final DateTime? salidaConfirmadaEn;

  bool get fuera => estado == EstadoZona.fuera;
}

/// Evalúa [lecturas] (en cualquier orden) contra [zona] en [ahora]:
///
/// - Se descartan las lecturas con precisión peor que [precisionInservible].
/// - Dentro → fuera: una lectura buena ([precisionBuena]) cuyo círculo de
///   error entero queda fuera del radio más la histéresis, o dos lecturas
///   seguidas con el centro fuera del radio más la histéresis.
/// - Fuera → dentro: una lectura con el centro dentro del radio y precisión
///   no peor que el radio. Al principio (sin estado), basta no estar fuera.
/// - Lo que cae entre medias no cambia el estado (y corta la racha de
///   lecturas fuera).
///
/// Sin [zona], el estado es [EstadoZona.desconocido] (con la última lectura).
SituacionZona evaluarZona({
  required ZonaSegura? zona,
  required Iterable<LecturaUbicacion> lecturas,
  required DateTime ahora,
}) {
  final orden = [...lecturas]
    ..sort((a, b) {
      final c = a.instante.compareTo(b.instante);
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  final ultima = orden.lastOrNull;
  final reciente =
      ultima != null && ahora.difference(ultima.instante) < sinPosicionTras;
  if (zona == null || !zona.valida) {
    return SituacionZona(
      estado: EstadoZona.desconocido,
      ultima: ultima,
      reciente: reciente,
    );
  }
  var estado = EstadoZona.desconocido;
  LecturaUbicacion? candidata; // primera lectura fuera de la racha
  LecturaUbicacion? salida;
  DateTime? confirmada;
  final umbralFuera = zona.radio + zona.histeresis;
  for (final l in orden) {
    if (l.precision > precisionInservible) continue;
    final d = distanciaMetros(zona.lat, zona.lon, l.lat, l.lon);
    final centroFuera = d > umbralFuera;
    final centroDentro = d <= zona.radio;
    if (estado == EstadoZona.fuera) {
      if (centroDentro && l.precision <= zona.radio) {
        estado = EstadoZona.dentro;
        salida = null;
        confirmada = null;
      }
      continue;
    }
    if (centroFuera) {
      final clara =
          l.precision <= precisionBuena && d - l.precision > umbralFuera;
      if (clara || candidata != null) {
        estado = EstadoZona.fuera;
        salida = candidata ?? l;
        confirmada = l.instante;
        candidata = null;
      } else {
        candidata = l;
      }
      continue;
    }
    // Dentro, o en la franja de la histéresis: no es una salida.
    candidata = null;
    estado = EstadoZona.dentro;
  }
  return SituacionZona(
    estado: estado,
    ultima: ultima,
    reciente: reciente,
    salida: estado == EstadoZona.fuera ? salida?.id : null,
    fueraDesde: estado == EstadoZona.fuera ? salida?.instante : null,
    salidaConfirmadaEn: estado == EstadoZona.fuera ? confirmada : null,
  );
}

/// Una búsqueda pedida por la familia (`busqueda_pedida`): hasta cuándo.
/// Una búsqueda parada antes de tiempo es otra con [hasta] = cuándo se paró.
final class BusquedaPedida {
  const BusquedaPedida({required this.pedidaEn, required this.hasta});

  final DateTime pedidaEn;
  final DateTime hasta;

  bool activaEn(DateTime ahora) =>
      !ahora.isBefore(pedidaEn.subtract(const Duration(minutes: 5))) &&
      ahora.isBefore(hasta);
}

/// La búsqueda vigente de [pedidas] en [ahora] (la última pedida manda), o
/// nula.
BusquedaPedida? busquedaActiva(
  Iterable<BusquedaPedida> pedidas,
  DateTime ahora,
) {
  BusquedaPedida? ultima;
  for (final b in pedidas) {
    if (ultima == null || !b.pedidaEn.isBefore(ultima.pedidaEn)) ultima = b;
  }
  return ultima != null && ultima.activaEn(ahora) ? ultima : null;
}
