import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/arranque.dart';
import 'core/reinicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  // Revisiones de avisos con la app cerrada (solo Android).
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await AndroidAlarmManager.initialize();
    } catch (_) {
      // Sin el servicio, los avisos salen solo con la app abierta.
    }
  }
  final overrides = await Arranque.iniciar();
  // Reiniciable: al unirse a un círculo se repite el arranque sin cerrar la
  // app.
  runApp(
    RaizReiniciable(
      overrides: overrides,
      iniciar: Arranque.iniciar,
      app: const NewEraApp(),
    ),
  );
}
