import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/repositorios/ubicacion_repositorio.dart';
import '../../core/plataforma/ubicacion/ubicador.dart';
import '../../core/plataforma/ubicacion/ubicador_movil.dart';
import '../../core/providers.dart';
import 'toma_ubicacion.dart';

/// Punto de ejemplo de la demo web: un punto céntrico genérico de Madrid
/// (no es la casa de nadie).
const latDemo = 40.4168;
const lonDemo = -3.7038;

/// `geolocator` en el móvil; en la demo web, el simulado (siempre el punto
/// de ejemplo).
final ubicadorProvider = Provider<Ubicador>((ref) {
  if (kIsWeb) {
    final reloj = ref.watch(relojProvider);
    return UbicadorSimulado(
      siguiente: PosicionGps(
        lat: latDemo,
        lon: lonDemo,
        precision: 25,
        instante: reloj.ahora(),
      ),
      ahora: reloj.ahora,
    );
  }
  return UbicadorMovil();
});

final ubicacionRepositorioProvider = Provider<UbicacionRepositorio>((ref) {
  return UbicacionRepositorio(
    db: ref.watch(baseDatosProvider),
    reloj: ref.watch(relojProvider),
    contexto: ref.watch(contextoProvider),
    eventos: ref.watch(eventosRepositorioProvider),
    autor: () => autorActual(ref),
  );
});

final tomaUbicacionProvider = Provider<TomaUbicacion>(
  (ref) => TomaUbicacion(
    ubicador: ref.watch(ubicadorProvider),
    repo: ref.watch(ubicacionRepositorioProvider),
  ),
);

/// Consentimiento de ubicación del círculo.
final consentimientoUbicacionProvider = StreamProvider<ConsentimientoUbicacion>(
  (ref) => ref.watch(ubicacionRepositorioProvider).observarConsentimiento(),
);

/// `true` con la ubicación encendida (consentimiento vigente).
final ubicacionActivaProvider = Provider<bool>(
  (ref) => ref.watch(consentimientoUbicacionProvider).value?.activo ?? false,
);

/// Zona segura del círculo (nula sin centro).
final zonaSeguraProvider = StreamProvider<ZonaSegura?>(
  (ref) => ref.watch(ubicacionRepositorioProvider).observarZona(),
);

/// Radio elegido (aunque aún no haya centro).
final radioZonaProvider = StreamProvider<int>(
  (ref) => ref.watch(ubicacionRepositorioProvider).observarRadio(),
);

/// Posiciones de los últimos 7 días, de la más antigua a la más reciente.
final lecturasUbicacionProvider = StreamProvider<List<LecturaUbicacion>>(
  (ref) => ref.watch(ubicacionRepositorioProvider).observarLecturas(),
);

/// Permiso que tenía el móvil de la persona en su última posición.
final permisoMovilPersonaProvider = StreamProvider<PermisoUbicacion?>(
  (ref) => ref.watch(ubicacionRepositorioProvider).observarPermisoDelMovil(),
);

/// Dentro, fuera o sin posición ([evaluarZona]); nula mientras carga o con
/// la ubicación apagada.
final situacionZonaProvider = Provider<SituacionZona?>((ref) {
  if (!ref.watch(ubicacionActivaProvider)) return null;
  final zona = ref.watch(zonaSeguraProvider);
  final lecturas = ref.watch(lecturasUbicacionProvider).value;
  final ahora = ref.watch(ahoraProvider).value;
  if (!zona.hasValue || lecturas == null || ahora == null) return null;
  return evaluarZona(zona: zona.value, lecturas: lecturas, ahora: ahora);
});

/// `true` si está fuera de la zona segura (para el semáforo).
final fueraDeZonaProvider = Provider<bool>(
  (ref) => ref.watch(situacionZonaProvider)?.fuera ?? false,
);

final busquedasProvider = StreamProvider<List<BusquedaPedida>>(
  (ref) => ref.watch(ubicacionRepositorioProvider).observarBusquedas(),
);

/// La búsqueda vigente («Buscarla ahora»), o nula.
final busquedaActivaProvider = Provider<BusquedaPedida?>((ref) {
  final b = ref.watch(busquedasProvider).value;
  final ahora = ref.watch(ahoraProvider).value;
  if (b == null || ahora == null) return null;
  return busquedaActiva(b, ahora);
});
