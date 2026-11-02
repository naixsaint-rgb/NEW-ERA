import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/arranque.dart';
import 'core/reinicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
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
