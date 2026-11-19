// `crearConstructorMapa()` según la plataforma: en el móvil y en los tests
// (dart:ffi), el mapa del archivo PMTiles; en la web, ninguno.
export 'constructor_mapa_web.dart'
    if (dart.library.ffi) 'constructor_mapa_movil.dart';
