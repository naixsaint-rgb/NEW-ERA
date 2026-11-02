import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/sync/config_sync.dart';
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
    expect(r.rechazados, [sobre.ulid]);
    expect(await t.recibidos().toList(), isEmpty);
    await t.desconectar();
  });

  test('SupabaseTransport: sin configuración válida no conecta', () async {
    for (final config in const [
      ConfigSync(),
      ConfigSync(url: 'https://x.supabase.co'),
      ConfigSync(url: 'http://x.supabase.co', claveAnonima: 'anon'),
      ConfigSync(url: 'no es una url', claveAnonima: 'anon'),
    ]) {
      final t = SupabaseTransport(
        config: config,
        circuloId: 'c1',
        circuloToken: () async => 'a' * 64,
      );
      await t.conectar();
      expect(t.estado, EstadoTransporte.sinConfigurar, reason: config.url);
      final r = await t.enviar([sobre]);
      expect(r.aceptados, isEmpty);
      expect(await t.recibidos().toList(), isEmpty);
      await t.desconectar();
    }
  });

  test('SupabaseTransport: sin token del círculo no conecta', () async {
    final t = SupabaseTransport(
      config: const ConfigSync(
        url: 'https://ejemplo.supabase.co',
        claveAnonima: 'anon',
      ),
      circuloId: 'c1',
      circuloToken: () async => null,
    );
    await t.conectar();
    expect(t.estado, EstadoTransporte.sinConfigurar);
  });
}
