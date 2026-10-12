import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alarmas/alarmas_pantalla.dart';
import '../../features/alarmas/control_horas_pantalla.dart';
import '../../features/ajustes/ajustes_pantalla.dart';
import '../../features/alimentacion/alimentacion_pantalla.dart';
import '../../features/calendario/calendario_pantalla.dart';
import '../../features/catalogo/catalogo_pantalla.dart';
import '../../features/catalogo/dosier_pantalla.dart';
import '../../features/catalogo/ficha_pantalla.dart';
import '../../features/catalogo/resumen_pantalla.dart';
import '../../features/circulo/circulo_pantalla.dart';
import '../../features/consultas/consultas_pantalla.dart';
import '../../features/hoy/hoy_pantalla.dart';
import '../../features/medicacion/alta_medicamento_pantalla.dart';
import '../../features/medicacion/cambio_pauta_pantalla.dart';
import '../../features/medicacion/detalle_medicamento_pantalla.dart';
import '../../features/medicacion/medicacion_pantalla.dart';
import '../../features/perfil/perfil_pantalla.dart';
import '../../features/persona_inicio/persona_inicio_pantalla.dart';
import '../../features/toma/toma_pantalla.dart';
import '../../features/voces/voces_pantalla.dart';
import '../contexto.dart';
import '../providers.dart';
import '../tema/tema_persona.dart';
import 'familia_shell.dart';
import 'rutas.dart';

/// Ruta con la que arranca el router (sustituible en tests).
final rutaInicialProvider = Provider<String>((ref) => Rutas.raiz);

/// Redirección por perfil. Devuelve `null` si la ruta es válida.
String? redirigirSegunPerfil(Sesion sesion, String ruta) {
  final perfil = sesion.perfil;
  if (perfil == null) return ruta == Rutas.perfil ? null : Rutas.perfil;
  if (ruta == Rutas.raiz) {
    return perfil == PerfilApp.persona ? Rutas.persona : Rutas.pestana('hoy');
  }
  if (ruta == Rutas.perfil) return null;
  if (perfil == PerfilApp.persona && ruta.startsWith(Rutas.familia)) {
    return Rutas.persona;
  }
  if (perfil == PerfilApp.familia && ruta == Rutas.persona) {
    return Rutas.pestana('hoy');
  }
  if (ruta == Rutas.familia) return Rutas.pestana('hoy');
  return null;
}

/// Envuelve una pantalla de la persona en su tema y su escala de texto
/// (entre 1,0 y 1,3).
Widget _enTemaPersona(Widget hijo) => Builder(
  builder: (context) => Theme(
    data: temaPersona(),
    child: MediaQuery.withClampedTextScaling(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.3,
      child: hijo,
    ),
  ),
);

final routerProvider = Provider<GoRouter>((ref) {
  final refresco = ValueNotifier<int>(0);
  ref.listen(sesionProvider, (_, _) => refresco.value++);
  ref.onDispose(refresco.dispose);

  GoRoute pestana(
    String slug,
    Widget Function() pantalla, {
    List<RouteBase> rutas = const [],
  }) => GoRoute(
    path: Rutas.pestana(slug),
    builder: (context, state) => pantalla(),
    routes: rutas,
  );

  final router = GoRouter(
    initialLocation: ref.read(rutaInicialProvider),
    refreshListenable: refresco,
    redirect: (context, state) =>
        redirigirSegunPerfil(ref.read(sesionProvider), state.uri.path),
    routes: [
      GoRoute(path: Rutas.raiz, builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: Rutas.perfil, builder: (_, _) => const PerfilPantalla()),
      GoRoute(
        path: Rutas.persona,
        builder: (_, _) => _enTemaPersona(const PersonaInicioPantalla()),
        routes: [
          GoRoute(
            path: 'toma/:id',
            builder: (_, state) => _enTemaPersona(
              TomaPantalla(
                tomaId: state.pathParameters['id']!,
                prueba: state.uri.queryParameters['prueba'] == '1',
              ),
            ),
          ),
        ],
      ),
      GoRoute(path: Rutas.mas, builder: (_, _) => const MasPantalla()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            FamiliaShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [pestana('hoy', () => const HoyPantalla())],
          ),
          StatefulShellBranch(
            routes: [
              pestana(
                'medicacion',
                () => const MedicacionPantalla(),
                rutas: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (_, _) => const AltaMedicamentoPantalla(),
                  ),
                  GoRoute(
                    path: ':medicamentoId',
                    builder: (_, state) => DetalleMedicamentoPantalla(
                      medicamentoId: state.pathParameters['medicamentoId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'pauta',
                        builder: (_, state) => CambioPautaPantalla(
                          medicamentoId: state.pathParameters['medicamentoId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [pestana('calendario', () => const CalendarioPantalla())],
          ),
          StatefulShellBranch(
            routes: [pestana('consultas', () => const ConsultasPantalla())],
          ),
          StatefulShellBranch(
            routes: [
              pestana(
                'alarmas',
                () => const AlarmasPantalla(),
                rutas: [
                  GoRoute(
                    path: 'control-horas',
                    builder: (_, _) => const ControlHorasPantalla(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [pestana('voces', () => const VocesPantalla())],
          ),
          StatefulShellBranch(
            routes: [
              pestana('alimentacion', () => const AlimentacionPantalla()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              pestana(
                'ideas',
                () => const CatalogoPantalla(),
                rutas: [
                  GoRoute(
                    path: 'fila/:filaId',
                    builder: (_, state) =>
                        FichaPantalla(filaId: state.pathParameters['filaId']!),
                  ),
                  GoRoute(
                    path: 'resumen',
                    builder: (_, _) => const ResumenPantalla(),
                  ),
                  GoRoute(
                    path: 'tema/:temaKey',
                    builder: (_, state) => DosierPantalla(
                      temaKey: state.pathParameters['temaKey']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [pestana('circulo', () => const CirculoPantalla())],
          ),
          StatefulShellBranch(
            routes: [pestana('ajustes', () => const AjustesPantalla())],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
