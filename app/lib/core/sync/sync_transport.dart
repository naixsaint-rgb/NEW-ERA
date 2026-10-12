import 'sobre_cifrado.dart';

enum EstadoTransporte { desconectado, conectando, conectado, sinConfigurar }

/// Resultado de un envío: ulids aceptados y rechazados.
final class ResultadoEnvio {
  const ResultadoEnvio({this.aceptados = const [], this.rechazados = const []});

  final List<String> aceptados;
  final List<String> rechazados;
}

abstract interface class SyncTransport {
  EstadoTransporte get estado;
  Future<void> conectar();
  Future<ResultadoEnvio> enviar(List<SobreCifrado> sobres);
  Stream<SobreCifrado> recibidos();
  Future<void> desconectar();
}
