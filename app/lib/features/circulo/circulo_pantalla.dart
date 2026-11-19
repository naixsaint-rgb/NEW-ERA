import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/circulo_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/avatar_familiar.dart';
import 'papel_familiar.dart';

/// Lista de familiares: "Añadir familiar" y, de cada uno, su ficha
/// (`FamiliarPantalla`: puesto en el orden de aviso, editar, quitar y, en el
/// de este móvil, sus avisos por ntfy). "Invitar otro móvil" empareja el de la
/// persona o el de otro familiar (no en la demo web: no tiene clave ni
/// cartero). Un móvil que se unió por invitación y aún se llama «Familiar»
/// ve arriba "Pon tu nombre".
class CirculoPantalla extends ConsumerWidget {
  const CirculoPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final demo = ref.watch(esDemoWebProvider);
    final abajo = MediaQuery.paddingOf(context).bottom;
    final propioId = ref.watch(sesionProvider).miembroId;
    final sinNombre = miembros
        .where(
          (m) =>
              m.id == propioId &&
              m.nombre == CirculoRepositorio.nombreProvisional,
        )
        .firstOrNull;
    String rol(String r) => switch (r) {
      'responsable' => l.rolResponsable,
      'cuidador' => l.rolCuidador,
      'apoyo' => l.rolApoyo,
      _ => l.rolLectura,
    };
    String detalle(Miembro m) {
      final relacion = l.relacionYRol(
        PapelFamiliar.etiqueta(l, m.relacion),
        rol(m.rol),
      );
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
            children: [
              if (sinNombre != null)
                FilaLista(
                  key: ClavesUi.circPonNombre,
                  leading: const IconoCuadrado(CupertinoIcons.pencil),
                  titulo: l.circPonTuNombre,
                  subtitulo: l.circPonTuNombreDetalle,
                  onTap: () => context.go(Rutas.familiarEditar(sinNombre.id)),
                ),
              FilaLista(
                key: ClavesUi.circAnadir,
                leading: const IconoCuadrado(CupertinoIcons.person_add),
                titulo: l.circAnadir,
                subtitulo: l.circAnadirDetalle,
                onTap: () => context.go(Rutas.circuloNuevo),
              ),
            ],
          ),
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
