/// Código de error de la capa nativa o de su sustituto en Dart.
enum CodigoAlarma {
  noImplementado('no_implementado'),
  noDisponible('no_disponible'),
  noAutorizado('no_autorizado'),
  argumentos('argumentos'),
  limite('limite');

  const CodigoAlarma(this.codigo);
  final String codigo;

  static CodigoAlarma? desdeCodigo(String codigo) {
    for (final c in values) {
      if (c.codigo == codigo) return c;
    }
    return null;
  }
}

/// Error al programar o cancelar una alarma.
final class ErrorAlarma implements Exception {
  const ErrorAlarma(this.codigo, [this.detalle]);

  final CodigoAlarma codigo;
  final String? detalle;

  @override
  String toString() =>
      'ErrorAlarma(${codigo.codigo}${detalle == null ? '' : ': $detalle'})';
}

enum AutorizacionAlarma { noDeterminada, autorizada, denegada }

/// Respuesta de `estado`.
final class EstadoAlarmas {
  const EstadoAlarmas({
    required this.disponible,
    required this.autorizacion,
    required this.programadas,
    required this.implementado,
  });

  final bool disponible;
  final AutorizacionAlarma autorizacion;
  final List<String> programadas;
  final bool implementado;

  static const noDisponible = EstadoAlarmas(
    disponible: false,
    autorizacion: AutorizacionAlarma.noDeterminada,
    programadas: [],
    implementado: false,
  );

  static AutorizacionAlarma autorizacionDesde(String? valor) => switch (valor) {
    'autorizada' => AutorizacionAlarma.autorizada,
    'denegada' => AutorizacionAlarma.denegada,
    _ => AutorizacionAlarma.noDeterminada,
  };
}

/// Contrato de alarmas (sección 8). `programar` y `cancelar` lanzan
/// [ErrorAlarma] con el código que corresponda.
abstract interface class ServicioAlarmas {
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  });

  Future<bool> cancelar(String idToma);

  Future<EstadoAlarmas> estado();

  /// Ids de toma cuya alarma está sonando (la app abre entonces su pantalla).
  Stream<String> sonando();
}
