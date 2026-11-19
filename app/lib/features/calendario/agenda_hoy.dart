import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../hoy/vistas/piezas_hoy.dart';
import 'agenda_filas.dart';
import 'dominio/agenda.dart';

/// Lo de la agenda en la vista Hoy: «Hoy está con ella: X» si hay un turno
/// en curso y las citas de hoy (con hora y título).
class AgendaHoy extends ConsumerWidget {
  const AgendaHoy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final f = ref.watch(fechasAgendaProvider);
    final citas = ref.watch(citasProvider).value ?? const <Cita>[];
    final turnos = ref.watch(turnosVigentesProvider).value ?? const <Turno>[];
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final nombres = {for (final m in miembros) m.id: m.nombre};
    final ahora = turnoAhora(turnos, fechaHoy: f.hoy, horaAhora: f.hora);
    final deHoy = citasDelDia(citas, f.hoy);
    if (ahora == null && deHoy.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        separacionBloques,
        if (ahora != null)
          GrupoLista(
            children: [
              FilaLista(
                key: ClavesUi.hoyEstaConElla,
                leading: IconoCuadrado(
                  CupertinoIcons.person_2_fill,
                  fondo: c.morado,
                  color: IconoCuadrado.simboloSobre(c.morado),
                ),
                titulo: l.agendaEstaConElla(nombres[ahora.miembroId] ?? ''),
                subtitulo: l.agendaHasta(ahora.hastaHora),
                onTap: () => context.go(Rutas.turno(ahora.id)),
              ),
            ],
          ),
        if (ahora != null && deHoy.isNotEmpty) separacionBloques,
        if (deHoy.isNotEmpty)
          _GrupoCitas(titulo: l.agendaCitasHoy, citas: deHoy, nombres: nombres),
      ],
    );
  }
}

/// Las citas de mañana en la vista Mañana.
class AgendaManana extends ConsumerWidget {
  const AgendaManana({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final f = ref.watch(fechasAgendaProvider);
    final citas = ref.watch(citasProvider).value ?? const <Cita>[];
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final delDia = citasDelDia(citas, f.manana);
    if (delDia.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        separacionBloques,
        _GrupoCitas(
          titulo: l.agendaCitasManana,
          citas: delDia,
          nombres: {for (final m in miembros) m.id: m.nombre},
        ),
      ],
    );
  }
}

class _GrupoCitas extends StatelessWidget {
  const _GrupoCitas({
    required this.titulo,
    required this.citas,
    required this.nombres,
  });

  final String titulo;
  final List<Cita> citas;
  final Map<String, String> nombres;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return GrupoLista(
      titulo: titulo,
      children: [
        for (final cita in citas)
          FilaCitaAgenda(
            key: citas.length == 1
                ? ClavesUi.hoyCita
                : ClavesUi.citaFila('hoy_${cita.id}'),
            cita: cita,
            l: l,
            nombres: nombres,
            onTap: () => context.go(Rutas.cita(cita.id)),
          ),
      ],
    );
  }
}
