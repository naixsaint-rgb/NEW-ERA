import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import 'datos/catalogo_repositorio.dart';
import 'dominio/filtro.dart';
import 'dominio/modelo.dart';
import 'estado_filtro.dart';
import 'etiqueta_direccion.dart';

/// Filas filtradas con el estado actual.
final filasFiltradasProvider = Provider<AsyncValue<List<FilaCatalogo>>>((ref) {
  final filtro = ref.watch(filtroCatalogoProvider);
  return ref
      .watch(catalogoProvider)
      .whenData((c) => filtrarFilas(c.filas, filtro));
});

const _ordenDirecciones = [
  'mejora',
  'sin cambio',
  'empeora',
  'mixto',
  'no aplica',
];

/// "Ideas y tablas": el catálogo con filtros, resumen, fichas y dosieres.
class CatalogoPantalla extends ConsumerWidget {
  const CatalogoPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final catalogo = ref.watch(catalogoProvider);
    final cabecera = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CabeceraGrande(titulo: l.pestanaIdeas),
    );
    return Scaffold(
      body: catalogo.when(
        loading: () => Column(
          children: [
            cabecera,
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (e, _) => Column(
          children: [
            cabecera,
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.catalogoNoCargado),
                ),
              ),
            ),
          ],
        ),
        data: (c) => _Contenido(catalogo: c, cabecera: cabecera),
      ),
    );
  }
}

class _Contenido extends ConsumerStatefulWidget {
  const _Contenido({required this.catalogo, required this.cabecera});

  final Catalogo catalogo;

  /// Cabecera grande, que se desplaza con la lista.
  final Widget cabecera;

  @override
  ConsumerState<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends ConsumerState<_Contenido> {
  late final TextEditingController _buscador;

  @override
  void initState() {
    super.initState();
    _buscador = TextEditingController(
      text: ref.read(filtroCatalogoProvider).texto,
    );
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final c = widget.catalogo;
    final filtro = ref.watch(filtroCatalogoProvider);
    final filas =
        ref.watch(filasFiltradasProvider).value ?? const <FilaCatalogo>[];
    ref.listen(filtroCatalogoProvider, (previo, ahora) {
      if (_buscador.text != ahora.texto) _buscador.text = ahora.texto;
    });
    final notificador = ref.read(filtroCatalogoProvider.notifier);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: widget.cabecera),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TarjetaGrande(
                  child: Text(l.catalogoCabecera, style: t.bodyLarge),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go(Rutas.resumen),
                      icon: const Icon(Icons.table_chart),
                      label: Text(l.resumenPorGrupo),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: Text(l.dosieresPorTema),
                  children: [
                    for (final tema in c.temas)
                      ListTile(
                        title: Text(tema.titulo),
                        subtitle: Text(l.nFilas(tema.nFilas)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(Rutas.tema(tema.key)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  key: ClavesUi.buscadorCatalogo,
                  controller: _buscador,
                  decoration: InputDecoration(
                    labelText: l.buscar,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: notificador.texto,
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: Text(l.filtrarPorTema),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (final tema in c.temas)
                            FilterChip(
                              label: Text(tema.titulo),
                              selected: filtro.temas.contains(tema.key),
                              onSelected: (_) =>
                                  notificador.alternarTema(tema.key),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(l.filtrarPorDireccion, style: t.titleSmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final d in _ordenDirecciones)
                      if (c.indice.porDireccion.containsKey(d))
                        FilterChip(
                          avatar: Icon(
                            EtiquetaDireccion.iconoDe(d),
                            color: EtiquetaDireccion.colorDe(d),
                            size: 18,
                          ),
                          label: Text(
                            l.etiquetaConConteo(
                              EtiquetaDireccion.textoDe(context, d),
                              c.indice.porDireccion[d]!,
                            ),
                          ),
                          selected: filtro.direcciones.contains(d),
                          onSelected: (_) => notificador.alternarDireccion(d),
                        ),
                  ],
                ),
                ExpansionTile(
                  title: Text(l.filtrarPorTipoFuente),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (final e in c.indice.porTipoFuente.entries)
                            FilterChip(
                              label: Text(l.etiquetaConConteo(e.key, e.value)),
                              selected: filtro.tiposFuente.contains(e.key),
                              onSelected: (_) =>
                                  notificador.alternarTipo(e.key),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (filtro.grupo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: InputChip(
                      label: Text(l.grupoFiltrado(filtro.grupo!)),
                      onDeleted: notificador.quitarGrupo,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.nDeTotal(filas.length, c.indice.totalFilas),
                        style: t.titleMedium,
                      ),
                    ),
                    if (!filtro.vacio)
                      TextButton.icon(
                        onPressed: notificador.limpiar,
                        icon: const Icon(Icons.filter_alt_off),
                        label: Text(l.quitarFiltros),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList.builder(
            itemCount: filas.length,
            itemBuilder: (context, i) =>
                _TarjetaFila(fila: filas[i], catalogo: c),
          ),
        ),
      ],
    );
  }
}

class _TarjetaFila extends StatelessWidget {
  const _TarjetaFila({required this.fila, required this.catalogo});

  final FilaCatalogo fila;
  final Catalogo catalogo;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TarjetaGrande(
        key: ClavesUi.filaCatalogo(fila.id),
        onTap: () => context.go(Rutas.fila(fila.id)),
        etiquetaSemantica: l.abrirFicha(fila.estudio ?? fila.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fila.grupo ?? l.noConsta, style: t.titleMedium),
            const SizedBox(height: 2),
            Text(fila.estudio ?? l.noConsta, style: t.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                EtiquetaDireccion(direccion: fila.direccionSegunLaFuente),
                Text(fila.tipoFuente ?? l.noConsta, style: t.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              fila.resultadoReportado ?? l.noConsta,
              style: t.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
