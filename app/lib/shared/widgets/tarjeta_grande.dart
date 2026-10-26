import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';

/// Tarjeta de contenido de aspecto iOS: sin borde, radio 14 y relleno amplio.
///
/// Por defecto es del color `tarjeta` del tema; si la pantalla ya es de ese
/// color (las de la persona, blancas), usa `rellenoSuave` para que se vea.
/// Con [conSombra], la sombra muy suave de las tarjetas de Resumen.
class TarjetaGrande extends StatelessWidget {
  const TarjetaGrande({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.relleno = const EdgeInsets.all(16),
    this.etiquetaSemantica,
    this.radio = 14,
    this.conSombra = false,
    this.margen,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets relleno;
  final String? etiquetaSemantica;

  /// 14 la normal; 20–28 la destacada (Resumen, persona).
  final double radio;
  final bool conSombra;

  /// Margen exterior; por defecto, el de `Card` (4).
  final EdgeInsetsGeometry? margen;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final fondoPantalla = Theme.of(context).scaffoldBackgroundColor;
    final fondo =
        color ?? (fondoPantalla == c.tarjeta ? c.rellenoSuave : c.tarjeta);
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radio),
    );
    final contenido = Padding(padding: relleno, child: child);
    return Card(
      elevation: conSombra ? 1 : 0,
      shadowColor: const Color(0x0A000000),
      surfaceTintColor: Colors.transparent,
      color: fondo,
      shape: forma,
      margin: margen,
      clipBehavior: onTap == null ? Clip.none : Clip.antiAlias,
      child: onTap == null
          ? contenido
          : Semantics(
              button: true,
              label: etiquetaSemantica,
              child: InkWell(
                onTap: onTap,
                customBorder: forma,
                child: contenido,
              ),
            ),
    );
  }
}
