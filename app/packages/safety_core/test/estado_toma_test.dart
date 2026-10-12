import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

import 'utiles.dart';

void main() {
  setUpAll(inicializarZonas);

  const config = ConfigEscalado();
  final hora = utc(2026, 10, 13, 7);
  TomaPrevista toma({TipoComprobacion c = TipoComprobacion.video}) =>
      TomaPrevista(
        id: 'p1_20261013_0900',
        pautaId: 'p1',
        pautaVersionId: 'v1',
        medicamentoId: 'm1',
        previstaPara: hora,
        fechaLocal: '2026-10-13',
        horaLocal: '09:00',
        comprobacion: c,
      );
  EventoToma ev(
    String ulid,
    TipoEvento tipo, {
    String? sujeto = 'p1_20261013_0900',
    String? corrige,
    int min = 1,
  }) => EventoToma(
    ulid: ulid,
    tipo: tipo,
    ocurridoEn: hora.add(Duration(minutes: min)),
    sujeto: sujeto,
    corrigeA: corrige,
  );

  test('prevista: sin eventos y antes de 30 minutos', () {
    expect(
      estadoDeToma(toma(), [], hora.add(const Duration(minutes: 29)), config),
      EstadoToma.prevista,
    );
  });

  test('noConfirmada: pasados 30 minutos sin eventos', () {
    expect(
      estadoDeToma(toma(), [], hora.add(const Duration(minutes: 30)), config),
      EstadoToma.noConfirmada,
    );
  });

  test('confirmada con clip, confirmadaSinVideo sin él', () {
    final ahora = hora.add(const Duration(minutes: 5));
    final conf = ev('A', TipoEvento.tomaConfirmada);
    expect(
      estadoDeToma(toma(), [conf], ahora, config),
      EstadoToma.confirmadaSinVideo,
    );
    expect(
      estadoDeToma(
        toma(),
        [conf, ev('B', TipoEvento.clipGrabado)],
        ahora,
        config,
      ),
      EstadoToma.confirmada,
    );
    expect(
      estadoDeToma(
        toma(),
        [conf, ev('B', TipoEvento.clipFallido)],
        ahora,
        config,
      ),
      EstadoToma.confirmadaSinVideo,
    );
  });

  test('pauta sin comprobación: la confirmación basta', () {
    final ahora = hora.add(const Duration(minutes: 5));
    expect(
      estadoDeToma(
        toma(c: TipoComprobacion.ninguna),
        [ev('A', TipoEvento.tomaConfirmada)],
        ahora,
        config,
      ),
      EstadoToma.confirmada,
    );
  });

  test('cerradaPorFamiliar, y la confirmación gana aunque llegue tarde', () {
    final ahora = hora.add(const Duration(hours: 2));
    final cierre = ev('A', TipoEvento.tomaCerradaPorFamiliar);
    expect(
      estadoDeToma(toma(), [cierre], ahora, config),
      EstadoToma.cerradaPorFamiliar,
    );
    expect(
      estadoDeToma(
        toma(),
        [cierre, ev('B', TipoEvento.tomaConfirmada, min: 90)],
        ahora,
        config,
      ),
      EstadoToma.confirmadaSinVideo,
    );
  });

  test('anulación: el evento anulado se ignora', () {
    final ahora = hora.add(const Duration(minutes: 10));
    final conf = ev('A', TipoEvento.tomaConfirmada);
    final anula = ev('B', TipoEvento.anulacion, corrige: 'A');
    expect(
      estadoDeToma(toma(), [conf, anula], ahora, config),
      EstadoToma.prevista,
    );
    expect(
      estadoDeToma(
        toma(),
        [conf, anula],
        hora.add(const Duration(hours: 1)),
        config,
      ),
      EstadoToma.noConfirmada,
    );
    // La anulación anulada devuelve la vigencia al evento original.
    final reanula = ev('C', TipoEvento.anulacion, corrige: 'B');
    expect(
      estadoDeToma(toma(), [conf, anula, reanula], ahora, config),
      EstadoToma.confirmadaSinVideo,
    );
  });

  test('los eventos de otra toma no cuentan', () {
    final otro = ev('A', TipoEvento.tomaConfirmada, sujeto: 'otra');
    expect(
      estadoDeToma(
        toma(),
        [otro],
        hora.add(const Duration(minutes: 5)),
        config,
      ),
      EstadoToma.prevista,
    );
  });
}
