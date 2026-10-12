import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

void main() {
  test('RelojFijo avanza y fija', () {
    final r = RelojFijo(DateTime.utc(2026, 10, 13));
    r.avanzar(const Duration(hours: 1));
    expect(r.ahora(), DateTime.utc(2026, 10, 13, 1));
    r.fijar(DateTime.utc(2030));
    expect(r.ahora().year, 2030);
    expect(const RelojSistema().ahora().isUtc, isTrue);
  });

  test('DiasSemana: bit 0 lunes, 127 todos', () {
    expect(DiasSemana.deLista([1, 4]), 0x9);
    expect(DiasSemana.aLista(127), [1, 2, 3, 4, 5, 6, 7]);
    expect(DiasSemana.incluye(0x40, DateTime.sunday), isTrue);
    expect(DiasSemana.incluye(0x40, DateTime.monday), isFalse);
  });

  test('TipoEvento: nombres de base', () {
    expect(
      TipoEvento.desdeNombre('toma_confirmada'),
      TipoEvento.tomaConfirmada,
    );
    expect(TipoEvento.desdeNombre('nada'), isNull);
    for (final t in TipoEvento.values) {
      expect(TipoEvento.desdeNombre(t.nombre), t);
    }
  });
}
