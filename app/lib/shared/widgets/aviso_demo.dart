import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';
import '../l10n_ext.dart';

/// Banner fijo de la demo web: datos de ejemplo, sin cifrar.
///
/// Discreto: una sola línea tintada de naranja con texto de 13 y el botón
/// "Cambiar perfil" subrayado a la derecha; se lee en claro y en oscuro.
class AvisoDemo extends StatelessWidget {
  const AvisoDemo({super.key, required this.alCambiarPerfil});

  final VoidCallback alCambiarPerfil;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Material(
      color: c.naranjaClaro,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.avisoDemo,
                  style: t.bodySmall?.copyWith(
                    color: c.texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: alCambiarPerfil,
                style: TextButton.styleFrom(
                  foregroundColor: c.texto,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: Text(l.cambiarPerfil),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
