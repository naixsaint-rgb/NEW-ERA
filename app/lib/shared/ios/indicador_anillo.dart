import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';

/// Anillo de progreso (p. ej. tomas hechas de hoy): pista de [fondo] y arco
/// de [color] desde las 12 en el sentido de las agujas del reloj.
///
/// [fraccion] se recorta a 0–1. Con [etiquetaSemantica] ("3 de 5 tomas
/// hechas") se lee como imagen; [child] va en el centro.
class IndicadorAnillo extends StatelessWidget {
  const IndicadorAnillo(
    this.fraccion, {
    super.key,
    this.color,
    this.fondo,
    this.tamano = 56,
    this.grosor = 7,
    this.etiquetaSemantica,
    this.child,
  });

  final double fraccion;

  /// Arco; por defecto, verde.
  final Color? color;

  /// Pista; por defecto, `rellenoSuave`.
  final Color? fondo;
  final double tamano;
  final double grosor;
  final String? etiquetaSemantica;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final f = fraccion.isNaN ? 0.0 : fraccion.clamp(0.0, 1.0);
    final hijo = child;
    final anillo = SizedBox.square(
      dimension: tamano,
      child: CustomPaint(
        painter: PintorAnillo(
          fraccion: f,
          color: color ?? c.verde,
          fondo: fondo ?? c.rellenoSuave,
          grosor: grosor,
        ),
        child: hijo == null ? null : Center(child: hijo),
      ),
    );
    final etiqueta = etiquetaSemantica;
    if (etiqueta == null) return anillo;
    return Semantics(
      image: true,
      label: etiqueta,
      excludeSemantics: true,
      child: anillo,
    );
  }
}

/// Pintor del [IndicadorAnillo].
class PintorAnillo extends CustomPainter {
  const PintorAnillo({
    required this.fraccion,
    required this.color,
    required this.fondo,
    required this.grosor,
  });

  final double fraccion;
  final Color color;
  final Color fondo;
  final double grosor;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = (size.shortestSide - grosor) / 2;
    if (radio <= 0) return;
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..color = fondo,
    );
    if (fraccion <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: radio),
      -math.pi / 2,
      2 * math.pi * fraccion,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(PintorAnillo old) =>
      old.fraccion != fraccion ||
      old.color != color ||
      old.fondo != fondo ||
      old.grosor != grosor;
}
