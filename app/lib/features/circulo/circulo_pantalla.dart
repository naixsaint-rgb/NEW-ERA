import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/avatar_familiar.dart';

/// Lista de familiares (la gestión llega en la semana 16): cada uno lleva a
/// su puesto en el orden de aviso y, el de este móvil, a sus avisos por ntfy
/// (`FamiliarPantalla`). "Invitar otro móvil" empareja el de la persona o el
/// de otro familiar (no en la demo web: no tiene clave ni cartero).
class CirculoPantalla extends ConsumerWidget {
  const CirculoPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final demo = ref.watch(esDemoWebProvider);
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
          if (!demo) ...[
            GrupoLista(
              children: [
                FilaLista(
                  key: ClavesUi.circInvitar,
                  leading: const IconoCuadrado(CupertinoIcons.qrcode),
                  titulo: l.circInvitar,
                  subtitulo: l.circInvitarDetalle,
                  onTap: () => context.go(Rutas.circuloInvitar),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          GrupoLista(
            sangria: 84,
            pie: l.circuloGestion,
            children: [
              if (miembros.isEmpty)
                FilaLista(apagada: true, titulo: l.sinFamiliares),
              for (final m in miembros)
                FilaLista(
                  key: ClavesUi.circFamiliar(m.id),
                  altoMinimo: 76,
                  leading: AvatarFamiliar(miembro: m, tamano: 56),
                  titulo: m.nombre,
                  subtitulo: detalle(m),
                  onTap: () => context.go(Rutas.familiar(m.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
