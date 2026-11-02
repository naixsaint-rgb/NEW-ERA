import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:safety_core/safety_core.dart';

/// Revisiones de avisos con la app cerrada: a cada instante que importa (5 y
/// 10 minutos después de una toma, 10 después de una ronda) el móvil de la
/// persona mira la base y envía lo que toque.
abstract interface class ProgramadorAvisos {
  /// `true` si las revisiones corren con la app cerrada.
  bool get enSegundoPlano;

  /// Programa una revisión en cada uno de [instantes] (sustituye la que
  /// hubiera con el mismo instante). Devuelve cuántas quedaron programadas.
  Future<int> programar(Iterable<DateTime> instantes);

  /// La revisión [id] acaba de saltar: deja de estar programada y sale de
  /// la lista que se reprograma al reiniciar. Nunca lanza.
  Future<void> soltar(int id);
}

/// iOS, web y escritorio: sin revisiones en segundo plano. Los avisos salen
/// solo con la app abierta (temporizador de la app).
final class ProgramadorAvisosNulo implements ProgramadorAvisos {
  const ProgramadorAvisosNulo();

  @override
  bool get enSegundoPlano => false;

  @override
  Future<int> programar(Iterable<DateTime> instantes) async => 0;

  @override
  Future<void> soltar(int id) async {}
}

/// Android: `android_alarm_manager_plus` (Flutter Community) con alarmas
/// exactas que despiertan el móvil también en reposo (`exact`, `wakeup`,
/// `allowWhileIdle`) y sobreviven a un reinicio (`rescheduleOnReboot`).
/// [revisar] es una función de primer nivel con
/// `@pragma('vm:entry-point')`: corre en su propio hilo, sin la app. Exige
/// el permiso de alarmas exactas (`USE_EXACT_ALARM`/`SCHEDULE_EXACT_ALARM`,
/// ya en el manifiesto por las alarmas de las tomas); sin él, Android no la
/// programa.
///
/// El plugin guarda cada alarma con `rescheduleOnReboot` para volver a
/// programarla al reiniciar y no la borra al saltar (solo con `cancel`): cada
/// revisión llama a [soltar] con su id. Si no, la lista crecería sin fin
/// (unas 20 al día), al reiniciar saltarían todas las pasadas de golpe y,
/// pasadas 500, Android rechaza más alarmas de la app (también las de las
/// tomas).
final class ProgramadorAvisosAndroid implements ProgramadorAvisos {
  const ProgramadorAvisosAndroid(this.revisar);

  /// Lo que corre a cada instante.
  final Function revisar;

  /// Id estable de la revisión de [instante].
  static int idDe(DateTime instante) =>
      idAlarmaNumerico('aviso|${instante.millisecondsSinceEpoch}');

  @override
  bool get enSegundoPlano => true;

  @override
  Future<int> programar(Iterable<DateTime> instantes) async {
    var n = 0;
    for (final t in instantes.toSet()) {
      try {
        final ok = await AndroidAlarmManager.oneShotAt(
          t,
          idDe(t),
          revisar,
          exact: true,
          wakeup: true,
          allowWhileIdle: true,
          rescheduleOnReboot: true,
        );
        if (ok) n++;
      } catch (_) {
        // Sin permiso de alarmas exactas o sin servicio: quedan los avisos
        // con la app abierta.
      }
    }
    return n;
  }

  @override
  Future<void> soltar(int id) async {
    try {
      await AndroidAlarmManager.cancel(id);
    } catch (_) {
      // Sin servicio: se queda en la lista; al saltar otra vez, no avisa de
      // nuevo (el envío no repite).
    }
  }
}
