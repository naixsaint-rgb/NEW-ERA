import 'package:flutter/widgets.dart';
import 'package:safety_core/safety_core.dart';

/// Lo que se pinta encima del mapa y lo que el mapa devuelve.
class DatosMapa {
  const DatosMapa({
    required this.rutaArchivo,
    required this.ultima,
    required this.zona,
    required this.rastro,
    required this.alFijarCasa,
    required this.alAtribucion,
  });

  /// Archivo PMTiles guardado en el móvil.
  final String rutaArchivo;

  /// Última posición (punto y círculo de precisión).
  final LecturaUbicacion? ultima;

  /// Zona «Casa» (círculo).
  final ZonaSegura? zona;

  /// Recorrido, de la más antigua a la más reciente.
  final List<LecturaUbicacion> rastro;

  /// Pulsación larga en el mapa: poner ahí la casa.
  final void Function(double lat, double lon) alFijarCasa;

  /// Toque en «© OpenStreetMap»: abrir la licencia.
  final VoidCallback alAtribucion;
}

/// Construye el mapa. La web y los tests que no lo necesitan usan `null`
/// (sin mapa): la pantalla de Ubicación sigue como siempre.
typedef ConstructorMapa = Widget Function(DatosMapa datos);

/// Licencia de los datos de OpenStreetMap (ODbL), enlazada desde la atribución.
final urlLicenciaOsm = Uri.https('www.openstreetmap.org', '/copyright');
