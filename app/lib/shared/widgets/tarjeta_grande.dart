import 'package:flutter/material.dart';

/// Tarjeta de contenido con borde marcado y relleno amplio.
class TarjetaGrande extends StatelessWidget {
  const TarjetaGrande({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.relleno = const EdgeInsets.all(16),
    this.etiquetaSemantica,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets relleno;
  final String? etiquetaSemantica;

  @override
  Widget build(BuildContext context) {
    final contenido = Padding(padding: relleno, child: child);
    return Card(
      elevation: 0,
      color: color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF555555), width: 1.5),
      ),
      child: onTap == null
          ? contenido
          : Semantics(
              button: true,
              label: etiquetaSemantica,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: contenido,
              ),
            ),
    );
  }
}
