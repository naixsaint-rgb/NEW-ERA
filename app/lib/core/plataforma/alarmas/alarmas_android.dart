import 'dart:developer' as developer;
import 'dart:ui' show Color;

import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safety_core/safety_core.dart';

import 'servicio_alarmas.dart';

/// Alarmas en Android sobre el paquete `alarm`: id numérico estable
/// ([idAlarmaNumerico]), sonido en bucle, vibración y notificación.
///
/// Las rondas del control por horas ([esIdRonda]) llevan su propio aviso
/// ("¿Cómo estás?"), el tono suave si no hay frase grabada y menos volumen.
/// La pantalla de la pregunta las para al abrirse.
///
/// Sonido: [rutaAudio] si llega (la frase `toma` de la familia, una ruta
/// relativa `voces/….m4a`); si no, el tono. El paquete admite una ruta
/// relativa a la carpeta de documentos de la app (en Android,
/// `app_flutter`, que es la de `getApplicationDocumentsDirectory`) y la
/// reproduce con `MediaPlayer` (ver `assetAudioPath` en `AlarmSettings` y
/// `AudioService.playAudio` del paquete). Es almacenamiento privado: no hace
/// falta `READ_EXTERNAL_STORAGE`.
class AlarmasAndroid implements ServicioAlarmas, ConsultaAlarmaSonando {
  AlarmasAndroid();

  static const tituloNotificacion = 'Es la hora de la pastilla';
  static const botonParar = 'Parar el aviso';
  static const rutaTono = 'assets/audio/tono_alarma.wav';
  static const tituloRonda = '¿Cómo estás?';
  static const rutaTonoSuave = 'assets/audio/tono_suave.wav';

  bool _iniciada = false;

  /// `Alarm.init()` solo se llama en Android.
  Future<void> iniciar() async {
    if (_iniciada) return;
    await Alarm.init();
    _iniciada = true;
  }

  @override
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  }) async {
    await iniciar();
    final notificaciones = await Permission.notification.request();
    if (!notificaciones.isGranted) {
      throw const ErrorAlarma(CodigoAlarma.noAutorizado, 'notificaciones');
    }
    await Permission.scheduleExactAlarm.request();
    final ronda = esIdRonda(idToma);
    final ajustes = AlarmSettings(
      id: idAlarmaNumerico(idToma),
      dateTime: fecha.toLocal(),
      assetAudioPath: rutaAudio ?? (ronda ? rutaTonoSuave : rutaTono),
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: false,
      androidFullScreenIntent: true,
      payload: idToma,
      volumeSettings: VolumeSettings.fade(
        volume: ronda ? 0.6 : 0.8,
        fadeDuration: const Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: ronda ? tituloRonda : tituloNotificacion,
        body: titulo,
        stopButton: botonParar,
        iconColor: const Color(0xFF1B5E20),
      ),
    );
    final ok = await Alarm.set(alarmSettings: ajustes);
    developer.log('programada $idToma ok=$ok', name: 'newera.alarmas');
    if (!ok) throw const ErrorAlarma(CodigoAlarma.limite);
  }

  @override
  Future<bool> cancelar(String idToma) async {
    await iniciar();
    return Alarm.stop(idAlarmaNumerico(idToma));
  }

  @override
  Future<EstadoAlarmas> estado() async {
    await iniciar();
    final alarmas = await Alarm.getAlarms();
    final permiso = await Permission.notification.status;
    return EstadoAlarmas(
      disponible: true,
      autorizacion: permiso.isGranted
          ? AutorizacionAlarma.autorizada
          : permiso.isDenied
          ? AutorizacionAlarma.noDeterminada
          : AutorizacionAlarma.denegada,
      programadas: [
        for (final a in alarmas)
          if (a.payload != null) a.payload!,
      ],
      implementado: true,
    );
  }

  @override
  Future<bool> estaSonando(String idToma) async {
    try {
      await iniciar();
      return await Alarm.isRinging(idAlarmaNumerico(idToma));
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<String> sonando() async* {
    await iniciar();
    await for (final conjunto in Alarm.ringing) {
      for (final a in conjunto.alarms) {
        final id = a.payload;
        if (id != null) yield id;
      }
    }
  }
}
