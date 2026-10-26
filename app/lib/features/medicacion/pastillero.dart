import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/medicacion_repositorio.dart';
import '../../core/providers.dart';
import '../../shared/ios/celda_dia.dart';
import '../hoy/dominio/tomas.dart';

/// Última versión de cada pauta, por medicamento.
Map<String, Pauta> pautasVigentesDe(Iterable<Pauta> pautas) {
  final r = <String, Pauta>{};
  for (final p in pautas) {
    final actual = r[p.medicamentoId];
    if (actual == null ||
        (p.pautaId == actual.pautaId && p.version > actual.version) ||
        p.creadaEn >= actual.creadaEn) {
      r[p.medicamentoId] = p;
    }
  }
  return r;
}

/// Clave de la celda del pastillero de [fecha] (`yyyy-MM-dd`) y [hora]
/// (`HH:mm`). La usan los tests.
ValueKey<String> clavePastilleroCelda(String fecha, String hora) =>
    ValueKey<String>('pastillero_celda_${fecha}_$hora');

/// Una celda del pastillero: las tomas de un día y una hora.
final class CeldaPastillero {
  const CeldaPastillero({
    required this.estado,
    required this.tomas,
    required this.hechas,
  });

  final EstadoCelda estado;
  final List<TomaVista> tomas;

  /// Cuántas de [tomas] están hechas (confirmadas o cerradas).
  final int hechas;
}

/// La semana en curso (de lunes a domingo, en la zona de la persona).
final class DatosPastillero {
  const DatosPastillero({
    required this.fechas,
    required this.indiceHoy,
    required this.horas,
    required this.celdas,
  });

  /// `yyyy-MM-dd` de lunes a domingo.
  final List<String> fechas;

  /// 0 = lunes ... 6 = domingo.
  final int indiceHoy;

  /// Una fila por hora distinta (`HH:mm`) entre las pautas activas vigentes.
  final List<String> horas;

  /// `celdas[fila][dia]`; nula si ese día y a esa hora no hay toma.
  final List<List<CeldaPastillero?>> celdas;
}

/// Límites de la semana de [ahora] en [zona]: lunes 00:00 y el lunes
/// siguiente 00:00 (en UTC), las fechas locales y el índice de hoy.
({DateTime inicio, DateTime fin, List<String> fechas, int indiceHoy}) semanaDe(
  DateTime ahora,
  String zona,
) {
  final f = fechaLocalDe(zona, ahora);
  final hoy = DateTime.utc(f.anio, f.mes, f.dia);
  final indiceHoy = hoy.weekday - 1;
  final lunes = hoy.subtract(Duration(days: indiceHoy));
  final siguiente = lunes.add(const Duration(days: 7));
  String dos(int n) => n.toString().padLeft(2, '0');
  return (
    inicio: horaLocalAUtc(zona, lunes.year, lunes.month, lunes.day, 0, 0),
    fin: horaLocalAUtc(
      zona,
      siguiente.year,
      siguiente.month,
      siguiente.day,
      0,
      0,
    ),
    fechas: [
      for (var i = 0; i < 7; i++)
        () {
          final d = lunes.add(Duration(days: i));
          return '${d.year.toString().padLeft(4, '0')}-${dos(d.month)}-${dos(d.day)}';
        }(),
    ],
    indiceHoy: indiceHoy,
  );
}

bool _hecha(EstadoToma e) =>
    e == EstadoToma.confirmada ||
    e == EstadoToma.confirmadaSinVideo ||
    e == EstadoToma.cerradaPorFamiliar;

