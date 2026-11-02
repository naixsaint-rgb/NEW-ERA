/// Rutas de la app. URL por almohadilla (la de Flutter por defecto): en
/// GitHub Pages no da 404.
abstract final class Rutas {
  static const raiz = '/';
  static const perfil = '/perfil';

  /// "Este móvil se une a una familia que ya usa la app" (sin perfil aún).
  static const unirse = '/perfil/unirse';
  static const persona = '/persona';
  static const familia = '/familia';
  static const mas = '/familia/mas';

  /// Pantalla de toma. Con [prueba], no escribe eventos.
  static String toma(String id, {bool prueba = false}) =>
      '/persona/toma/${Uri.encodeComponent(id)}${prueba ? '?prueba=1' : ''}';

  /// "Mis pastillas" de la persona: las tomas de hoy con su foto.
  static const personaPastillas = '/persona/pastillas';

  /// Pregunta de la persona ("¿Cómo estás?"). Sin parámetros.
  static const personaPregunta = '/persona/pregunta';

  /// Pregunta de la persona; con [prueba] (desde la familia) no guarda nada.
  /// Con [ronda] (`ronda_<yyyyMMdd>_<HHmm>`), las respuestas son de esa
  /// ronda del control por horas.
  static String pregunta({bool prueba = false, String? ronda}) {
    final q = [
      if (prueba) 'prueba=1',
      if (ronda != null) 'ronda=${Uri.encodeQueryComponent(ronda)}',
    ];
    return q.isEmpty ? personaPregunta : '$personaPregunta?${q.join('&')}';
  }

  /// Las once secciones de la familia, en el orden de sus ramas.
  static const slugs = [
    'hoy',
    'resumen',
    'medicacion',
    'calendario',
    'consultas',
    'alarmas',
    'voces',
    'alimentacion',
    'ideas',
    'circulo',
    'ajustes',
  ];

  static String pestana(String slug) => '/familia/$slug';

  /// Hoy con una vista elegida: `ayer`, `hoy`, `manana` o `semana`.
  static String hoyVista(String vista) =>
      '/familia/hoy?vista=${Uri.encodeQueryComponent(vista)}';

  static const medicacionNuevo = '/familia/medicacion/nuevo';
  static String medicamento(String id) => '/familia/medicacion/$id';
  static String pauta(String id) => '/familia/medicacion/$id/pauta';

  static const ideas = '/familia/ideas';
  static String fila(String id) => '/familia/ideas/fila/$id';

  /// Tabla resumen del catálogo (no la pestaña "Resumen": esa es
  /// `pestana('resumen')`).
  static const resumen = '/familia/ideas/resumen';
  static String tema(String key) => '/familia/ideas/tema/$key';

  static const controlHoras = '/familia/alarmas/control-horas';

  /// Círculo › "Invitar otro móvil" (QR y código).
  static const circuloInvitar = '/familia/circulo/invitar';

  /// Círculo › un familiar: su puesto en el orden de aviso y, si es el de
  /// este móvil, sus avisos por ntfy.
  static String familiar(String miembroId) =>
      '/familia/circulo/familiar/${Uri.encodeComponent(miembroId)}';

  /// Esquema propio de la app: `newera://hoy` (lo abre el aviso de ntfy al
  /// tocarlo) lleva a la pantalla de inicio del perfil (Hoy en la familia).
  static const esquemaApp = 'newera';

  /// Voces › un familiar: sus frases.
  static String voz(String miembroId) =>
      '/familia/voces/${Uri.encodeComponent(miembroId)}';

  /// Voces › un familiar › permiso para grabar su voz.
  static String vozPermiso(String miembroId) => '${voz(miembroId)}/permiso';
}
