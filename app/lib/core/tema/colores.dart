import 'package:flutter/widgets.dart';

/// Tokens de color (sección 9). Todos tienen más de 6:1 de contraste con el
/// blanco. Ningún estado va solo por color: siempre color, icono y texto.
abstract final class Colores {
  static const texto = Color(0xFF1A1A1A);
  static const fondoPersona = Color(0xFFFFFDF7);
  static const fondoFamilia = Color(0xFFFFFFFF);

  /// Confirmar, verificada.
  static const verde = Color(0xFF1B5E20);

  /// Confirmada. Nunca va solo.
  static const azul = Color(0xFF0D47A1);

  /// Sin vídeo, dudosa.
  static const naranja = Color(0xFFA84300);

  /// No confirmada, ayuda.
  static const rojo = Color(0xFFB71C1C);

  /// Cerrada por un familiar.
  static const morado = Color(0xFF4A148C);

  /// Prevista.
  static const gris = Color(0xFF555555);

  static const blanco = Color(0xFFFFFFFF);
}
