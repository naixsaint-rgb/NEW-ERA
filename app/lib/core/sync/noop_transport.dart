import 'sobre_cifrado.dart';
import 'sync_transport.dart';

/// Transporte de la semana 1: nunca conecta, no acepta nada y no recibe nada.
final class NoopTransport implements SyncTransport {
  const NoopTransport();

  @override
  EstadoTransporte get estado => EstadoTransporte.desconectado;

  @override
  Future<void> conectar() async {}

  @override
  Future<ResultadoEnvio> enviar(List<SobreCifrado> sobres) async =>
      ResultadoEnvio(rechazados: [for (final s in sobres) s.ulid]);

  @override
  Stream<SobreCifrado> recibidos() => const Stream.empty();

  @override
  Future<void> desconectar() async {}
}
