import 'package:flutter/widgets.dart';

/// `Key` que usan los tests para encontrar elementos.
abstract final class ClavesUi {
  static const loSiguiente = ValueKey<String>('lo_siguiente');
  static const necesitoAyuda = ValueKey<String>('necesito_ayuda');
  static const confirmarToma = ValueKey<String>('confirmar_toma');
  static const enlaceFicha = ValueKey<String>('enlace_ficha');
  static const miGente = ValueKey<String>('mi_gente');
  static const esLaHora = ValueKey<String>('es_la_hora');
  static const muyBien = ValueKey<String>('muy_bien');
  static const semaforo = ValueKey<String>('semaforo');
  static const buscadorCatalogo = ValueKey<String>('buscador_catalogo');

  /// Botón "Mis pastillas" del inicio de la persona.
  static const misPastillas = ValueKey<String>('mis_pastillas');

  /// Pantalla "Mis pastillas" de la persona.
  static const pantallaMisPastillas = ValueKey<String>(
    'pantalla_mis_pastillas',
  );

  /// Pantalla de pregunta de la persona ("¿Cómo estás?").
  static const pregunta = ValueKey<String>('pregunta');

  /// Pestaña "Resumen" de la familia (la pantalla).
  static const pantallaResumen = ValueKey<String>('pantalla_resumen');

  /// Botón "Probar pregunta" (modo prueba) de la familia.
  static const probarPregunta = ValueKey<String>('probar_pregunta');

  /// Tarjeta "Pastillero de la semana" de Medicación.
  static const pastillero = ValueKey<String>('pastillero');

  /// Anillo de tomas hechas de hoy (Resumen).
  static const anilloTomas = ValueKey<String>('anillo_tomas');

  /// Botón "Volver al inicio" de las pantallas de la persona.
  static const volverAlInicio = ValueKey<String>('volver_al_inicio');

  /// Pestaña de la familia: `hoy`, `medicacion`, `calendario`...
  static ValueKey<String> pestana(String slug) =>
      ValueKey<String>('pestana_$slug');

  /// Segmento de un `SelectorSegmentos`: `ayer`, `hoy`, `manana`, `semana`...
  static ValueKey<String> segmento(String valor) =>
      ValueKey<String>('segmento_$valor');

  /// Opción del ajuste "Aspecto": `automatico`, `claro`, `oscuro`, `horas`.
  static ValueKey<String> aspecto(String valor) =>
      ValueKey<String>('aspecto_$valor');

  /// Respuesta de la pantalla de pregunta: `bien`, `regular`, `mal`...
  static ValueKey<String> respuesta(String valor) =>
      ValueKey<String>('respuesta_$valor');

  /// Fila del catálogo por id (`cobre_metales-000`).
  static ValueKey<String> filaCatalogo(String id) =>
      ValueKey<String>('fila_$id');
}
