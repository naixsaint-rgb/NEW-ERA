import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/db/repositorios/eventos_repositorio.dart';
import '../../../core/db/repositorios/medicacion_repositorio.dart';
import '../../../core/i18n/fechas.dart';
import '../../../core/providers.dart';

/// Una toma con su estado, su medicamento y sus eventos.
final class TomaVista {
  const TomaVista({
    required this.toma,
    required this.estado,
    required this.eventos,
    this.medicamento,
    this.pauta,
  });

  final TomaPrevista toma;
  final EstadoToma estado;
  final Medicamento? medicamento;
  final Pauta? pauta;

  /// Eventos de esta toma, del más antiguo al más reciente.
  final List<Evento> eventos;

  String get nombreMedicamento => medicamento?.nombre ?? '';
  String get nombreParaPersona => medicamento?.nombreParaPersona ?? '';

  /// Evento vigente de un tipo (el último), si lo hay.
  Evento? ultimoDe(TipoEvento tipo) {
    Evento? r;
    for (final e in eventos) {
      if (e.tipo == tipo.nombre) r = e;
    }
    return r;
  }
}

/// Configuración de escalado vigente (la del plan 2.2).
final configEscaladoProvider = Provider<ConfigEscalado>(
  (ref) => const ConfigEscalado(),
);

/// Día (desde la época) del reloj: cambia a medianoche UTC.
final _diaProvider = Provider<int>((ref) {
  final ahora = ref.watch(ahoraProvider.select((v) => v.value));
  final t = ahora ?? ref.read(relojProvider).ahora();
  return t.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
});

final eventosDeTomaProvider = StreamProvider<List<Evento>>((ref) {
  final dia = ref.watch(_diaProvider);
  final desde = DateTime.fromMillisecondsSinceEpoch(
    (dia - 4) * Duration.millisecondsPerDay,
    isUtc: true,
  );
  return ref.watch(eventosRepositorioProvider).observarEventosDeToma(desde);
});

/// Ventana de tomas: desde el inicio de ayer (hora local) hasta 25 h después
/// de ahora.
final tomasProvider = Provider<AsyncValue<List<TomaVista>>>((ref) {
  final pautas = ref.watch(pautasProvider);
  final meds = ref.watch(medicamentosProvider);
  final eventos = ref.watch(eventosDeTomaProvider);
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
  final ahora = ahoraAsync.requireValue;
  return AsyncValue.data(
    calcularTomas(
      pautas: pautas.requireValue,
      medicamentos: meds.requireValue,
      eventos: eventos.requireValue,
      ahora: ahora,
      config: config,
      zona: contexto.zonaHoraria,
    ),
  );
});

/// Calcula las tomas de la ventana [inicio de ayer, ahora + 25 h).
List<TomaVista> calcularTomas({
  required List<Pauta> pautas,
  required List<Medicamento> medicamentos,
  required List<Evento> eventos,
  required DateTime ahora,
  required ConfigEscalado config,
  required String zona,
  DateTime? desde,
  DateTime? hasta,
}) {
  final inicio =
      desde ?? inicioDelDia(ahora.subtract(const Duration(days: 1)), zona);
  final fin = hasta ?? ahora.add(const Duration(hours: 25));
  final versiones = [for (final p in pautas) MedicacionRepositorio.aVersion(p)];
  final previstas = proximasTomas(
    versiones: versiones,
    desde: inicio,
    hasta: fin,
  );
  final pautaPorVersion = {for (final p in pautas) p.id: p};
  final medPorId = {for (final m in medicamentos) m.id: m};
  final eventosToma = EventosRepositorio.aEventosToma(eventos);
  final porSujeto = <String, List<Evento>>{};
  for (final e in eventos) {
    final s = e.sujeto;
    if (s != null) porSujeto.putIfAbsent(s, () => []).add(e);
  }
  return [
    for (final t in previstas)
      TomaVista(
        toma: t,
        estado: estadoDeToma(t, eventosToma, ahora, config),
        medicamento: medPorId[t.medicamentoId],
        pauta: pautaPorVersion[t.pautaVersionId],
        eventos: porSujeto[t.id] ?? const [],
      ),
  ];
}

/// Tomas de hoy (fecha local de la persona).
final tomasDeHoyProvider = Provider<AsyncValue<List<TomaVista>>>((ref) {
  final contexto = ref.watch(contextoProvider);
  final ahora =
      ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
  final hoy = fechaLocalTexto(ahora, contexto.zonaHoraria);
  return ref
      .watch(tomasProvider)
      .whenData(
        (l) => [
          for (final t in l)
            if (t.toma.fechaLocal == hoy) t,
        ],
      );
});

/// Primera toma `prevista` o `noConfirmada` entre 3 h antes y 24 h después.
TomaVista? siguienteToma(List<TomaVista> tomas, DateTime ahora) {
  final desde = ahora.subtract(const Duration(hours: 3));
  final hasta = ahora.add(const Duration(hours: 24));
  for (final t in tomas) {
    if (t.estado != EstadoToma.prevista &&
        t.estado != EstadoToma.noConfirmada) {
      continue;
    }
    final p = t.toma.previstaPara;
    if (p.isBefore(desde) || p.isAfter(hasta)) continue;
    return t;
  }
  return null;
}

final siguienteTomaProvider = Provider<AsyncValue<TomaVista?>>((ref) {
  final ahora =
      ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
  return ref.watch(tomasProvider).whenData((l) => siguienteToma(l, ahora));
});

/// Busca una toma por su id (`<pautaId>_<yyyyMMdd>_<HHmm>`), aunque quede
/// fuera de la ventana habitual.
final tomaPorIdProvider = Provider.family<AsyncValue<TomaVista?>, String>((
  ref,
  id,
) {
  final pautas = ref.watch(pautasProvider);
  final meds = ref.watch(medicamentosProvider);
  final eventos = ref.watch(eventosDeTomaProvider);
  final ahoraAsync = ref.watch(ahoraProvider);
  final config = ref.watch(configEscaladoProvider);
  final contexto = ref.watch(contextoProvider);
  if (!pautas.hasValue ||
      !meds.hasValue ||
      !eventos.hasValue ||
      !ahoraAsync.hasValue) {
    return const AsyncValue.loading();
  }
  final partes = id.split('_');
  if (partes.length < 3) return const AsyncValue.data(null);
  final dia = partes[partes.length - 2];
  if (dia.length != 8) return const AsyncValue.data(null);
  final y = int.tryParse(dia.substring(0, 4));
  final m = int.tryParse(dia.substring(4, 6));
  final d = int.tryParse(dia.substring(6, 8));
  if (y == null || m == null || d == null) return const AsyncValue.data(null);
  final centro = DateTime.utc(y, m, d, 12);
  final lista = calcularTomas(
    pautas: pautas.requireValue,
    medicamentos: meds.requireValue,
    eventos: eventos.requireValue,
    ahora: ahoraAsync.requireValue,
    config: config,
    zona: contexto.zonaHoraria,
    desde: centro.subtract(const Duration(days: 1)),
    hasta: centro.add(const Duration(days: 1)),
  );
  for (final t in lista) {
    if (t.toma.id == id) return AsyncValue.data(t);
  }
  return const AsyncValue.data(null);
});
