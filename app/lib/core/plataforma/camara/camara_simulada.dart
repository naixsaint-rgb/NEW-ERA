import 'package:flutter/widgets.dart';
import 'package:safety_core/safety_core.dart';

import '../../../l10n/app_localizations.dart';

import 'camara_comprobacion.dart';

/// Web y tests: no hay cámara. Muestra una caja gris con el texto de la demo y
/// termina con `clip_fallido` (`no_disponible`).
class CamaraSimulada implements CamaraComprobacion {
  const CamaraSimulada({this.espera = const Duration(seconds: 1)});

  /// Duración de cada paso de la cuenta atrás.
  final Duration espera;

  @override
  Future<(SesionCamara?, MotivoClipFallido?)> abrir() async =>
      (_SesionSimulada(espera), null);
}

class _SesionSimulada implements SesionCamara {
  _SesionSimulada(this.espera);

  final Duration espera;
  bool _cerrada = false;

  @override
  Widget vistaPrevia(BuildContext context) => ColoredBox(
    color: const Color(0xFF9E9E9E),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppLocalizations.of(context).camaraDemo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );

  @override
  Future<ResultadoCamara> grabar({
    required String tomaId,
    required TipoComprobacion tipo,
    required int segundos,
    required ValueChanged<int> restante,
  }) async {
    // En la demo la cuenta atrás es corta: 3 pasos como mucho.
    final pasos = segundos.clamp(1, 3);
    for (var i = pasos; i > 0; i--) {
      if (_cerrada) return const ClipFallido(MotivoClipFallido.cancelado);
      restante(i);
      await Future<void>.delayed(espera);
    }
    return const ClipFallido(MotivoClipFallido.noDisponible);
  }

  @override
  Future<void> cerrar() async => _cerrada = true;
}
