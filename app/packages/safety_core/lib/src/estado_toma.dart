import 'escalado.dart';
import 'proximas_tomas.dart';
import 'tipos.dart';

/// Estado derivado de una toma. Nunca se guarda.
enum EstadoToma {
  prevista,
  confirmada,
  confirmadaSinVideo,
  noConfirmada,
  cerradaPorFamiliar,
}

/// Vista mínima de un evento para calcular estados.
final class EventoToma {
  const EventoToma({
    required this.ulid,
    required this.tipo,
    required this.ocurridoEn,
    this.sujeto,
    this.corrigeA,
    this.payload = const {},
  });

  final String ulid;
  final TipoEvento tipo;
  final DateTime ocurridoEn;

  /// Id de la toma (o medicamento…) a la que se refiere.
  final String? sujeto;

  /// Ulid del evento que corrige (solo en `anulacion`).
  final String? corrigeA;
  final Map<String, Object?> payload;
}

/// Estado de [toma] en [ahora], según sus [eventos].
///
/// Orden: (1) se ignoran los eventos anulados; (2) `toma_confirmada`:
/// `confirmada` si hay `clip_grabado` o la pauta dice `ninguna`, si no
/// `confirmadaSinVideo`; (3) `toma_cerrada_por_familiar`; (4) pasada la
/// espera de la configuración, `noConfirmada`; (5) `prevista`.
EstadoToma estadoDeToma(
  TomaPrevista toma,
  Iterable<EventoToma> eventos,
  DateTime ahora,
  ConfigEscalado config,
) {
  final todos = eventos.toList();
  final porUlid = {for (final e in todos) e.ulid: e};
  final anulaciones = todos.where((e) => e.tipo == TipoEvento.anulacion);

  // (1) Una anulación solo vale si ella misma no está anulada.
  final memo = <String, bool>{};
  bool anulado(String ulid, Set<String> visitados) {
    if (memo.containsKey(ulid)) return memo[ulid]!;
    if (!visitados.add(ulid)) return false;
    var resultado = false;
    for (final a in anulaciones) {
      if (a.corrigeA == ulid && porUlid.containsKey(a.ulid)) {
        if (!anulado(a.ulid, visitados)) {
          resultado = true;
          break;
        }
      }
    }
    memo[ulid] = resultado;
    return resultado;
  }

  final vigentes = todos
      .where(
        (e) =>
            e.tipo != TipoEvento.anulacion &&
            e.sujeto == toma.id &&
            !anulado(e.ulid, <String>{}),
      )
      .toList();

  bool hay(TipoEvento t) => vigentes.any((e) => e.tipo == t);

  // (2)
  if (hay(TipoEvento.tomaConfirmada)) {
    if (hay(TipoEvento.clipGrabado) ||
        toma.comprobacion == TipoComprobacion.ninguna) {
      return EstadoToma.confirmada;
    }
    return EstadoToma.confirmadaSinVideo;
  }
  // (3)
  if (hay(TipoEvento.tomaCerradaPorFamiliar)) {
    return EstadoToma.cerradaPorFamiliar;
  }
  // (4)
  if (ahora.toUtc().difference(toma.previstaPara.toUtc()) >=
      config.noConfirmadaTras) {
    return EstadoToma.noConfirmada;
  }
  // (5)
  return EstadoToma.prevista;
}
