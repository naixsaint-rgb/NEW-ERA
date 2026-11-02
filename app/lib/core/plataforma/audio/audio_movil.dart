import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import 'archivos_voz.dart';
import 'grabadora.dart';
import 'reproductor.dart';

/// Graba con el paquete `record`: AAC-LC mono ([FormatoVoz]) en Android e
/// iOS; en la web, Opus si el navegador lo admite y, si no, WAV (devuelve una
/// URL `blob:`). El grabador se crea al primer uso.
class GrabadoraMovil implements Grabadora {
  GrabadoraMovil(this._archivos);

  final ArchivosVoz _archivos;
  AudioRecorder? _grabador;
  String? _ruta;

  AudioRecorder get _g => _grabador ??= AudioRecorder();

  @override
  Future<bool> pedirPermiso() async {
    try {
      return await _g.hasPermission();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> empezar(String ruta) async {
    final RecordConfig config;
    if (kIsWeb) {
      final opus = await _g.isEncoderSupported(AudioEncoder.opus);
      config = RecordConfig(
        encoder: opus ? AudioEncoder.opus : AudioEncoder.wav,
        numChannels: FormatoVoz.canales,
      );
    } else {
      config = const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: FormatoVoz.bitRate,
        sampleRate: FormatoVoz.frecuencia,
        numChannels: FormatoVoz.canales,
      );
    }
    final destino = await _archivos.prepararEscritura(ruta);
    await _g.start(config, path: destino);
    _ruta = ruta;
  }

  @override
  Future<String?> parar() async {
    final ruta = _ruta;
    _ruta = null;
    try {
      final resultado = await _grabador?.stop();
      if (resultado == null || ruta == null) return null;
      if (kIsWeb) return resultado;
      return await _archivos.existe(ruta) ? ruta : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cancelar() async {
    _ruta = null;
    try {
      await _grabador?.cancel();
    } catch (_) {}
  }

  @override
  Future<void> liberar() async {
    try {
      await _grabador?.dispose();
    } catch (_) {}
    _grabador = null;
  }
}

/// Reproduce con el paquete `audioplayers` (un solo reproductor, creado al
/// primer uso). En iOS suena aunque el iPhone esté en silencio (categoría
/// `playback`, la de por defecto del paquete).
class ReproductorMovil implements Reproductor {
  ReproductorMovil(this._archivos);

  final ArchivosVoz _archivos;
  AudioPlayer? _reproductor;

  @override
  Future<void> reproducir(String ruta) async {
    try {
      final r = _reproductor ??= AudioPlayer();
      await r.stop();
      final Source fuente = ruta.startsWith('blob:')
          ? UrlSource(ruta)
          : DeviceFileSource(await _archivos.absoluta(ruta));
      await r.play(fuente);
    } catch (_) {
      // Sin audio no pasa nada: la pantalla sigue igual.
    }
  }

  @override
  Future<void> parar() async {
    try {
      await _reproductor?.stop();
    } catch (_) {}
  }

  @override
  Future<void> liberar() async {
    try {
      await _reproductor?.dispose();
    } catch (_) {}
    _reproductor = null;
  }
}
