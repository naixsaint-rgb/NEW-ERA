import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/l10n_ext.dart';
import 'rutas.dart';

/// Una pestaña de la familia.
class PestanaFamilia {
  const PestanaFamilia(this.slug, this.icono);

  final String slug;
  final IconData icono;

  String etiqueta(AppLocalizations l) => switch (slug) {
    'hoy' => l.pestanaHoy,
    'medicacion' => l.pestanaMedicacion,
    'calendario' => l.pestanaCalendario,
    'consultas' => l.pestanaConsultas,
    'alarmas' => l.pestanaAlarmas,
    'voces' => l.pestanaVoces,
    'alimentacion' => l.pestanaAlimentacion,
    'ideas' => l.pestanaIdeas,
    'circulo' => l.pestanaCirculo,
    _ => l.pestanaAjustes,
  };
}

const pestanasFamilia = [
  PestanaFamilia('hoy', Icons.today),
  PestanaFamilia('medicacion', Icons.medication),
  PestanaFamilia('calendario', Icons.calendar_month),
  PestanaFamilia('consultas', Icons.medical_services),
  PestanaFamilia('alarmas', Icons.alarm),
  PestanaFamilia('voces', Icons.record_voice_over),
  PestanaFamilia('alimentacion', Icons.restaurant),
  PestanaFamilia('ideas', Icons.science),
  PestanaFamilia('circulo', Icons.groups),
  PestanaFamilia('ajustes', Icons.settings),
];

/// Las cuatro pestañas de la barra inferior (la quinta es "Más").
const _slugsBarra = ['hoy', 'medicacion', 'calendario', 'ideas'];

/// Las seis que van en "Más".
final _slugsMas = [
  for (final p in pestanasFamilia)
    if (!_slugsBarra.contains(p.slug)) p,
];

const _anchoRail = 840.0;

/// Desde 840 dp, `NavigationRail` con las 10 pestañas (desplazable); por
/// debajo, `NavigationBar` con cuatro pestañas y "Más".
class FamiliaShell extends StatelessWidget {
  const FamiliaShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ancho = MediaQuery.sizeOf(context).width;
    if (ancho >= _anchoRail) {
      return Scaffold(
        body: Row(
          children: [
            LayoutBuilder(
              builder: (context, restricciones) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: restricciones.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      labelType: NavigationRailLabelType.all,
                      onDestinationSelected: (i) => navigationShell.goBranch(
                        i,
                        initialLocation: i == navigationShell.currentIndex,
                      ),
                      destinations: [
                        for (final p in pestanasFamilia)
                          NavigationRailDestination(
                            icon: Icon(p.icono),
                            label: Text(
                              p.etiqueta(l),
                              key: ClavesUi.pestana(p.slug),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }
    final slugActual = pestanasFamilia[navigationShell.currentIndex].slug;
    final indiceBarra = _slugsBarra.contains(slugActual)
        ? _slugsBarra.indexOf(slugActual)
        : _slugsBarra.length;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BarraFamilia(
        seleccionada: indiceBarra,
        alElegir: (i) {
          if (i == _slugsBarra.length) {
            context.go(Rutas.mas);
          } else {
            final rama = Rutas.slugs.indexOf(_slugsBarra[i]);
            navigationShell.goBranch(
              rama,
              initialLocation: rama == navigationShell.currentIndex,
            );
          }
        },
      ),
    );
  }
}

class _BarraFamilia extends StatelessWidget {
  const _BarraFamilia({required this.seleccionada, required this.alElegir});

  final int seleccionada;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final barra = [
      for (final slug in _slugsBarra)
        pestanasFamilia.firstWhere((p) => p.slug == slug),
    ];
    return NavigationBar(
      selectedIndex: seleccionada,
      onDestinationSelected: alElegir,
      destinations: [
        for (final p in barra)
          NavigationDestination(
            key: ClavesUi.pestana(p.slug),
            icon: Icon(p.icono),
            label: p.etiqueta(l),
          ),
        NavigationDestination(
          key: ClavesUi.pestana('mas'),
          icon: const Icon(Icons.more_horiz),
          label: l.pestanaMas,
        ),
      ],
    );
  }
}

/// "Más": cuadrícula con las otras seis pestañas (solo en pantalla estrecha).
class MasPantalla extends StatelessWidget {
  const MasPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.pestanaMas)),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          for (final p in _slugsMas)
            Card(
              key: ClavesUi.pestana(p.slug),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF555555), width: 1.5),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.go(Rutas.pestana(p.slug)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(p.icono, size: 36),
                    const SizedBox(height: 8),
                    Text(p.etiqueta(l), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _BarraFamilia(
        seleccionada: _slugsBarra.length,
        alElegir: (i) {
          if (i == _slugsBarra.length) return;
          context.go(Rutas.pestana(_slugsBarra[i]));
        },
      ),
    );
  }
}
