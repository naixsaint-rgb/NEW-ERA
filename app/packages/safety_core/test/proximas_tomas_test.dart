import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

import 'utiles.dart';

void main() {
  setUpAll(inicializarZonas);

  test('tres horas diarias durante un día', () {
    final tomas = proximasTomas(
      versiones: [
        version(horas: ['09:00', '14:00', '21:00']),
      ],
      desde: utc(2026, 10, 12, 22),
      hasta: utc(2026, 10, 13, 22),
    );
    expect(tomas.map((t) => t.id), [
      'p1_20261013_0900',
      'p1_20261013_1400',
      'p1_20261013_2100',
    ]);
    expect(tomas.first.previstaPara, utc(2026, 10, 13, 7)); // CEST, +2
    expect(tomas.first.fechaLocal, '2026-10-13');
    expect(tomas.first.horaLocal, '09:00');
    expect(tomas.first.pautaVersionId, 'v1');
    expect(tomas.first.medicamentoId, 'm1');
  });

  test('solo lunes y jueves', () {
    final tomas = proximasTomas(
      versiones: [
        version(dias: DiasSemana.deLista([DateTime.monday, DateTime.thursday])),
      ],
      desde: utc(2026, 10, 12), // lunes
      hasta: utc(2026, 10, 19),
    );
    expect(tomas.map((t) => t.fechaLocal), ['2026-10-12', '2026-10-15']);
  });

  test('una versión nueva rige desde su vigente_desde', () {
    final v1 = version(horas: ['09:00']);
    final v2 = version(
      id: 'v2',
      version: 2,
      horas: ['10:00'],
      desde: utc(2026, 10, 14, 12), // miércoles a mediodía
    );
    final tomas = proximasTomas(
      versiones: [v2, v1],
      desde: utc(2026, 10, 13),
      hasta: utc(2026, 10, 16),
    );
    expect(tomas.map((t) => '${t.id}/${t.pautaVersionId}'), [
      'p1_20261013_0900/v1',
      'p1_20261014_0900/v1',
      'p1_20261015_1000/v2',
    ]);
  });

  test('una pauta suspendida deja de generar tomas', () {
    final v1 = version();
    final suspendida = version(
      id: 'v2',
      version: 2,
      activa: false,
      desde: utc(2026, 10, 14, 12),
    );
    final tomas = proximasTomas(
      versiones: [v1, suspendida],
      desde: utc(2026, 10, 13),
      hasta: utc(2026, 10, 18),
    );
    expect(tomas.map((t) => t.fechaLocal), ['2026-10-13', '2026-10-14']);
  });

  test('rango vacío y orden estable entre pautas', () {
    final a = version(pautaId: 'a', id: 'a1', horas: ['09:00']);
    final b = version(pautaId: 'b', id: 'b1', horas: ['08:00', '09:00']);
    final tomas = proximasTomas(
      versiones: [a, b],
      desde: utc(2026, 10, 13),
      hasta: utc(2026, 10, 14),
    );
    expect(tomas.map((t) => t.id), [
      'b_20261013_0800',
      'a_20261013_0900',
      'b_20261013_0900',
    ]);
    expect(
      proximasTomas(
        versiones: [a],
        desde: utc(2026, 10, 13),
        hasta: utc(2026, 10, 13),
      ),
      isEmpty,
    );
  });

  test('la toma lleva la comprobación de su versión', () {
    final tomas = proximasTomas(
      versiones: [version(comprobacion: TipoComprobacion.ninguna)],
      desde: utc(2026, 10, 13),
      hasta: utc(2026, 10, 14),
    );
    expect(tomas.single.comprobacion, TipoComprobacion.ninguna);
  });
}
