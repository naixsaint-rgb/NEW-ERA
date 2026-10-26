import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/avatar_familiar.dart';
import '../providers.dart';
import '../tema/colores.dart';
import 'rutas.dart';

/// Una sección de la familia.
class PestanaFamilia {
  const PestanaFamilia(this.slug, this.icono);

  final String slug;
  final IconData icono;

  String etiqueta(AppLocalizations l) => switch (slug) {
    'hoy' => l.pestanaHoy,
    'resumen' => l.pestanaResumen,
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

  /// Fondo del icono cuadrado en "Más" y el color de su símbolo.
  (Color fondo, Color simbolo) coloresEnMas(ColoresApp c) => switch (slug) {
    'calendario' => (c.rojo, c.sobreRojo),
    'consultas' => (c.indigo, IconoCuadrado.simboloSobre(c.indigo)),
    'alarmas' => (c.naranjaRelleno, c.sobreNaranja),
    'voces' => (c.morado, IconoCuadrado.simboloSobre(c.morado)),
    'circulo' => (c.verde, c.sobreVerde),
    'ajustes' => (c.gris, IconoCuadrado.simboloSobre(c.gris)),
    _ => (c.azul, c.sobreAzul),
  };
}

/// Las once secciones, en el orden de [Rutas.slugs] (el de las ramas).
const pestanasFamilia = [
  PestanaFamilia('hoy', CupertinoIcons.house_fill),
  PestanaFamilia('resumen', CupertinoIcons.heart_fill),
  PestanaFamilia('medicacion', CupertinoIcons.capsule_fill),
  PestanaFamilia('calendario', CupertinoIcons.calendar),
  PestanaFamilia('consultas', CupertinoIcons.doc_text_fill),
  PestanaFamilia('alarmas', CupertinoIcons.alarm_fill),
  PestanaFamilia('voces', CupertinoIcons.waveform),
  // CupertinoIcons no trae cubiertos.
  PestanaFamilia('alimentacion', Icons.restaurant),
  PestanaFamilia('ideas', CupertinoIcons.book_fill),
  PestanaFamilia('circulo', CupertinoIcons.person_2_fill),
  PestanaFamilia('ajustes', CupertinoIcons.gear_alt_fill),
];

/// Las cinco pestañas de la barra inferior.
const slugsBarra = ['hoy', 'resumen', 'medicacion', 'alimentacion', 'ideas'];

/// Las seis secciones que van en "Más".
final pestanasMas = [
  for (final p in pestanasFamilia)
    if (!slugsBarra.contains(p.slug)) p,
];

PestanaFamilia _pestana(String slug) =>
    pestanasFamilia.firstWhere((p) => p.slug == slug);

/// Iniciales de quien usa este móvil de la familia (nulas si no se sabe).
final inicialesUsuarioProvider = Provider<String?>((ref) {
  final id = ref.watch(sesionProvider).miembroId;
  if (id == null) return null;
  final miembros = ref.watch(miembrosProvider).value;
  final yo = miembros?.where((m) => m.id == id).firstOrNull;
  return yo == null ? null : AvatarFamiliar.iniciales(yo.nombre);
});

const _anchoRail = 840.0;

/// Desde 840 dp, `NavigationRail` con las 11 secciones (desplazable); por
/// debajo, [BarraPestanas] con cinco pestañas y el botón "Más" arriba a la
/// derecha (una sola vez, encima de la pestaña).
class FamiliaShell extends ConsumerWidget {
  const FamiliaShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _irARama(int rama) => navigationShell.goBranch(
    rama,
    initialLocation: rama == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(
      listEquals([for (final p in pestanasFamilia) p.slug], Rutas.slugs),
      'pestanasFamilia y Rutas.slugs deben ir en el mismo orden',
    );
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
                      onDestinationSelected: _irARama,
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
    final slugActual = Rutas.slugs[navigationShell.currentIndex];
    final indiceBarra = slugsBarra.indexOf(slugActual);
    final arriba = MediaQuery.paddingOf(context).top;
    // El círculo de 40 queda a 12 de la zona segura y a 20 del borde; la zona
    // táctil (48) sobresale 4 por cada lado.
    const sobra = (BotonMas.zonaTactil - BotonMas.diametro) / 2;
    // Solo en las pestañas de primer nivel: en las pantallas anidadas (con su
    // AppBar) taparía el título.
    final ruta = GoRouterState.of(context).uri.path;
    final enPestana = Rutas.slugs.any((s) => ruta == Rutas.pestana(s));
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          if (enPestana)
            PositionedDirectional(
              top: arriba + 12 - sobra,
              end: 20 - sobra,
              child: BotonMas(iniciales: ref.watch(inicialesUsuarioProvider)),
            ),
        ],
      ),
      bottomNavigationBar: BarraPestanas(
        seleccionada: indiceBarra < 0 ? null : indiceBarra,
        alElegir: (i) => _irARama(Rutas.slugs.indexOf(slugsBarra[i])),
        elementos: [
          for (final slug in slugsBarra)
            ElementoBarra(
              clave: ClavesUi.pestana(slug),
              icono: _pestana(slug).icono,
              etiqueta: _pestana(slug).etiqueta(l),
            ),
        ],
      ),
    );
  }
}

/// "Más": lista agrupada con las otras seis secciones (calendario, consultas,
/// alarmas, voces, círculo y ajustes). Se abre encima de la pestaña actual
/// y vuelve a ella con "Volver".
class MasPantalla extends StatelessWidget {
  const MasPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final abajo = MediaQuery.paddingOf(context).bottom;
    void volver() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(Rutas.pestana('hoy'));
      }
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            titulo: l.pestanaMas,
            alVolver: volver,
            reservarBotonMas: false,
          ),
          const SizedBox(height: 14),
          GrupoLista(
            children: [
              for (final p in pestanasMas)
                FilaLista(
                  key: ClavesUi.pestana(p.slug),
                  leading: IconoCuadrado(
                    p.icono,
                    fondo: p.coloresEnMas(c).$1,
                    color: p.coloresEnMas(c).$2,
                  ),
                  titulo: p.etiqueta(l),
                  onTap: () => context.go(Rutas.pestana(p.slug)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
