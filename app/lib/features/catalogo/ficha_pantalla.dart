import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import 'datos/catalogo_repositorio.dart';
import 'dominio/modelo.dart';
import 'etiqueta_direccion.dart';

/// Los 21 campos de una fila, con "Abrir la fuente".
class FichaPantalla extends ConsumerWidget {
  const FichaPantalla({super.key, required this.filaId});

  final String filaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final catalogo = ref.watch(catalogoProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.fichaTitulo),
        leading: BackButton(onPressed: () => context.go(Rutas.ideas)),
      ),
      body: catalogo.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l.catalogoNoCargado)),
        data: (c) {
          final f = c.fila(filaId);
          if (f == null) return Center(child: Text(l.filaNoEncontrada));
          final campos = _campos(l, c, f);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TarjetaGrande(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.grupo ?? l.noConsta, style: t.headlineSmall),
                    const SizedBox(height: 8),
                    EtiquetaDireccion(direccion: f.direccionSegunLaFuente),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final (etiqueta, valor) in campos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(etiqueta, style: t.titleSmall),
                      SelectableText(valor ?? l.noConsta, style: t.bodyLarge),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: ClavesUi.enlaceFicha,
                onPressed: f.enlace == null
                    ? null
                    : () async {
                        final uri = Uri.tryParse(f.enlace!);
                        if (uri != null) {
                          try {
                            await ref.read(abrirEnlaceProvider)(uri);
                          } catch (_) {
                            // Sin navegador disponible: la dirección queda seleccionable.
                          }
                        }
                      },
                icon: const Icon(Icons.open_in_new),
                label: Text(l.abrirLaFuente),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Los 21 campos, con las etiquetas de `COLS` de `build_catalogo.py`.
  static List<(String, String?)> _campos(
    AppLocalizations l,
    Catalogo c,
    FilaCatalogo f,
  ) => [
    (l.campoTema, c.tituloDeTema(f.temaKey)),
    (l.campoGrupo, f.grupo),
    (l.campoIntervencion, f.intervencion),
    (l.campoTradicion, f.tradicionOAngulo),
    (l.campoEstudio, f.estudio),
    (l.campoTipoFuente, f.tipoFuente),
    (l.campoDiseno, f.diseno),
    (l.campoN, f.n),
    (l.campoPoblacion, f.poblacion),
    (l.campoDuracion, f.duracion),
    (l.campoDosis, f.dosisOProtocolo),
    (l.campoQueMidio, f.queMidio),
    (l.campoResultado, f.resultadoReportado),
    (l.campoDireccion, f.direccionSegunLaFuente),
    (l.campoEfectosAdversos, f.efectosAdversosReportados),
    (l.campoFinanciacion, f.financiacionYConflictos),
    (l.campoComoProbarlo, f.comoProbarloEnCasa),
    (l.campoCoste, f.costeAprox),
    (l.campoVerificacion, f.verificacion),
    (l.campoIdentificador, f.identificador),
    (l.campoEnlace, f.enlace),
  ];
}
