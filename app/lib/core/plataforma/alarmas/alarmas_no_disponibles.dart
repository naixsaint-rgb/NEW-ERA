import 'servicio_alarmas.dart';

/// Web y tests: no hay alarmas del sistema.
final class AlarmasNoDisponibles implements ServicioAlarmas {
  const AlarmasNoDisponibles();

  @override
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  }) => throw const ErrorAlarma(CodigoAlarma.noDisponible);

  @override
  Future<bool> cancelar(String idToma) async => false;

  @override
  Future<EstadoAlarmas> estado() async => EstadoAlarmas.noDisponible;

  @override
  Stream<String> sonando() => const Stream.empty();
}
