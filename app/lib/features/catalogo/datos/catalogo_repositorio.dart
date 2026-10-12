import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dominio/modelo.dart';

/// El catálogo no coincide con su índice.
final class CatalogoInvalido implements Exception {
  const CatalogoInvalido(this.motivo);

  final String motivo;

  @override
  String toString() => 'CatalogoInvalido($motivo)';
}

/// Carga `catalogo.json` e `indice.json` de los assets y comprueba el sha.
class CatalogoRepositorio {
  const CatalogoRepositorio({
    this.rutaCatalogo = 'assets/catalogo/catalogo.json',
    this.rutaIndice = 'assets/catalogo/indice.json',
  });

  final String rutaCatalogo;
  final String rutaIndice;

  Future<Catalogo> cargar([AssetBundle? bundle]) async {
    final origen = bundle ?? rootBundle;
    final bytes = (await origen.load(rutaCatalogo)).buffer.asUint8List();
    final indiceTexto = await origen.loadString(rutaIndice);
    final indice = IndiceCatalogo.desdeJson(
      jsonDecode(indiceTexto) as Map<String, dynamic>,
    );

    final sha = sha256.convert(bytes).toString();
    if (sha != indice.catalogoSha256) {
      throw CatalogoInvalido('sha256 distinto: $sha');
    }
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final columnas = [
      for (final c in json['columnas'] as List<dynamic>) c as String,
    ];
    final posiciones = {
      for (var i = 0; i < columnas.length; i++) columnas[i]: i,
    };
    final temas = [
      for (final t in json['temas'] as List<dynamic>)
        TemaCatalogo.desdeJson(
          Map<String, dynamic>.from(t as Map<dynamic, dynamic>),
        ),
    ];
    final filas = [
      for (final f in json['filas'] as List<dynamic>)
        FilaCatalogo.desdeArray(
          f as List<dynamic>,
          posiciones,
          (i) => temas[i].key,
        ),
    ];
    if (filas.length != indice.totalFilas) {
      throw CatalogoInvalido(
        'filas ${filas.length} distinto de ${indice.totalFilas}',
      );
    }
    return Catalogo(
      esquema: json['esquema'] as int,
      fuenteSha256: json['fuente_sha256'] as String,
      columnas: columnas,
      temas: temas,
      filas: filas,
      indice: indice,
    );
  }
}

/// El catálogo cargado (sustituible en tests).
final catalogoProvider = FutureProvider<Catalogo>(
  (ref) => const CatalogoRepositorio().cargar(),
);
