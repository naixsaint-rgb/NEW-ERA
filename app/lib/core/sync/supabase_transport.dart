import 'sobre_cifrado.dart';
import 'sync_transport.dart';

/// Esqueleto del transporte con Supabase (semana 3). Sin paquete ni
/// credenciales: todo lo que intenta hacer lanza [UnimplementedError].
final class SupabaseTransport implements SyncTransport {
  const SupabaseTransport(this.url, this.claveAnonima);

  final String url;
  final String claveAnonima;

  @override
  EstadoTransporte get estado => EstadoTransporte.sinConfigurar;

  @override
  Future<void> conectar() => throw UnimplementedError('semana 3');

  @override
  Future<ResultadoEnvio> enviar(List<SobreCifrado> sobres) =>
      throw UnimplementedError('semana 3');

  @override
  Stream<SobreCifrado> recibidos() => throw UnimplementedError('semana 3');

  @override
  Future<void> desconectar() => throw UnimplementedError('semana 3');
}
