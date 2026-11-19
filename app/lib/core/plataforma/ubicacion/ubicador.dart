/// Posición del móvil (plan v3, 7.1). La app solo la pide en el móvil de la
/// persona y solo con su consentimiento (`consentimientos`, sobre
/// `ubicacion`); quién la pide y cuándo lo decide `TomaUbicacion`.
library;

/// Permiso del sistema para leer la posición.
enum PermisoUbicacion {
  /// Aún no se ha preguntado.
  sinPreguntar('sin_preguntar'),

  /// Denegado (o denegado para siempre: solo se cambia en Ajustes).
  denegado('denegado'),

  /// Solo con la app abierta.
  conAppAbierta('con_app_abierta'),

  /// También con la app cerrada (Android: «Permitir todo el tiempo»).
  siempre('siempre'),

  /// El móvil tiene la ubicación apagada o no la admite.
  sinServicio('sin_servicio');

  const PermisoUbicacion(this.nombre);
  final String nombre;

  bool get concedido => this == conAppAbierta || this == siempre;

  static PermisoUbicacion? desdeNombre(Object? nombre) {
    for (final p in values) {
      if (p.nombre == nombre) return p;
    }
    return null;
  }
}

/// Una posición tal como la da el sistema.
final class PosicionGps {
  const PosicionGps({
    required this.lat,
    required this.lon,
    required this.precision,
    required this.instante,
  });

  final double lat;
  final double lon;

  /// Radio de error en metros.
  final double precision;

  /// Cuándo la tomó el sistema (UTC).
  final DateTime instante;
}

/// Lee la posición del móvil. Ninguna llamada lanza.
abstract interface class Ubicador {
  /// Permiso actual, sin preguntar nada.
  Future<PermisoUbicacion> permiso();

  /// Pide el permiso al sistema (con su diálogo). En Android, si ya está
  /// concedido con la app abierta, pide además el de la app cerrada.
  Future<PermisoUbicacion> pedirPermiso();

  /// Una posición, o nula (sin permiso, sin señal o pasado [limite]). Con
  /// [precisa], el GPS; si no, la de bajo consumo (wifi y antenas).
  Future<PosicionGps?> posicion({
    bool precisa = false,
    Duration limite = const Duration(seconds: 20),
  });

  /// Batería del móvil (0 a 100), o nula si no se puede leer.
  Future<int?> bateria();
}

/// Tests y demo web: posiciones fijas que se pueden cambiar. Nunca sale
/// nada del aparato.
final class UbicadorSimulado implements Ubicador {
  UbicadorSimulado({
    this.estado = PermisoUbicacion.conAppAbierta,
    this.siguiente,
    this.nivelBateria = 80,
    this.alPedirPermiso = PermisoUbicacion.conAppAbierta,
    this.ahora,
  });

  /// Si se da, cada posición sale con esta hora (la demo web: «ahora»).
  final DateTime Function()? ahora;

  PermisoUbicacion estado;

  /// Lo que dará [pedirPermiso].
  PermisoUbicacion alPedirPermiso;

  /// La próxima posición (sin ella, nula).
  PosicionGps? siguiente;
  int? nivelBateria;

  /// Cuántas veces se ha pedido una posición (y si precisa).
  final List<bool> pedidas = [];
  int permisosPedidos = 0;

  @override
  Future<PermisoUbicacion> permiso() async => estado;

  @override
  Future<PermisoUbicacion> pedirPermiso() async {
    permisosPedidos++;
    return estado = alPedirPermiso;
  }

  @override
  Future<PosicionGps?> posicion({
    bool precisa = false,
    Duration limite = const Duration(seconds: 20),
  }) async {
    pedidas.add(precisa);
    final p = siguiente;
    if (!estado.concedido || p == null) return null;
    final reloj = ahora;
    return reloj == null
        ? p
        : PosicionGps(
            lat: p.lat,
            lon: p.lon,
            precision: p.precision,
            instante: reloj(),
          );
  }

  @override
  Future<int?> bateria() async => nivelBateria;
}
