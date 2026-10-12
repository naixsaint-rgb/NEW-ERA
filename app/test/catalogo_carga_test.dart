import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/features/catalogo/datos/catalogo_repositorio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el sha256 del catálogo coincide con el del índice', () async {
    final bytes = File('assets/catalogo/catalogo.json').readAsBytesSync();
    final indice = jsonDecode(
      File('assets/catalogo/indice.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(sha256.convert(bytes).toString(), indice['catalogo_sha256']);
  });

  test('filas y temas coinciden con el índice', () async {
    final c = await const CatalogoRepositorio().cargar();
    expect(c.filas.length, c.indice.totalFilas);
    expect(c.temas.length, c.indice.temas.length);
    for (var i = 0; i < c.temas.length; i++) {
      expect(c.temas[i].key, c.indice.temas[i].key);
      expect(c.temas[i].nFilas, c.indice.temas[i].nFilas);
      final delTema = c.filas.where((f) => f.temaKey == c.temas[i].key).length;
      expect(delTema, c.temas[i].nFilas, reason: c.temas[i].key);
    }
    final porDireccion = <String, int>{};
    for (final f in c.filas) {
      porDireccion.update(
        f.direccionSegunLaFuente!,
        (n) => n + 1,
        ifAbsent: () => 1,
      );
    }
    expect(porDireccion, c.indice.porDireccion);
  });

  test('todas las filas tienen enlace que empieza por http', () async {
    final c = await const CatalogoRepositorio().cargar();
    for (final f in c.filas) {
      expect(f.enlace, isNotNull, reason: f.id);
      expect(f.enlace!.startsWith('http'), isTrue, reason: f.id);
    }
  });

  test('cada tema trae sus 9 apartados de dosier', () async {
    final c = await const CatalogoRepositorio().cargar();
    for (final t in c.temas) {
      expect(t.dosier.numeroApartados, 9, reason: t.key);
    }
  });

  test('un índice que no cuadra se rechaza', () async {
    expect(
      () =>
          const CatalogoRepositorio(rutaIndice: 'assets/catalogo/catalogo.json')
              .cargar(),
      throwsA(anything),
    );
  });
}
