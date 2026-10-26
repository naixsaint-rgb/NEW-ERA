import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';

/// Cabecera de sección de iOS: 13/600, mayúsculas, gris, margen izquierdo 16.
///
/// El texto se muestra en mayúsculas pero el lector de pantalla lee [texto]
/// tal cual. En los tests: `find.text(texto.toUpperCase())` o
/// `find.bySemanticsLabel(texto)`.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.mayusculas = true});

  final String texto;
  final bool mayusculas;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 6),
      child: Semantics(
        header: true,
        child: Text(
          mayusculas ? texto.toUpperCase() : texto,
          semanticsLabel: texto,
          style: t.labelMedium?.copyWith(
            color: c.textoSecundario,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
