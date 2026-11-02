import 'dart:typed_data';

/// Dónde viven los audios de las voces: rutas relativas (`voces/…`) a una
/// carpeta base. En el móvil, la carpeta de documentos de la app
/// ([ArchivosVozDisco]); en la demo web y en los tests de pantallas, la
/// memoria ([ArchivosVozMemoria]).
///
/// Las rutas que se guardan en `frases.audio_ruta` son siempre relativas: en
/// iOS la ruta absoluta de Documentos cambia con cada actualización de la app
/// y el paquete `alarm` busca los sonidos relativos a esa carpeta.
abstract interface class ArchivosVoz {
  /// Ruta absoluta (o URL) de [ruta] para el grabador y el reproductor.
  Future<String> absoluta(String ruta);

  /// Como [absoluta], pero crea antes las carpetas que falten.
  Future<String> prepararEscritura(String ruta);

  Future<void> escribir(String ruta, Uint8List bytes);

  /// Los bytes de [ruta], o nulo si no existe o no se puede leer.
  Future<Uint8List?> leer(String ruta);

  Future<bool> existe(String ruta);

  /// Borra [ruta] si existe. Nunca lanza.
  Future<void> borrar(String ruta);
}

/// Carpeta de las voces y comprobación de rutas.
abstract final class RutasVoz {
  static const carpeta = 'voces';

  /// Extensión del formato del móvil (AAC en MPEG-4).
  static const extension = 'm4a';

  /// Solo `voces/<nombre>.<ext>` con letras, números, `-` y `_`: una ruta
  /// que llega de fuera (o que se compone con un id recibido) nunca sale de
  /// la carpeta.
  static final _valida = RegExp(r'^voces/[A-Za-z0-9_-]{1,120}\.[a-z0-9]{1,5}$');

  static bool valida(String ruta) => _valida.hasMatch(ruta);

  /// Ruta de una grabación: `voces/<nombre>.<ext>`.
  static String de(String nombre, {String ext = extension}) {
    final ruta = '$carpeta/$nombre.$ext';
    if (!valida(ruta)) throw ArgumentError.value(nombre, 'nombre');
    return ruta;
  }

  /// Lanza si [ruta] no es una ruta de voz válida.
  static void comprobar(String ruta) {
    if (!valida(ruta)) throw ArgumentError.value(ruta, 'ruta');
  }
}

/// Audios en memoria: demo web (no hay sistema de archivos) y tests de
/// pantallas (sin E/S real dentro del reloj falso).
class ArchivosVozMemoria implements ArchivosVoz {
  ArchivosVozMemoria();

  final Map<String, Uint8List> archivos = {};

  @override
  Future<String> absoluta(String ruta) async {
    RutasVoz.comprobar(ruta);
    return 'memoria://$ruta';
  }

  @override
  Future<String> prepararEscritura(String ruta) => absoluta(ruta);

  @override
  Future<void> escribir(String ruta, Uint8List bytes) async {
    RutasVoz.comprobar(ruta);
    archivos[ruta] = Uint8List.fromList(bytes);
  }

  @override
  Future<Uint8List?> leer(String ruta) async =>
      RutasVoz.valida(ruta) ? archivos[ruta] : null;

  @override
  Future<bool> existe(String ruta) async =>
      RutasVoz.valida(ruta) && archivos.containsKey(ruta);

  @override
  Future<void> borrar(String ruta) async => archivos.remove(ruta);
}
