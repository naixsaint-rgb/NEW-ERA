import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/repositorios/eventos_repositorio.dart';
import '../../../core/providers.dart';
import '../../../core/sync/clips.dart';
import '../../../core/tema/colores.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../dominio/tomas.dart';

enum _Estado { quieto, bajando, noDisponible, noSeBaja }

/// Fila de un vídeo (o foto) de comprobación en Hoy y Ayer.
///
/// Si el clip viajó por el cartero (su `clip_grabado` trae `clipId`), a la
/// derecha pone «Ver vídeo»: al tocar baja los trozos (con el progreso),
/// los descifra, comprueba el hash y abre el reproductor. Si el servidor ya
/// no lo tiene (7 días), lo dice. Los clips de antes de esta versión no
/// cambian.
class FilaClip extends ConsumerStatefulWidget {
  const FilaClip({super.key, required this.clip, required this.titulo});

  final ClipDeToma clip;
  final String titulo;

  @override
  ConsumerState<FilaClip> createState() => _FilaClipState();
}

class _FilaClipState extends ConsumerState<FilaClip> {
  _Estado _estado = _Estado.quieto;
  double _progreso = 0;

  Future<void> _ver(MetaClip meta) async {
    if (_estado == _Estado.bajando) return;
    setState(() {
      _estado = _Estado.bajando;
      _progreso = 0;
    });
    final clips = ref.read(clipsProvider);
    final r = await clips.bajar(
      meta,
      progreso: (hechos, total) {
        if (mounted && total > 0) setState(() => _progreso = hechos / total);
      },
    );
    if (!mounted) return;
    switch (r) {
      case ClipListo(:final ruta, :final mime):
        setState(() => _estado = _Estado.quieto);
        final absoluta = await clips.archivos.absoluta(ruta);
        if (!mounted) return;
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => VisorClipPantalla(
              titulo: widget.titulo,
              ruta: absoluta,
              mime: mime,
            ),
          ),
        );
      case ClipNoDisponible():
        setState(() => _estado = _Estado.noDisponible);
      case ClipNoSeBaja():
        setState(() => _estado = _Estado.noSeBaja);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final payload = EventosRepositorio.payloadDe(widget.clip.clip);
    final meta = MetaClip.dePayload(payload);
    final foto = payload['tipo'] == 'foto' || (meta?.esFoto ?? false);
    final omitido = payload['omitido'] != null;
    final noDisponible = _estado == _Estado.noDisponible;

    String? subtitulo = widget.clip.toma.nombreParaPersona;
    if (omitido) {
      subtitulo = l.hoyClipOmitido;
    } else if (noDisponible) {
      subtitulo = foto ? l.hoyFotoNoDisponible : l.hoyVideoNoDisponible;
    } else if (_estado == _Estado.noSeBaja) {
      subtitulo = l.hoyClipNoSeBaja;
    }

    final porcentaje = (_progreso * 100).round();
    final bajando = _estado == _Estado.bajando;
    final sePuedeVer = meta != null && !noDisponible;
    return FilaLista(
      leading: IconoCuadrado(
        foto ? CupertinoIcons.camera_fill : CupertinoIcons.videocam_fill,
        redondo: true,
        fondo: c.azulClaro,
        color: c.azulSobreTinte,
      ),
      titulo: widget.titulo,
      subtitulo: subtitulo,
      detalle: !sePuedeVer
          ? null
          : bajando
          ? l.hoyClipBajando(porcentaje)
          : (foto ? l.hoyVerFoto : l.hoyVerVideo),
      trailing: bajando
          ? Semantics(
              label: l.hoyClipBajandoSemantica(porcentaje),
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  value: _progreso > 0 ? _progreso : null,
                ),
              ),
            )
          : null,
      conChevron: sePuedeVer && !bajando,
      onTap: sePuedeVer && !bajando ? () => _ver(meta) : null,
    );
  }
}

/// El vídeo o la foto a pantalla completa, sobre negro.
class VisorClipPantalla extends ConsumerWidget {
  const VisorClipPantalla({
    super.key,
    required this.titulo,
    required this.ruta,
    required this.mime,
  });

  final String titulo;

  /// Ruta absoluta del clip ya descifrado.
  final String ruta;
  final String mime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final visor = ref.watch(visorClipProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(titulo, style: const TextStyle(fontSize: 17)),
        leading: IconButton(
          tooltip: l.visorCerrar,
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: visor.construir(context, ruta: ruta, mime: mime),
      ),
    );
  }
}
