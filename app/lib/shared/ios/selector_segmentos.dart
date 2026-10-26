import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';

/// Selector de segmentos de iOS (`CupertinoSlidingSegmentedControl`):
/// "Ayer · Hoy · Mañana · Semana", "Automático · Claro · Oscuro · Noche".
///
/// Cada segmento mide [altoMinimo] (48 por defecto, el mínimo táctil de
/// Android). [clave] da la `Key` de cada segmento para los tests, p. ej.
/// `clave: (v) => ClavesUi.segmento(v.name)`. Las etiquetas largas pasan a
/// dos líneas en vez de cortarse.
class SelectorSegmentos<T extends Object> extends StatelessWidget {
  const SelectorSegmentos({
    super.key,
    required this.valores,
    required this.etiqueta,
    required this.seleccionado,
    required this.alCambiar,
    this.clave,
    this.altoMinimo = 48,
  });

  final List<T> valores;
  final String Function(T valor) etiqueta;
  final T seleccionado;
  final ValueChanged<T> alCambiar;
  final Key Function(T valor)? clave;
  final double altoMinimo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final base = Theme.of(context).textTheme.labelMedium;
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: seleccionado,
      backgroundColor: c.segmentosFondo,
      thumbColor: c.segmentosSeleccion,
      onValueChanged: (v) {
        if (v != null && v != seleccionado) alCambiar(v);
      },
      children: {
        for (final v in valores)
          v: ConstrainedBox(
            key: clave?.call(v),
            constraints: BoxConstraints(minHeight: altoMinimo),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  etiqueta(v),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: base?.copyWith(
                    fontSize: 13,
                    color: c.texto,
                    fontWeight: v == seleccionado
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      },
    );
  }
}
