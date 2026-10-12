import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/db/repositorios/circulo_repositorio.dart';

/// Elige o hace una foto reducida (`maxWidth: 1280`, `imageQuality: 80`).
typedef SelectorFoto = Future<FotoNueva?> Function(ImageSource fuente);

final selectorFotoProvider = Provider<SelectorFoto>((ref) {
  final selector = ImagePicker();
  return (fuente) async {
    final archivo = await selector.pickImage(
      source: fuente,
      maxWidth: 1280,
      imageQuality: 80,
    );
    if (archivo == null) return null;
    return FotoNueva(
      await archivo.readAsBytes(),
      mime: archivo.mimeType ?? 'image/jpeg',
    );
  };
});
