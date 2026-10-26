import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'dominio/tomas.dart';
import 'vistas/vista_ayer.dart';
import 'vistas/vista_hoy.dart';
import 'vistas/vista_manana.dart';
import 'vistas/vista_semana.dart';

// Siguen importables desde aquí, como antes del rediseño.
export 'dominio/tomas.dart'
    show NivelSemaforo, nivelSemaforo, nombresAutoresProvider;
export 'vistas/piezas_hoy.dart' show quienConfirmo, quienYComo;

/// Las cuatro vistas del selector; su `name` es el valor de `?vista=`.
enum PeriodoHoy { ayer, hoy, manana, semana }

/// Pestaña Hoy de la familia: Ayer · Hoy · Mañana · Semana (spec §7).
///
/// Empieza en la vista de `?vista=` ([Rutas.hoyVista]) si es válida.
class HoyPantalla extends ConsumerStatefulWidget {
  const HoyPantalla({super.key});

  @override
  ConsumerState<HoyPantalla> createState() => _HoyPantallaState();
}

class _HoyPantallaState extends ConsumerState<HoyPantalla> {
  PeriodoHoy _periodo = PeriodoHoy.hoy;

  /// Último `?vista=` leído de la ruta, para no pisar la elección a mano.
  String? _vistaDeRuta;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vista = _leerVista();
    if (vista == _vistaDeRuta) return;
    _vistaDeRuta = vista;
    for (final p in PeriodoHoy.values) {
      if (p.name == vista) _periodo = p;
    }
  }

  String? _leerVista() {
    try {
      return GoRouterState.of(context).uri.queryParameters['vista'];
    } on GoError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final ahora =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final datos = ref.watch(tomasPorDiaProvider);
    final abajo = MediaQuery.paddingOf(context).bottom;

    final contenido = datos.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(
        l.errorGenerico,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.texto),
      ),
      data: (d) => switch (_periodo) {
        PeriodoHoy.ayer => VistaAyer(datos: d),
        PeriodoHoy.hoy => VistaHoy(datos: d, ahora: ahora),
        PeriodoHoy.manana => VistaManana(datos: d),
        PeriodoHoy.semana => VistaSemana(datos: d),
      },
    );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: fechaLarga(aLocal(ahora, zona)),
            titulo: l.pestanaHoy,
          ),
          const SizedBox(height: 14),
          SelectorSegmentos<PeriodoHoy>(
            valores: PeriodoHoy.values,
            etiqueta: (p) => switch (p) {
              PeriodoHoy.ayer => l.hoySegmentoAyer,
              PeriodoHoy.hoy => l.hoySegmentoHoy,
              PeriodoHoy.manana => l.hoySegmentoManana,
              PeriodoHoy.semana => l.hoySegmentoSemana,
            },
            seleccionado: _periodo,
            alCambiar: (p) => setState(() => _periodo = p),
            clave: (p) => ClavesUi.segmento(p.name),
          ),
          const SizedBox(height: 14),
          contenido,
        ],
      ),
    );
  }
}
