import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';
import '../../shared/l10n_ext.dart';

/// Dirección según la propia fuente: color, icono y texto.
class EtiquetaDireccion extends StatelessWidget {
  const EtiquetaDireccion({super.key, required this.direccion});

  final String? direccion;

  static Color colorDe(String? d) => switch (d) {
    'mejora' => Colores.verde,
    'empeora' => Colores.rojo,
    'mixto' => Colores.naranja,
    'no aplica' => Colores.morado,
    _ => Colores.gris,
  };

  static IconData iconoDe(String? d) => switch (d) {
    'mejora' => Icons.trending_up,
    'empeora' => Icons.trending_down,
    'mixto' => Icons.swap_vert,
    'no aplica' => Icons.block,
    _ => Icons.drag_handle,
  };

  static String textoDe(BuildContext context, String? d) {
    final l = context.l;
    return switch (d) {
      'mejora' => l.direccionMejora,
      'empeora' => l.direccionEmpeora,
      'mixto' => l.direccionMixto,
      'no aplica' => l.direccionNoAplica,
      'sin cambio' => l.direccionSinCambio,
      _ => l.noConsta,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = colorDe(direccion);
    final texto = textoDe(context, direccion);
    return Semantics(
      label: context.l.semanticaDireccion(texto),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconoDe(direccion), color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              texto,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
