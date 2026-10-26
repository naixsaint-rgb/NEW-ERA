import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../dominio/tomas.dart';
import 'piezas_hoy.dart';

/// Vista "Ayer": tomas de ayer con su estado y quién las confirmó, las
/// comprobaciones y el aviso del control por horas.
class VistaAyer extends ConsumerWidget {
  const VistaAyer({super.key, required this.datos});

  final TomasPorDia datos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final nombres = ref.watch(nombresAutoresProvider);
    final deAyer = datos.de(datos.ayer);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GrupoTomas(
          titulo: l.hoyTomasDeAyer,
          tomas: deAyer,
          vacio: l.hoySinTomasAyer,
          nota: (x) => quienConfirmo(l, x, nombres),
        ),
        separacionBloques,
        GrupoComprobaciones(tomas: deAyer, vacio: l.hoySinComprobacionesAyer),
        separacionBloques,
        GrupoLista(
          children: [FilaLlegaPronto(titulo: l.hoyRespuestasControlLlega(5))],
        ),
      ],
    );
  }
}
