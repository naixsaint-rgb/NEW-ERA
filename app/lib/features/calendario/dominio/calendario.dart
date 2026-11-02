import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/providers.dart';
import '../../hoy/dominio/tomas.dart';

/// Un mes del calendario en la hora de pared de la persona.
final class MesCalendario {
  const MesCalendario(this.anio, this.mes);

  /// El mes en que cae [utc] según [zona].
  factory MesCalendario.de(DateTime utc, String zona) {
    final f = fechaLocalDe(zona, utc);
    return MesCalendario(f.anio, f.mes);
  }

  final int anio;

  /// 1 a 12.
  final int mes;

  MesCalendario get anterior =>
      mes == 1 ? MesCalendario(anio - 1, 12) : MesCalendario(anio, mes - 1);

  MesCalendario get siguiente =>
      mes == 12 ? MesCalendario(anio + 1, 1) : MesCalendario(anio, mes + 1);

  /// Días que tiene el mes.
  int get diasEnMes => DateTime.utc(anio, mes + 1, 0).day;

  /// El día 1 a las 00:00, sin zona, para formatearlo ("Octubre de 2026").
  DateTime get pared => DateTime.utc(anio, mes);

  /// Huecos en blanco antes del día 1 con el lunes primero (0 a 6).
  int get huecosAntes => pared.weekday - 1;

  /// Filas de la rejilla de 7 columnas.
  int get filas => (huecosAntes + diasEnMes + 6) ~/ 7;

  /// 00:00 local del día 1, en UTC.
  DateTime inicio(String zona) => horaLocalAUtc(zona, anio, mes, 1, 0, 0);

  /// 00:00 local del día 1 del mes siguiente, en UTC.
  DateTime fin(String zona) => siguiente.inicio(zona);

  /// `yyyy-MM-dd` del día [dia] de este mes, como `TomaPrevista.fechaLocal`.
  String fecha(int dia) => fechaDeDia(anio, mes, dia);

  /// El día [dia] a las 00:00, sin zona, para formatearlo.
  DateTime paredDe(int dia) => DateTime.utc(anio, mes, dia);

  @override
  bool operator ==(Object other) =>
      other is MesCalendario && other.anio == anio && other.mes == mes;

  @override
  int get hashCode => Object.hash(anio, mes);
}

/// `yyyy-MM-dd`.
String fechaDeDia(int anio, int mes, int dia) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${anio.toString().padLeft(4, '0')}-${dos(mes)}-${dos(dia)}';
}

/// Qué punto lleva un día del calendario.
enum EstadoDiaCalendario {
  /// Sin tomas: sin punto.
  sinTomas,

  /// Todas hechas ([esHecha]): verde.
  completo,

  /// Alguna hecha, pero no todas: naranja.
  parcial,

  /// Ninguna hecha y alguna no confirmada: rojo.
  sinHechas,

  /// Ninguna hecha y quedan previstas: gris.
  previstas,
}

/// Estado del punto de un día según sus [tomas].
EstadoDiaCalendario estadoDelDia(Iterable<TomaVista> tomas) {
  final c = contarTomas(tomas);
  if (c.previstas == 0) return EstadoDiaCalendario.sinTomas;
  if (c.hechas == c.previstas) return EstadoDiaCalendario.completo;
  if (c.hechas > 0) return EstadoDiaCalendario.parcial;
  if (c.noConfirmadas > 0) return EstadoDiaCalendario.sinHechas;
  return EstadoDiaCalendario.previstas;
}

/// Hechos de un día que no son de toma, tal como salen en el calendario.
final class HechoDelDia {
  const HechoDelDia({required this.evento, required this.tipo});

  final Evento evento;
  final TipoEvento tipo;
}

/// Tipos de evento que el calendario cuenta como "hechos" (los de toma van
/// con su toma).
const tiposDeHecho = {
  TipoEvento.mensajeFamilia,
  TipoEvento.ayudaPedida,
  TipoEvento.llamadaIniciada,
  TipoEvento.medicamentoCreado,
};

/// Las tomas y los hechos de un mes, por fecha local (`yyyy-MM-dd`).
final class DatosMes {
  const DatosMes({
    required this.mes,
    required this.tomasPorFecha,
    required this.hechosPorFecha,
  });

  /// Agrupa [tomas] y [eventos] por su fecha local en [zona]. Los eventos
  /// fuera de [mes] se descartan.
  factory DatosMes.calcular({
    required MesCalendario mes,
    required Iterable<TomaVista> tomas,
    required Iterable<Evento> eventos,
    required String zona,
  }) {
    final inicio = mes.inicio(zona).millisecondsSinceEpoch;
    final fin = mes.fin(zona).millisecondsSinceEpoch;
    final hechos = <String, List<HechoDelDia>>{};
    for (final e in eventos) {
      if (e.ocurridoEn < inicio || e.ocurridoEn >= fin) continue;
      final tipo = TipoEvento.desdeNombre(e.tipo);
      if (tipo == null || !tiposDeHecho.contains(tipo)) continue;
      final fecha = _fechaLocalDeMs(e.ocurridoEn, zona);
      hechos
          .putIfAbsent(fecha, () => [])
          .add(HechoDelDia(evento: e, tipo: tipo));
    }
    return DatosMes(
      mes: mes,
      tomasPorFecha: agruparPorDia(tomas),
      hechosPorFecha: hechos,
    );
  }

  final MesCalendario mes;
  final Map<String, List<TomaVista>> tomasPorFecha;

  /// Del más antiguo al más reciente.
  final Map<String, List<HechoDelDia>> hechosPorFecha;

  List<TomaVista> tomasDe(String fecha) => tomasPorFecha[fecha] ?? const [];
  List<HechoDelDia> hechosDe(String fecha) => hechosPorFecha[fecha] ?? const [];
  EstadoDiaCalendario estadoDe(String fecha) => estadoDelDia(tomasDe(fecha));
}

String _fechaLocalDeMs(int ms, String zona) {
  final f = fechaLocalDe(
    zona,
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
  );
  return fechaDeDia(f.anio, f.mes, f.dia);
}

/// Eventos desde el inicio de [mes] (todo lo que pasó, para tomas y hechos).
final eventosDelMesProvider = StreamProvider.autoDispose
    .family<List<Evento>, MesCalendario>((ref, mes) {
      final zona = ref.watch(contextoProvider).zonaHoraria;
      return ref
          .watch(eventosRepositorioProvider)
          .observarEventosDesde(mes.inicio(zona));
    });

/// Tomas (con su estado de ahora) y hechos de [mes].
final datosMesProvider = Provider.autoDispose
    .family<AsyncValue<DatosMes>, MesCalendario>((ref, mes) {
      final pautas = ref.watch(pautasProvider);
      final meds = ref.watch(medicamentosProvider);
      final eventos = ref.watch(eventosDelMesProvider(mes));
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
      final tomas = calcularTomas(
        pautas: pautas.requireValue,
        medicamentos: meds.requireValue,
        eventos: eventos.requireValue,
        ahora: ahoraAsync.requireValue,
        config: config,
        zona: zona,
        desde: mes.inicio(zona),
        hasta: mes.fin(zona),
      );
      return AsyncValue.data(
        DatosMes.calcular(
          mes: mes,
          tomas: tomas,
          eventos: eventos.requireValue,
          zona: zona,
        ),
      );
    });
