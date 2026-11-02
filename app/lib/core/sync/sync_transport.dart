import 'sobre_cifrado.dart';
import 'trozo_cifrado.dart';

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

  // ------------------------------------------- Trozos de clips (tabla aparte)

  /// Sube [trozos] de [clipId] en lotes de hasta 5 filas por petición, con
  /// reintentos. Idempotente por `(clip_id, n)`: un trozo que ya estaba no se
  /// duplica ni se cambia. Devuelve los `n` de [trozos] que están en el
  /// servidor después de subir (también los que ya estaban). Nunca lanza: sin
  /// red, devuelve los que se sabe que están (quizá ninguno).
  Future<Set<int>> subirTrozos(String clipId, List<TrozoCifrado> trozos);

  /// Los `n` de [clipId] que ya están en el servidor. Lanza sin red.
  Future<Set<int>> trozosEnServidor(String clipId);

  /// Hasta [limite] trozos de [clipId] con `n >= desde`, por orden de `n`.
  /// Vacío si no hay (ya caducaron o nunca subieron). Lanza sin red.
  Future<List<TrozoCifrado>> bajarTrozos(
    String clipId, {
    int desde = 0,
    int limite = 5,
  });
}

/// Sin servidor no se puede subir ni bajar un clip.
final class SinServidor implements Exception {
  const SinServidor();

  @override
  String toString() => 'SinServidor';
}
