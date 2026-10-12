import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

void main() {
  const config = ConfigEscalado();
  final hora = DateTime.utc(2026, 10, 13, 7);
  List<int> minutos(Duration d, EstadoToma e) => accionesVencidas(
    hora,
    hora.add(d),
    e,
    config,
  ).map((p) => p.minuto).toList();

  test('a 4:59 vencen los pasos 0 y 2', () {
    expect(
      minutos(const Duration(minutes: 4, seconds: 59), EstadoToma.prevista),
      [0, 2],
    );
  });

  test('a 5:00 vence el familiar 1', () {
    final pasos = accionesVencidas(
      hora,
      hora.add(const Duration(minutes: 5)),
      EstadoToma.prevista,
      config,
    );
    expect(pasos.last, const PasoEscalado(5, AccionEscalado.avisarFamiliar1));
  });

  test('a 10:00 vence el familiar 2 con el reloj', () {
    final pasos = accionesVencidas(
      hora,
      hora.add(const Duration(minutes: 10)),
      EstadoToma.prevista,
      config,
    );
    expect(
      pasos.last,
      const PasoEscalado(10, AccionEscalado.avisarFamiliar2YReloj),
    );
    expect(pasos.map((p) => p.minuto), [0, 2, 5, 10]);
  });

  test('antes de la hora no vence nada', () {
    expect(minutos(const Duration(seconds: -1), EstadoToma.prevista), isEmpty);
  });

  test('confirmada a los 3 minutos: ningún paso más', () {
    for (final e in [
      EstadoToma.confirmada,
      EstadoToma.confirmadaSinVideo,
      EstadoToma.cerradaPorFamiliar,
    ]) {
      expect(minutos(const Duration(minutes: 3), e), isEmpty);
      expect(minutos(const Duration(minutes: 40), e), isEmpty);
    }
  });

  test('noConfirmada conserva todos los pasos hasta el minuto 30', () {
    expect(minutos(const Duration(minutes: 31), EstadoToma.noConfirmada), [
      0,
      2,
      5,
      10,
      15,
      30,
    ]);
  });
}
