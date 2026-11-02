import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/enrutado/rutas.dart';
import '../../../core/i18n/fechas.dart';
import '../../../core/providers.dart';
import '../../../core/tema/colores.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../dominio/control_horas.dart';
import '../dominio/tomas.dart';

/// Una respuesta en palabras de la familia: "Bien", "Le duele un poco",
/// "Va a pasear"…
String textoRespuestaControl(
  AppLocalizations l,
  TipoPreguntaControl tipo,
  String valor,
) {
  if (valor == 'decirlo') return l.controlDecirlo;
  return switch ((tipo, valor)) {
    (TipoPreguntaControl.estado, 'bien') => l.controlEstadoBien,
    (TipoPreguntaControl.estado, 'regular') => l.controlEstadoRegular,
    (TipoPreguntaControl.estado, 'mal') => l.controlEstadoMal,
    (TipoPreguntaControl.dolor, 'nada') => l.controlDolorNada,
    (TipoPreguntaControl.dolor, 'poco') => l.controlDolorPoco,
    (TipoPreguntaControl.dolor, 'mucho') => l.controlDolorMucho,
    (TipoPreguntaControl.plan, 'pasear') => l.controlPlanPasear,
    (TipoPreguntaControl.plan, 'descansar') => l.controlPlanDescansar,
    (TipoPreguntaControl.plan, 'tele') => l.controlPlanTele,
    (TipoPreguntaControl.plan, 'otra') => l.controlPlanOtra,
    _ => valor,
  };
}

/// "cada hora", "cada 2 horas", "cada 3 horas".
String textoRitmo(AppLocalizations l, int cadaHoras) => switch (cadaHoras) {
  2 => l.controlRitmoCada2,
  3 => l.controlRitmoCada3,
  _ => l.controlRitmoCada1,
};

/// "09:00".
String horaEnPunto(int hora) => '${hora.toString().padLeft(2, '0')}:00';

String _cuanto(AppLocalizations l, String? valor) =>
    valor == 'mucho' ? l.controlCuantoMucho : l.controlCuantoPoco;

