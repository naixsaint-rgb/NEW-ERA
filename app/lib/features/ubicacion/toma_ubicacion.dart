import 'package:safety_core/safety_core.dart';

import '../../core/db/repositorios/ubicacion_repositorio.dart';
import '../../core/plataforma/ubicacion/ubicador.dart';

/// Toma una posición del móvil de la persona y la guarda
/// (`ubicacion_registrada`), solo con el consentimiento vigente y el permiso
/// del sistema. La usan la app abierta, la revisión en segundo plano de
/// Android, las alarmas y «Necesito ayuda».
///
/// Una posición por llamada, sin GPS continuo: la de bajo consumo salvo con
/// [precisa] (ayuda pedida y búsqueda). Después borra las de más de 7 días.
final class TomaUbicacion {
  TomaUbicacion({required this.ubicador, required this.repo});

  final Ubicador ubicador;
  final UbicacionRepositorio repo;

  bool _tomando = false;

  /// Ulid del evento guardado, o nulo (sin consentimiento, sin permiso, sin
  /// señal, o una de rutina con otra ya en curso: las precisas siempre
  /// salen). Con [ayuda], el ulid del `ayuda_pedida` al que acompaña. Nunca
  /// lanza.
  Future<String?> tomar(
    OrigenUbicacion origen, {
    bool precisa = false,
    String? ayuda,
  }) async {
    if (_tomando && !precisa) return null;
    _tomando = true;
    try {
      if (!await repo.consentimientoActivo()) return null;
      final permiso = await ubicador.permiso();
      if (!permiso.concedido) return null;
      final p = await ubicador.posicion(precisa: precisa);
      if (p == null) return null;
      final id = await repo.registrar(
        p,
        origen: origen,
        bateria: await ubicador.bateria(),
        permiso: permiso,
        ayuda: ayuda,
      );
      await repo.purgar();
      return id;
    } catch (_) {
      return null;
    } finally {
      _tomando = false;
    }
  }

  /// Con el consentimiento vigente, pide el permiso del sistema si aún no se
  /// ha preguntado y, en Android, el de la app cerrada si [tambienCerrada]
  /// (una sola vez cada uno: lo recuerda [yaPedido]/[apuntar]). Nunca lanza.
  Future<PermisoUbicacion?> asegurarPermiso({
    required bool tambienCerrada,
    required Future<bool> Function(String clave) yaPedido,
    required Future<void> Function(String clave) apuntar,
  }) async {
    try {
      if (!await repo.consentimientoActivo()) return null;
      var p = await ubicador.permiso();
      if (p == PermisoUbicacion.sinPreguntar && !await yaPedido(clavePermiso)) {
        await apuntar(clavePermiso);
        p = await ubicador.pedirPermiso();
      }
      if (tambienCerrada &&
          p == PermisoUbicacion.conAppAbierta &&
          !await yaPedido(clavePermisoCerrada)) {
        await apuntar(clavePermisoCerrada);
        p = await ubicador.pedirPermiso();
      }
      return p;
    } catch (_) {
      return null;
    }
  }

  /// Claves (en el almacén) de «ya se pidió».
  static const clavePermiso = 'newera.ubicacion.permiso_pedido';
  static const clavePermisoCerrada = 'newera.ubicacion.permiso_cerrada_pedido';
}
