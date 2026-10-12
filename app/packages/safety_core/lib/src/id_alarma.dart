import 'dart:convert';

/// Id numérico estable para una alarma: FNV-1a de 32 bits sobre UTF-8,
/// `& 0x7fffffff`. Evita desbordar en web (sin multiplicaciones por encima
/// de 2^53).
int idAlarmaNumerico(String idToma) {
  var h = 0x811c9dc5;
  for (final b in utf8.encode(idToma)) {
    h = (h ^ b) % 4294967296;
    // h * 0x01000193 (mod 2^32) = (h * 2^24 + h * 0x193) mod 2^32
    h = (((h & 0xff) * 16777216) + h * 0x193) % 4294967296;
  }
  return h & 0x7fffffff;
}
