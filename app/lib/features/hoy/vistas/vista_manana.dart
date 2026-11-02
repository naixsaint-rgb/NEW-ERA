import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/providers.dart';
import '../../../core/tema/colores.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../dominio/tomas.dart';
import 'control_hoy.dart' show nombresDe;
import 'piezas_hoy.dart';

/// Vista "Mañana": tomas previstas y quién recibe los avisos.
class VistaManana extends ConsumerWidget {
  const VistaManana({super.key, required this.datos});

  final TomasPorDia datos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final config = ref.watch(configEscaladoProvider);
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final nombre = {for (final m in miembros) m.id: m.nombre};
    final familiares = [
      for (final m in miembros) (id: m.id, orden: m.ordenEscalado),
    ];
    // Los mismos que reciben el aviso real (con puestos: el 1 y el 2; sin
    // puestos: todos las dos veces).
    final avisos = [
      for (final e in escalonesToma)
        if (destinatariosDeEscalon(familiares, e) case final ids
            when ids.isNotEmpty)
          l.hoyAvisoAMinutos(
            nombresDe(l, [for (final id in ids) nombre[id] ?? '']),
            minutoDeEscalon(config, e),
          ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GrupoTomas(
          titulo: l.hoyTomasDeManana,
          tomas: datos.de(datos.manana),
          vacio: l.hoySinTomasManana,
          conEstado: false,
        ),
        separacionBloques,
        GrupoLista(
          titulo: l.hoyQuienRecibeAvisos,
          children: [
            FilaLista(
              leading: IconoCuadrado(
                CupertinoIcons.bell_fill,
                fondo: c.naranjaRelleno,
                color: c.sobreNaranja,
              ),
              titulo: avisos.isEmpty ? l.hoySinFamiliares : avisos.join(' · '),
              subtitulo: avisos.isEmpty ? null : l.hoyQuienRecibeAyuda,
            ),
          ],
        ),
      ],
    );
  }
}