/// Grupo "Control por horas" de Hoy: la última respuesta (las tres y la
/// hora), las rondas de hoy sin respuesta y la franja, que lleva a sus
/// ajustes.
class GrupoControlHoras extends ConsumerWidget {
  const GrupoControlHoras({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final alias = ref.watch(personaProvider).value?.alias ?? '';
    final ajustes =
        ref.watch(ajustesControlProvider).value ?? AjustesControl.porDefecto;
    final control = ref.watch(controlDeHoyProvider).value;
    final ultima = control?.ultima;
    String hora(DateTime utc) => horaCorta(aLocal(utc, zona));

    final Widget filaUltima;
    if (ultima == null) {
      filaUltima = FilaLista(
        leading: IconoCuadrado(
          CupertinoIcons.chat_bubble_text,
          redondo: true,
          fondo: c.rellenoSuave,
          color: c.textoSecundario,
        ),
        titulo: l.controlUltimaRespuesta,
        subtitulo: !ajustes.activado
            ? l.controlDesactivado
            : control?.inicio == null
            ? l.controlSinMovil(alias)
            : l.controlSinRespuestasHoy,
      );
    } else {
      final estado = ultima.respuestas[TipoPreguntaControl.estado]?.valor;
      final (fondo, simbolo) = switch (estado) {
        'mal' => (c.rojoClaro, c.rojo),
        'regular' => (c.naranjaClaro, c.naranja),
        'bien' => (c.verdeClaro, c.verde),
        _ => (c.azulClaro, c.azul),
      };
      filaUltima = FilaLista(
        leading: IconoCuadrado(
          CupertinoIcons.chat_bubble_text_fill,
          redondo: true,
          fondo: fondo,
          color: simbolo,
        ),
        titulo: l.controlUltimaRespuesta,
        subtitulo: [
          for (final t in TipoPreguntaControl.values)
            if (ultima.respuestas[t] case final r?)
              textoRespuestaControl(l, t, r.valor),
        ].join(' · '),
        detalle: hora(ultima.cuando),
      );
    }
    final sin = control?.sinRespuesta ?? const <RondaDelDia>[];
    return GrupoLista(
      titulo: l.controlHorasTitulo,
      children: [
        filaUltima,
        if (sin.isNotEmpty)
          FilaLista(
            leading: IconoCuadrado(
              CupertinoIcons.exclamationmark_bubble_fill,
              redondo: true,
              fondo: sin.length > 1 ? c.rojoClaro : c.naranjaClaro,
              color: sin.length > 1 ? c.rojo : c.naranja,
            ),
            titulo: l.controlSinRespuesta,
            subtitulo: [for (final r in sin) hora(r.ronda.hora)].join(', '),
            detalle: '${sin.length}',
          ),
        FilaLista(
          leading: IconoCuadrado(
            CupertinoIcons.clock_fill,
            fondo: c.azul,
            color: c.sobreAzul,
          ),
          titulo: l.controlFranjaYRitmo,
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
    );
  }
}

/// Texto de un aviso del día.
String textoAviso(AppLocalizations l, AvisoDelDia a, String zona) =>
    switch (a.tipo) {
      TipoAviso.ayudaPedida => l.avisoAyuda,
      TipoAviso.llamadaIniciada => l.avisoLlamada,
      TipoAviso.estadoMal => l.avisoEstadoMal,
      TipoAviso.dolorNuevo => l.avisoDolorNuevo(_cuanto(l, a.valor)),
      TipoAviso.dolorRepetido => l.avisoDolorRepetido(_cuanto(l, a.valor)),
      TipoAviso.dosSinRespuesta => l.avisoDosSinRespuesta(
        a.rondas.isEmpty ? '' : _horaDeRonda(a.rondas.first),
        a.rondas.isEmpty ? '' : _horaDeRonda(a.rondas.last),
      ),
    };

/// "10:00" de `ronda_20261013_1000`.
String _horaDeRonda(String id) {
  final hhmm = id.substring(id.length - 4);
  return '${hhmm.substring(0, 2)}:${hhmm.substring(2)}';
}

/// "Lucía", "Lucía y Javier", "Lucía, Javier y Marta".
String nombresDe(AppLocalizations l, List<String> nombres) {
  if (nombres.isEmpty) return l.envioUnFamiliar;
  if (nombres.length == 1) return nombres.first;
  return l.envioYUltimo(
    nombres.sublist(0, nombres.length - 1).join(', '),
    nombres.last,
  );
}

/// Por qué salió un aviso, en palabras de la familia.
String motivoEnvio(AppLocalizations l, EnvioDelDia e) => switch (e.motivo) {
  MotivoAviso.tomaSinConfirmar => l.envioMotivoToma(_horaDeRonda(e.sujeto)),
  MotivoAviso.rondaSinRespuesta => l.envioMotivoRonda(_horaDeRonda(e.sujeto)),
  MotivoAviso.ayudaPedida => l.avisoAyuda,
  MotivoAviso.estadoMal => l.avisoEstadoMal,
  MotivoAviso.dolorNuevo => l.envioMotivoDolor,
};

/// "Avisos de hoy": ayuda, llamadas y las situaciones del control por horas,
/// y los avisos que salieron a la familia por ntfy («Aviso enviado a Lucía ·
/// 14:05»). Sin nada, no se pinta.
class GrupoAvisosHoy extends ConsumerWidget {
  const GrupoAvisosHoy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final avisos = ref.watch(avisosDeHoyProvider).value ?? const [];
    final envios = ref.watch(enviosDeHoyProvider);
    final nombres = ref.watch(nombresAutoresProvider);
    if (avisos.isEmpty && envios.isEmpty) return const SizedBox.shrink();
    final filas = <(DateTime, Widget)>[
      for (final e in envios)
        (
          e.cuando,
          FilaLista(
            leading: IconoCuadrado(
              e.resultado == ResultadoAviso.enviado
                  ? CupertinoIcons.paperplane_fill
                  : CupertinoIcons.xmark_octagon_fill,
              redondo: true,
              fondo: e.resultado == ResultadoAviso.enviado
                  ? c.azulClaro
                  : c.rojoClaro,
              color: e.resultado == ResultadoAviso.enviado ? c.azul : c.rojo,
            ),
            titulo: () {
              final quienes = nombresDe(l, [
                for (final id in e.miembros) nombres[id] ?? l.envioUnFamiliar,
              ]);
              return e.resultado == ResultadoAviso.enviado
                  ? l.envioA(quienes)
                  : l.envioFallidoA(quienes);
            }(),
            subtitulo: motivoEnvio(l, e),
            detalle: horaCorta(aLocal(e.cuando, zona)),
          ),
        ),
      for (final a in avisos) (a.cuando, _filaAviso(context, a, zona)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: GrupoLista(
        titulo: l.avisosDeHoy,
        pie: l.avisosPie,
        children: [for (final f in filas) f.$2],
      ),
    );
  }

  Widget _filaAviso(BuildContext context, AvisoDelDia a, String zona) {
    final l = context.l;
    final c = context.colores;
    return FilaLista(
      leading: IconoCuadrado(
        switch (a.tipo) {
          TipoAviso.llamadaIniciada => CupertinoIcons.phone_fill,
          TipoAviso.ayudaPedida => CupertinoIcons.exclamationmark_triangle_fill,
          _ => CupertinoIcons.bell_fill,
        },
        redondo: true,
        fondo: switch (a.tipo) {
          TipoAviso.llamadaIniciada => c.verdeClaro,
          TipoAviso.dolorNuevo || TipoAviso.dolorRepetido => c.naranjaClaro,
          _ => c.rojoClaro,
        },
        color: switch (a.tipo) {
          TipoAviso.llamadaIniciada => c.verde,
          TipoAviso.dolorNuevo || TipoAviso.dolorRepetido => c.naranja,
          _ => c.rojo,
        },
      ),
      titulo: textoAviso(l, a, zona),
      detalle: horaCorta(aLocal(a.cuando, zona)),
    );
  }
}
