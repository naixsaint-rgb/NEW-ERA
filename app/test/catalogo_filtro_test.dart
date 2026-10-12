import 'package:flutter_test/flutter_test.dart';
import 'package:newera/features/catalogo/datos/catalogo_repositorio.dart';
import 'package:newera/features/catalogo/dominio/filtro.dart';
import 'package:newera/features/catalogo/dominio/modelo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Catalogo c;

  setUpAll(() async {
    c = await const CatalogoRepositorio().cargar();
  });

  test('un filtro vacío no filtra', () {
    expect(
      filtrarFilas(c.filas, const FiltroCatalogo()).length,
      c.filas.length,
    );
  });

  test('nutricion_alimentos da su n_filas', () {
    final r = filtrarFilas(
      c.filas,
      const FiltroCatalogo(temas: {'nutricion_alimentos'}),
    );
    final esperado = c.indice.temas
        .firstWhere((t) => t.key == 'nutricion_alimentos')
        .nFilas;
    expect(r.length, esperado);
  });

  test('mejora da su por_direccion', () {
    final r = filtrarFilas(
      c.filas,
      const FiltroCatalogo(direcciones: {'mejora'}),
    );
    expect(r.length, c.indice.porDireccion['mejora']);
  });

  test('"o" dentro de un campo y "y" entre campos', () {
    final o = filtrarFilas(
      c.filas,
      const FiltroCatalogo(direcciones: {'mejora', 'empeora'}),
    );
    expect(
      o.length,
      c.indice.porDireccion['mejora']! + c.indice.porDireccion['empeora']!,
    );
    final y = filtrarFilas(
      c.filas,
      const FiltroCatalogo(
        temas: {'nutricion_alimentos'},
        direcciones: {'mejora'},
      ),
    );
    expect(
      y.every(
        (f) =>
            f.temaKey == 'nutricion_alimentos' &&
            f.direccionSegunLaFuente == 'mejora',
      ),
      isTrue,
    );
    expect(y.length, lessThan(o.length));
  });

  test('"mind" encuentra la dieta MIND sin importar mayúsculas ni tildes', () {
    final a = filtrarFilas(c.filas, const FiltroCatalogo(texto: 'mind'));
    final b = filtrarFilas(c.filas, const FiltroCatalogo(texto: 'MIND'));
    final d = filtrarFilas(c.filas, const FiltroCatalogo(texto: 'mínd'));
    expect(a, isNotEmpty);
    expect(b.length, a.length);
    expect(d.length, a.length);
    expect(a.any((f) => (f.grupo ?? '').contains('MIND')), isTrue);
  });

  test('las tildes del texto buscado y del dato no importan', () {
    final conTilde = filtrarFilas(
      c.filas,
      const FiltroCatalogo(texto: 'población'),
    );
    final sinTilde = filtrarFilas(
      c.filas,
      const FiltroCatalogo(texto: 'POBLACION'),
    );
    expect(conTilde, isNotEmpty);
    expect(sinTilde.length, conTilde.length);
  });

  test('el grupo filtra por coincidencia exacta', () {
    final g = c.indice.grupos.first;
    final r = filtrarFilas(
      c.filas,
      FiltroCatalogo(temas: {g.tema}, grupo: g.grupo),
    );
    expect(r.length, g.n);
  });

  test('normalizarTexto quita mayúsculas y tildes', () {
    expect(
      normalizarTexto('Dieta MEDITERRÁNEA, niño'),
      'dieta mediterranea, nino',
    );
  });
}
