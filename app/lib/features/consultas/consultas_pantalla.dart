import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../calendario/campos_agenda.dart';
import '../calendario/dominio/agenda.dart';
import 'dominio/consultas.dart';

/// Consultas (familia, en «Más»): las citas, las próximas arriba y las
/// pasadas debajo, con «Nueva cita» (el formulario del calendario). Al tocar
/// una se abre su ficha de consulta: preguntas para llevar, lo ocurrido
/// desde la última, notas, grabación con permiso y resumen para la familia.
class ConsultasPantalla extends ConsumerWidget {
  const ConsultasPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final citas = ref.watch(citasProvider).value ?? const <Cita>[];
    final preguntas =
        ref.watch(todasLasPreguntasProvider).value ??
        const <PreguntaConsulta>[];
    final grabaciones =
        ref.watch(grabacionesConsultaProvider).value ??
        const <GrabacionConsulta>[];
    final fechas = ref.watch(fechasAgendaProvider);
    final partes = repartirCitas(
      citas,
      fechaHoy: fechas.hoy,
      horaAhora: fechas.hora,
    );
    final conGrabacion = {for (final g in grabaciones) g.id};
    final preguntasPor = <String, int>{};
    for (final p in preguntas) {
      if (!p.preguntada) {
        preguntasPor[p.citaId] = (preguntasPor[p.citaId] ?? 0) + 1;
      }
    }

    Widget fila(Cita c) => _FilaConsulta(
      key: ClavesUi.consFila(c.id),
      cita: c,
      l: l,
      preguntas: preguntasPor[c.id] ?? 0,
      grabacion: conGrabacion.contains(c.id),
      alPulsar: () => context.push(Rutas.consulta(c.id)),
    );

    return Scaffold(
      key: ClavesUi.pantallaConsultas,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(vispera: l.consVispera, titulo: l.pestanaConsultas),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: ClavesUi.consNuevaCita,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: () => context.push(Rutas.consultaCitaNueva),
            icon: const Icon(CupertinoIcons.add),
            label: Text(l.consNuevaCita),
          ),
          const SizedBox(height: 20),
          if (citas.where((c) => c.bajaEn == null).isEmpty)
            GrupoLista(
              children: [FilaLista(titulo: l.consSinCitas, apagada: true)],
            )
          else ...[
            GrupoLista(
              titulo: l.consProximas,
              children: [
                if (partes.proximas.isEmpty)
                  FilaLista(titulo: l.consSinProximas, apagada: true)
                else
                  for (final c in partes.proximas) fila(c),
              ],
            ),
            if (partes.pasadas.isNotEmpty) ...[
              const SizedBox(height: 20),
              GrupoLista(
                titulo: l.consPasadas,
                children: [for (final c in partes.pasadas) fila(c)],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Fila de una cita en la lista: su tipo, título, la hora a la derecha y, de
/// subtítulo, la fecha, el lugar, cuántas preguntas faltan por hacer y si
/// hay grabación.
class _FilaConsulta extends StatelessWidget {
  const _FilaConsulta({
    super.key,
    required this.cita,
    required this.l,
    required this.preguntas,
    required this.grabacion,
    required this.alPulsar,
  });

  final Cita cita;
  final AppLocalizations l;
  final int preguntas;
  final bool grabacion;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final partes = [
      fechaCorta(fechaDeTexto(cita.fecha)),
      if (cita.lugar != null) cita.lugar!,
      if (preguntas > 0) l.consPreguntasN(preguntas),
      if (grabacion) l.consHayGrabacion,
    ];
    return FilaLista(
      leading: IconoCuadrado(
        iconoTipoCita(cita.tipo),
        fondo: c.indigo,
        color: IconoCuadrado.simboloSobre(c.indigo),
      ),
      titulo: cita.titulo,
      subtitulo: partes.join(' · '),
      detalle: cita.hora,
      onTap: alPulsar,
    );
  }
}
