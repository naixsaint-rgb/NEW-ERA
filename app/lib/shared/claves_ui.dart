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

  /// Pestaña de la familia: `hoy`, `medicacion`, `calendario`...
  static ValueKey<String> pestana(String slug) =>
      ValueKey<String>('pestana_$slug');

  /// Fila del catálogo por id (`cobre_metales-000`).
  static ValueKey<String> filaCatalogo(String id) =>
      ValueKey<String>('fila_$id');
}
