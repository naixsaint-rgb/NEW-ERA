import 'package:safety_core/safety_core.dart';

DateTime utc(int a, int m, int d, [int h = 0, int mi = 0]) =>
    DateTime.utc(a, m, d, h, mi);

PautaVersion version({
  String id = 'v1',
  String pautaId = 'p1',
  int version = 1,
  List<String> horas = const ['09:00'],
  int dias = DiasSemana.todos,
  DateTime? desde,
  bool activa = true,
  String zona = 'Europe/Madrid',
  TipoComprobacion comprobacion = TipoComprobacion.video,
}) => PautaVersion(
  id: id,
  pautaId: pautaId,
  version: version,
  medicamentoId: 'm1',
  horas: horas,
  zonaHoraria: zona,
  vigenteDesde: desde ?? utc(2026, 1, 1),
  activa: activa,
  diasSemana: dias,
  comprobacion: comprobacion,
);
