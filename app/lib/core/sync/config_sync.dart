/// Dónde está el servidor del cartero cifrado.
///
/// Se fija al compilar con `--dart-define=SUPABASE_URL=...` y
/// `--dart-define=SUPABASE_ANON_KEY=...` (ver `supabase/README.md`). La clave
/// anon es pública por diseño: solo deja hacer lo que permiten las políticas
/// de la tabla `sobres`. Vacías, la app funciona solo en local.
final class ConfigSync {
  const ConfigSync({this.url = '', this.claveAnonima = ''});

  /// La de la compilación.
  factory ConfigSync.desdeEntorno() => const ConfigSync(
    url: String.fromEnvironment('SUPABASE_URL'),
    claveAnonima: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final String url;
  final String claveAnonima;

  /// Hay algo escrito en las dos.
  bool get configurada =>
      url.trim().isNotEmpty && claveAnonima.trim().isNotEmpty;

  /// Está configurada y la URL es `https://<algo>` sin ruta.
  bool get valida {
    if (!configurada) return false;
    final u = Uri.tryParse(urlLimpia);
    return u != null &&
        u.scheme == 'https' &&
        u.host.isNotEmpty &&
        (u.path.isEmpty || u.path == '/');
  }

  /// La URL sin espacios ni barra final.
  String get urlLimpia {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }
}
