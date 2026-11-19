import 'mapa_pmtiles.dart';
import 'vista_mapa.dart';

/// En el móvil, el mapa del archivo PMTiles guardado.
ConstructorMapa? crearConstructorMapa() =>
    (datos) => MapaPmtiles(datos: datos);
