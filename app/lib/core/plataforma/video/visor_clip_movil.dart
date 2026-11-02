import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../l10n/app_localizations.dart';
import 'visor_clip.dart';

/// Vídeo con `video_player` (sin sonido: se graba sin audio) y foto con
/// `Image.file`. El vídeo empieza solo; un toque lo para o lo sigue.
class VisorClipMovil implements VisorClip {
  const VisorClipMovil();

  @override
  Widget construir(
    BuildContext context, {
    required String ruta,
    required String mime,
  }) {
    if (mime.startsWith('image/')) {
      return InteractiveViewer(
        child: Center(
          child: Image.file(
            File(ruta),
            fit: BoxFit.contain,
            errorBuilder: (context, _, _) => const _NoSeAbre(),
          ),
        ),
      );
    }
    return _VideoClip(ruta: ruta);
  }
}

class _VideoClip extends StatefulWidget {
  const _VideoClip({required this.ruta});

  final String ruta;

  @override
  State<_VideoClip> createState() => _VideoClipState();
}

class _VideoClipState extends State<_VideoClip> {
  late final VideoPlayerController _control = VideoPlayerController.file(
    File(widget.ruta),
  );
  bool _listo = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _abrir();
  }

  Future<void> _abrir() async {
    try {
      await _control.initialize();
      if (!mounted) return;
      setState(() => _listo = true);
      await _control.play();
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  void _alternar() {
    final v = _control.value;
    if (v.isPlaying) {
      _control.pause();
    } else {
      if (v.position >= v.duration) _control.seekTo(Duration.zero);
      _control.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return const _NoSeAbre();
    if (!_listo) return const Center(child: CircularProgressIndicator());
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _control.value.aspectRatio,
              child: GestureDetector(
                onTap: _alternar,
                child: VideoPlayer(_control),
              ),
            ),
          ),
        ),
        VideoProgressIndicator(_control, allowScrubbing: true),
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _control,
          builder: (context, v, _) => IconButton(
            iconSize: 44,
            color: Colors.white,
            tooltip: v.isPlaying ? l.visorPausar : l.visorReproducir,
            icon: Icon(
              v.isPlaying
                  ? CupertinoIcons.pause_circle_fill
                  : CupertinoIcons.play_circle_fill,
            ),
            onPressed: _alternar,
          ),
        ),
      ],
    );
  }
}

class _NoSeAbre extends StatelessWidget {
  const _NoSeAbre();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        AppLocalizations.of(context).visorClipNoSeAbre,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 17, color: Colors.white),
      ),
    ),
  );
}
