import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

void main() {
  test('fronteras de la mañana, la tarde y la noche', () {
    expect(parteDelDia(5), ParteDelDia.noche);
    expect(parteDelDia(6), ParteDelDia.manana);
    expect(parteDelDia(13), ParteDelDia.manana);
    expect(parteDelDia(14), ParteDelDia.tarde);
    expect(parteDelDia(20), ParteDelDia.tarde);
    expect(parteDelDia(21), ParteDelDia.noche);
    expect(parteDelDia(0), ParteDelDia.noche);
  });
}
