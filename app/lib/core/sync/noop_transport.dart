import 'sobre_cifrado.dart';
import 'sync_transport.dart';

/// Transporte sin servidor: nunca conecta, no acepta nada y no recibe nada.
/// Es el que se usa mientras no haya `SUPABASE_URL` y `SUPABASE_ANON_KEY`.
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
  Stream<SobreCifrado> recibidos({int desde = 0}) => const Stream.empty();

  @override
  Future<void> desconectar() async {}
}
