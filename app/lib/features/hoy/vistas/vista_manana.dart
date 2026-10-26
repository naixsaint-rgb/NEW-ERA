import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/providers.dart';
import '../../../core/tema/colores.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../../persona_inicio/llamadas.dart';
import '../dominio/tomas.dart';
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
    final orden = familiaresPorOrden(miembros);
    final minutos = [
      minutoDePaso(config, AccionEscalado.avisarFamiliar1, porDefecto: 5),
      minutoDePaso(
        config,
        AccionEscalado.avisarFamiliar2YReloj,
        porDefecto: 10,
      ),
    ];
    final avisos = [
      for (var i = 0; i < orden.length && i < minutos.length; i++)
        l.hoyAvisoAMinutos(orden[i].nombre, minutos[i]),
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
