/// Estilo del mapa (formato de estilo de MapLibre/Mapbox que lee
/// `vector_tile_renderer`) para las capas del mapa base de Protomaps
/// (https://docs.protomaps.com/basemaps/layers): tierra, agua, usos del
/// suelo, edificios, calles con su nombre y lugares. Propio y corto, con
/// rótulos grandes. Claro y oscuro.
///
/// SIN VERIFICAR con un archivo real: los nombres de capa y los valores de
/// `kind` siguen la documentación del esquema 4 de Protomaps.
library;

/// Nombre de la fuente en el estilo (la que sirve el lector del archivo).
const fuenteMapa = 'protomaps';

class _Paleta {
  const _Paleta({
    required this.fondo,
    required this.agua,
    required this.parque,
    required this.urbano,
    required this.edificio,
    required this.calle,
    required this.calleBorde,
    required this.principal,
    required this.principalBorde,
    required this.texto,
    required this.halo,
    required this.limite,
  });

  final String fondo, agua, parque, urbano, edificio, calle, calleBorde;
  final String principal, principalBorde, texto, halo, limite;
}

const _claro = _Paleta(
  fondo: '#F2EFE9',
  agua: '#A9CCE3',
  parque: '#CFE5C1',
  urbano: '#ECE7DF',
  edificio: '#DDD6CC',
  calle: '#FFFFFF',
  calleBorde: '#CFC8BE',
  principal: '#FBE3A6',
  principalBorde: '#D9B866',
  texto: '#2B2B2B',
  halo: '#FFFFFF',
  limite: '#A39BB0',
);

const _oscuro = _Paleta(
  fondo: '#1C1C1E',
  agua: '#1F3A52',
  parque: '#22382A',
  urbano: '#232325',
  edificio: '#2E2E31',
  calle: '#3A3A3D',
  calleBorde: '#2A2A2C',
  principal: '#5A4A26',
  principalBorde: '#3E3420',
  texto: '#EDEDED',
  halo: '#000000',
  limite: '#77708A',
);

Map<String, Object?> _capa(
  String id,
  String tipo,
  String capaFuente, {
  List<Object?>? filtro,
  Map<String, Object?>? paint,
  Map<String, Object?>? layout,
  double? minzoom,
}) => {
  'id': id,
  'type': tipo,
  'source': fuenteMapa,
  'source-layer': capaFuente,
  'filter': ?filtro,
  'minzoom': ?minzoom,
  'layout': ?layout,
  'paint': ?paint,
};

List<Object?> _ancho(double z12, double z18) => [
  'interpolate',
  ['exponential', 1.6],
  ['zoom'],
  12,
  z12,
  18,
  z18,
];

/// Estilo para [oscuro] o claro.
Map<String, Object?> estiloMapa({required bool oscuro}) {
  final p = oscuro ? _oscuro : _claro;
  const menores = ['in', 'kind', 'minor_road', 'other', 'path'];
  const mayores = ['in', 'kind', 'major_road', 'highway'];
  return {
    'version': 8,
    'id': oscuro ? 'newera-oscuro' : 'newera-claro',
    'sources': {
      fuenteMapa: {'type': 'vector'},
    },
    'layers': [
      {
        'id': 'fondo',
        'type': 'background',
        'paint': {'background-color': p.fondo},
      },
      _capa('tierra', 'fill', 'earth', paint: {'fill-color': p.fondo}),
      _capa(
        'urbano',
        'fill',
        'landuse',
        filtro: [
          'in',
          'kind',
          'residential',
          'commercial',
          'industrial',
          'pedestrian',
        ],
        paint: {'fill-color': p.urbano},
      ),
      _capa(
        'parques',
        'fill',
        'landuse',
        filtro: [
          'in',
          'kind',
          'park',
          'garden',
          'grass',
          'forest',
          'wood',
          'cemetery',
          'golf_course',
          'nature_reserve',
        ],
        paint: {'fill-color': p.parque},
      ),
      _capa('agua', 'fill', 'water', paint: {'fill-color': p.agua}),
      _capa(
        'edificios',
        'fill',
        'buildings',
        minzoom: 14,
        paint: {'fill-color': p.edificio},
      ),
      _capa(
        'limites',
        'line',
        'boundaries',
        paint: {'line-color': p.limite, 'line-width': 1},
      ),
      _capa(
        'calles-borde',
        'line',
        'roads',
        filtro: menores,
        minzoom: 13,
        layout: {'line-cap': 'round', 'line-join': 'round'},
        paint: {'line-color': p.calleBorde, 'line-width': _ancho(1.5, 16)},
      ),
      _capa(
        'calles',
        'line',
        'roads',
        filtro: menores,
        minzoom: 13,
        layout: {'line-cap': 'round', 'line-join': 'round'},
        paint: {'line-color': p.calle, 'line-width': _ancho(1, 13)},
      ),
      _capa(
        'principales-borde',
        'line',
        'roads',
        filtro: mayores,
        layout: {'line-cap': 'round', 'line-join': 'round'},
        paint: {'line-color': p.principalBorde, 'line-width': _ancho(3, 22)},
      ),
      _capa(
        'principales',
        'line',
        'roads',
        filtro: mayores,
        layout: {'line-cap': 'round', 'line-join': 'round'},
        paint: {'line-color': p.principal, 'line-width': _ancho(2, 19)},
      ),
      _capa(
        'nombres-calles',
        'symbol',
        'roads',
        minzoom: 15,
        layout: {
          'symbol-placement': 'line',
          'text-field': ['get', 'name'],
          'text-size': 14,
          'text-font': ['Noto Sans Regular'],
        },
        paint: {
          'text-color': p.texto,
          'text-halo-color': p.halo,
          'text-halo-width': 2,
        },
      ),
      _capa(
        'lugares',
        'symbol',
        'places',
        filtro: [
          'in',
          'kind',
          'locality',
          'neighbourhood',
          'macrohood',
          'region',
        ],
        layout: {
          'text-field': ['get', 'name'],
          'text-size': [
            'match',
            ['get', 'kind'],
            'locality',
            17,
            'region',
            16,
            15,
          ],
          'text-font': ['Noto Sans Medium'],
        },
        paint: {
          'text-color': p.texto,
          'text-halo-color': p.halo,
          'text-halo-width': 2,
        },
      ),
    ],
  };
}
