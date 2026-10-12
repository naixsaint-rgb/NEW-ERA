import 'dart:developer' as developer;
import 'dart:ui' show Color;

import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safety_core/safety_core.dart';

import 'servicio_alarmas.dart';

/// Alarmas en Android sobre el paquete `alarm`: id numérico estable
/// ([idAlarmaNumerico]), tono en bucle, vibración y notificación.
class AlarmasAndroid implements ServicioAlarmas {
  AlarmasAndroid();

  static const tituloNotificacion = 'Es la hora de la pastilla';
  static const botonParar = 'Parar el aviso';
  static const rutaTono = 'assets/audio/tono_alarma.wav';

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
    final ajustes = AlarmSettings(
      id: idAlarmaNumerico(idToma),
      dateTime: fecha.toLocal(),
      assetAudioPath: rutaAudio ?? rutaTono,
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: false,
      androidFullScreenIntent: true,
      payload: idToma,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: tituloNotificacion,
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
