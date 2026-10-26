import 'package:flutter/cupertino.dart';

import '../../core/db/base_datos.dart';
import '../../core/tema/colores.dart';
import '../l10n_ext.dart';
import '../pictogramas/pastilla_pictograma.dart';
import '../widgets/foto_imagen.dart';

/// Foto de la pastilla sobre el fondo "mesa"; si no hay foto, su
/// [PastillaPictograma].
///
/// Con [insigniaCamara], una insignia de cámara pequeña abajo a la derecha
/// cuando hay foto (la hizo la familia). Radio de 12 a 20 según [tamano].
/// Se lee como "Foto de la pastilla: (nombre para la persona)".
class FotoPastilla extends StatelessWidget {
  const FotoPastilla(
    this.medicamento, {
    super.key,
    this.tamano = 56,
    this.insigniaCamara = false,
    this.radio,
    this.etiquetaSemantica,
  });

  /// Nulo si la toma no tiene medicamento: pictograma genérico.
  final Medicamento? medicamento;
  final double tamano;
  final bool insigniaCamara;
  final double? radio;
  final String? etiquetaSemantica;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final med = medicamento;
    final r = radio ?? (tamano * 0.22).clamp(12.0, 20.0);
    final etiqueta =
        etiquetaSemantica ??
        (med == null
            ? null
            : context.l.semanticaFotoPastilla(med.nombreParaPersona));
    final foto = ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: ColoredBox(
        color: c.mesa,
        child: SizedBox.square(
          dimension: tamano,
          child: FotoImagen(
            fotoId: med?.fotoPastillaId,
            ancho: tamano,
            alto: tamano,
            alternativa: Center(
              child: PastillaPictograma(
                forma: med?.forma ?? 'otra',
                color: med?.color,
                tamano: tamano * 0.8,
                colorBorde: c.mesaBorde,
              ),
            ),
          ),
        ),
      ),
    );
    Widget hijo = foto;
    if (insigniaCamara && med?.fotoPastillaId != null) {
      final d = (tamano * 0.36).clamp(18.0, 28.0);
      hijo = Stack(
        clipBehavior: Clip.none,
        children: [
          foto,
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: d,
              height: d,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.tarjeta,
                shape: BoxShape.circle,
                border: Border.all(color: c.barraBorde),
              ),
              child: Icon(
                CupertinoIcons.camera_fill,
                size: d * 0.55,
                color: c.texto,
              ),
            ),
          ),
        ],
      );
    }
    return Semantics(
      image: true,
      label: etiqueta,
      excludeSemantics: true,
      child: SizedBox.square(dimension: tamano, child: hijo),
    );
  }
}
