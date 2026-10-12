import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

import 'utiles.dart';

List<DateTime> tomasDelDia(
  List<String> horas,
  DateTime desde,
  DateTime hasta,
) => proximasTomas(
  versiones: [version(horas: horas)],
  desde: desde,
  hasta: hasta,
).map((t) => t.previstaPara).toList();

void main() {
  setUpAll(inicializarZonas);

  test('09:00 del 28-3-2026 (aún invierno) son las 08:00Z', () {
    expect(tomasDelDia(['09:00'], utc(2026, 3, 28), utc(2026, 3, 29)), [
      utc(2026, 3, 28, 8),
    ]);
  });

  test('09:00 del 29-3-2026 (ya verano) son las 07:00Z', () {
    expect(tomasDelDia(['09:00'], utc(2026, 3, 29), utc(2026, 3, 30)), [
      utc(2026, 3, 29, 7),
    ]);
  });

  test('02:30 del 29-3-2026 no existe: primer instante válido, 01:00Z', () {
    final tomas = proximasTomas(
      versiones: [
        version(horas: ['02:30']),
      ],
      desde: utc(2026, 3, 29),
      hasta: utc(2026, 3, 30),
    );
    expect(tomas.single.previstaPara, utc(2026, 3, 29, 1));
    expect(tomas.single.id, 'p1_20260329_0230');
  });

  test('02:30 del 25-10-2026 se repite: solo la primera vez, 00:30Z', () {
    expect(tomasDelDia(['02:30'], utc(2026, 10, 25), utc(2026, 10, 26)), [
      utc(2026, 10, 25, 0, 30),
    ]);
  });

  test('09:00 del 25-10-2026 (ya invierno) son las 08:00Z', () {
    expect(tomasDelDia(['09:00'], utc(2026, 10, 25), utc(2026, 10, 26)), [
      utc(2026, 10, 25, 8),
    ]);
  });

  test('otras zonas: Canarias va una hora por detrás', () {
    final tomas = proximasTomas(
      versiones: [version(zona: 'Atlantic/Canary')],
      desde: utc(2026, 7, 1),
      hasta: utc(2026, 7, 2),
    );
    expect(tomas.single.previstaPara, utc(2026, 7, 1, 8));
  });
}
