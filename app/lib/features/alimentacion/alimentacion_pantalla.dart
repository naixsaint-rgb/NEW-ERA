import 'package:flutter/material.dart';

import '../../shared/l10n_ext.dart';
import '../../shared/widgets/pantalla_proxima_semana.dart';

class AlimentacionPantalla extends StatelessWidget {
  const AlimentacionPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PantallaProximaSemana(
      titulo: l.pestanaAlimentacion,
      tendra: l.alimentacionTendra,
      semana: l.llegaEnSemana(14),
    );
  }
}
