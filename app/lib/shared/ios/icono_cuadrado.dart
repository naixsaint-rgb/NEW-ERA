import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';

/// Icono de 30×30 de las listas de iOS (decorativo: no se lee).
///
/// Cuadrado (radio 8): fondo de color ([fondo], azul por defecto) y símbolo
/// blanco (o oscuro si el fondo es claro). Redondo ([redondo]): fondo claro (azulClaro por defecto) y símbolo
/// de color, para estados. Sobre fondos naranjas pasa
/// `color: context.colores.sobreNaranja`.
class IconoCuadrado extends StatelessWidget {
  const IconoCuadrado(
    this.icono, {
    super.key,
    this.color,
    this.fondo,
    this.redondo = false,
    this.tamano = 30,
  });

  final IconData icono;

  /// Color del símbolo.
  final Color? color;

  /// Color del fondo.
  final Color? fondo;
  final bool redondo;
  final double tamano;

  /// Símbolo legible sobre [fondo]: el de más contraste entre el blanco y el
  /// texto oscuro de la paleta (p. ej. oscuro sobre el índigo de la noche).
  static Color simboloSobre(Color fondo) {
    final l = fondo.computeLuminance() + 0.05;
    final conBlanco = 1.05 / l;
    final conOscuro = l / (Colores.texto.computeLuminance() + 0.05);
    return conOscuro > conBlanco ? Colores.texto : Colores.blanco;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final relleno = fondo ?? (redondo ? c.azulClaro : c.azul);
    final simbolo = color ?? (redondo ? c.azul : simboloSobre(relleno));
    return ExcludeSemantics(
      child: Container(
        width: tamano,
        height: tamano,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: relleno,
          borderRadius: BorderRadius.circular(redondo ? tamano / 2 : 8),
        ),
        child: Icon(icono, size: tamano * 0.6, color: simbolo),
      ),
    );
  }
}
