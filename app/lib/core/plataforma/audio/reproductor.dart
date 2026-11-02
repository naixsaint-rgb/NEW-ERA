/// Reproduce las frases grabadas por la familia.
///
/// Implementaciones: `ReproductorMovil` (paquete `audioplayers`) y
/// `ReproductorSimulado` (tests y demo web). Nunca lanza: si una frase no se
/// puede reproducir, no suena.
abstract interface class Reproductor {
  /// Para lo que esté sonando y reproduce [ruta] (relativa, `voces/…`).
  Future<void> reproducir(String ruta);

  Future<void> parar();

  Future<void> liberar();
}
