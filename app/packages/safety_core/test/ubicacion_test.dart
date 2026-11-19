import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

/// Un punto céntrico genérico de Madrid (ejemplo neutro, no es una casa).
const _lat = 40.4168;
const _lon = -3.7038;

/// Un grado de latitud son unos 111 195 m.
double _norte(double metros) => _lat + metros / 111195;

final _t0 = DateTime.utc(2026, 10, 13, 10);

LecturaUbicacion _l(
  String id,
  int minuto, {
  double metros = 0,
  double precision = 20,
}) => LecturaUbicacion(
  id: id,
  lat: _norte(metros),
  lon: _lon,
  precision: precision,
  instante: _t0.add(Duration(minutes: minuto)),
);

const _zona = ZonaSegura(lat: _lat, lon: _lon, radio: 200);

SituacionZona _evaluar(List<LecturaUbicacion> l, {int ahora = 60}) =>
    evaluarZona(
      zona: _zona,
      lecturas: l,
      ahora: _t0.add(Duration(minutes: ahora)),
    );

void main() {
  test('distancia: 1 km al norte son unos 1000 m', () {
    expect(distanciaMetros(_lat, _lon, _norte(1000), _lon), closeTo(1000, 1));
    expect(distanciaMetros(_lat, _lon, _lat, _lon), 0);
  });

  test('sin zona: desconocido, con la última lectura', () {
    final s = evaluarZona(
      zona: null,
      lecturas: [_l('a', 0), _l('b', 5)],
      ahora: _t0.add(const Duration(minutes: 10)),
    );
    expect(s.estado, EstadoZona.desconocido);
    expect(s.ultima?.id, 'b');
    expect(s.reciente, isTrue);
  });

  test('dentro con lecturas en casa', () {
    final s = _evaluar([_l('a', 0), _l('b', 5, metros: 150)]);
    expect(s.estado, EstadoZona.dentro);
    expect(s.salida, isNull);
  });

  test('una lectura buena claramente fuera basta para salir', () {
    final s = _evaluar([_l('a', 0), _l('b', 5, metros: 600, precision: 15)]);
    expect(s.estado, EstadoZona.fuera);
    expect(s.salida, 'b');
    expect(s.fueraDesde, _t0.add(const Duration(minutes: 5)));
    expect(s.salidaConfirmadaEn, _t0.add(const Duration(minutes: 5)));
  });

  test('una lectura mala fuera no basta: hacen falta dos seguidas', () {
    var s = _evaluar([_l('a', 0), _l('b', 5, metros: 600, precision: 300)]);
    expect(s.estado, EstadoZona.dentro);
    s = _evaluar([
      _l('a', 0),
      _l('b', 5, metros: 600, precision: 300),
      _l('c', 10, metros: 650, precision: 300),
    ]);
    expect(s.estado, EstadoZona.fuera);
    // La salida es la primera de las dos; se confirma con la segunda.
    expect(s.salida, 'b');
    expect(s.fueraDesde, _t0.add(const Duration(minutes: 5)));
    expect(s.salidaConfirmadaEn, _t0.add(const Duration(minutes: 10)));
  });

  test('una lectura en medio corta la racha', () {
    final s = _evaluar([
      _l('a', 0),
      _l('b', 5, metros: 600, precision: 300),
      _l('c', 10, metros: 50),
      _l('d', 15, metros: 600, precision: 300),
    ]);
    expect(s.estado, EstadoZona.dentro);
  });

  test('lecturas inservibles (más de 1 km de error) no cuentan', () {
    final s = _evaluar([
      _l('a', 0),
      _l('b', 5, metros: 3000, precision: 1500),
      _l('c', 10, metros: 3000, precision: 1500),
    ]);
    expect(s.estado, EstadoZona.dentro);
    // Pero sí es la última lectura.
    expect(s.ultima?.id, 'c');
  });

  test('histéresis: en la franja justo fuera del radio no sale', () {
    // Radio 200 + 30 de histéresis: a 220 m sigue dentro.
    final s = _evaluar([
      _l('a', 0),
      _l('b', 5, metros: 220, precision: 5),
      _l('c', 10, metros: 225, precision: 5),
    ]);
    expect(_zona.histeresis, 30);
    expect(s.estado, EstadoZona.dentro);
  });

  test('histéresis: fuera, en la franja no vuelve; dentro del radio, sí', () {
    final salir = [_l('a', 0), _l('b', 5, metros: 600, precision: 10)];
    var s = _evaluar([...salir, _l('c', 10, metros: 220, precision: 10)]);
    expect(s.estado, EstadoZona.fuera);
    expect(s.salida, 'b');
    s = _evaluar([...salir, _l('c', 10, metros: 100, precision: 10)]);
    expect(s.estado, EstadoZona.dentro);
    expect(s.salida, isNull);
  });

  test('cada salida tiene su propio origen', () {
    final s = _evaluar([
      _l('a', 0),
      _l('b', 5, metros: 600, precision: 10),
      _l('c', 10, metros: 0),
      _l('d', 15, metros: 800, precision: 10),
    ]);
    expect(s.estado, EstadoZona.fuera);
    expect(s.salida, 'd');
  });

  test('el orden de llegada no importa', () {
    final s = _evaluar([
      _l('c', 10, metros: 650, precision: 300),
      _l('a', 0),
      _l('b', 5, metros: 600, precision: 300),
    ]);
    expect(s.salida, 'b');
  });

  test('sin posición reciente', () {
    var s = _evaluar([_l('a', 0)], ahora: 89);
    expect(s.reciente, isTrue);
    s = _evaluar([_l('a', 0)], ahora: 90);
    expect(s.reciente, isFalse);
    expect(s.estado, EstadoZona.dentro);
    s = _evaluar(const []);
    expect(s.estado, EstadoZona.desconocido);
    expect(s.ultima, isNull);
    expect(s.reciente, isFalse);
  });

  test('payload: ida y vuelta, y valores fuera de rango', () {
    final p = LecturaUbicacion.payload(
      lat: _lat,
      lon: _lon,
      precision: 12.5,
      bateria: 80,
      origen: OrigenUbicacion.ayuda,
    );
    final l = LecturaUbicacion.desdePayload('x', _t0, p)!;
    expect(l.lat, _lat);
    expect(l.precision, 12.5);
    expect(l.bateria, 80);
    expect(l.origen, OrigenUbicacion.ayuda);
    expect(LecturaUbicacion.desdePayload('x', _t0, {...p, 'lat': 91}), isNull);
    expect(LecturaUbicacion.desdePayload('x', _t0, const {}), isNull);
    expect(
      LecturaUbicacion.desdePayload('x', _t0, {...p, 'bateria': 300})!.bateria,
      isNull,
    );
  });

  test('búsqueda: dura hasta su hora y la última pedida manda', () {
    final b1 = BusquedaPedida(pedidaEn: _t0, hasta: _t0.add(duracionBusqueda));
    expect(busquedaActiva([b1], _t0.add(const Duration(minutes: 29))), b1);
    expect(busquedaActiva([b1], _t0.add(const Duration(minutes: 30))), isNull);
    // Parada a los 10 minutos.
    final parar = BusquedaPedida(
      pedidaEn: _t0.add(const Duration(minutes: 10)),
      hasta: _t0.add(const Duration(minutes: 10)),
    );
    expect(
      busquedaActiva([parar, b1], _t0.add(const Duration(minutes: 11))),
      isNull,
    );
    expect(busquedaActiva(const [], _t0), isNull);
  });

  test('motivo fuera_de_zona: prioridad 5 y nombre estable', () {
    expect(MotivoAviso.fueraDeZona.prioridad, 5);
    expect(MotivoAviso.desdeNombre('fuera_de_zona'), MotivoAviso.fueraDeZona);
    expect(
      TipoEvento.desdeNombre('ubicacion_registrada'),
      TipoEvento.ubicacionRegistrada,
    );
  });
  test('elegir la zona estando lejos con lecturas malas no da salida que '
      'avise', () {
    // Lecturas de bajo consumo (400 m): dos lejos y la última en el centro,
    // que no basta para volver. La familia pone «Casa» en esa última.
    final lecturas = [
      _l('a', 0, metros: 1500, precision: 400),
      _l('b', 5, metros: 1500, precision: 400),
      _l('c', 9, precision: 400),
    ];
    final zona = ZonaSegura(
      lat: _lat,
      lon: _lon,
      radio: 200,
      elegidaEn: _t0.add(const Duration(minutes: 10)),
    );
    final s = evaluarZona(
      zona: zona,
      lecturas: lecturas,
      ahora: _t0.add(const Duration(minutes: 11)),
    );
    expect(s.salidaConfirmadaEn, isNull);
    // Sin la hora de la zona, la misma salida sí avisaría.
    expect(_evaluar(lecturas, ahora: 11).salidaConfirmadaEn, isNotNull);
    // Vuelve (una lectura buena en casa) y sale después: esa sí avisa.
    final despues = evaluarZona(
      zona: zona,
      lecturas: [
        ...lecturas,
        _l('d', 12, precision: 10),
        _l('e', 15, metros: 900, precision: 10),
      ],
      ahora: _t0.add(const Duration(minutes: 16)),
    );
    expect(despues.salidaConfirmadaEn, _t0.add(const Duration(minutes: 15)));
  });
}
