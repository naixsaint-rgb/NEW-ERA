import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:newera/core/sync/config_sync.dart';
import 'package:newera/core/sync/sobre_cifrado.dart';
import 'package:newera/core/sync/supabase_transport.dart';
import 'package:newera/core/sync/sync_transport.dart';

final _miToken = 'a' * 64;
final _otroToken = 'b' * 64;
const _config = ConfigSync(
  url: 'https://ejemplo.supabase.co/',
  claveAnonima: 'clave-anon-de-prueba',
);

/// PostgREST mínimo en memoria con las mismas reglas que `supabase/schema.sql`:
/// solo se ve y se deja lo del token de la cabecera, y el ulid es único.
class _PostgrestFalso {
  final filas = <Map<String, Object?>>[];
  final peticiones = <http.Request>[];
  int _id = 0;
  bool caido = false;

  void sembrar(String ulid, String token) => filas.add({
    'id': ++_id,
    'ulid': ulid,
    'circulo_token': token,
    'remitente': 'otro',
    'version_clave': 1,
    'nonce': base64Encode(Uint8List(12)),
    'contenido': base64Encode(Uint8List(32)),
  });

  Future<http.Response> responder(http.Request r) async {
    peticiones.add(r);
    if (caido) throw http.ClientException('sin_red');
    // Como las respuestas de verdad, cada una lleva su petición.
    http.Response respuesta(String cuerpo, int estado) => http.Response(
      cuerpo,
      estado,
      request: r,
      headers: {'content-type': 'application/json'},
    );
    if (r.url.path != '/rest/v1/sobres') return respuesta('', 404);
    final token = r.headers[SupabaseTransport.cabeceraToken];
    if (r.method == 'POST') {
      final lote = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
      // Un CHECK que falla tumba la sentencia entera, como en PostgreSQL.
      if (lote.any((f) => f['version_clave'] == 0)) {
        return respuesta('{"code":"23514","message":"check"}', 400);
      }
      if (lote.any((f) => f['circulo_token'] != token)) {
        return respuesta(
          '{"code":"42501","message":"row-level security"}',
          403,
        );
      }
      for (final f in lote) {
        if (!filas.any((x) => x['ulid'] == f['ulid'])) {
          filas.add({...f, 'id': ++_id});
        }
      }
      return respuesta('', 201);
    }
    final q = r.url.queryParameters;
    Iterable<Map<String, Object?>> vistas = filas.where(
      (f) => f['circulo_token'] == token,
    );
    for (final MapEntry(:key, :value) in q.entries) {
      if (const {'select', 'order', 'limit'}.contains(key)) continue;
      if (value.startsWith('eq.')) {
        vistas = vistas.where((f) => '${f[key]}' == value.substring(3));
      } else if (value.startsWith('gt.')) {
        final n = int.parse(value.substring(3));
        vistas = vistas.where((f) => (f[key] as int) > n);
      } else if (value.startsWith('in.(')) {
        final lista = [
          for (final v in value.substring(4, value.length - 1).split(','))
            v.replaceAll('"', ''),
        ];
        vistas = vistas.where((f) => lista.contains(f[key]));
      }
    }
    final orden = vistas.toList()
      ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    final limite = int.tryParse(q['limit'] ?? '') ?? orden.length;
    final columnas = q['select']!.split(',');
    return respuesta(
      jsonEncode([
        for (final f in orden.take(limite)) {for (final c in columnas) c: f[c]},
      ]),
      200,
    );
  }
}

SobreCifrado _sobre(String ulid) => SobreCifrado(
  ulid: ulid,
  circuloId: 'c1',
  versionClave: 1,
  nonce: Uint8List.fromList(List.generate(12, (i) => i)),
  contenido: Uint8List.fromList(List.generate(40, (i) => 200 - i)),
);

