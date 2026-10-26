import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import 'datos/catalogo_repositorio.dart';
import 'estado_filtro.dart';

/// Dosier de un tema con sus 9 apartados.
class DosierPantalla extends ConsumerWidget {
  const DosierPantalla({super.key, required this.temaKey});

  final String temaKey;

  static String _titulo(AppLocalizations l, String apartado) =>
      switch (apartado) {
        'tesis' => l.dosierTesis,
        'defensores' => l.dosierDefensores,
        'mecanismos' => l.dosierMecanismos,
        'consenso_y_quien_lo_paga' => l.dosierConsenso,
        'lo_enterrado' => l.dosierEnterrado,
        'protocolos_reportados' => l.dosierProtocolos,
        'riesgos_reconocidos_por_defensores' => l.dosierRiesgos,
        'fuentes_heterodoxas' => l.dosierFuentes,
        'ideas_para_la_app' => l.dosierIdeas,
        _ => apartado,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final catalogo = ref.watch(catalogoProvider);
    final cabecera = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CabeceraGrande(
        titulo: l.dosierTitulo,
        alVolver: () => context.go(Rutas.ideas),
      ),
    );
    Widget conCabecera(Widget centro) => Column(
      children: [
        cabecera,
        Expanded(child: Center(child: centro)),
      ],
    );
    return Scaffold(
      body: catalogo.when(
        loading: () => conCabecera(const CircularProgressIndicator()),
        error: (_, _) => conCabecera(Text(l.catalogoNoCargado)),
        data: (c) {
          final tema = c.tema(temaKey);
          if (tema == null) return conCabecera(Text(l.temaNoEncontrado));
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              CabeceraGrande(
                titulo: l.dosierTitulo,
                alVolver: () => context.go(Rutas.ideas),
              ),
              const SizedBox(height: 14),
              Text(tema.titulo, style: t.headlineSmall),
              const SizedBox(height: 4),
              Text(l.nFilas(tema.nFilas), style: t.bodyMedium),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(filtroCatalogoProvider.notifier).soloTema(tema.key);
                  context.go(Rutas.ideas);
                },
                icon: const Icon(Icons.list),
                label: Text(l.verFilasDelTema),
              ),
              const SizedBox(height: 12),
              for (final e in tema.dosier.apartados.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TarjetaGrande(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(_titulo(l, e.key), style: t.titleMedium),
                        ),
                        const SizedBox(height: 8),
                        if (e.value is List)
                          for (final x in e.value! as List<String>)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(
                                    child: SelectableText(
                                      x,
                                      style: t.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            )
                        else
                          SelectableText(
                            (e.value as String?) ?? l.noConsta,
                            style: t.bodyLarge,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
