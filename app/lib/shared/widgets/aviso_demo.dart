import 'package:flutter/material.dart';

import '../l10n_ext.dart';

/// Banner fijo de la demo web: datos de ejemplo, sin cifrar.
class AvisoDemo extends StatelessWidget {
  const AvisoDemo({super.key, required this.alCambiarPerfil});

  final VoidCallback alCambiarPerfil;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Material(
      color: const Color(0xFFFFF3CD),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Text(
                l.avisoDemo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: alCambiarPerfil,
                child: Text(l.cambiarPerfil),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
