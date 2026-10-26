import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'datos/catalogo_repositorio.dart';
import 'estado_filtro.dart';

/// Tabla resumen por grupo, ordenable por n; un toque filtra la lista.
class ResumenPantalla extends ConsumerStatefulWidget {
  const ResumenPantalla({super.key});

  @override
  ConsumerState<ResumenPantalla> createState() => _ResumenState();
}

class _ResumenState extends ConsumerState<ResumenPantalla> {
  bool _ascendente = false;
  bool _ordenadoPorN = false;

  /// Tema mostrado (`null`: todos). Por defecto el primero, para no pintar
  /// cientos de filas a la vez.
  String? _tema;
  bool _temaFijado = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final catalogo = ref.watch(catalogoProvider);
    final cabecera = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CabeceraGrande(
        titulo: l.resumenPorGrupo,
        alVolver: () => context.go(Rutas.ideas),
      ),
    );
    return Scaffold(
      body: catalogo.when(
        loading: () => Column(
          children: [
            cabecera,
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (_, _) => Column(
          children: [
            cabecera,
            Expanded(child: Center(child: Text(l.catalogoNoCargado))),
          ],
        ),
        data: (c) {
          if (!_temaFijado) {
            _tema = c.temas.first.key;
            _temaFijado = true;
          }
          final grupos = [
            for (final g in c.indice.grupos)
              if (_tema == null || g.tema == _tema) g,
          ];
          if (_ordenadoPorN) {
            grupos.sort(
              (a, b) => _ascendente ? a.n.compareTo(b.n) : b.n.compareTo(a.n),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cabecera,
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: DropdownButton<String?>(
                    value: _tema,
                    isExpanded: true,
                    onChanged: (v) => setState(() => _tema = v),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l.todosLosTemas),
                      ),
                      for (final t in c.temas)
                        DropdownMenuItem<String?>(
                          value: t.key,
                          child: Text(
                            t.titulo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      sortColumnIndex: _ordenadoPorN ? 2 : null,
                      sortAscending: _ascendente,
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(label: Text(l.campoTema)),
                        DataColumn(label: Text(l.campoGrupo)),
                        DataColumn(
                          label: Text(l.campoN),
                          numeric: true,
                          onSort: (_, asc) => setState(() {
                            _ordenadoPorN = true;
                            _ascendente = asc;
                          }),
                        ),
                        DataColumn(
                          label: Text(l.direccionMejora),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(l.direccionSinCambio),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(l.direccionEmpeora),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(l.direccionMixto),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(l.direccionNoAplica),
                          numeric: true,
                        ),
                      ],
                      rows: [
                        for (final g in grupos)
                          DataRow(
                            onSelectChanged: (_) {
                              ref
                                  .read(filtroCatalogoProvider.notifier)
                                  .soloGrupo(g.tema, g.grupo);
                              context.go(Rutas.ideas);
                            },
                            cells: [
                              DataCell(
                                _Celda(c.tituloDeTema(g.tema), ancho: 150),
                              ),
                              DataCell(_Celda(g.grupo, ancho: 220)),
                              DataCell(Text(g.n.toString())),
                              DataCell(Text(g.mejora.toString())),
                              DataCell(Text(g.sinCambio.toString())),
                              DataCell(Text(g.empeora.toString())),
                              DataCell(Text(g.mixto.toString())),
                              DataCell(Text(g.noAplica.toString())),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Texto de una celda con un ancho máximo y como mucho dos líneas.
class _Celda extends StatelessWidget {
  const _Celda(this.texto, {required this.ancho});

  final String texto;
  final double ancho;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: ancho),
    child: Text(texto, maxLines: 2, overflow: TextOverflow.ellipsis),
  );
}
