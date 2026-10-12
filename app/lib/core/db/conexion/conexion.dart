// Una sola función, `abrirConexion`, según la plataforma:
// móvil/escritorio (dart:ffi) -> nativa.dart (SQLCipher); web -> web.dart.
export 'no_soportada.dart'
    if (dart.library.ffi) 'nativa.dart'
    if (dart.library.js_interop) 'web.dart';
