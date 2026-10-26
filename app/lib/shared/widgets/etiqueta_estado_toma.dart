import 'package:flutter/material.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/tema/colores.dart';
import '../l10n_ext.dart';

/// Color, icono y texto de cada estado: ningún estado va solo por color.
class EtiquetaEstadoToma extends StatelessWidget {
  const EtiquetaEstadoToma({super.key, required this.estado, this.tamanoTexto});

  final EstadoToma estado;
  final double? tamanoTexto;

  /// Color de cada estado con los tokens [c] (claros si no se pasan).
  static Color colorDe(EstadoToma e, [ColoresApp c = ColoresApp.claro]) =>
      switch (e) {
        EstadoToma.prevista => c.textoSecundario,
        EstadoToma.confirmada => c.azul,
        EstadoToma.confirmadaSinVideo => c.naranja,
        EstadoToma.noConfirmada => c.rojo,
        EstadoToma.cerradaPorFamiliar => c.morado,
      };

  static IconData iconoDe(EstadoToma e) => switch (e) {
    EstadoToma.prevista => Icons.schedule,
    EstadoToma.confirmada => Icons.check_circle,
    EstadoToma.confirmadaSinVideo => Icons.videocam_off,
    EstadoToma.noConfirmada => Icons.error,
    EstadoToma.cerradaPorFamiliar => Icons.person,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final texto = switch (estado) {
      EstadoToma.prevista => l.estadoPrevista,
      EstadoToma.confirmada => l.estadoConfirmada,
      EstadoToma.confirmadaSinVideo => l.estadoConfirmadaSinVideo,
      EstadoToma.noConfirmada => l.estadoNoConfirmada,
      EstadoToma.cerradaPorFamiliar => l.estadoCerradaPorFamiliar,
    };
    final color = colorDe(estado, context.colores);
    final base = Theme.of(context).textTheme.bodyMedium;
    return Semantics(
      label: l.semanticaEstadoToma(texto),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconoDe(estado), color: color, size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                texto,
                style: base?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: tamanoTexto,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
