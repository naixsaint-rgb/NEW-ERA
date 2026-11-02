import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Cómo se enseña un vídeo o una foto de comprobación ya bajado y
/// descifrado. En el móvil, con `video_player` ([VisorClipMovil]); en la demo
/// web y en los tests, un marcador ([VisorClipSimulado]).
abstract interface class VisorClip {
  /// [ruta] es la absoluta del archivo; [mime], su tipo (`video/mp4`,
  /// `image/jpeg`…).
  Widget construir(
    BuildContext context, {
    required String ruta,
    required String mime,
  });
}

/// Web y tests: no hay archivos ni reproductor. Una caja gris con el texto de
/// la demo.
class VisorClipSimulado implements VisorClip {
  const VisorClipSimulado();

  @override
  Widget construir(
    BuildContext context, {
    required String ruta,
    required String mime,
  }) => ColoredBox(
    color: const Color(0xFF9E9E9E),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppLocalizations.of(context).visorClipDemo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
