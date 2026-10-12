import 'package:flutter/material.dart';

import '../../shared/l10n_ext.dart';
import '../../shared/widgets/pantalla_proxima_semana.dart';

class ControlHorasPantalla extends StatelessWidget {
  const ControlHorasPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PantallaProximaSemana(
      titulo: l.controlHorasTitulo,
      tendra: l.controlHorasTendra,
      semana: l.llegaEnSemana(5),
    );
  }
}
