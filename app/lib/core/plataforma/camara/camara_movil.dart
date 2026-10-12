import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safety_core/safety_core.dart';

import 'camara_comprobacion.dart';

/// Cámara frontal en Android e iOS. Los vídeos van a
/// `<documentos>/clips/<tomaId>.mp4`, en el almacenamiento privado de la app
/// (el cifrado de clips llega en la semana 3).
class CamaraMovil implements CamaraComprobacion {
  const CamaraMovil();

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
      );
      await controlador.initialize();
      return (_SesionMovil(controlador), null);
    } catch (_) {
      return (null, MotivoClipFallido.error);
    }
  }
}

class _SesionMovil implements SesionCamara {
  _SesionMovil(this.controlador);

  final CameraController controlador;

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
      final docs = await getApplicationDocumentsDirectory();
      final carpeta = Directory(p.join(docs.path, 'clips'));
      await carpeta.create(recursive: true);
      final cronometro = Stopwatch()..start();
      if (tipo == TipoComprobacion.foto) {
        for (var i = 3; i > 0; i--) {
          restante(i);
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        final foto = await controlador.takePicture();
        final destino = p.join(carpeta.path, '$tomaId.jpg');
        await _mover(foto.path, destino);
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
      final destino = p.join(carpeta.path, '$tomaId.mp4');
      await _mover(video.path, destino);
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
