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

  /// Las diez pestañas de la familia, en el orden de sus ramas.
  static const slugs = [
    'hoy',
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

  static const medicacionNuevo = '/familia/medicacion/nuevo';
  static String medicamento(String id) => '/familia/medicacion/$id';
  static String pauta(String id) => '/familia/medicacion/$id/pauta';

  static const ideas = '/familia/ideas';
  static String fila(String id) => '/familia/ideas/fila/$id';
  static const resumen = '/familia/ideas/resumen';
  static String tema(String key) => '/familia/ideas/tema/$key';

  static const controlHoras = '/familia/alarmas/control-horas';
}
