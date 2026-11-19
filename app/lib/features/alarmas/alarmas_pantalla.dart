import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../hoy/dominio/tomas.dart';
import '../hoy/vistas/control_hoy.dart'
    show FilaEnvio, horaEnPunto, nombresDe, textoRitmo;

/// Alarmas (familia): la entrada al control por horas, a quién avisa cada
/// situación según el orden de Círculo y los últimos avisos que salieron.
class AlarmasPantalla extends ConsumerWidget {
  const AlarmasPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final router = GoRouter.maybeOf(context);
    final puedeVolver = router != null && router.canPop();
    final ajustes =
        ref.watch(ajustesControlProvider).value ?? AjustesControl.porDefecto;
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            titulo: l.pestanaAlarmas,
            alVolver: puedeVolver ? router.pop : null,
          ),
          const SizedBox(height: 14),
          GrupoLista(
            children: [
              FilaLista(
                leading: const IconoCuadrado(CupertinoIcons.clock_fill),
                titulo: l.verControlHoras,
                subtitulo: ajustes.activado
                    ? l.controlFranjaResumen(
                        horaEnPunto(ajustes.desde),
                        horaEnPunto(ajustes.hasta),
                        textoRitmo(l, ajustes.cadaHoras),
                      )
                    : l.controlDesactivado,
                onTap: () => context.go(Rutas.controlHoras),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _QuienRecibeAvisos(),
          const SizedBox(height: 14),
          const _UltimosAvisos(),
        ],
      ),
    );
  }
}

/// Tabla de solo lectura: cada tipo de aviso y a quién va. Usa la misma
/// regla que el envío real ([destinatariosDeEscalon] con el puesto de cada
/// familiar en Círculo y los minutos de [minutoDeEscalon]).
class _QuienRecibeAvisos extends ConsumerWidget {
  const _QuienRecibeAvisos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final config = ref.watch(configEscaladoProvider);
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final nombre = {for (final m in miembros) m.id: m.nombre};
    final familiares = [
      for (final m in miembros) (id: m.id, orden: m.ordenEscalado),
    ];
    String quienes(int escalon) => nombresDe(l, [
      for (final id in destinatariosDeEscalon(familiares, escalon))
        nombre[id] ?? '',
    ]);
    final minutosRonda = esperaRespuestaRonda.inMinutes;
    final filas = <(IconData, Color, Color, String, int)>[
      (
        CupertinoIcons.bell_fill,
        c.naranjaRelleno,
        c.sobreNaranja,
        l.alarmasAvisoToma(minutoDeEscalon(config, 1)),
        1,
      ),
      (
        CupertinoIcons.bell_fill,
        c.naranjaRelleno,
        c.sobreNaranja,
        l.alarmasAvisoToma(minutoDeEscalon(config, 2)),
        2,
      ),
      (
        CupertinoIcons.exclamationmark_triangle_fill,
        c.rojo,
        c.sobreRojo,
        l.avisoAyuda,
        0,
      ),
      (
        CupertinoIcons.exclamationmark_octagon_fill,
        c.rojo,
        c.sobreRojo,
        l.avisoEstadoMal,
        0,
      ),
      (
        CupertinoIcons.heart_fill,
        c.naranjaRelleno,
        c.sobreNaranja,
        l.envioMotivoDolor,
        0,
      ),
      (
        CupertinoIcons.exclamationmark_bubble_fill,
        c.naranjaRelleno,
        c.sobreNaranja,
        l.alarmasAvisoRonda(minutosRonda),
        0,
      ),
    ];
    return GrupoLista(
      titulo: l.hoyQuienRecibeAvisos,
      pie: l.alarmasPieOrden,
      children: [
        if (familiares.isEmpty)
          FilaLista(titulo: l.hoySinFamiliares, apagada: true)
        else
          for (final (icono, fondo, color, titulo, escalon) in filas)
            FilaLista(
              leading: IconoCuadrado(icono, fondo: fondo, color: color),
              titulo: titulo,
              subtitulo: quienes(escalon),
            ),
        FilaLista(
          leading: const IconoCuadrado(CupertinoIcons.person_2_fill),
          titulo: l.alarmasCambiarOrden,
          onTap: () => context.go(Rutas.pestana('circulo')),
        ),
      ],
    );
  }
}

/// Los avisos enviados en los últimos 7 días, del más reciente al más
/// antiguo, con los que no se pudieron entregar.
class _UltimosAvisos extends ConsumerWidget {
  const _UltimosAvisos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final envios = ref.watch(enviosUltimos7Provider).value ?? const [];
    final nombres = ref.watch(nombresAutoresProvider);
    return GrupoLista(
      titulo: l.alarmasUltimosAvisos,
      pie: envios.isEmpty ? null : l.alarmasUltimosPie,
      children: [
        if (envios.isEmpty)
          FilaLista(titulo: l.alarmasSinAvisos, apagada: true)
        else
          for (final e in envios)
            FilaEnvio(
              envio: e,
              nombres: nombres,
              detalle: diaYHora(aLocal(e.cuando, zona)),
            ),
      ],
    );
  }
}
