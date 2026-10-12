import 'package:flutter_test/flutter_test.dart';

import 'utiles/lector_textos.dart';

/// `Text('…')` o `Text("…")` con letras: todo texto sale de `AppLocalizations`.
final RegExp _textoLiteral = RegExp(
  r'''\b(?:SelectableText|Text)\(\s*(?:const\s+)?r?(?:'[^'\n]*\p{L}[^'\n]*'|"[^"\n]*\p{L}[^"\n]*")''',
  unicode: true,
);

void main() {
  test('control: el detector salta con literales y no con variables', () {
    expect(_textoLiteral.hasMatch("Text('Hola')"), isTrue);
    expect(_textoLiteral.hasMatch('const Text( "Hola" )'), isTrue);
    expect(_textoLiteral.hasMatch("Text(context.l.hola)"), isFalse);
    expect(_textoLiteral.hasMatch("Text('• ')"), isFalse);
    expect(_textoLiteral.hasMatch("Text(texto, style: t)"), isFalse);
  });

  test('en lib/ no hay Text con literales con letras', () {
    final fallos = <String>[];
    for (final f in archivosBajo('lib', (r) => r.endsWith('.dart'))) {
      if (f.path.contains('l10n/')) continue;
      final limpio = sinComentariosDart(f.readAsStringSync());
      for (final m in _textoLiteral.allMatches(limpio)) {
        final linea = '\n'.allMatches(limpio.substring(0, m.start)).length + 1;
        fallos.add('${f.path}:$linea -> ${m.group(0)}');
      }
    }
    expect(fallos, isEmpty, reason: fallos.join('\n'));
  });
}
