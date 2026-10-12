import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Muestra una foto de la base por id; si no hay, el [alternativa].
class FotoImagen extends ConsumerWidget {
  const FotoImagen({
    super.key,
    required this.fotoId,
    required this.alternativa,
    this.ancho,
    this.alto,
    this.ajuste = BoxFit.cover,
    this.etiquetaSemantica,
  });

  final String? fotoId;
  final Widget alternativa;
  final double? ancho;
  final double? alto;
  final BoxFit ajuste;
  final String? etiquetaSemantica;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = fotoId;
    if (id == null) return alternativa;
    final foto = ref.watch(fotoProvider(id));
    return foto.when(
      data: (bytes) => bytes == null
          ? alternativa
          : Image.memory(
              bytes,
              width: ancho,
              height: alto,
              fit: ajuste,
              gaplessPlayback: true,
              semanticLabel: etiquetaSemantica,
              errorBuilder: (_, _, _) => alternativa,
            ),
      loading: () => SizedBox(width: ancho, height: alto),
      error: (_, _) => alternativa,
    );
  }
}
