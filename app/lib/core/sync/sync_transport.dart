import 'sobre_cifrado.dart';

enum EstadoTransporte { desconectado, conectando, conectado, sinConfigurar }

/// Resultado de un envío: ulids aceptados y rechazados.
///
/// Aceptado quiere decir "está en el servidor", también si ya estaba (el envío
/// es idempotente por ulid). Los rechazados se reintentan más tarde.
final class ResultadoEnvio {
  const ResultadoEnvio({this.aceptados = const [], this.rechazados = const []});

  final List<String> aceptados;
  final List<String> rechazados;
}

abstract interface class SyncTransport {
  EstadoTransporte get estado;
  Future<void> conectar();
  Future<ResultadoEnvio> enviar(List<SobreCifrado> sobres);

  /// Primero lo pendiente con [SobreCifrado.posicion] mayor que [desde];
  /// después, lo que vaya llegando. Sin red, reintenta por dentro: el stream
  /// no da error.
  Stream<SobreCifrado> recibidos({int desde = 0});
  Future<void> desconectar();
}
