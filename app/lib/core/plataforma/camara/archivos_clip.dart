import 'dart:typed_data';

/// Dónde viven los vídeos y fotos de comprobación: rutas relativas
/// (`clips/…`) a una carpeta base. En el móvil, la carpeta de documentos de
/// la app ([ArchivosClipDisco]); en la demo web y en los tests, la memoria
/// ([ArchivosClipMemoria]).
///
/// - En el móvil de la persona, el clip recién grabado espera aquí a subir
///   por el cartero y se borra al terminar de subir (ella no lo ve).
/// - En el móvil de la familia, aquí queda el clip bajado y descifrado; se
///   borra a los 7 días ([RutasClip.caducidad]).
///
/// La base guarda siempre la ruta relativa: en iOS la absoluta cambia con
/// cada actualización de la app.
abstract interface class ArchivosClip {
  /// Ruta absoluta de [ruta] para la cámara y el reproductor.
  Future<String> absoluta(String ruta);

  /// Como [absoluta], pero crea antes las carpetas que falten.
  Future<String> prepararEscritura(String ruta);

  /// Escribe entero o nada (temporal y renombrado).
  Future<void> escribir(String ruta, Uint8List bytes);

  /// Los bytes de [ruta], o nulo si no existe o no se puede leer.
  Future<Uint8List?> leer(String ruta);

  Future<bool> existe(String ruta);

  /// Renombra [origen] a [destino] (los dos relativos). Devuelve si lo hizo.
  Future<bool> mover(String origen, String destino);

  /// Borra [ruta] si existe. Nunca lanza.
  Future<void> borrar(String ruta);

  /// Clips guardados y su última modificación. Nunca lanza.
  Future<List<({String ruta, DateTime modificado})>> listar();
}

/// Carpeta de los clips, comprobación de rutas y tipos.
abstract final class RutasClip {
  static const carpeta = 'clips';

  /// Pasado este tiempo, el clip se borra del móvil y del servidor (ADR-0003).
  static const caducidad = Duration(days: 7);

  /// Solo `clips/<nombre>.<ext>` con letras, números, `-` y `_`: una ruta
  /// compuesta con un id recibido nunca sale de la carpeta.
  static final _valida = RegExp(r'^clips/[A-Za-z0-9_-]{1,120}\.[a-z0-9]{1,5}$');

  static bool valida(String ruta) => _valida.hasMatch(ruta);

  /// Ruta de un clip: `clips/<nombre>.<ext>`.
  static String de(String nombre, String ext) {
    final ruta = '$carpeta/$nombre.$ext';
    if (!valida(ruta)) throw ArgumentError.value(nombre, 'nombre');
    return ruta;
  }

  /// Lanza si [ruta] no es una ruta de clip válida.
  static void comprobar(String ruta) {
    if (!valida(ruta)) throw ArgumentError.value(ruta, 'ruta');
  }

  /// Tipos que admite el cartero de clips, con su extensión.
  static const extensiones = {
    'video/mp4': 'mp4',
    'video/quicktime': 'mov',
    'image/jpeg': 'jpg',
  };

  /// Extensión de [mime], o nula si no se admite.
  static String? extensionDe(String mime) => extensiones[mime];

  /// Tipo de [ruta] por su extensión (`video/mp4` si no se conoce).
  static String mimeDe(String ruta) {
    final ext = ruta.split('.').last.toLowerCase();
    for (final MapEntry(:key, :value) in extensiones.entries) {
      if (value == ext) return key;
    }
    return ext == 'jpeg' ? 'image/jpeg' : 'video/mp4';
  }
}

/// Clips en memoria: demo web (no hay sistema de archivos) y tests.
class ArchivosClipMemoria implements ArchivosClip {
  ArchivosClipMemoria({DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final DateTime Function() _ahora;
  final Map<String, Uint8List> archivos = {};

  /// Última modificación de cada archivo (los tests la pueden cambiar).
  final Map<String, DateTime> modificados = {};

  @override
  Future<String> absoluta(String ruta) async {
    RutasClip.comprobar(ruta);
    return 'memoria://$ruta';
  }

  @override
  Future<String> prepararEscritura(String ruta) => absoluta(ruta);

  @override
  Future<void> escribir(String ruta, Uint8List bytes) async {
    RutasClip.comprobar(ruta);
    archivos[ruta] = Uint8List.fromList(bytes);
    modificados[ruta] = _ahora();
  }

  @override
  Future<Uint8List?> leer(String ruta) async =>
      RutasClip.valida(ruta) ? archivos[ruta] : null;

  @override
  Future<bool> existe(String ruta) async =>
      RutasClip.valida(ruta) && archivos.containsKey(ruta);

  @override
  Future<bool> mover(String origen, String destino) async {
    if (!RutasClip.valida(origen) || !RutasClip.valida(destino)) return false;
    final bytes = archivos.remove(origen);
    if (bytes == null) return false;
    archivos[destino] = bytes;
    modificados[destino] = modificados.remove(origen) ?? _ahora();
    return true;
  }

  @override
  Future<void> borrar(String ruta) async {
    archivos.remove(ruta);
    modificados.remove(ruta);
  }

  @override
  Future<List<({String ruta, DateTime modificado})>> listar() async => [
    for (final r in archivos.keys)
      (ruta: r, modificado: modificados[r] ?? _ahora()),
  ];
}
