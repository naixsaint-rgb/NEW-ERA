import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/base_datos.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/avatar_familiar.dart';

/// Lista de familiares, solo lectura (la gestión llega en la semana 16).
class CirculoPantalla extends ConsumerWidget {
  const CirculoPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final abajo = MediaQuery.paddingOf(context).bottom;
    String rol(String r) => switch (r) {
      'responsable' => l.rolResponsable,
      'cuidador' => l.rolCuidador,
      'apoyo' => l.rolApoyo,
      _ => l.rolLectura,
    };
    String detalle(Miembro m) {
      final relacion = l.relacionYRol(m.relacion, rol(m.rol));
      final orden = m.ordenEscalado;
      return orden == null ? relacion : '$relacion\n${l.ordenDeAviso(orden)}';
    }

    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(titulo: l.pestanaCirculo),
          const SizedBox(height: 14),
          GrupoLista(
            sangria: 84,
            pie: l.circuloGestion,
            children: [
              if (miembros.isEmpty)
                FilaLista(apagada: true, titulo: l.sinFamiliares),
              for (final m in miembros)
                FilaLista(
                  altoMinimo: 76,
                  leading: AvatarFamiliar(miembro: m, tamano: 56),
                  titulo: m.nombre,
                  subtitulo: detalle(m),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
