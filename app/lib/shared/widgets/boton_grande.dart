import 'package:flutter/material.dart';

/// Botón grande de ancho completo, con icono opcional.
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
  });

  final String texto;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icono;
  final double altura;
  final String? etiquetaSemantica;
  final double? tamanoTexto;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.white,
      fontSize: tamanoTexto,
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
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF9E9E9E),
            disabledForegroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icono != null) ...[
                Icon(icono, size: (altura * 0.4).clamp(28, 56)),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(texto, style: estilo, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
