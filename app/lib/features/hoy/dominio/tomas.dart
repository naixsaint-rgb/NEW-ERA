import 'package:drift/drift.dart';
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

/// Eventos de toma de los últimos 8 días (la vista Semana necesita 7).
final eventosDeTomaProvider = StreamProvider<List<Evento>>((ref) {
  final dia = ref.watch(_diaProvider);
  final desde = DateTime.fromMillisecondsSinceEpoch(
    (dia - 8) * Duration.millisecondsPerDay,
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

// ------------------------------------------------------------ Por días

/// `true` si la toma cuenta como hecha: confirmada (con o sin vídeo) o
/// cerrada por un familiar.
bool esHecha(EstadoToma e) =>
    e == EstadoToma.confirmada ||
    e == EstadoToma.confirmadaSinVideo ||
    e == EstadoToma.cerradaPorFamiliar;

/// Un día en la hora de pared de la persona.
final class DiaLocal {
  const DiaLocal({
    required this.fecha,
    required this.pared,
    required this.inicio,
    required this.fin,
  });

  /// `yyyy-MM-dd`, como `TomaPrevista.fechaLocal`.
  final String fecha;

  /// La fecha (a las 00:00, sin zona) para formatearla: "Martes 13 de
  /// octubre".
  final DateTime pared;

  /// 00:00 local de ese día, en UTC.
  final DateTime inicio;

  /// 00:00 local del día siguiente, en UTC.
  final DateTime fin;

  /// 1 lunes ... 7 domingo.
  int get diaSemana => pared.weekday;

  @override
  bool operator ==(Object other) => other is DiaLocal && other.fecha == fecha;

  @override
  int get hashCode => fecha.hashCode;
}

/// El día local de [ahora] en [zona] desplazado [desplazamiento] días (-1
/// ayer, 1 mañana).
DiaLocal diaLocal(DateTime ahora, String zona, [int desplazamiento = 0]) {
  final f = fechaLocalDe(zona, ahora);
  final pared = DateTime.utc(f.anio, f.mes, f.dia + desplazamiento);
  final siguiente = DateTime.utc(pared.year, pared.month, pared.day + 1);
  String dos(int n) => n.toString().padLeft(2, '0');
  return DiaLocal(
    fecha:
        '${pared.year.toString().padLeft(4, '0')}-'
        '${dos(pared.month)}-${dos(pared.day)}',
    pared: pared,
    inicio: horaLocalAUtc(zona, pared.year, pared.month, pared.day, 0, 0),
    fin: horaLocalAUtc(
      zona,
      siguiente.year,
      siguiente.month,
      siguiente.day,
      0,
      0,
    ),
  );
}

/// Tomas agrupadas por su fecha local (`yyyy-MM-dd`), en su orden.
Map<String, List<TomaVista>> agruparPorDia(Iterable<TomaVista> tomas) {
  final r = <String, List<TomaVista>>{};
  for (final t in tomas) {
    r.putIfAbsent(t.toma.fechaLocal, () => []).add(t);
  }
  return r;
}

/// Cuentas de un grupo de tomas (un día, una semana).
final class CuentaTomas {
  const CuentaTomas({
    this.hechas = 0,
    this.previstas = 0,
    this.pendientes = 0,
    this.noConfirmadas = 0,
  });

  /// Confirmadas, sin vídeo o cerradas por un familiar ([esHecha]).
  final int hechas;

  /// Todas las del grupo.
  final int previstas;

  /// En estado `prevista`: aún pueden tomarse.
  final int pendientes;
  final int noConfirmadas;
}

CuentaTomas contarTomas(Iterable<TomaVista> tomas) {
  var hechas = 0, previstas = 0, pendientes = 0, noConfirmadas = 0;
  for (final t in tomas) {
    previstas++;
    if (esHecha(t.estado)) hechas++;
    if (t.estado == EstadoToma.prevista) pendientes++;
    if (t.estado == EstadoToma.noConfirmada) noConfirmadas++;
  }
  return CuentaTomas(
    hechas: hechas,
    previstas: previstas,
    pendientes: pendientes,
    noConfirmadas: noConfirmadas,
  );
}

/// Un vídeo o una foto de comprobación y su toma.
typedef ClipDeToma = ({TomaVista toma, Evento clip});

/// Clips grabados (`clip_grabado`) de [tomas] que nadie ha anulado, en el
/// orden de las tomas.
List<ClipDeToma> clipsDe(Iterable<TomaVista> tomas) {
  final r = <ClipDeToma>[];
  for (final t in tomas) {
    final anulados = {
      for (final e in t.eventos)
        if (e.tipo == TipoEvento.anulacion.nombre && e.corrigeA != null)
          e.corrigeA!,
    };
    for (final e in t.eventos) {
      if (e.tipo == TipoEvento.clipGrabado.nombre &&
          !anulados.contains(e.ulid)) {
        r.add((toma: t, clip: e));
      }
    }
  }
  return r;
}

/// Minuto del primer paso de [accion] en [config], o [porDefecto] si no
/// está.
int minutoDePaso(
  ConfigEscalado config,
  AccionEscalado accion, {
  required int porDefecto,
}) {
  for (final p in config.pasos) {
    if (p.accion == accion) return p.minuto;
  }
  return porDefecto;
}

/// Las tomas de los últimos 7 días (hoy incluido) y de mañana, con el
/// estado de ahora.
final class TomasPorDia {
  const TomasPorDia({required this.dias, required this.porFecha});

  /// De hace 6 días a mañana: 8 días; el penúltimo es hoy.
  final List<DiaLocal> dias;
  final Map<String, List<TomaVista>> porFecha;

  DiaLocal get hoy => dias[dias.length - 2];
  DiaLocal get ayer => dias[dias.length - 3];
  DiaLocal get manana => dias.last;

  /// Los últimos 7 días, hoy el último.
  List<DiaLocal> get ultimos7 => dias.sublist(0, dias.length - 1);

  List<TomaVista> de(DiaLocal dia) => porFecha[dia.fecha] ?? const [];
}

/// Tomas de hace 6 días a mañana (pestaña Hoy de la familia).
final tomasPorDiaProvider = Provider<AsyncValue<TomasPorDia>>((ref) {
  final pautas = ref.watch(pautasProvider);
  final meds = ref.watch(medicamentosProvider);
  final eventos = ref.watch(eventosDeTomaProvider);
  final ahoraAsync = ref.watch(ahoraProvider);
  final config = ref.watch(configEscaladoProvider);
  final zona = ref.watch(contextoProvider).zonaHoraria;
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
  final dias = [for (var d = -6; d <= 1; d++) diaLocal(ahora, zona, d)];
  final lista = calcularTomas(
    pautas: pautas.requireValue,
    medicamentos: meds.requireValue,
    eventos: eventos.requireValue,
    ahora: ahora,
    config: config,
    zona: zona,
    desde: dias.first.inicio,
    hasta: dias.last.fin,
  );
  return AsyncValue.data(
    TomasPorDia(dias: dias, porFecha: agruparPorDia(lista)),
  );
});

/// Fecha local (`yyyy-MM-dd`) de hoy: solo cambia a medianoche local.
final _fechaDeHoyProvider = Provider<String>((ref) {
  final zona = ref.watch(contextoProvider).zonaHoraria;
  final ahora =
      ref.watch(ahoraProvider.select((v) => v.value)) ??
      ref.read(relojProvider).ahora();
  return fechaLocalTexto(ahora, zona);
});

/// Avisos de hoy: ayuda pedida y llamadas iniciadas desde las 00:00 local.
final avisosDeHoyProvider = StreamProvider<int>((ref) {
  ref.watch(_fechaDeHoyProvider);
  final zona = ref.watch(contextoProvider).zonaHoraria;
  final ahora = ref.read(relojProvider).ahora();
  final desde = inicioDelDia(ahora, zona).millisecondsSinceEpoch;
  final db = ref.watch(baseDatosProvider);
  final q = db.select(db.eventos)
    ..where(
      (e) =>
          e.tipo.isIn([
            TipoEvento.ayudaPedida.nombre,
            TipoEvento.llamadaIniciada.nombre,
          ]) &
          e.ocurridoEn.isBiggerOrEqualValue(desde),
    );
  return q.watch().map((l) => l.length);
});

// ------------------------------------------------------------ Semáforo

/// Nivel del semáforo del día.
enum NivelSemaforo { verde, naranja, rojo }

/// Rojo si hoy hay una `noConfirmada`; naranja si hay una
/// `confirmadaSinVideo`; si no, verde.
NivelSemaforo nivelSemaforo(Iterable<TomaVista> deHoy) {
  var nivel = NivelSemaforo.verde;
  for (final t in deHoy) {
    if (t.estado == EstadoToma.noConfirmada) return NivelSemaforo.rojo;
    if (t.estado == EstadoToma.confirmadaSinVideo) {
      nivel = NivelSemaforo.naranja;
    }
  }
  return nivel;
}

/// Nombres de quien firma cada evento (familiares y persona).
final nombresAutoresProvider = Provider<Map<String, String>>((ref) {
  final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
  final persona = ref.watch(personaProvider).value;
  return {
    for (final m in miembros) m.id: m.nombre,
    if (persona != null) persona.id: persona.alias,
  };
});
