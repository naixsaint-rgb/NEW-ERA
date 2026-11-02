import 'dart:typed_data';

import 'archivos_voz.dart';
import 'grabadora.dart';
import 'reproductor.dart';

/// Grabadora de la demo web y de los tests: no usa el micrófono. Al parar
/// escribe [tamano] bytes de relleno (no es audio de nadie) en la ruta.
class GrabadoraSimulada implements Grabadora {
  GrabadoraSimulada(this._archivos, {this.tamano = 2048, this.permiso = true});

  final ArchivosVoz _archivos;

  /// Bytes de cada "grabación".
  int tamano;

  /// Lo que contesta [pedirPermiso].
  bool permiso;

  /// Rutas grabadas, en orden.
  final List<String> grabadas = [];

  String? _actual;

  /// Contenido de una grabación simulada de [tamano] bytes.
  static Uint8List relleno(int tamano) {
    final marca = 'NEWERA-VOZ-SIMULADA'.codeUnits;
    return Uint8List.fromList([
      for (var i = 0; i < tamano; i++)
        i < marca.length ? marca[i] : (i * 31 + 7) % 251,
    ]);
  }

  @override
  Future<bool> pedirPermiso() async => permiso;

  @override
  Future<void> empezar(String ruta) async {
    RutasVoz.comprobar(ruta);
    _actual = ruta;
  }

  @override
  Future<String?> parar() async {
    final ruta = _actual;
    _actual = null;
    if (ruta == null) return null;
    await _archivos.escribir(ruta, relleno(tamano));
    grabadas.add(ruta);
    return ruta;
  }

  @override
  Future<void> cancelar() async => _actual = null;

  @override
  Future<void> liberar() async {}
}

/// Reproductor de la demo web y de los tests: no suena; apunta las rutas.
class ReproductorSimulado implements Reproductor {
  ReproductorSimulado();

  /// Rutas "reproducidas", en orden.
  final List<String> reproducidas = [];

  /// Veces que se llamó a [parar].
  int paradas = 0;

  @override
  Future<void> reproducir(String ruta) async => reproducidas.add(ruta);

  @override
  Future<void> parar() async => paradas++;

  @override
  Future<void> liberar() async {}
}
