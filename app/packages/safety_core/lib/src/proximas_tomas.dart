import 'tipos.dart';
import 'zonas.dart';

/// Una toma prevista, calculada a partir de las pautas. No se guarda su
/// estado: se deriva de los eventos.
final class TomaPrevista {
  const TomaPrevista({
    required this.id,
    required this.pautaId,
    required this.pautaVersionId,
    required this.medicamentoId,
    required this.previstaPara,
    required this.fechaLocal,
    required this.horaLocal,
    this.comprobacion = TipoComprobacion.video,
  });

  /// `<pautaId>_<yyyyMMdd>_<HHmm>` en hora local de la pauta.
  final String id;
  final String pautaId;
  final String pautaVersionId;
  final String medicamentoId;

  /// Instante previsto, en UTC.
  final DateTime previstaPara;

  /// `yyyy-MM-dd` local.
  final String fechaLocal;

  /// `HH:mm` local (la de la pauta, aunque ese día no exista por el cambio de hora).
  final String horaLocal;

  /// Comprobación que pedía la versión de pauta que la generó.
  final TipoComprobacion comprobacion;

  @override
  bool operator ==(Object other) =>
      other is TomaPrevista &&
      other.id == id &&
      other.pautaId == pautaId &&
      other.pautaVersionId == pautaVersionId &&
      other.medicamentoId == medicamentoId &&
      other.previstaPara == previstaPara &&
      other.fechaLocal == fechaLocal &&
      other.horaLocal == horaLocal &&
      other.comprobacion == comprobacion;

  @override
  int get hashCode => Object.hash(
    id,
    pautaId,
    pautaVersionId,
    medicamentoId,
    previstaPara,
    fechaLocal,
    horaLocal,
    comprobacion,
  );

  @override
  String toString() => 'TomaPrevista($id, $previstaPara)';
}

String _dos(int n) => n.toString().padLeft(2, '0');

/// Tomas previstas en `[desde, hasta)` para el conjunto de [versiones].
///
/// La versión `v` aporta una toma si `v.activa` y
/// `v.vigenteDesde <= previstaPara < siguiente.vigenteDesde`, donde
/// `siguiente` es la versión posterior de la misma pauta. Resultado ordenado
/// por instante y, a igualdad, por id.
List<TomaPrevista> proximasTomas({
  required Iterable<PautaVersion> versiones,
  required DateTime desde,
  required DateTime hasta,
}) {
  final porPauta = <String, List<PautaVersion>>{};
  for (final v in versiones) {
    porPauta.putIfAbsent(v.pautaId, () => []).add(v);
  }
  final resultado = <String, TomaPrevista>{};
  final desdeUtc = desde.toUtc();
  final hastaUtc = hasta.toUtc();
  if (!desdeUtc.isBefore(hastaUtc)) return const [];

  for (final lista in porPauta.values) {
    lista.sort((a, b) {
      final c = a.version.compareTo(b.version);
      return c != 0 ? c : a.vigenteDesde.compareTo(b.vigenteDesde);
    });
    for (var i = 0; i < lista.length; i++) {
      final v = lista[i];
      if (!v.activa) continue;
      final fin = i + 1 < lista.length
          ? lista[i + 1].vigenteDesde.toUtc()
          : null;
      final inicio = v.vigenteDesde.toUtc();
      // Días locales a recorrer: un día de margen por cada lado.
      final primero = fechaLocalDe(
        v.zonaHoraria,
        desdeUtc.subtract(const Duration(days: 1)),
      );
      final ultimo = fechaLocalDe(
        v.zonaHoraria,
        hastaUtc.add(const Duration(days: 1)),
      );
      var dia = DateTime.utc(primero.anio, primero.mes, primero.dia);
      final tope = DateTime.utc(ultimo.anio, ultimo.mes, ultimo.dia);
      while (!dia.isAfter(tope)) {
        if (DiasSemana.incluye(v.diasSemana, dia.weekday)) {
          for (final hora in v.horas) {
            final partes = hora.split(':');
            final hh = int.parse(partes[0]);
            final mm = int.parse(partes[1]);
            final previsto = horaLocalAUtc(
              v.zonaHoraria,
              dia.year,
              dia.month,
              dia.day,
              hh,
              mm,
            );
            if (previsto.isBefore(desdeUtc) || !previsto.isBefore(hastaUtc)) {
              continue;
            }
            if (previsto.isBefore(inicio)) continue;
            if (fin != null && !previsto.isBefore(fin)) continue;
            final fecha =
                '${dia.year.toString().padLeft(4, '0')}-${_dos(dia.month)}-${_dos(dia.day)}';
            final id =
                '${v.pautaId}_${dia.year.toString().padLeft(4, '0')}${_dos(dia.month)}${_dos(dia.day)}_${_dos(hh)}${_dos(mm)}';
            resultado[id] = TomaPrevista(
              id: id,
              pautaId: v.pautaId,
              pautaVersionId: v.id,
              medicamentoId: v.medicamentoId,
              previstaPara: previsto,
              fechaLocal: fecha,
              horaLocal: '${_dos(hh)}:${_dos(mm)}',
              comprobacion: v.comprobacion,
            );
          }
        }
        dia = DateTime.utc(dia.year, dia.month, dia.day + 1);
      }
    }
  }
  final ordenadas = resultado.values.toList()
    ..sort((a, b) {
      final c = a.previstaPara.compareTo(b.previstaPara);
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  return ordenadas;
}
