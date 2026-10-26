import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';
import '../l10n_ext.dart';

/// Cabecera grande de iOS: víspera (13/600 en mayúsculas, gris) y título
/// 34/800.
///
/// Va dentro del margen lateral de la pantalla (20) y pone ella misma la zona
/// segura de arriba + 12, así que puede ser el primer hijo de una lista sin
/// relleno superior. Deja [reservaBotonMas] libres a la derecha para el botón
/// "Más" que pinta el `FamiliaShell` (quítalo con `reservarBotonMas: false`).
class CabeceraGrande extends StatelessWidget {
  const CabeceraGrande({
    super.key,
    required this.titulo,
    this.vispera,
    this.accion,
    this.alVolver,
    this.reservarBotonMas = true,
  });

  /// Ancho libre a la derecha para el botón "Más".
  static const reservaBotonMas = 48.0;

  final String titulo;

  /// Texto pequeño encima del título (la fecha, "Pastillero y pastillas").
  final String? vispera;

  /// Botón opcional a la derecha del título (p. ej. "Añadir medicamento").
  final Widget? accion;

  /// Si no es nulo, pinta un botón "Volver" encima del título.
  final VoidCallback? alVolver;

  final bool reservarBotonMas;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final arriba = MediaQuery.paddingOf(context).top + 12;
    final vispera = this.vispera;
    final accion = this.accion;
    final alVolver = this.alVolver;
    return Padding(
      padding: EdgeInsets.only(
        top: arriba,
        bottom: 2,
        right: reservarBotonMas ? reservaBotonMas : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alVolver != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: alVolver,
                style: TextButton.styleFrom(
                  foregroundColor: c.azul,
                  padding: const EdgeInsetsDirectional.only(start: 0, end: 8),
                  textStyle: t.bodyLarge,
                ),
                icon: const Icon(CupertinoIcons.chevron_back, size: 22),
                label: Text(context.l.volver),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (vispera != null)
                      Text(
                        vispera.toUpperCase(),
                        semanticsLabel: vispera,
                        style: t.labelMedium?.copyWith(
                          color: c.textoSecundario,
                          letterSpacing: 0.4,
                        ),
                      ),
                    // El título de 34 se limita a 1,5x: al 200 % se partiría a
                    // media palabra.
                    MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.5,
                      child: Semantics(
                        header: true,
                        child: Text(
                          titulo,
                          maxLines: 2,
                          softWrap: true,
                          style: t.headlineLarge?.copyWith(
                            color: c.texto,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (accion != null) ...[const SizedBox(width: 12), accion],
            ],
          ),
        ],
      ),
    );
  }
}
