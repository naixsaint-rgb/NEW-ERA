import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:safety_core/safety_core.dart' show esIdRonda;

import 'servicio_alarmas.dart';

/// Implementación de iOS sobre `MethodChannel('newera/alarmas')`. El lado
/// nativo está en `ios/Runner/AlarmasCanal.swift` (AlarmKit en iOS 26 o
/// posterior; notificaciones locales repetidas en iOS anteriores). Está sin
/// compilar: ver `docs/vault/specs/ios-alarmkit.md`.
///
/// Contrato (sección 8), de Dart a nativo:
/// - `programar` `{idToma, fecha (ms UTC), titulo, rutaAudio?, tipo
///   ("toma"|"ronda"), cabecera, botonParar, botonAbrir}` -> `{ok: bool}`
/// - `cancelar` `{idToma}` -> `bool`
/// - `cancelarTodas` -> `int`
/// - `autorizar` -> `"autorizada" | "denegada" | "no_determinada"`
/// - `estado` -> `{disponible, autorizacion, programadas, implementado, motor}`
/// - `pendientes` -> `[{metodo, idToma, origen?}]`: avisos que llegaron antes
///   de que Dart escuchara.
/// Errores: `no_implementado`, `no_disponible`, `no_autorizado`,
/// `argumentos`, `limite`. Cualquier otro fallo del canal se trata como
/// `no_disponible`, y el programador lo apunta como `alarma_no_programada`.
///
/// De nativo a Dart: `alarmaDisparada {idToma}` y
/// `alarmaParada {idToma, origen: "parar"|"abrir"|"sistema"}`. [sonando]
/// emite el id cuando la alarma empieza a sonar o cuando la persona toca
/// «Abrir» (la app abre entonces la pantalla de la toma o la pregunta de la
/// ronda). Parar en el sistema no confirma la toma.
///
/// Las rondas del control por horas van por el mismo canal con su id
/// (`ronda_<yyyyMMdd>_<HHmm>`) y `tipo: "ronda"`.
class AlarmasCanal implements ServicioAlarmas {
  AlarmasCanal([MethodChannel? canal])
    : _canal = canal ?? const MethodChannel(nombreCanal);

  static const nombreCanal = 'newera/alarmas';

  /// Textos del aviso (los mismos que en Android).
  static const cabeceraToma = 'Es la hora de la pastilla';
  static const cabeceraRonda = '¿Cómo estás?';
  static const botonParar = 'Parar el aviso';
  static const botonAbrir = 'Abrir';

  final MethodChannel _canal;
  StreamController<String>? _sonando;

  void _registrar(String mensaje) =>
      developer.log(mensaje, name: 'newera.alarmas');

  ErrorAlarma _traducir(PlatformException e) => ErrorAlarma(
    CodigoAlarma.desdeCodigo(e.code) ?? CodigoAlarma.noDisponible,
    e.message,
  );

  /// Ejecuta una llamada al canal y convierte cualquier fallo en
  /// [ErrorAlarma].
  Future<T> _llamar<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on ErrorAlarma {
      rethrow;
    } on PlatformException catch (e) {
      throw _traducir(e);
    } on MissingPluginException {
      throw const ErrorAlarma(CodigoAlarma.noImplementado);
    } catch (e) {
      throw ErrorAlarma(CodigoAlarma.noDisponible, '$e');
    }
  }

  @override
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  }) async {
    _registrar('programar $idToma para ${fecha.toUtc().toIso8601String()}');
    final ronda = esIdRonda(idToma);
    await _llamar(() async {
      final r = await _canal.invokeMapMethod<String, Object?>('programar', {
        'idToma': idToma,
        'fecha': fecha.toUtc().millisecondsSinceEpoch,
        'titulo': titulo,
        'rutaAudio': rutaAudio,
        'tipo': ronda ? 'ronda' : 'toma',
        'cabecera': ronda ? cabeceraRonda : cabeceraToma,
        'botonParar': botonParar,
        'botonAbrir': botonAbrir,
      });
      if (r == null || r['ok'] != true) {
        throw const ErrorAlarma(CodigoAlarma.noDisponible);
      }
    });
  }

  @override
  Future<bool> cancelar(String idToma) async {
    _registrar('cancelar $idToma');
    return _llamar(
      () async =>
          await _canal.invokeMethod<bool>('cancelar', {'idToma': idToma}) ??
          false,
    );
  }

  /// Quita todas las alarmas de esta app. Devuelve cuántas había.
  Future<int> cancelarTodas() async {
    _registrar('cancelarTodas');
    return _llamar(
      () async => await _canal.invokeMethod<int>('cancelarTodas') ?? 0,
    );
  }

  /// Pide el permiso de alarmas (AlarmKit) o de notificaciones (iOS < 26).
  /// `programar` también lo pide si aún no se ha pedido.
  Future<AutorizacionAlarma> autorizar() async {
    try {
      return EstadoAlarmas.autorizacionDesde(
        await _canal.invokeMethod<String>('autorizar'),
      );
    } catch (_) {
      return AutorizacionAlarma.noDeterminada;
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
    } catch (_) {
      return EstadoAlarmas.noDisponible;
    }
  }

  @override
  Stream<String> sonando() {
    final existente = _sonando;
    if (existente != null) return existente.stream;
    final controlador = StreamController<String>.broadcast();
    _sonando = controlador;
    _canal.setMethodCallHandler(_recibir);
    unawaited(_recogerPendientes());
    return controlador.stream;
  }

  /// Avisos guardados en nativo antes de que Dart escuchara (por ejemplo, la
  /// app se abrió desde el botón «Abrir» de la alarma).
  Future<void> _recogerPendientes() async {
    try {
      final lista = await _canal.invokeListMethod<Object?>('pendientes');
      for (final e in lista ?? const <Object?>[]) {
        if (e is! Map) continue;
        _avisar(e['metodo'] as String?, e);
      }
    } catch (_) {
      // Sin canal nativo (tests, web): no hay avisos.
    }
  }

  Future<Object?> _recibir(MethodCall llamada) async {
    final args = llamada.arguments;
    if (args is Map) _avisar(llamada.method, args);
    return null;
  }

  void _avisar(String? metodo, Map<Object?, Object?> args) {
    final id = args['idToma'];
    if (id is! String || id.isEmpty) return;
    _registrar('$metodo $id ${args['origen'] ?? ''}');
    final abrir =
        metodo == 'alarmaDisparada' ||
        (metodo == 'alarmaParada' && args['origen'] == 'abrir');
    if (abrir) _sonando?.add(id);
  }
}
