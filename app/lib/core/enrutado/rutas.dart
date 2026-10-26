/// Rutas de la app. URL por almohadilla (la de Flutter por defecto): en
/// GitHub Pages no da 404.
abstract final class Rutas {
  static const raiz = '/';
  static const perfil = '/perfil';
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
  static String pregunta({bool prueba = false}) =>
      '$personaPregunta${prueba ? '?prueba=1' : ''}';

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
}
