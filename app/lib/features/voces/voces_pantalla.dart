import 'package:flutter/material.dart';

import '../../shared/l10n_ext.dart';
import '../../shared/widgets/pantalla_proxima_semana.dart';

class VocesPantalla extends StatelessWidget {
  const VocesPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PantallaProximaSemana(
      titulo: l.pestanaVoces,
      tendra: l.vocesTendra,
      semana: l.llegaEnSemanas(8, 9),
    );
  }
}
