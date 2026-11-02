import 'dart:convert';
import 'dart:typed_data';

import '../db/base_datos.dart';

/// Lo que va dentro de un sobre: una fila de `eventos` tal cual, en JSON.
///
/// Se rellena con espacios hasta un múltiplo de [bloque] bytes para que el
/// tamaño del sobre no delate el tipo de evento (JSON admite espacios al
/// final). El formato es propio y explícito: no depende de los nombres que
/// genere drift.
abstract final class EventoEnSobre {
  static const formato = 1;
  static const bloque = 256;

  static Uint8List codificar(Evento e) {
    final json = utf8.encode(
      jsonEncode({
        'f': formato,
        'ulid': e.ulid,
        'circuloId': e.circuloId,
        'autor': e.autor,
        'dispositivo': e.dispositivo,
        'tipo': e.tipo,
        'sujeto': e.sujeto,
        'ocurridoEn': e.ocurridoEn,
        'registradoEn': e.registradoEn,
        'payload': e.payload,
        'corrigeA': e.corrigeA,
      }),
    );
    final total = (json.length ~/ bloque + 1) * bloque;
    return Uint8List(total)
      ..setAll(0, json)
      ..fillRange(json.length, total, 0x20);
  }

  /// La fila, o nulo si no es un evento de un formato conocido.
  static Evento? decodificar(List<int> bytes) {
    try {
      final d = jsonDecode(utf8.decode(bytes));
      if (d is! Map<String, dynamic> || d['f'] != formato) return null;
      return Evento(
        ulid: d['ulid'] as String,
        circuloId: d['circuloId'] as String,
        autor: d['autor'] as String,
        dispositivo: d['dispositivo'] as String,
        tipo: d['tipo'] as String,
        sujeto: d['sujeto'] as String?,
        ocurridoEn: d['ocurridoEn'] as int,
        registradoEn: d['registradoEn'] as int,
        payload: d['payload'] as String,
        corrigeA: d['corrigeA'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
