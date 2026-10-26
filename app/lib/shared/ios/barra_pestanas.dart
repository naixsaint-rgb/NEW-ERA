import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';

/// Un destino de la [BarraPestanas].
class ElementoBarra {
  const ElementoBarra({
    required this.icono,
    required this.etiqueta,
    this.clave,
  });

  final IconData icono;
  final String etiqueta;

  /// `Key` del destino (p. ej. `ClavesUi.pestana('hoy')`).
  final Key? clave;
}

/// Barra de pestañas inferior de iOS: fondo `barra` con borde fino arriba,
/// iconos de 26 y etiqueta 10/600 (11 en Android); la activa en azul y el
/// resto en gris. Sustituye a `NavigationBar` en pantalla estrecha.
///
/// [seleccionada] nulo: ninguna activa (p. ej. en Ajustes, que está en "Más").
class BarraPestanas extends StatelessWidget {
  const BarraPestanas({
    super.key,
    required this.elementos,
    required this.seleccionada,
    required this.alElegir,
  });

  final List<ElementoBarra> elementos;
  final int? seleccionada;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Material(
      color: c.barra,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.barraBorde, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < elementos.length; i++)
                    Expanded(
                      child: _Pestana(
                        key: elementos[i].clave,
                        elemento: elementos[i],
                        activa: i == seleccionada,
                        alPulsar: () => alElegir(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({
    super.key,
    required this.elemento,
    required this.activa,
    required this.alPulsar,
  });

  final ElementoBarra elemento;
  final bool activa;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final color = activa ? c.azul : c.textoSecundario;
    final android = Theme.of(context).platform == TargetPlatform.android;
    return Semantics(
      button: true,
      selected: activa,
      label: elemento.etiqueta,
      excludeSemantics: true,
      onTap: alPulsar,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alPulsar,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(elemento.icono, size: 26, color: color),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    elemento.etiqueta,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: android ? 11 : 10,
                      fontWeight: activa ? FontWeight.w600 : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
