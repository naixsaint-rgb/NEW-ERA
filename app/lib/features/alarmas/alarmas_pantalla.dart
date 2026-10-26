import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/pantalla_proxima_semana.dart';

class AlarmasPantalla extends StatelessWidget {
  const AlarmasPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PantallaProximaSemana(
      titulo: l.pestanaAlarmas,
      tendra: l.alarmasTendra,
      semana: l.llegaEnSemanas(4, 5),
      acciones: [
        const SizedBox(height: 14),
        GrupoLista(
          children: [
            FilaLista(
              leading: const IconoCuadrado(CupertinoIcons.clock_fill),
              titulo: l.verControlHoras,
              onTap: () => context.go(Rutas.controlHoras),
            ),
          ],
        ),
      ],
    );
  }
}
