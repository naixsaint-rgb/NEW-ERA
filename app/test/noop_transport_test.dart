import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/sync/noop_transport.dart';
import 'package:newera/core/sync/sobre_cifrado.dart';
import 'package:newera/core/sync/supabase_transport.dart';
import 'package:newera/core/sync/sync_transport.dart';

void main() {
  final sobre = SobreCifrado(
    ulid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
    circuloId: 'c1',
    versionClave: 1,
    nonce: Uint8List(12),
    contenido: Uint8List(4),
  );

  test('NoopTransport: siempre desconectado y sin aceptar nada', () async {
    const t = NoopTransport();
    expect(t.estado, EstadoTransporte.desconectado);
    await t.conectar();
    expect(t.estado, EstadoTransporte.desconectado);
    final r = await t.enviar([sobre]);
    expect(r.aceptados, isEmpty);
    expect(await t.recibidos().toList(), isEmpty);
    await t.desconectar();
  });

  test('SupabaseTransport: esqueleto sin configurar', () {
    const t = SupabaseTransport('https://ejemplo.invalid', 'sin-clave');
    expect(t.estado, EstadoTransporte.sinConfigurar);
    expect(t.conectar, throwsUnimplementedError);
  });
}
