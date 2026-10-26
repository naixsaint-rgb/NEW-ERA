import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/repositorios/eventos_repositorio.dart';
import '../../../core/tema/colores.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../../../shared/widgets/etiqueta_estado_toma.dart';
import '../dominio/tomas.dart';

/// Separación entre bloques de la pantalla (spec §5).
const separacionBloques = SizedBox(height: 14);

/// "Confirmada por Carmen, desde el móvil", "Cerrada por Lucía" o nulo si
/// nadie la ha confirmado ni cerrado.
String? quienConfirmo(
  AppLocalizations l,
  TomaVista t,
  Map<String, String> nombres,
) {
  final conf = t.ultimoDe(TipoEvento.tomaConfirmada);
  if (conf != null) {
    final quien = nombres[conf.autor] ?? l.alguien;
    final origen = EventosRepositorio.payloadDe(conf)['origen'];
    final como = switch (origen) {
      'reloj' => l.origenReloj,
      'familiar' => l.origenFamiliar,
      _ => l.origenMovil,
    };
    return l.confirmadaPorDesde(quien, como);
  }
  final cierre = t.ultimoDe(TipoEvento.tomaCerradaPorFamiliar);
  if (cierre != null) {
    return l.cerradaPor(nombres[cierre.autor] ?? l.alguien);
  }
  return null;
}

/// Como [quienConfirmo], con "Sin confirmar" si nadie lo hizo.
String quienYComo(
  AppLocalizations l,
  TomaVista t,
  Map<String, String> nombres,
) => quienConfirmo(l, t, nombres) ?? l.sinConfirmarAun;

/// "09:00 · Mañana" (con el compartimento del pastillero si lo hay).
String horaYCompartimento(AppLocalizations l, TomaVista t) {
  final comp = t.pauta?.compartimento;
  if (comp == null || comp.trim().isEmpty) return t.toma.horaLocal;
  return l.hoyHoraYCompartimento(t.toma.horaLocal, comp);
}

/// Fila de una toma en una [GrupoLista]: hora, foto, nombre para la
/// persona, compartimento y, si [conEstado], su [EtiquetaEstadoToma].
/// [nota] añade una línea gris (quién la confirmó).
class FilaTomaHoy extends StatelessWidget {
  const FilaTomaHoy({
    super.key,
    required this.toma,
    this.conEstado = true,
    this.nota,
  });

  /// Sangría del separador entre filas: relleno, hora, foto y hueco.
  static const sangria = 16.0 + 56 + 44 + 12;

  final TomaVista toma;
  final bool conEstado;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final comp = toma.pauta?.compartimento;
    final nota = this.nota;
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  toma.toma.horaLocal,
                  style: t.titleSmall?.copyWith(
                    color: c.texto,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FotoPastilla(toma.medicamento, tamano: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      toma.nombreParaPersona,
                      style: t.titleSmall?.copyWith(color: c.texto),
                    ),
                    if (comp != null && comp.trim().isNotEmpty)
                      Text(
                        comp,
                        style: t.bodySmall?.copyWith(color: c.textoSecundario),
                      ),
                    if (conEstado) ...[
                      const SizedBox(height: 6),
                      EtiquetaEstadoToma(estado: toma.estado, tamanoTexto: 13),
                    ],
                    if (nota != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        nota,
                        style: t.bodySmall?.copyWith(color: c.textoSecundario),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lista agrupada de tomas, o una fila gris con [vacio] si no hay.
class GrupoTomas extends StatelessWidget {
  const GrupoTomas({
    super.key,
    required this.titulo,
    required this.tomas,
    required this.vacio,
    this.conEstado = true,
    this.nota,
  });

  final String titulo;
  final List<TomaVista> tomas;
  final String vacio;
  final bool conEstado;
  final String? Function(TomaVista toma)? nota;

  @override
  Widget build(BuildContext context) {
    return GrupoLista(
      titulo: titulo,
      sangria: tomas.isEmpty ? 58 : FilaTomaHoy.sangria,
      children: [
        if (tomas.isEmpty)
          FilaLista(titulo: vacio, apagada: true)
        else
          for (final x in tomas)
            FilaTomaHoy(toma: x, conEstado: conEstado, nota: nota?.call(x)),
      ],
    );
  }
}

/// "Comprobaciones": los vídeos y fotos de [tomas], o [vacio].
class GrupoComprobaciones extends StatelessWidget {
  const GrupoComprobaciones({
    super.key,
    required this.tomas,
    required this.vacio,
  });

  final List<TomaVista> tomas;
  final String vacio;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final clips = clipsDe(tomas);
    return GrupoLista(
      titulo: l.hoyComprobaciones,
      children: [
        if (clips.isEmpty)
          FilaLista(
            titulo: vacio,
            apagada: true,
            leading: IconoCuadrado(
              CupertinoIcons.videocam,
              redondo: true,
              fondo: c.rellenoSuave,
              color: c.textoSecundario,
            ),
          )
        else
          for (final x in clips) _FilaClip(clip: x, titulo: _tituloClip(l, x)),
      ],
    );
  }

  static String _tituloClip(AppLocalizations l, ClipDeToma x) {
    final p = EventosRepositorio.payloadDe(x.clip);
    final hora = x.toma.toma.horaLocal;
    if (p['tipo'] == TipoComprobacion.foto.nombre) {
      return l.hoyFotoDeLaToma(hora);
    }
    final ms = p['duracionMs'];
    final segundos = ms is num ? (ms / 1000).round() : 0;
    return segundos > 0
        ? l.hoyVideoDeLaToma(hora, segundos)
        : l.hoyVideoDeLaTomaSinDuracion(hora);
  }
}

class _FilaClip extends StatelessWidget {
  const _FilaClip({required this.clip, required this.titulo});

  final ClipDeToma clip;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final foto =
        EventosRepositorio.payloadDe(clip.clip)['tipo'] ==
        TipoComprobacion.foto.nombre;
    return FilaLista(
      leading: IconoCuadrado(
        foto ? CupertinoIcons.camera_fill : CupertinoIcons.videocam_fill,
        redondo: true,
        fondo: c.azulClaro,
        color: c.azulSobreTinte,
      ),
      titulo: titulo,
      subtitulo: clip.toma.nombreParaPersona,
    );
  }
}

/// Fila gris de algo que aún no existe ("Llega en la semana 5").
class FilaLlegaPronto extends StatelessWidget {
  const FilaLlegaPronto({super.key, required this.titulo, this.subtitulo});

  final String titulo;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return FilaLista(
      leading: IconoCuadrado(
        CupertinoIcons.clock,
        redondo: true,
        fondo: c.rellenoSuave,
        color: c.textoSecundario,
      ),
      titulo: titulo,
      subtitulo: subtitulo,
      apagada: true,
    );
  }
}
