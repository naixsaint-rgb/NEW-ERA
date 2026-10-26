import 'package:flutter/material.dart';

/// Colores de pastilla que se pueden elegir (nombre guardado -> color).
const coloresPastilla = <String, Color>{
  'blanco': Color(0xFFF5F5F5),
  'amarillo': Color(0xFFF9D648),
  'rojo': Color(0xFFD32F2F),
  'rosa': Color(0xFFF48FB1),
  'naranja': Color(0xFFFB8C00),
  'verde': Color(0xFF66BB6A),
  'azul': Color(0xFF42A5F5),
  'marron': Color(0xFF8D6E63),
};

Color colorDePastilla(String? nombre) =>
    coloresPastilla[nombre] ?? const Color(0xFFE0E0E0);

/// Dibujo propio de una pastilla (sin imágenes externas).
class PastillaPictograma extends StatelessWidget {
  const PastillaPictograma({
    super.key,
    required this.forma,
    this.color,
    this.tamano = 96,
    this.etiquetaSemantica,
    this.colorBorde = const Color(0xFF555555),
  });

  /// `redonda`, `ovalada`, `capsula` u `otra`.
  final String forma;
  final String? color;
  final double tamano;
  final String? etiquetaSemantica;

  /// Contorno de la pastilla (sobre el fondo "mesa", `mesaBorde`).
  final Color colorBorde;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: etiquetaSemantica,
      image: true,
      excludeSemantics: etiquetaSemantica != null,
      child: SizedBox(
        width: tamano,
        height: tamano,
        child: CustomPaint(
          painter: _PintorPastilla(forma, colorDePastilla(color), colorBorde),
        ),
      ),
    );
  }
}

class _PintorPastilla extends CustomPainter {
  _PintorPastilla(this.forma, this.color, this.colorBorde);

  final String forma;
  final Color color;
  final Color colorBorde;

  @override
  void paint(Canvas canvas, Size size) {
    final relleno = Paint()..color = color;
    final borde = Paint()
      ..color = colorBorde
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.03;
    final brillo = Paint()..color = const Color(0x66FFFFFF);
    final w = size.width;
    final h = size.height;
    switch (forma) {
      case 'redonda':
        final c = Offset(w / 2, h / 2);
        final r = w * 0.38;
        canvas.drawCircle(c, r, relleno);
        canvas.drawCircle(c, r, borde);
        canvas.drawCircle(
          Offset(c.dx - r * 0.35, c.dy - r * 0.35),
          r * 0.22,
          brillo,
        );
      case 'ovalada':
        final rect = Rect.fromCenter(
          center: Offset(w / 2, h / 2),
          width: w * 0.84,
          height: h * 0.5,
        );
        canvas.drawOval(rect, relleno);
        canvas.drawOval(rect, borde);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.38, h * 0.42),
            width: w * 0.28,
            height: h * 0.1,
          ),
          brillo,
        );
      case 'capsula':
        final rect = Rect.fromCenter(
          center: Offset(w / 2, h / 2),
          width: w * 0.84,
          height: h * 0.4,
        );
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(h * 0.2));
        canvas.drawRRect(rr, relleno);
        canvas.save();
        canvas.clipRRect(rr);
        canvas.drawRect(
          Rect.fromLTRB(w / 2, rect.top, rect.right, rect.bottom),
          Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.85),
        );
        canvas.restore();
        canvas.drawRRect(rr, borde);
        canvas.drawLine(
          Offset(w / 2, rect.top),
          Offset(w / 2, rect.bottom),
          borde,
        );
      default:
        final rect = Rect.fromCenter(
          center: Offset(w / 2, h / 2),
          width: w * 0.62,
          height: h * 0.62,
        );
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(w * 0.12));
        canvas.drawRRect(rr, relleno);
        canvas.drawRRect(rr, borde);
        canvas.drawLine(
          Offset(rect.left + w * 0.08, h / 2),
          Offset(rect.right - w * 0.08, h / 2),
          borde,
        );
    }
  }

  @override
  bool shouldRepaint(_PintorPastilla old) =>
      old.forma != forma || old.color != color || old.colorBorde != colorBorde;
}
