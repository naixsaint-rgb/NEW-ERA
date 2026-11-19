import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/i18n/fechas.dart';
import '../../../core/providers.dart';
import '../../../core/tema/colores.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../dominio/control_horas.dart';
import '../dominio/tomas.dart';
import 'control_hoy.dart' show textoRespuestaControl;
import 'piezas_hoy.dart';

/// Vista "Ayer": tomas de ayer con su estado y quién las confirmó, las
/// comprobaciones y el control por horas de ayer (las rondas con sus tres
/// respuestas y su hora, y las que quedaron sin respuesta).
class VistaAyer extends ConsumerWidget {
  const VistaAyer({super.key, required this.datos});

  final TomasPorDia datos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final nombres = ref.watch(nombresAutoresProvider);
    final deAyer = datos.de(datos.ayer);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GrupoTomas(
          titulo: l.hoyTomasDeAyer,
          tomas: deAyer,
          vacio: l.hoySinTomasAyer,
          nota: (x) => quienConfirmo(l, x, nombres),
        ),
        separacionBloques,
        GrupoComprobaciones(tomas: deAyer, vacio: l.hoySinComprobacionesAyer),
        separacionBloques,
        const _GrupoControlDeAyer(),
      ],
    );
  }
}

/// Las rondas de ayer: «Bien · Sin dolor · Va a pasear» con la hora de la
/// respuesta, y «Sin respuesta» para las que nadie contestó.
class _GrupoControlDeAyer extends ConsumerWidget {
  const _GrupoControlDeAyer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final control = ref.watch(controlSemanaProvider).value?.ayer;
    if (control == null) return const SizedBox.shrink();
    final rondas = [
      for (final r in control.rondas)
        if (r.estado == EstadoRonda.contestada ||
            r.estado == EstadoRonda.sinRespuesta)
          r,
    ];
    if (rondas.isEmpty) {
      return GrupoLista(
        titulo: l.hoyControlDeAyer,
        children: [FilaLista(titulo: l.hoySinRondasAyer, apagada: true)],
      );
    }
    final cuenta = contarControl([control]);
    return GrupoLista(
      titulo: l.hoyControlDeAyer,
      pie: l.hoyControlCuenta(cuenta.contestadas, cuenta.sinRespuesta),
      children: [
        for (final r in rondas)
          if (r.estado == EstadoRonda.sinRespuesta)
            FilaLista(
              leading: IconoCuadrado(
                CupertinoIcons.exclamationmark_bubble_fill,
                redondo: true,
                fondo: c.naranjaClaro,
                color: c.naranja,
              ),
              titulo: l.controlSinRespuesta,
              subtitulo: l.hoyRondaDeLas(r.ronda.horaLocal),
              detalle: r.ronda.horaLocal,
            )
          else
            FilaLista(
              leading: IconoCuadrado(
                CupertinoIcons.chat_bubble_text_fill,
                redondo: true,
                fondo: _fondo(c, r.respuestas[TipoPreguntaControl.estado]),
                color: _color(c, r.respuestas[TipoPreguntaControl.estado]),
              ),
              titulo: [
                for (final t in TipoPreguntaControl.values)
                  if (r.respuestas[t] case final x?)
                    textoRespuestaControl(l, t, x.valor),
              ].join(' · '),
              subtitulo: l.hoyRondaDeLas(r.ronda.horaLocal),
              detalle: horaCorta(
                aLocal(
                  r.respuestas.values
                      .map((x) => x.cuando)
                      .reduce((a, b) => a.isAfter(b) ? a : b),
                  zona,
                ),
              ),
            ),
      ],
    );
  }

  static Color _fondo(ColoresApp c, RespuestaControl? estado) =>
      switch (estado?.valor) {
        'mal' => c.rojoClaro,
        'regular' => c.naranjaClaro,
        'bien' => c.verdeClaro,
        _ => c.azulClaro,
      };

  static Color _color(ColoresApp c, RespuestaControl? estado) =>
      switch (estado?.valor) {
        'mal' => c.rojo,
        'regular' => c.naranja,
        'bien' => c.verde,
        _ => c.azul,
      };
}
