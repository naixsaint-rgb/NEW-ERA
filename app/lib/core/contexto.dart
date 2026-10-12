/// Perfil de este móvil.
enum PerfilApp {
  persona('persona'),
  familia('familia');

  const PerfilApp(this.nombre);
  final String nombre;

  static PerfilApp? desdeNombre(String? nombre) {
    for (final p in values) {
      if (p.nombre == nombre) return p;
    }
    return null;
  }
}

/// Identificadores de este dispositivo y de su círculo, fijados al arrancar.
final class ContextoApp {
  const ContextoApp({
    required this.circuloId,
    required this.personaId,
    required this.dispositivoId,
    required this.plataforma,
    this.zonaHoraria = 'Europe/Madrid',
  });

  final String circuloId;
  final String personaId;
  final String dispositivoId;

  /// `ios`, `android` o `web`.
  final String plataforma;
  final String zonaHoraria;
}

/// Quién usa este móvil ahora.
final class Sesion {
  const Sesion({this.perfil, this.miembroId});

  final PerfilApp? perfil;

  /// Miembro de la familia que usa el móvil (solo en perfil familia).
  final String? miembroId;

  Sesion copiar({
    PerfilApp? perfil,
    String? miembroId,
    bool sinPerfil = false,
  }) => Sesion(
    perfil: sinPerfil ? null : (perfil ?? this.perfil),
    miembroId: miembroId ?? this.miembroId,
  );
}
