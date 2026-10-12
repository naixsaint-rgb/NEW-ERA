import 'dart:convert';
import 'dart:io';

/// Un texto con su archivo y su línea.
class TextoEnArchivo {
  const TextoEnArchivo(this.archivo, this.linea, this.texto);

  final String archivo;
  final int linea;
  final String texto;
}

/// Quita comentarios y devuelve los literales de cadena de un archivo Dart.
///
/// Un analizador sencillo: entiende `'..'`, `".."`, `'''..'''`, `""".."""`,
/// cadenas crudas (`r'..'`) y escapes. Basta para revisar textos.
List<TextoEnArchivo> literalesDart(String archivo, String fuente) {
  final r = <TextoEnArchivo>[];
  var i = 0;
  var linea = 1;
  final n = fuente.length;
  while (i < n) {
    final c = fuente[i];
    if (c == '\n') {
      linea++;
      i++;
    } else if (c == '/' && i + 1 < n && fuente[i + 1] == '/') {
      while (i < n && fuente[i] != '\n') {
        i++;
      }
    } else if (c == '/' && i + 1 < n && fuente[i + 1] == '*') {
      i += 2;
      while (i + 1 < n && !(fuente[i] == '*' && fuente[i + 1] == '/')) {
        if (fuente[i] == '\n') linea++;
        i++;
      }
      i += 2;
    } else if (c == "'" || c == '"') {
      final crudo = i > 0 && fuente[i - 1] == 'r';
      final triple = i + 2 < n && fuente[i + 1] == c && fuente[i + 2] == c;
      final comilla = triple ? c * 3 : c;
      final inicio = linea;
      i += comilla.length;
      final sb = StringBuffer();
      while (i < n) {
        if (!crudo && fuente[i] == r'\') {
          if (i + 1 < n && fuente[i + 1] == '\n') linea++;
          sb.write(i + 1 < n ? fuente[i + 1] : '');
          i += 2;
          continue;
        }
        if (fuente.startsWith(comilla, i)) {
          i += comilla.length;
          break;
        }
        if (fuente[i] == '\n') {
          if (!triple) break;
          linea++;
        }
        sb.write(fuente[i]);
        i++;
      }
      r.add(TextoEnArchivo(archivo, inicio, sb.toString()));
    } else {
      i++;
    }
  }
  return r;
}

/// Quita los comentarios de un archivo Dart y conserva el resto, con sus líneas.
String sinComentariosDart(String fuente) {
  final sb = StringBuffer();
  var i = 0;
  final n = fuente.length;
  String? comilla;
  while (i < n) {
    final c = fuente[i];
    if (comilla != null) {
      sb.write(c);
      if (c == r'\' && i + 1 < n) {
        sb.write(fuente[i + 1]);
        i += 2;
        continue;
      }
      if (fuente.startsWith(comilla, i) && comilla.length == 1) {
        comilla = null;
      } else if (comilla.length == 3 && fuente.startsWith(comilla, i)) {
        sb.write(fuente.substring(i + 1, i + 3));
        i += 3;
        comilla = null;
        continue;
      }
      i++;
      continue;
    }
    if (c == '/' && i + 1 < n && fuente[i + 1] == '/') {
      while (i < n && fuente[i] != '\n') {
        i++;
      }
    } else if (c == '/' && i + 1 < n && fuente[i + 1] == '*') {
      i += 2;
      while (i + 1 < n && !(fuente[i] == '*' && fuente[i + 1] == '/')) {
        if (fuente[i] == '\n') sb.write('\n');
        i++;
      }
      i += 2;
    } else if (c == "'" || c == '"') {
      final triple = i + 2 < n && fuente[i + 1] == c && fuente[i + 2] == c;
      comilla = triple ? c * 3 : c;
      sb.write(comilla);
      i += comilla.length;
    } else {
      sb.write(c);
      i++;
    }
  }
  return sb.toString();
}

/// Valores de un `.arb` con su línea (se ignoran las claves que empiezan por `@`).
List<TextoEnArchivo> valoresArb(String archivo, String contenido) {
  final json = jsonDecode(contenido) as Map<String, dynamic>;
  final lineas = const LineSplitter().convert(contenido);
  final r = <TextoEnArchivo>[];
  for (final e in json.entries) {
    if (e.key.startsWith('@') || e.value is! String) continue;
    final idx = lineas.indexWhere((l) => l.contains('"${e.key}"'));
    r.add(TextoEnArchivo(archivo, idx < 0 ? 0 : idx + 1, e.value as String));
  }
  return r;
}

/// Archivos bajo [raiz] cuyo nombre cumple [filtro].
List<File> archivosBajo(String raiz, bool Function(String ruta) filtro) {
  final dir = Directory(raiz);
  if (!dir.existsSync()) return const [];
  return [
    for (final e in dir.listSync(recursive: true, followLinks: false))
      if (e is File && filtro(e.path.replaceAll(r'\', '/'))) e,
  ]..sort((a, b) => a.path.compareTo(b.path));
}
