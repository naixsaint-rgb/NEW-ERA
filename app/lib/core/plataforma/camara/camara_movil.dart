import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safety_core/safety_core.dart';

import 'archivos_clip.dart';
import 'camara_comprobacion.dart';

/// Cámara frontal en Android e iOS. Los vídeos van a `clips/<tomaId>.mp4`
/// dentro de [ArchivosClip] (documentos de la app, almacenamiento privado);
/// de ahí los cifra y los sube el cartero (`ClipsCartero`) y después se
/// borran.
///
/// Peso: 15 fps, ~500 kbps, resolución media (~480p) y sin audio. 10 s a
/// 500 kbps son unos 625 KB (con ffmpeg y vídeo sintético, ~640 KB: 10
/// trozos de 64 KiB). Sin medir aún con la cámara de un móvil.
class CamaraMovil implements CamaraComprobacion {
  const CamaraMovil(this.archivos);

  final ArchivosClip archivos;

  static const fps = 15;
  static const bitsPorSegundo = 500000;

  @override
  Future<(SesionCamara?, MotivoClipFallido?)> abrir() async {
    final permiso = await Permission.camera.request();
    if (!permiso.isGranted) return (null, MotivoClipFallido.permiso);
    try {
      final camaras = await availableCameras();
      if (camaras.isEmpty) return (null, MotivoClipFallido.noDisponible);
      final frontal = camaras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => camaras.first,
      );
      final controlador = CameraController(
        frontal,
        ResolutionPreset.medium,
        enableAudio: false,
        fps: fps,
        videoBitrate: bitsPorSegundo,
      );
      await controlador.initialize();
      return (_SesionMovil(controlador, archivos), null);
    } catch (_) {
      return (null, MotivoClipFallido.error);
    }
  }
}

class _SesionMovil implements SesionCamara {
  _SesionMovil(this.controlador, this.archivos);

  final CameraController controlador;
  final ArchivosClip archivos;

  @override
  Widget vistaPrevia(BuildContext context) => CameraPreview(controlador);

  @override
  Future<ResultadoCamara> grabar({
    required String tomaId,
    required TipoComprobacion tipo,
    required int segundos,
    required ValueChanged<int> restante,
  }) async {
    try {
      final cronometro = Stopwatch()..start();
      if (tipo == TipoComprobacion.foto) {
        for (var i = 3; i > 0; i--) {
          restante(i);
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        final foto = await controlador.takePicture();
        final destino = RutasClip.de(tomaId, 'jpg');
        await _mover(foto.path, await archivos.prepararEscritura(destino));
        return ClipGrabado(
          tipo: tipo,
          ruta: destino,
          duracionMs: cronometro.elapsedMilliseconds,
        );
      }
      await controlador.startVideoRecording();
      for (var i = segundos; i > 0; i--) {
        restante(i);
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      final video = await controlador.stopVideoRecording();
      final destino = RutasClip.de(tomaId, 'mp4');
      await _mover(video.path, await archivos.prepararEscritura(destino));
      return ClipGrabado(
        tipo: tipo,
        ruta: destino,
        duracionMs: cronometro.elapsedMilliseconds,
      );
    } catch (_) {
      return const ClipFallido(MotivoClipFallido.error);
    }
  }

  /// Copia el archivo temporal de la cámara a su sitio y borra el original:
  /// que no quede una copia del clip en la caché.
  static Future<void> _mover(String origen, String destino) async {
    final archivo = File(origen);
    await archivo.copy(destino);
    try {
      await archivo.delete();
    } catch (_) {
      // Si no se deja borrar, lo limpiará el sistema con la caché.
    }
  }

  @override
  Future<void> cerrar() => controlador.dispose();
}
