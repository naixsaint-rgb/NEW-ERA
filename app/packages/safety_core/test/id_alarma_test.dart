import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

void main() {
  test('FNV-1a de 32 bits con máscara de 31', () {
    expect(idAlarmaNumerico('p1_20261013_0900'), 1659551138);
  });

  test('siempre no negativo y estable', () {
    for (final s in ['', 'a', 'p1_20261013_0900', 'ñandú', 'x' * 500]) {
      final id = idAlarmaNumerico(s);
      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThanOrEqualTo(0x7fffffff));
      expect(idAlarmaNumerico(s), id);
    }
  });
}
