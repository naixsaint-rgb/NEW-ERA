import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'ubicador.dart';

/// Android e iPhone: `geolocator` (Baseflow, MIT) y `battery_plus` (Flutter
/// Community, BSD-3).
///
/// - Sin GPS continuo: cada llamada pide una sola posición y se apaga. Por
///   defecto, la de bajo consumo (`LocationAccuracy.medium`: wifi y antenas,
///   100 a 500 m en Android); con `precisa` (ayuda pedida, búsqueda), el GPS.
/// - Android 10+: con `ACCESS_BACKGROUND_LOCATION` en el manifiesto,
///   `requestPermission` pide primero «mientras se usa la app» y, en una
///   segunda llamada, «todo el tiempo» (Android 11+ lleva a Ajustes).
/// - iPhone: solo «mientras se usa la app» (`NSLocationWhenInUseUsageDescription`).
final class UbicadorMovil implements Ubicador {
  UbicadorMovil();

  final Battery _bateria = Battery();

  @override
  Future<PermisoUbicacion> permiso() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return PermisoUbicacion.sinServicio;
      }
      return _traducir(await Geolocator.checkPermission());
    } catch (_) {
      return PermisoUbicacion.sinServicio;
    }
  }

  @override
  Future<PermisoUbicacion> pedirPermiso() async {
    try {
      return _traducir(await Geolocator.requestPermission());
    } catch (_) {
      // Sin pantalla (segundo plano) o una petición ya en curso.
      return permiso();
    }
  }

  static PermisoUbicacion _traducir(LocationPermission p) => switch (p) {
    LocationPermission.always => PermisoUbicacion.siempre,
    LocationPermission.whileInUse => PermisoUbicacion.conAppAbierta,
    LocationPermission.denied => PermisoUbicacion.sinPreguntar,
    LocationPermission.deniedForever => PermisoUbicacion.denegado,
    LocationPermission.unableToDetermine => PermisoUbicacion.sinServicio,
  };

  @override
  Future<PosicionGps?> posicion({
    bool precisa = false,
    Duration limite = const Duration(seconds: 20),
  }) async {
    try {
      if (!(await permiso()).concedido) return null;
      final precision = precisa
          ? LocationAccuracy.high
          : LocationAccuracy.medium;
      final ajustes = defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(accuracy: precision, timeLimit: limite)
          : LocationSettings(accuracy: precision, timeLimit: limite);
      final p = await Geolocator.getCurrentPosition(locationSettings: ajustes);
      return PosicionGps(
        lat: p.latitude,
        lon: p.longitude,
        precision: p.accuracy,
        instante: p.timestamp.toUtc(),
      );
    } catch (_) {
      // Sin señal, sin permiso o pasado el límite.
      return null;
    }
  }

  @override
  Future<int?> bateria() async {
    try {
      final n = await _bateria.batteryLevel;
      return n >= 0 && n <= 100 ? n : null;
    } catch (_) {
      return null;
    }
  }
}
