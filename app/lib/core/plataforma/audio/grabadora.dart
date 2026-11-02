/// Formato de las frases de la familia.
///
/// AAC-LC mono a 32 kbps y 22,05 kHz en un contenedor MPEG-4 (`.m4a`), en
/// Android e iOS. Una frase de 8 s ocupa unos 34 KB (medido con ffmpeg, no
/// con el codificador del móvil) y cabe en un sobre del cartero (tope de
/// 45 KB de audio, como las fotos). En la web, lo que dé el navegador (Opus o
/// WAV).
abstract final class FormatoVoz {
  static const bitRate = 32000;
  static const frecuencia = 22050;
  static const canales = 1;

  /// Duración máxima de una frase.
  static const segundosMaximos = 8;
}

/// Graba la voz de un familiar en un archivo.
///
/// Implementaciones: `GrabadoraMovil` (paquete `record`) y
/// `GrabadoraSimulada` (tests y demo web).
abstract interface class Grabadora {
  /// Pide el permiso del micrófono si hace falta. `false` si no se concede.
  Future<bool> pedirPermiso();

  /// Empieza a grabar en [ruta] (relativa, `voces/…`).
  Future<void> empezar(String ruta);

  /// Para y devuelve la ruta de lo grabado (en la web, una URL `blob:`), o
  /// nulo si no se grabó nada.
  Future<String?> parar();

  /// Para y descarta lo grabado.
  Future<void> cancelar();

  Future<void> liberar();
}
