import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'servicio_alarmas.dart';

/// Implementación de iOS sobre `MethodChannel('newera/alarmas')`.
///
/// Contrato (sección 8):
/// - `programar` `{idToma, fecha (ms UTC), titulo, rutaAudio?}` -> `{ok: bool}`
/// - `cancelar` `{idToma}` -> `bool`
/// - `estado` -> `{disponible, autorizacion, programadas, implementado}`
/// Errores: `no_implementado`, `no_disponible` (iOS < 26), `no_autorizado`,
/// `argumentos`, `limite`.
///
/// Reservados para la semana 2, de nativo a Dart: `alarmaDisparada {idToma}` y
/// `alarmaParada {idToma, origen}`. Parar en el sistema no confirma la toma.
///
/// Implementación provisional: además de llamar al canal, registra en consola
/// lo que pide, para poder seguir la demo sin AlarmKit.
class AlarmasCanal implements ServicioAlarmas {
  AlarmasCanal([MethodChannel? canal])
    : _canal = canal ?? const MethodChannel(nombreCanal);

  static const nombreCanal = 'newera/alarmas';

  final MethodChannel _canal;

  void _registrar(String mensaje) =>
      developer.log(mensaje, name: 'newera.alarmas');

  ErrorAlarma _traducir(PlatformException e) => ErrorAlarma(
    CodigoAlarma.desdeCodigo(e.code) ?? CodigoAlarma.noDisponible,
    e.message,
  );

  @override
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  }) async {
    _registrar('programar $idToma para ${fecha.toUtc().toIso8601String()}');
    try {
      final r = await _canal.invokeMapMethod<String, Object?>('programar', {
        'idToma': idToma,
        'fecha': fecha.toUtc().millisecondsSinceEpoch,
        'titulo': titulo,
        'rutaAudio': rutaAudio,
      });
      if (r == null || r['ok'] != true) {
        throw const ErrorAlarma(CodigoAlarma.noDisponible);
      }
    } on PlatformException catch (e) {
      throw _traducir(e);
    } on MissingPluginException {
      throw const ErrorAlarma(CodigoAlarma.noImplementado);
    }
  }

  @override
  Future<bool> cancelar(String idToma) async {
    _registrar('cancelar $idToma');
    try {
      return await _canal.invokeMethod<bool>('cancelar', {'idToma': idToma}) ??
          false;
    } on PlatformException catch (e) {
      throw _traducir(e);
    } on MissingPluginException {
      throw const ErrorAlarma(CodigoAlarma.noImplementado);
    }
  }

  @override
  Future<EstadoAlarmas> estado() async {
    try {
      final r = await _canal.invokeMapMethod<String, Object?>('estado');
      if (r == null) return EstadoAlarmas.noDisponible;
      return EstadoAlarmas(
        disponible: r['disponible'] == true,
        autorizacion: EstadoAlarmas.autorizacionDesde(
          r['autorizacion'] as String?,
        ),
        programadas: [
          for (final p in (r['programadas'] as List<Object?>? ?? const []))
            p.toString(),
        ],
        implementado: r['implementado'] == true,
      );
    } on PlatformException {
      return EstadoAlarmas.noDisponible;
    } on MissingPluginException {
      return EstadoAlarmas.noDisponible;
    }
  }

  @override
  Stream<String> sonando() => const Stream.empty();
}