void main() {
  late _PostgrestFalso servidor;
  late StreamController<void> avisos;
  late SupabaseTransport t;
  late List<String> temas;

  setUp(() {
    servidor = _PostgrestFalso();
    avisos = StreamController<void>.broadcast();
    temas = [];
    t = SupabaseTransport(
      config: _config,
      circuloId: 'c1',
      remitente: 'movil-a',
      circuloToken: () async => _miToken,
      clienteHttp: MockClient(servidor.responder),
      avisos: (_, tema) {
        temas.add(tema);
        return avisos.stream;
      },
      esperaMinima: const Duration(milliseconds: 1),
      esperaMaxima: const Duration(milliseconds: 5),
      intentos: 2,
      tamLote: 2,
      sondeo: const Duration(hours: 1),
    );
  });

  tearDown(() async {
    await t.desconectar();
    await avisos.close();
  });

  test('conecta sin tocar la red', () async {
    await t.conectar();
    expect(t.estado, EstadoTransporte.conectado);
    expect(servidor.peticiones, isEmpty);
  });

  test('enviar: lote idempotente con la cabecera del círculo', () async {
    // Un ulid que ya existe en otro círculo no se puede pisar: rechazado.
    servidor.sembrar('ULIDAJENO', _otroToken);
    final r = await t.enviar([_sobre('ULID1'), _sobre('ULIDAJENO')]);
    expect(r.aceptados, ['ULID1']);
    expect(r.rechazados, ['ULIDAJENO']);

    final post = servidor.peticiones.firstWhere((p) => p.method == 'POST');
    expect(post.url.host, 'ejemplo.supabase.co');
    expect(post.headers[SupabaseTransport.cabeceraToken], _miToken);
    expect(post.headers['apikey'], _config.claveAnonima);
    expect(post.url.queryParameters['on_conflict'], 'ulid');
    expect(post.headers['Prefer'], contains('resolution=ignore-duplicates'));
    final fila = (jsonDecode(post.body) as List).first as Map<String, dynamic>;
    expect(fila.keys, {
      'ulid',
      'circulo_token',
      'remitente',
      'version_clave',
      'nonce',
      'contenido',
    });
    expect(fila['remitente'], 'movil-a');
    expect(base64Decode(fila['nonce'] as String), _sobre('x').nonce);

    // Reenviar lo mismo (respuesta perdida, reintento...) se acepta igual y
    // no duplica.
    final otra = await t.enviar([_sobre('ULID1')]);
    expect(otra.aceptados, ['ULID1']);
    expect(servidor.filas.where((f) => f['ulid'] == 'ULID1'), hasLength(1));
  });

  test('un sobre que el servidor no admite no bloquea a los demás', () async {
    final malo = SobreCifrado(
      ulid: 'ULIDMALO',
      circuloId: 'c1',
      versionClave: 0,
      nonce: Uint8List(12),
      contenido: Uint8List(40),
    );
    final r = await t.enviar([_sobre('ULID1'), malo, _sobre('ULID2')]);
    expect(r.aceptados, ['ULID1', 'ULID2']);
    expect(r.rechazados, ['ULIDMALO']);
    // Rechazo del servidor: no se reintenta, se separa. Lotes de 2:
    // [ULID1, malo] falla y va de uno en uno (1 + 2); [ULID2] entra (1).
    expect(servidor.peticiones.where((p) => p.method == 'POST'), hasLength(4));
  });

  test('enviar sin red: rechaza tras reintentar, sin lanzar', () async {
    servidor.caido = true;
    final r = await t.enviar([_sobre('ULID1')]);
    expect(r.aceptados, isEmpty);
    expect(r.rechazados, ['ULID1']);
    expect(servidor.peticiones, hasLength(2)); // intentos: 2
  });

  test('recibidos: primero lo pendiente desde el cursor y luego los avisos', () async {
    servidor
      ..sembrar('ULID1', _miToken)
      ..sembrar('AJENO', _otroToken)
      ..sembrar('ULID2', _miToken)
      ..sembrar('ULID3', _miToken);
    final llegados = <SobreCifrado>[];
    final sub = t.recibidos(desde: 1).listen(llegados.add);
    addTearDown(sub.cancel);

    await _esperarA(() => llegados.length == 2);
    expect(llegados.map((s) => s.ulid), ['ULID2', 'ULID3']);
    expect(llegados.map((s) => s.posicion), [3, 4]);
    expect(llegados.first.circuloId, 'c1');
    expect(llegados.first.nonce, Uint8List(12));
    expect(temas, [SupabaseTransport.temaAvisos(_miToken)]);
    // Lo mismo que calcula el disparador de supabase/schema.sql con
    // encode(sha256(convert_to(token, 'UTF8')), 'hex') (comprobado en
    // PostgreSQL 16).
    expect(
      temas.single,
      'aviso_ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb',
    );

    servidor.sembrar('ULID4', _miToken);
    avisos.add(null);
    await _esperarA(() => llegados.length == 3);
    expect(llegados.last.ulid, 'ULID4');
    expect(llegados.last.posicion, 5);
  });

  test('recibidos sin red: reintenta y entrega al volver', () async {
    servidor
      ..caido = true
      ..sembrar('ULID1', _miToken);
    final llegados = <SobreCifrado>[];
    final sub = t.recibidos().listen(llegados.add, onError: (_) {});
    addTearDown(sub.cancel);
    await _esperarA(() => servidor.peticiones.length >= 2);
    expect(llegados, isEmpty);
    servidor.caido = false;
    await _esperarA(() => llegados.length == 1);
  });
}

Future<void> _esperarA(bool Function() condicion) async {
  final reloj = Stopwatch()..start();
  while (!condicion()) {
    if (reloj.elapsed > const Duration(seconds: 10)) fail('tiempo agotado');
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