/// Calcula el pastillero de la semana de [ahora].
///
/// Las tomas salen de [calcularTomas] entre el lunes 00:00 y el lunes
/// siguiente 00:00. Cada celda agrupa las tomas de ese día y hora:
/// - todas hechas: completa; algunas hechas: parcial;
/// - ninguna hecha y alguna no confirmada: fallida;
/// - la toma "de ahora" ([siguienteToma]): hoy;
/// - el resto: futura.
DatosPastillero calcularPastillero({
  required List<Pauta> pautas,
  required List<Medicamento> medicamentos,
  required List<Evento> eventos,
  required DateTime ahora,
  required ConfigEscalado config,
  required String zona,
}) {
  final semana = semanaDe(ahora, zona);
  final retirados = {
    for (final m in medicamentos)
      if (m.retiradoEn != null) m.id,
  };
  final vigentes = pautasVigentesDe(pautas);
  final horas = {
    for (final p in vigentes.values)
      if (p.activa && !retirados.contains(p.medicamentoId))
        ...MedicacionRepositorio.horasDe(p),
  }.toList()..sort();
  final tomas = [
    for (final t in calcularTomas(
      pautas: pautas,
      medicamentos: medicamentos,
      eventos: eventos,
      ahora: ahora,
      config: config,
      zona: zona,
      desde: semana.inicio,
      hasta: semana.fin,
    ))
      if (!retirados.contains(t.toma.medicamentoId)) t,
  ];
  final deAhora = siguienteToma(tomas, ahora)?.toma.id;
  final porCelda = <String, List<TomaVista>>{};
  for (final t in tomas) {
    porCelda
        .putIfAbsent('${t.toma.fechaLocal}|${t.toma.horaLocal}', () => [])
        .add(t);
  }
  CeldaPastillero? celda(String fecha, String hora) {
    final lista = porCelda['$fecha|$hora'];
    if (lista == null || lista.isEmpty) return null;
    final hechas = lista.where((t) => _hecha(t.estado)).length;
    final EstadoCelda estado;
    if (hechas == lista.length) {
      estado = EstadoCelda.completa;
    } else if (hechas > 0) {
      estado = EstadoCelda.parcial;
    } else if (lista.any((t) => t.estado == EstadoToma.noConfirmada)) {
      estado = EstadoCelda.fallida;
    } else if (lista.any((t) => t.toma.id == deAhora)) {
      estado = EstadoCelda.hoy;
    } else {
      estado = EstadoCelda.futura;
    }
    return CeldaPastillero(estado: estado, tomas: lista, hechas: hechas);
  }

  return DatosPastillero(
    fechas: semana.fechas,
    indiceHoy: semana.indiceHoy,
    horas: horas,
    celdas: [
      for (final h in horas) [for (final f in semana.fechas) celda(f, h)],
    ],
  );
}

/// Lunes 00:00 de la semana en curso. Solo cambia al cambiar de semana, así
/// que lo que dependa de él no se recalcula en cada latido del reloj.
final _inicioSemanaProvider = Provider<DateTime>((ref) {
  final zona = ref.watch(contextoProvider).zonaHoraria;
  final ahora =
      ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
  return semanaDe(ahora, zona).inicio;
});

/// Eventos de toma desde el día antes del lunes: así no dependemos de cuántos
/// días atrás mire `eventosDeTomaProvider`.
final eventosDeSemanaProvider = StreamProvider<List<Evento>>((ref) {
  final inicio = ref.watch(_inicioSemanaProvider);
  return ref
      .watch(eventosRepositorioProvider)
      .observarEventosDeToma(inicio.subtract(const Duration(days: 1)));
});

/// El pastillero de la semana en curso.
final pastilleroProvider = Provider<AsyncValue<DatosPastillero>>((ref) {
  final pautas = ref.watch(pautasProvider);
  final meds = ref.watch(medicamentosProvider);
  final eventos = ref.watch(eventosDeSemanaProvider);
  final ahoraAsync = ref.watch(ahoraProvider);
  final config = ref.watch(configEscaladoProvider);
  final contexto = ref.watch(contextoProvider);
  for (final a in [pautas, meds, eventos, ahoraAsync]) {
    if (a.hasError && !a.hasValue) {
      return AsyncValue.error(a.error!, a.stackTrace ?? StackTrace.empty);
    }
  }
  if (!pautas.hasValue ||
      !meds.hasValue ||
      !eventos.hasValue ||
      !ahoraAsync.hasValue) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data(
    calcularPastillero(
      pautas: pautas.requireValue,
      medicamentos: meds.requireValue,
      eventos: eventos.requireValue,
      ahora: ahoraAsync.requireValue,
      config: config,
      zona: contexto.zonaHoraria,
    ),
  );
});

/// Eventos `medicamento_creado` (el sujeto es el id del medicamento): dicen
/// quién hizo la foto y cuándo.
final eventosDeAltaProvider = StreamProvider<Map<String, Evento>>((ref) {
  final db = ref.watch(baseDatosProvider);
  final q = db.select(db.eventos)
    ..where((e) => e.tipo.equals(TipoEvento.medicamentoCreado.nombre));
  return q.watch().map((filas) {
    final r = <String, Evento>{};
    for (final e in filas) {
      final s = e.sujeto;
      if (s == null) continue;
      final previo = r[s];
      if (previo == null || e.ocurridoEn < previo.ocurridoEn) r[s] = e;
    }
    return r;
  });
});
