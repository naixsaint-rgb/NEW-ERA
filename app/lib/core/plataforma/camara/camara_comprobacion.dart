import 'package:flutter/widgets.dart';
import 'package:safety_core/safety_core.dart';

/// Motivos de `clip_fallido`.
enum MotivoClipFallido {
  permiso('permiso'),
  cancelado('cancelado'),
  error('error'),
  noDisponible('no_disponible');

  const MotivoClipFallido(this.nombre);
  final String nombre;
}

/// Resultado de la comprobación con cámara.
sealed class ResultadoCamara {
  const ResultadoCamara();
}

final class ClipGrabado extends ResultadoCamara {
  const ClipGrabado({
    required this.tipo,
    required this.ruta,
    required this.duracionMs,
  });

  /// `video` o `foto`.
  final TipoComprobacion tipo;
  final String ruta;
  final int duracionMs;
}

final class ClipFallido extends ResultadoCamara {
  const ClipFallido(this.motivo);

  final MotivoClipFallido motivo;
}

/// Una sesión de cámara abierta para una toma.
abstract interface class SesionCamara {
  /// Vista previa a pantalla completa.
  Widget vistaPrevia(BuildContext context);

  /// Graba [segundos] (vídeo) o hace una foto a los 3 s, avisando de los
  /// segundos que quedan con [restante].
  Future<ResultadoCamara> grabar({
    required String tomaId,
    required TipoComprobacion tipo,
    required int segundos,
    required ValueChanged<int> restante,
  });

  Future<void> cerrar();
}

/// Fábrica de sesiones: la cámara frontal en móvil, un marcador en web.
abstract interface class CamaraComprobacion {
  /// Abre la cámara. Si no puede, devuelve el motivo.
  Future<(SesionCamara?, MotivoClipFallido?)> abrir();
}
