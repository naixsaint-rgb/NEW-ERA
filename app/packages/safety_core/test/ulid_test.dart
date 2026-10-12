import 'dart:math';

import 'package:safety_core/safety_core.dart';
import 'package:test/test.dart';

void main() {
  final azar = Random(42);

  test('26 caracteres Crockford', () {
    final u = Ulid.generar(RelojFijo(DateTime.utc(2026, 10, 13)), azar);
    expect(u, hasLength(26));
    expect(RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$').hasMatch(u), isTrue);
  });

  test('guarda el instante en los 48 bits de tiempo', () {
    final t = DateTime.utc(2026, 10, 13, 9, 30);
    final u = Ulid.generar(RelojFijo(t), azar);
    expect(Ulid.tiempoDe(u), t.millisecondsSinceEpoch);
  });

  test('monótono dentro del mismo milisegundo', () {
    final reloj = RelojFijo(DateTime.utc(2027, 1, 1));
    final lista = [for (var i = 0; i < 200; i++) Ulid.generar(reloj, azar)];
    final ordenada = List<String>.of(lista)..sort();
    expect(lista, ordenada);
    expect(lista.toSet(), hasLength(200));
  });

  test('crece con el tiempo', () {
    final reloj = RelojFijo(DateTime.utc(2028, 1, 1));
    final a = Ulid.generar(reloj, azar);
    reloj.avanzar(const Duration(milliseconds: 1));
    final b = Ulid.generar(reloj, azar);
    expect(a.compareTo(b), lessThan(0));
  });
}
