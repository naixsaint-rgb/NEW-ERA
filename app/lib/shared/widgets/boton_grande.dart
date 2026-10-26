import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';

/// Alineación del contenido de un [BotonGrande].
enum AlineacionBoton { izquierda, centro }

/// Botón grande de ancho completo (persona): radio 24, icono opcional a la
/// izquierda, texto 28/700.
///
/// El texto es blanco u oscuro según el [color] (el que más contraste dé),
/// salvo que se pase [colorTexto]. Con `alinear: AlineacionBoton.izquierda`,
/// icono y texto van a la izquierda, como en la maqueta A-Persona.
class BotonGrande extends StatelessWidget {
  const BotonGrande({
    super.key,
    required this.texto,
    required this.onPressed,
    required this.color,
    this.icono,
    this.altura = 96,
    this.etiquetaSemantica,
    this.tamanoTexto,
    this.alinear = AlineacionBoton.centro,
    this.colorTexto,
    this.radio = 24,
  });

  final String texto;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icono;
  final double altura;
  final String? etiquetaSemantica;

  /// 28 por defecto (escala con el sistema).
  final double? tamanoTexto;
  final AlineacionBoton alinear;
  final Color? colorTexto;
  final double radio;

  /// Blanco u oscuro, el que más contraste tenga con [fondo].
  static Color textoSobre(Color fondo) {
    double ratio(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final (claro, oscuro) = la > lb ? (la, lb) : (lb, la);
      return (claro + 0.05) / (oscuro + 0.05);
    }

    return ratio(Colores.blanco, fondo) >= ratio(Colores.texto, fondo)
        ? Colores.blanco
        : Colores.texto;
  }

  @override
  Widget build(BuildContext context) {
    final primerPlano = colorTexto ?? textoSobre(color);
    final izquierda = alinear == AlineacionBoton.izquierda;
    final estilo = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: primerPlano,
      fontSize: tamanoTexto ?? 28,
      letterSpacing: 0,
    );
    return Semantics(
      button: true,
      label: etiquetaSemantica ?? texto,
      excludeSemantics: true,
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: altura,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: primerPlano,
            disabledBackgroundColor: const Color(0xFFC7C7CC),
            disabledForegroundColor: Colores.texto,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radio),
            ),
            padding: EdgeInsets.symmetric(horizontal: izquierda ? 24 : 16),
          ),
          child: Row(
            mainAxisAlignment: izquierda
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (icono != null) ...[
                Icon(icono, size: (altura * 0.4).clamp(36, 40)),
                SizedBox(width: izquierda ? 18 : 12),
              ],
              Flexible(
                child: Text(
                  texto,
                  style: estilo,
                  textAlign: izquierda ? TextAlign.start : TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
