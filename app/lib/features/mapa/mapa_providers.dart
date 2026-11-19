import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'constructor_mapa.dart';
import 'gestor_mapas.dart';
import 'vista_mapa.dart';

/// Gestor de mapas en `Documentos/mapas/`; nulo en la web (no se guardan
/// mapas en el navegador).
final gestorMapasProvider = Provider<GestorMapas?>((ref) {
  if (kIsWeb) return null;
  return GestorMapas(
    carpeta: () async =>
        Directory('${(await getApplicationDocumentsDirectory()).path}/mapas'),
    cliente: http.Client.new,
  );
});

/// El mapa guardado en este móvil, o nulo.
final mapaInstaladoProvider = FutureProvider<MapaInstalado?>((ref) async {
  final g = ref.watch(gestorMapasProvider);
  if (g == null) return null;
  try {
    return await g.instalado();
  } catch (_) {
    return null;
  }
});

/// Cómo se dibuja el mapa; nulo sin mapa (web).
final constructorMapaProvider = Provider<ConstructorMapa?>(
  (ref) => crearConstructorMapa(),
);
