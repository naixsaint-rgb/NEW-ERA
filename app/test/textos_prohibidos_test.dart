import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'utiles/lector_textos.dart';

/// Palabras prohibidas en la app y en la tienda (sección 10).
const _alternativas = [
  'cura|curas|curan|curar|curación|curaciones',
  'revierte|revierten|revertir',
  'trata|tratan|tratar',
  'funciona|funcionan',
  r'milagro\w*',
  'sustituye a|sustituyen a',
  r'sin necesidad de (un )?médico',
  'natural|naturales',
];

final RegExp prohibidas = RegExp(
  r'(?<![\p{L}\p{N}])(?:' + _alternativas.join('|') + r')(?![\p{L}\p{N}])',
  unicode: true,
  caseSensitive: false,
);

/// Palabras prohibidas encontradas en [texto].
List<String> buscarProhibidas(String texto) => [
  for (final m in prohibidas.allMatches(texto)) m.group(0)!,
];

void main() {
  group('control del detector', () {
    test('positivo: encuentra las palabras prohibidas', () {
      for (final frase in [
        'Esto cura la memoria',
        'Un MILAGRO',
        'milagrosa',
        'No funciona',
        'Lo trata un médico',
        'Sin necesidad de médico',
        'sin necesidad de un médico',
        'Esto sustituye a la medicación',
        'Es natural',
        'Productos naturales',
        'Se revierte con tiempo.',
        'La CURACIÓN llega',
      ]) {
        expect(buscarProhibidas(frase), isNotEmpty, reason: frase);
      }
    });

    test('negativo: no salta con palabras parecidas', () {
      for (final frase in [
        'tratamiento',
        'La función del reloj',
        'naturaleza',
        'secura',
        'estructura',
        'Funcionamiento',
        'Hola, ¿qué tal?',
      ]) {
        expect(buscarProhibidas(frase), isEmpty, reason: frase);
      }
    });
  });

  test('ningún texto de la app o de la tienda usa palabras prohibidas', () {
    final fallos = <String>[];
    var revisados = 0;

    void revisar(Iterable<TextoEnArchivo> textos) {
      for (final t in textos) {
        revisados++;
        for (final palabra in buscarProhibidas(t.texto)) {
          fallos.add('${t.archivo}:${t.linea} -> "$palabra"');
        }
      }
    }

    for (final f in archivosBajo('lib', (r) => r.endsWith('.arb'))) {
      revisar(valoresArb(f.path, f.readAsStringSync()));
    }
    for (final f in archivosBajo('lib', (r) => r.endsWith('.dart'))) {
      revisar(literalesDart(f.path, f.readAsStringSync()));
    }
    final planos = [
      ...archivosBajo(
        'ios',
        (r) => r.endsWith('/Info.plist') || r.endsWith('.strings'),
      ),
      ...archivosBajo('android', (r) => r.endsWith('strings.xml')),
      ...archivosBajo('store', (r) => r.endsWith('.txt')),
    ];
    for (final f in planos) {
      final lineas = const LineSplitter().convert(f.readAsStringSync());
      for (var i = 0; i < lineas.length; i++) {
        for (final palabra in buscarProhibidas(lineas[i])) {
          fallos.add('${f.path}:${i + 1} -> "$palabra"');
        }
      }
    }
    expect(Directory('store/es-ES').existsSync(), isTrue);
    expect(
      revisados,
      greaterThan(200),
      reason: 'el revisor no ha leído los textos',
    );
    expect(fallos, isEmpty, reason: fallos.join('\n'));
  });
}
