import 'package:flutter/material.dart';

import '../../shared/l10n_ext.dart';
import '../../shared/widgets/pantalla_proxima_semana.dart';

class CalendarioPantalla extends StatelessWidget {
  const CalendarioPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PantallaProximaSemana(
      titulo: l.pestanaCalendario,
      tendra: l.calendarioTendra,
      semana: l.llegaEnSemana(13),
    );
  }
}
