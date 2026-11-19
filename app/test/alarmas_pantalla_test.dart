import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/features/alarmas/alarmas_pantalla.dart';

import 'utiles/app_prueba.dart';

void main() {
  testWidgets('Alarmas: a quién va cada aviso y los últimos enviados', (
    tester,
  ) async {
    final entorno = await tester.runAsync(
      () => prepararEntorno(perfil: PerfilApp.familia),
    );
    await montarApp(tester, entorno!, rutaInicial: '/familia/alarmas');
    await pasar(tester, const Duration(seconds: 1));
    expect(find.byType(AlarmasPantalla), findsOneWidget);
    expect(find.textContaining('Llega en la semana'), findsNothing);
    expect(find.text('Ver el control por horas'), findsOneWidget);
    expect(find.text('De 09:00 a 21:00, cada hora'), findsOneWidget);

    // Con la semilla: Lucía puesto 1, Javier puesto 2, Marta sin puesto. La
    // primera toma sin confirmar va al puesto 1, la segunda al 2 y el resto
    // a todos.
    await tester.scrollUntilVisible(find.text('QUIÉN RECIBE LOS AVISOS'), 200);
    expect(find.text('Toma sin confirmar a los 5 min'), findsOneWidget);
    expect(find.text('Toma sin confirmar a los 10 min'), findsOneWidget);
    expect(find.text('Lucía'), findsOneWidget);
    expect(find.text('Javier'), findsOneWidget);
    expect(find.text('Pidió ayuda'), findsOneWidget);
    expect(find.text('Dijo «Mal»'), findsOneWidget);
    expect(find.text('Dolor nuevo'), findsOneWidget);
    expect(find.text('Ronda sin respuesta a los 10 min'), findsOneWidget);
    expect(find.text('Lucía, Javier y Marta'), findsNWidgets(4));
    await tester.scrollUntilVisible(
      find.text('Cambiar el orden en Círculo'),
      200,
    );

    // El aviso de la ronda sin respuesta de hoy, enviado a Lucía.
    await tester.scrollUntilVisible(find.text('ÚLTIMOS AVISOS ENVIADOS'), 200);
    await tester.scrollUntilVisible(find.text('Aviso enviado a Lucía'), 200);
    expect(find.text('Ronda de las 10:00 sin respuesta'), findsOneWidget);
    expect(find.text('Martes 13, 10:10'), findsOneWidget);
    expect(find.text('No se pudo avisar a Lucía'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
