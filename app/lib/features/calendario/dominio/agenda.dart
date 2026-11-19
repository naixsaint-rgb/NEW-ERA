import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/i18n/fechas.dart';
import '../../../core/providers.dart';

/// `HH:mm` a minutos desde las 00:00.
int minutosDeHora(String hora) =>
    int.parse(hora.substring(0, 2)) * 60 + int.parse(hora.substring(3, 5));

/// El día `yyyy-MM-dd` como fecha UTC a las 00:00 (solo para sumar días y
/// leer el día de la semana).
DateTime _dia(String fecha) => DateTime.utc(
  int.parse(fecha.substring(0, 4)),
  int.parse(fecha.substring(5, 7)),
  int.parse(fecha.substring(8, 10)),
);

String _texto(DateTime d) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${dos(d.month)}-${dos(d.day)}';
}

/// `yyyy-MM-dd` [dias] días después (o antes, si es negativo) de [fecha].
String fechaMasDias(String fecha, int dias) =>
    _texto(_dia(fecha).add(Duration(days: dias)));

/// Un día de [turno] visto desde una fecha: el turno que empieza ese día o
/// la continuación del que empezó el anterior y cruza la medianoche.
final class TurnoEnDia {
  const TurnoEnDia({
    required this.turno,
    required this.inicio,
    required this.continuacion,
  });

  final Turno turno;

  /// Día en que empieza esta repetición (`yyyy-MM-dd`).
  final String inicio;

  /// `true` si es la parte que cae después de la medianoche de [inicio].
  final bool continuacion;
}

extension TurnoAgenda on Turno {
  /// Acaba al día siguiente (guardia de noche).
  bool get cruzaMedianoche =>
      minutosDeHora(hastaHora) <= minutosDeHora(desdeHora);

  /// Empieza el día [fecha]: su día, o ese día de la semana si se repite.
  bool empiezaEl(String fecha) {
    if (fecha == this.fecha) return true;
    if (!repetirSemanal) return false;
    final f = _dia(fecha);
    final primero = _dia(this.fecha);
    return !f.isBefore(primero) && f.difference(primero).inDays % 7 == 0;
  }
}

/// Citas del día [fecha], por hora.
List<Cita> citasDelDia(Iterable<Cita> citas, String fecha) => [
  for (final c in citas)
    if (c.fecha == fecha && c.bajaEn == null) c,
]..sort((a, b) => a.hora.compareTo(b.hora));

/// Turnos que tocan el día [fecha] (los que empiezan y las continuaciones
/// de los que empezaron la víspera), por hora de inicio.
List<TurnoEnDia> turnosDelDia(Iterable<Turno> turnos, String fecha) {
  final ayer = fechaMasDias(fecha, -1);
  final r = <TurnoEnDia>[];
  for (final t in turnos) {
    if (t.bajaEn != null) continue;
    if (t.empiezaEl(fecha)) {
      r.add(TurnoEnDia(turno: t, inicio: fecha, continuacion: false));
    }
    if (t.cruzaMedianoche && t.empiezaEl(ayer)) {
      r.add(TurnoEnDia(turno: t, inicio: ayer, continuacion: true));
    }
  }
  // Las continuaciones primero (acaban de madrugada), luego por hora.
  r.sort((a, b) {
    if (a.continuacion != b.continuacion) return a.continuacion ? -1 : 1;
    return a.turno.desdeHora.compareTo(b.turno.desdeHora);
  });
  return r;
}

/// Las [n] siguientes citas desde [ahora] (la hora de pared de la persona:
/// [fechaHoy] y [horaAhora] `HH:mm`), una cita que empieza ahora aún cuenta.
List<Cita> proximasCitas(
  Iterable<Cita> citas, {
  required String fechaHoy,
  required String horaAhora,
  int n = 3,
}) {
  final futuras = [
    for (final c in citas)
      if (c.bajaEn == null &&
          (c.fecha.compareTo(fechaHoy) > 0 ||
              (c.fecha == fechaHoy && c.hora.compareTo(horaAhora) >= 0)))
        c,
  ]..sort((a, b) => '${a.fecha} ${a.hora}'.compareTo('${b.fecha} ${b.hora}'));
  return futuras.take(n).toList();
}

/// El turno en curso a [horaAhora] de [fechaHoy], si lo hay (el primero que
/// empezó, por si hay dos a la vez).
Turno? turnoAhora(
  Iterable<Turno> turnos, {
  required String fechaHoy,
  required String horaAhora,
}) {
  final ahora = minutosDeHora(horaAhora);
  for (final x in turnosDelDia(turnos, fechaHoy)) {
    final desde = minutosDeHora(x.turno.desdeHora);
    final hasta = minutosDeHora(x.turno.hastaHora);
    final dentro = x.continuacion
        ? ahora < hasta
        : (x.turno.cruzaMedianoche
              ? ahora >= desde
              : ahora >= desde && ahora < hasta);
    if (dentro) return x.turno;
  }
  return null;
}

/// Fecha y hora de pared de la persona ahora.
typedef AhoraLocal = ({String fecha, String hora});

AhoraLocal ahoraLocal(DateTime ahora, String zona) =>
    (fecha: fechaLocalTexto(ahora, zona), hora: horaCorta(aLocal(ahora, zona)));

/// Turnos vigentes: sin los de un familiar que ya no está en el círculo.
final turnosVigentesProvider = Provider<AsyncValue<List<Turno>>>((ref) {
  final turnos = ref.watch(turnosProvider);
  final miembros = ref.watch(miembrosProvider);
  if (turnos.hasError && !turnos.hasValue) {
    return AsyncValue.error(
      turnos.error!,
      turnos.stackTrace ?? StackTrace.empty,
    );
  }
  if (!turnos.hasValue || !miembros.hasValue) return const AsyncValue.loading();
  final ids = {for (final m in miembros.requireValue) m.id};
  return AsyncValue.data([
    for (final t in turnos.requireValue)
      if (ids.contains(t.miembroId)) t,
  ]);
});

/// Fecha de hoy y de mañana y la hora de ahora, en la zona de la persona.
final fechasAgendaProvider =
    Provider<({String hoy, String manana, String hora})>((ref) {
      final zona = ref.watch(contextoProvider).zonaHoraria;
      final ahora =
          ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
      final a = ahoraLocal(ahora, zona);
      return (hoy: a.fecha, manana: fechaMasDias(a.fecha, 1), hora: a.hora);
    });
