import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/voces_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/avatar_familiar.dart';
import 'textos_voz.dart';

/// Voces (familia): cada familiar con su voz grabada y cuántas frases tiene
/// aprobadas. Tocar un familiar abre sus frases. La voz clonada llega en la
/// semana 9.
class VocesPantalla extends ConsumerWidget {
  const VocesPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final router = GoRouter.maybeOf(context);
    final puedeVolver = router != null && router.canPop();
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final voces = ref.watch(vocesProvider).value ?? const <Voz>[];
    final frases = ref.watch(frasesProvider).value ?? const <Frase>[];
    final alias = ref.watch(personaProvider).value?.alias ?? '';

    String estado(Miembro m) {
      final activa = vozActivaDe(m.id, voces);
      if (activa == null) {
        return vozRetiradaDe(m.id, voces) == null
            ? l.vozSinGrabar
            : l.vozRetirada;
      }
      final aprobadas = frasesDeVoz(
        activa.id,
        frases,
      ).values.where((f) => f.aprobada && f.audioRuta != null).length;
      return l.vozAprobadas(aprobadas, UsoFrase.values.length);
    }

    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            titulo: l.pestanaVoces,
            vispera: l.vozVispera,
            alVolver: puedeVolver ? router.pop : null,
          ),
          const SizedBox(height: 8),
          Text(l.vozIntro(alias), style: t.bodyLarge?.copyWith(color: c.texto)),
          const SizedBox(height: 14),
          GrupoLista(
            titulo: l.vozFamiliares,
            sangria: 84,
            children: [
              if (miembros.isEmpty)
                FilaLista(apagada: true, titulo: l.sinFamiliares),
              for (final m in miembros)
                FilaLista(
                  key: ClavesUi.vozMiembro(m.id),
                  altoMinimo: 76,
                  leading: AvatarFamiliar(miembro: m, tamano: 56),
                  titulo: m.nombre,
                  subtitulo: estado(m),
                  onTap: () => context.go(Rutas.voz(m.id)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          GrupoLista(
            titulo: l.hoyLlegaPronto,
            children: [
              FilaLista(
                apagada: true,
                leading: IconoCuadrado(CupertinoIcons.waveform, fondo: c.gris),
                titulo: l.vozClonada,
                subtitulo: l.llegaEnSemana(9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
