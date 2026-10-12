import 'package:flutter/material.dart';

import '../../shared/l10n_ext.dart';
import '../../shared/widgets/pantalla_proxima_semana.dart';

class ConsultasPantalla extends StatelessWidget {
  const ConsultasPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PantallaProximaSemana(
      titulo: l.pestanaConsultas,
      tendra: l.consultasTendra,
      semana: l.llegaEnSemana(12),
    );
  }
}
