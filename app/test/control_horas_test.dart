import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newera/core/arranque.dart';
import 'package:newera/core/contexto.dart';
import 'package:newera/core/cripto/almacen_seguro.dart';
import 'package:newera/core/cripto/clave_circulo.dart';
import 'package:newera/core/db/base_datos.dart';
import 'package:newera/core/db/repositorios/voces_repositorio.dart';
import 'package:newera/core/plataforma/alarmas/programador_alarmas.dart';
import 'package:newera/core/plataforma/alarmas/servicio_alarmas.dart';
import 'package:newera/core/plataforma/audio/audio_simulado.dart';
import 'package:newera/core/providers.dart';
import 'package:newera/core/sync/fichas.dart';
import 'package:newera/core/sync/servicio_sync.dart';
import 'package:newera/features/alarmas/control_horas_pantalla.dart';
import 'package:newera/features/hoy/dominio/control_horas.dart';
import 'package:newera/features/hoy/dominio/tomas.dart';
import 'package:newera/features/pregunta/pregunta_pantalla.dart';
import 'package:newera/shared/claves_ui.dart';
import 'package:safety_core/safety_core.dart';

import 'utiles/app_prueba.dart';
import 'utiles/base_prueba.dart';
import 'utiles/servidor_memoria.dart';

const _madrid = 'Europe/Madrid';

/// Hora de Madrid (UTC+2 en octubre de 2026) del día [dia] a UTC.
DateTime _m(int hora, [int minuto = 0, int dia = 13, int segundo = 0]) =>
    DateTime.utc(2026, 10, dia, hora - 2, minuto, segundo);

/// Hora local "HH:mm" de un instante UTC en Madrid.
String _local(DateTime utc) {
  final l = utc.add(const Duration(hours: 2));
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(l.hour)}:${dos(l.minute)}';
}

/// Alarmas de mentira: apunta cuándo y con qué audio se programa cada una.
class _Alarmas implements ServicioAlarmas {
  final fechas = <String, DateTime>{};
  final audio = <String, String?>{};
  final canceladas = <String>[];
  final _sonando = StreamController<String>.broadcast();

  void sonar(String id) => _sonando.add(id);

  @override
  Future<void> programar({
    required String idToma,
    required DateTime fecha,
    required String titulo,
    String? rutaAudio,
  }) async {
    fechas[idToma] = fecha;
    audio[idToma] = rutaAudio;
  }

  @override
  Future<bool> cancelar(String idToma) async {
    canceladas.add(idToma);
    audio.remove(idToma);
    return fechas.remove(idToma) != null;
  }

  @override
  Future<EstadoAlarmas> estado() async => EstadoAlarmas(
    disponible: true,
    autorizacion: AutorizacionAlarma.autorizada,
    programadas: [...fechas.keys],
    implementado: true,
  );

  @override
  Stream<String> sonando() => _sonando.stream;

  Iterable<String> get rondas => fechas.keys.where(esIdRonda);
}

RespuestaControl _resp(
  String ronda,
  TipoPreguntaControl tipo,
  String valor,
  DateTime cuando,
) => RespuestaControl(
  ulid: '${cuando.millisecondsSinceEpoch}${tipo.index}',
  ronda: ronda,
  tipo: tipo,
  valor: valor,
  cuando: cuando,
);

/// Control de hoy (13/10) con los valores por defecto, móvil de la persona
/// desde las 08:00 y sin tomas, visto con el reloj [reloj].
ControlDelDia _control(
  Reloj reloj, {
  List<RespuestaControl> respuestas = const [],
  AjustesControl ajustes = AjustesControl.porDefecto,
  List<DateTime> tomas = const [],
  DateTime? inicio,
}) => calcularControlDelDia(
  ajustes: ajustes,
  dia: diaLocal(_m(12), _madrid),
  zona: _madrid,
  tomas: tomas,
  respuestas: respuestas,
  ahora: reloj.ahora(),
  inicio: inicio ?? _m(8),
);

Future<void> _evento(
  EntornoPrueba e, {
  required String tipo,
  required DateTime cuando,
  String? sujeto,
  Map<String, Object?> payload = const {},
}) => e.db
    .into(e.db.eventos)
    .insert(
      EventosCompanion.insert(
        ulid: Ulid.generar(RelojFijo(cuando), Random(cuando.second + 7)),
        circuloId: e.contexto.circuloId,
        autor: e.contexto.personaId,
        dispositivo: 'movil-persona',
        tipo: tipo,
        sujeto: Value(sujeto),
        ocurridoEn: cuando.millisecondsSinceEpoch,
        registradoEn: cuando.millisecondsSinceEpoch,
        payload: Value(jsonEncode(payload)),
      ),
    );

/// El móvil de la persona eligió su perfil a [cuando].
Future<void> _movilPersona(EntornoPrueba e, DateTime cuando) => _evento(
  e,
  tipo: 'perfil_elegido',
  cuando: cuando,
  payload: const {'perfil': 'persona'},
);

/// Las tres respuestas de [ronda] desde [cuando] (con un minuto entre ellas).
Future<void> _ronda(
  EntornoPrueba e,
  String ronda,
  DateTime cuando, {
  String estado = 'bien',
  String dolor = 'nada',
  String plan = 'pasear',
}) async {
  var i = 0;
  for (final (tipo, valor) in [
    ('estado', estado),
    ('dolor', dolor),
    ('plan', plan),
  ]) {
    await _evento(
      e,
      tipo: 'pregunta_respondida',
      cuando: cuando.add(Duration(minutes: i++)),
      sujeto: ronda,
      payload: {
        'ronda': ronda,
        'tipo': tipo,
        'respuesta': valor,
        'tiempo_ms': 2000,
        'origen': 'movil',
      },
    );
  }
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    inicializarZonas();
  });

  group('rondas: franja y ritmo', () {
    List<String> horas(AjustesControl a, {List<DateTime> tomas = const []}) => [
      for (final r in rondasControl(
        ajustes: a,
        zona: _madrid,
        desde: _m(0),
        hasta: _m(0, 0, 14),
        tomas: tomas,
      ))
        _local(r.hora),
    ];

    test('por defecto: de 9 a 21 cada hora, trece rondas', () {
      final r = rondasControl(
        ajustes: AjustesControl.porDefecto,
        zona: _madrid,
        desde: _m(0),
        hasta: _m(0, 0, 14),
      );
      expect(r, hasLength(13));
      expect(r.first.id, 'ronda_20261013_0900');
      expect(r.first.hora, DateTime.utc(2026, 10, 13, 7));
      expect(r.first.horaLocal, '09:00');
      expect(r.first.fechaLocal, '2026-10-13');
      expect(r.last.id, 'ronda_20261013_2100');
      expect(r.every((x) => !x.retrasada), isTrue);
      expect(AjustesControl.porDefecto.horas, hasLength(13));
    });

    test('ritmo cada 2 y cada 3 horas, y otra franja', () {
      expect(horas(const AjustesControl(cadaHoras: 2)), [
        '09:00',
        '11:00',
        '13:00',
        '15:00',
        '17:00',
        '19:00',
        '21:00',
      ]);
      expect(horas(const AjustesControl(cadaHoras: 3)), [
        '09:00',
        '12:00',
        '15:00',
        '18:00',
        '21:00',
      ]);
      expect(horas(const AjustesControl(desde: 10, hasta: 15, cadaHoras: 2)), [
        '10:00',
        '12:00',
        '14:00',
      ]);
    });

    test('desactivado o no válido: ninguna ronda', () {
      expect(horas(const AjustesControl(activado: false)), isEmpty);
      expect(horas(const AjustesControl(desde: 21, hasta: 9)), isEmpty);
      expect(horas(const AjustesControl(cadaHoras: 4)), isEmpty);
      expect(horas(const AjustesControl(desde: 3, hasta: 9)), isEmpty);
      expect(const AjustesControl(desde: 3).valido, isFalse);
    });

    test('nunca de noche: en 48 h ninguna ronda fuera de la franja', () {
      for (final a in [
        AjustesControl.porDefecto,
        const AjustesControl(desde: 8, hasta: 22, cadaHoras: 3),
      ]) {
        final r = rondasControl(
          ajustes: a,
          zona: _madrid,
          desde: _m(21, 30),
          hasta: _m(21, 30, 15),
          tomas: [_m(22, 0, 13), _m(9, 0, 14), _m(22, 0, 14)],
        );
        expect(r, isNotEmpty);
        for (final x in r) {
          final local = x.hora.add(const Duration(hours: 2));
          final minutos = local.hour * 60 + local.minute;
          expect(minutos, greaterThanOrEqualTo(a.desde * 60), reason: '$x');
          expect(minutos, lessThanOrEqualTo(a.hasta * 60), reason: '$x');
        }
      }
    });

    test('una toma cerca retrasa la ronda 15 minutos', () {
      final r = horas(
        AjustesControl.porDefecto,
        tomas: [
          _m(9), // a la misma hora
          _m(11, 50), // 10 min antes de las 12
          _m(14, 10), // 10 min después de las 14 y 5 antes de las 14:15
          _m(16, 20), // a 20 min: no retrasa
          _m(21), // la última: ya no cabe en la franja
        ],
      );
      expect(r, [
        '09:15',
        '10:00',
        '11:00',
        '12:15',
        '13:00',
        '14:30',
        '15:00',
        '16:00',
        '17:00',
        '18:00',
        '19:00',
        '20:00',
      ]);
      expect(horaConRetraso(_m(9), [_m(8, 50)]), _m(9, 15));
      expect(horaConRetraso(_m(9), [_m(8, 45)]), _m(9));
    });

    test('activoDesde: las de antes no cuentan; la siguiente, estricta', () {
      final a = AjustesControl(activoDesde: _m(15, 30));
      expect(horas(a).first, '16:00');
      final s = siguienteRonda(
        ajustes: AjustesControl.porDefecto,
        zona: _madrid,
        ahora: _m(12),
      );
      expect(s?.id, 'ronda_20261013_1300');
      final noche = siguienteRonda(
        ajustes: AjustesControl.porDefecto,
        zona: _madrid,
        ahora: _m(21, 30),
      );
      expect(noche?.id, 'ronda_20261014_0900');
      expect(esIdRonda('ronda_20261013_0900'), isTrue);
      expect(esIdRonda('2c9a_20261013_0900'), isFalse);
    });
  });

  group('sin respuesta (lo deduce la familia, reloj inyectado)', () {
    test('a los 10 minutos sin respuesta, aunque el móvil esté apagado', () {
      final reloj = RelojFijo(_m(10, 10));
      var c = _control(reloj);
      final diez = c.rondas.firstWhere((r) => r.ronda.horaLocal == '10:00');
      expect(diez.estado, EstadoRonda.enEspera);
      expect(c.rondas.last.estado, EstadoRonda.porLlegar);
      // Las de las 09:00 pasaron hace más de 10 min: sin respuesta.
      expect(c.sinRespuesta.map((r) => r.ronda.id), ['ronda_20261013_0900']);

      reloj.fijar(_m(10, 10, 13, 1));
      c = _control(reloj);
      expect(c.sinRespuesta.map((r) => r.ronda.id), [
        'ronda_20261013_0900',
        'ronda_20261013_1000',
      ]);
      expect(c.dosSeguidasSinRespuesta, isTrue);
    });

    test('contestada con una sola respuesta; las de otro día no cuentan', () {
      final reloj = RelojFijo(_m(12));
      final c = _control(
        reloj,
        respuestas: [
          _resp(
            'ronda_20261013_0900',
            TipoPreguntaControl.estado,
            'bien',
            _m(9, 1),
          ),
          _resp(
            'ronda_20261012_1000',
            TipoPreguntaControl.estado,
            'bien',
            _m(10, 1, 12),
          ),
          _resp(
            'ronda_20261013_1100',
            TipoPreguntaControl.plan,
            'tele',
            _m(11, 2),
          ),
        ],
      );
      expect(c.contestadas, 2);
      expect(c.sinRespuesta.map((r) => r.ronda.horaLocal), ['10:00']);
      expect(c.ultima?.ronda, 'ronda_20261013_1100');
      expect(c.ultima?.cuando, _m(11, 2));
    });

    test('antes del móvil de la persona no se espera nada', () {
      final reloj = RelojFijo(_m(12));
      expect(
        _control(reloj, inicio: _m(11, 30)).rondas.first.ronda.horaLocal,
        '12:00',
      );
      final sinMovil = calcularControlDelDia(
        ajustes: AjustesControl.porDefecto,
        dia: diaLocal(_m(12), _madrid),
        zona: _madrid,
        tomas: const [],
        respuestas: const [],
        ahora: _m(20),
        inicio: null,
      );
      expect(sinMovil.rondas, isEmpty);
      expect(sinMovil.nivel, NivelSemaforo.verde);
      expect(inicioDelControl(null, AjustesControl.porDefecto), isNull);
      expect(
        inicioDelControl(_m(8), AjustesControl(activoDesde: _m(10))),
        _m(10),
      );
    });

    test('con una toma cerca, cuenta desde la hora retrasada', () {
      final reloj = RelojFijo(_m(9, 20));
      final c = _control(reloj, tomas: [_m(9)]);
      // La de las 09:00 pasa a las 09:15: a las 09:20 aún se espera.
      expect(c.rondas.first.ronda.hora, _m(9, 15));
      expect(c.rondas.first.estado, EstadoRonda.enEspera);
      reloj.fijar(_m(9, 25, 13, 1));
      expect(
        _control(reloj, tomas: [_m(9)]).rondas.first.estado,
        EstadoRonda.sinRespuesta,
      );
    });
  });

  group('semáforo y avisos del día', () {
    const config = ConfigEscalado();

    test('naranja con una ronda sin respuesta; rojo con dos seguidas', () {
      final reloj = RelojFijo(_m(9, 11));
      var s = semaforoDelDia(
        const [],
        reloj.ahora(),
        config,
        control: _control(reloj),
      );
      expect(s.nivel, NivelSemaforo.naranja);
      expect(s.motivo, MotivoSemaforo.rondaSinRespuesta);

      reloj.fijar(_m(10, 11));
      s = semaforoDelDia(
        const [],
        reloj.ahora(),
        config,
        control: _control(reloj),
      );
      expect(s.nivel, NivelSemaforo.rojo);
      expect(s.motivo, MotivoSemaforo.dosSinRespuesta);

      // Contestada la de las 10: ya no son seguidas.
      s = semaforoDelDia(
        const [],
        reloj.ahora(),
        config,
        control: _control(
          reloj,
          respuestas: [
            _resp(
              'ronda_20261013_1000',
              TipoPreguntaControl.estado,
              'bien',
              _m(10, 2),
            ),
          ],
        ),
      );
      expect(s.nivel, NivelSemaforo.naranja);
    });

    test('rojo si la última respuesta de estado es «mal»', () {
      final reloj = RelojFijo(_m(10, 5));
      ControlDelDia con(List<RespuestaControl> r) =>
          _control(reloj, respuestas: r);
      final mal = _resp(
        'ronda_20261013_0900',
        TipoPreguntaControl.estado,
        'mal',
        _m(9, 2),
      );
      var s = semaforoDelDia(
        const [],
        reloj.ahora(),
        config,
        control: con([mal]),
      );
      expect(s.nivel, NivelSemaforo.rojo);
      expect(s.motivo, MotivoSemaforo.estadoMal);
      // Si después dice «bien», deja de ser rojo.
      s = semaforoDelDia(
        const [],
        reloj.ahora(),
        config,
        control: con([
          mal,
          _resp(
            'ronda_20261013_1000',
            TipoPreguntaControl.estado,
            'bien',
            _m(10, 1),
          ),
        ]),
      );
      expect(s.nivel, NivelSemaforo.verde);
      // Sin control, el semáforo de siempre.
      expect(
        nivelSemaforo(const [], reloj.ahora(), config),
        NivelSemaforo.verde,
      );
    });

    test(
      '«mal», dolor nuevo, dos sin respuesta y el mismo dolor tres veces',
      () {
        final reloj = RelojFijo(_m(16, 30));
        final c = _control(
          reloj,
          respuestas: [
            _resp(
              'ronda_20261013_0900',
              TipoPreguntaControl.dolor,
              'nada',
              _m(9, 1),
            ),
            _resp(
              'ronda_20261013_1000',
              TipoPreguntaControl.estado,
              'mal',
              _m(10, 1),
            ),
            _resp(
              'ronda_20261013_1000',
              TipoPreguntaControl.dolor,
              'poco',
              _m(10, 2),
            ),
            _resp(
              'ronda_20261013_1100',
              TipoPreguntaControl.dolor,
              'poco',
              _m(11, 1),
            ),
            // 12 y 13 sin respuesta.
            _resp(
              'ronda_20261013_1400',
              TipoPreguntaControl.dolor,
              'poco',
              _m(14, 1),
            ),
            _resp(
              'ronda_20261013_1500',
              TipoPreguntaControl.dolor,
              'mucho',
              _m(15, 1),
            ),
            _resp(
              'ronda_20261013_1600',
              TipoPreguntaControl.estado,
              'bien',
              _m(16, 1),
            ),
          ],
        );
        final avisos = c.avisos;
        expect(
          [for (final a in avisos) (a.tipo, _local(a.cuando), a.valor)],
          [
            (TipoAviso.estadoMal, '10:01', 'mal'),
            (TipoAviso.dolorNuevo, '10:02', 'poco'),
            (TipoAviso.dosSinRespuesta, '13:10', null),
            (TipoAviso.dolorRepetido, '14:01', 'poco'),
            (TipoAviso.dolorNuevo, '15:01', 'mucho'),
          ],
        );
        expect(avisos[2].rondas, [
          'ronda_20261013_1200',
          'ronda_20261013_1300',
        ]);
        // La última de estado es «bien»; pero hubo dos seguidas sin respuesta.
        expect(c.nivel, NivelSemaforo.rojo);
      },
    );
  });

  group('alarmas de las rondas', () {
    test('se programan con la voz, retrasadas y nunca de noche; desactivar '
        'las cancela', () async {
      final e = await prepararEntorno(perfil: PerfilApp.persona);
      final c = ProviderContainer(overrides: e.overrides);
      addTearDown(() async {
        c.dispose();
        await e.db.close();
      });
      final alarmas = _Alarmas();
      final control = c.read(controlHorasRepositorioProvider);
      final programador = ProgramadorAlarmas(
        servicio: alarmas,
        medicacion: c.read(medicacionRepositorioProvider),
        eventos: c.read(eventosRepositorioProvider),
        reloj: e.reloj,
        contexto: e.contexto,
        voces: c.read(vocesRepositorioProvider),
        control: control,
      );
      await programador.reprogramar();
      final rondas = alarmas.rondas.toSet();
      expect(rondas, contains('ronda_20261013_1300'));
      // Toma a las 14:00: la ronda espera a las 14:15.
      expect(alarmas.fechas['ronda_20261013_1400'], _m(14, 15));
      // Toma a las 21:00: esa ronda ya no cabe en la franja.
      expect(rondas, isNot(contains('ronda_20261013_2100')));
      expect(alarmas.fechas['ronda_20261014_0900'], _m(9, 15, 14));
      for (final id in rondas) {
        final h = int.parse(id.substring(id.length - 4, id.length - 2));
        expect(h, inInclusiveRange(9, 21), reason: id);
      }
      // Sin frase grabada: la plataforma pone el tono suave.
      expect({for (final id in rondas) alarmas.audio[id]}, {null});
      // Las tomas siguen ahí.
      expect(alarmas.fechas.keys.where((id) => !esIdRonda(id)), isNotEmpty);

      // Con la frase "¿Cómo estás?" grabada, las rondas suenan con ella.
      final voces = c.read(vocesRepositorioProvider);
      final lucia = (await (e.db.select(
        e.db.miembros,
      )..where((m) => m.nombre.equals('Lucía'))).getSingle()).id;
      final vozId = await voces.otorgarConsentimiento(
        miembroId: lucia,
        textoMostrado: 'Texto de prueba del permiso',
      );
      final ruta = voces.rutaNueva(vozId, UsoFrase.comoEstas);
      await e.archivos.escribir(ruta, GrabadoraSimulada.relleno(1500));
      final fraseId = await voces.guardarGrabacion(
        vozId: vozId,
        uso: UsoFrase.comoEstas,
        texto: '¿Cómo estás?',
        ruta: ruta,
      );
      await voces.aprobar(fraseId);
      await programador.reprogramar();
      expect({for (final id in alarmas.rondas) alarmas.audio[id]}, {ruta});

      // Desactivado: las rondas se cancelan y las tomas no.
      await control.guardarAjustes(
        AjustesControl.porDefecto.copiar(activado: false),
      );
      await programador.reprogramar();
      expect(alarmas.rondas, isEmpty);
      expect(alarmas.fechas.keys.where((id) => !esIdRonda(id)), isNotEmpty);
    });
  });

  group('persona: la pregunta guarda y avisa', () {
    testWidgets('cada respuesta se guarda con su ronda y deja '
        '«pregunta_respondida»', (tester) async {
      final alarmas = _Alarmas();
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.persona, alarmas: alarmas),
      ))!;
      await montarApp(
        tester,
        e,
        rutaInicial: '/persona/pregunta?ronda=ronda_20261013_1200',
      );
      await pasar(tester, const Duration(seconds: 1));
      // Al abrirse para una ronda, para su alarma.
      expect(alarmas.canceladas, contains('ronda_20261013_1200'));

      e.reloj.avanzar(const Duration(seconds: 4));
      await tester.tap(find.byKey(ClavesUi.respuesta('regular')));
      await pasar(tester, const Duration(milliseconds: 300));
      e.reloj.avanzar(const Duration(seconds: 2));
      await tester.tap(find.byKey(ClavesUi.respuesta('poco')));
      await pasar(tester, const Duration(milliseconds: 300));
      await tester.ensureVisible(find.text('Prefiero decirlo'));
      await tester.pump();
      await tester.tap(find.text('Prefiero decirlo'));
      await pasar(tester, const Duration(milliseconds: 300));
      expect(find.text('Gracias'), findsOneWidget);

      final (eventos, preguntas, respuestas) = (await tester.runAsync(
        () async => (
          await (e.db.select(
            e.db.eventos,
          )..where((x) => x.tipo.equals('pregunta_respondida'))).get(),
          await e.db.select(e.db.preguntasControl).get(),
          await e.db.select(e.db.respuestas).get(),
        ),
      ))!;
      expect(eventos, hasLength(3));
      final pagos = [
        for (final x in eventos) jsonDecode(x.payload) as Map<String, dynamic>,
      ];
      expect([for (final p in pagos) p['tipo']], ['estado', 'dolor', 'plan']);
      expect(
        [for (final p in pagos) p['respuesta']],
        ['regular', 'poco', 'decirlo'],
      );
      expect([for (final p in pagos) p['tiempo_ms']], [4000, 2000, 0]);
      for (final x in eventos) {
        expect(x.sujeto, 'ronda_20261013_1200');
        expect(x.autor, e.contexto.personaId);
      }
      expect({for (final p in pagos) p['ronda']}, {'ronda_20261013_1200'});
      expect({for (final p in pagos) p['origen']}, {'movil'});
      expect(preguntas.map((p) => p.tipo), ['estado', 'dolor', 'plan']);
      expect(preguntas.first.texto, '¿Cómo estás?');
      expect({for (final p in preguntas) p.origen}, {'movil'});
      expect(respuestas.map((r) => r.valor).toSet(), {
        'regular',
        'poco',
        'decirlo',
      });
      expect(
        respuestas.map((r) => r.preguntaId).toSet(),
        preguntas.map((p) => p.id).toSet(),
      );
      await pasar(tester, const Duration(seconds: 3));
      expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
    });

    testWidgets('el modo prueba no guarda nada', (tester) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      await montarApp(tester, e, rutaInicial: '/persona/pregunta?prueba=1');
      await pasar(tester, const Duration(seconds: 1));
      for (final r in ['bien', 'mucho', 'tele']) {
        await tester.tap(find.byKey(ClavesUi.respuesta(r)));
        await pasar(tester, const Duration(milliseconds: 300));
      }
      expect(find.text('Gracias'), findsOneWidget);
      final n = await tester.runAsync(
        () async =>
            (await e.db.select(e.db.preguntasControl).get()).length +
            (await e.db.select(e.db.respuestas).get()).length +
            (await (e.db.select(
                  e.db.eventos,
                )..where((x) => x.tipo.equals('pregunta_respondida'))).get())
                .length,
      );
      expect(n, 0);
      await pasar(tester, const Duration(seconds: 3));
    });

    testWidgets('con la app abierta, la ronda se lanza a su hora', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.persona),
      ))!;
      e.reloj.fijar(_m(12, 59, 13, 50));
      await montarApp(tester, e);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byKey(ClavesUi.loSiguiente), findsOneWidget);
      expect(find.byType(PreguntaPantalla), findsNothing);

      // Llega la hora: el temporizador abre la pregunta de las 13:00.
      e.reloj.fijar(_m(13));
      await pasar(tester, const Duration(seconds: 10));
      expect(find.byType(PreguntaPantalla), findsOneWidget);
      await tester.tap(find.byKey(ClavesUi.respuesta('bien')));
      await pasar(tester, const Duration(milliseconds: 300));
      final sujeto = await tester.runAsync(
        () async =>
            (await (e.db.select(e.db.eventos)
                      ..where((x) => x.tipo.equals('pregunta_respondida')))
                    .getSingle())
                .sujeto,
      );
      expect(sujeto, 'ronda_20261013_1300');
      // Se desmonta la app: no queda ningún temporizador.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('si suena la alarma de una ronda, se abre su pregunta', (
      tester,
    ) async {
      final alarmas = _Alarmas();
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.persona, alarmas: alarmas),
      ))!;
      await montarApp(tester, e);
      await pasar(tester, const Duration(seconds: 1));
      alarmas.sonar('ronda_20261013_1200');
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byType(PreguntaPantalla), findsOneWidget);
      expect(alarmas.canceladas, contains('ronda_20261013_1200'));
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('familia: Hoy y Resumen', () {
    Future<EntornoPrueba> familia(
      WidgetTester tester,
      Future<void> Function(EntornoPrueba e) preparar,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      await tester.runAsync(() => preparar(e));
      return e;
    }

    testWidgets('Hoy: última respuesta, sin respuesta, semáforo y avisos', (
      tester,
    ) async {
      final e = await familia(tester, (e) async {
        await _movilPersona(e, _m(9, 30));
        await _ronda(e, 'ronda_20261013_1000', _m(10, 2), dolor: 'poco');
      });
      await montarApp(tester, e);
      await pasar(tester, const Duration(seconds: 1));
      // 09:00 confirmada con vídeo, pero la ronda de las 11 sin respuesta.
      expect(find.text('Una ronda de preguntas sin respuesta'), findsOneWidget);
      // Avisos: el dolor nuevo de las 10:03.
      await tester.scrollUntilVisible(find.text('Última respuesta'), 300);
      expect(
        find.text('Bien · Le duele un poco · Va a pasear'),
        findsOneWidget,
      );
      expect(find.text('10:04'), findsOneWidget);
      expect(find.text('Sin respuesta'), findsOneWidget);
      expect(find.text('11:00'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('AVISOS DE HOY'), 300);
      expect(find.text('Dolor nuevo: un poco'), findsOneWidget);
      expect(find.text('10:03'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Hoy: rojo con «mal» y con dos rondas sin respuesta', (
      tester,
    ) async {
      final e = await familia(tester, (e) async {
        await _movilPersona(e, _m(8));
        await _ronda(e, 'ronda_20261013_0900', _m(9, 20), estado: 'mal');
        await _ronda(e, 'ronda_20261013_1000', _m(10, 2));
      });
      // A las 12:00 faltan las 11 y… la de las 12 aún se espera: naranja.
      // A las 13:11 faltan 11, 12 y 13 seguidas: rojo.
      e.reloj.fijar(_m(13, 11));
      await montarApp(tester, e);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.text('Dos rondas seguidas sin respuesta'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('AVISOS DE HOY'), 300);
      expect(find.text('Dijo «Mal»'), findsOneWidget);
      expect(
        find.text('Dos rondas seguidas sin respuesta (11:00 y 12:00)'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Hoy: si la última de estado es «mal», rojo', (tester) async {
      final e = await familia(tester, (e) async {
        await _movilPersona(e, _m(10, 30));
        await _ronda(e, 'ronda_20261013_1100', _m(11, 3), estado: 'mal');
      });
      await montarApp(tester, e);
      await pasar(tester, const Duration(seconds: 1));
      expect(find.text('En la última pregunta dijo «Mal»'), findsOneWidget);
    });

    testWidgets('Resumen: contestadas y sin respuesta de hoy y de la semana', (
      tester,
    ) async {
      final manejador = tester.ensureSemantics();
      final e = await familia(tester, (e) async {
        await _movilPersona(e, _m(8, 0, 12));
        await _ronda(e, 'ronda_20261012_2000', _m(20, 1, 12));
        await _ronda(e, 'ronda_20261013_1000', _m(10, 2));
      });
      await montarApp(tester, e);
      await pasar(tester, const Duration(seconds: 1));
      await tester.tap(find.byKey(ClavesUi.pestana('resumen')));
      await pasar(tester, const Duration(seconds: 1));
      expect(find.text('Carmen: una ronda sin respuesta'), findsOneWidget);
      // Hoy: 9 y 11 sin respuesta (dos, pero no seguidas), 10 contestada.
      expect(find.text('Tomas de Carmen al día'), findsNothing);
      expect(find.text('Carmen: una toma sin vídeo'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Hoy: 1 contestada · 2 sin respuesta'),
        300,
        scrollable: find
            .descendant(
              of: find.byKey(ClavesUi.pantallaResumen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      // Ayer (desde las 08:00): 12 rondas (la de las 21:00 no cabe por la
      // toma), una contestada; hoy, 1 y 2.
      expect(
        find.text('Semana: 2 contestadas · 13 sin respuesta'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('10:00: contestada'), findsOneWidget);
      expect(find.bySemanticsLabel('11:00: sin respuesta'), findsOneWidget);
      expect(
        find.bySemanticsLabel('12:00: esperando respuesta'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('13:00: aún no ha llegado'), findsOneWidget);
      expect(tester.takeException(), isNull);
      manejador.dispose();
    });
  });

  group('pantalla Control por horas', () {
    testWidgets('interruptor, franja y ritmo se guardan y viajan como ficha', (
      tester,
    ) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      await montarApp(tester, e, rutaInicial: '/familia/alarmas/control-horas');
      await pasar(tester, const Duration(seconds: 1));
      expect(find.byType(ControlHorasPantalla), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('21:00'), findsOneWidget);
      expect(
        find.text('13 rondas al día: de 09:00 a 21:00, cada hora.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('el móvil de Carmen le pregunta'),
        findsOneWidget,
      );

      Future<FilaAjustesControl?> fila() =>
          tester.runAsync<FilaAjustesControl?>(
            () => e.db.select(e.db.ajustesControlHoras).getSingleOrNull(),
          );
      expect(await fila(), isNull);

      await tester.tap(find.byKey(ClavesUi.controlHora('desde', 'mas')));
      await pasar(tester, const Duration(milliseconds: 300));
      await tester.tap(find.byKey(ClavesUi.controlHora('hasta', 'menos')));
      await pasar(tester, const Duration(milliseconds: 300));
      await tester.tap(find.byKey(ClavesUi.controlRitmo(2)));
      await pasar(tester, const Duration(milliseconds: 300));
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(
        find.text('6 rondas al día: de 10:00 a 20:00, cada 2 horas.'),
        findsOneWidget,
      );
      var f = await fila();
      expect(f?.desdeHora, 10);
      expect(f?.hastaHora, 20);
      expect(f?.cadaHoras, 2);
      expect(f?.activado, isTrue);
      expect(f?.activoDesde, isNull);

      // Desactivar: desaparecen franja y ritmo; volver a activar apunta desde
      // cuándo.
      await tester.tap(find.byKey(ClavesUi.controlActivado));
      await pasar(tester, const Duration(milliseconds: 300));
      expect(find.text('10:00'), findsNothing);
      expect(
        find.textContaining('Desactivado: el móvil de Carmen'),
        findsOneWidget,
      );
      expect((await fila())?.activado, isFalse);
      await tester.tap(find.byType(CupertinoSwitch));
      await pasar(tester, const Duration(milliseconds: 300));
      f = await fila();
      expect(f?.activado, isTrue);
      expect(f?.activoDesde, instantePrueba.millisecondsSinceEpoch);

      final fichas = await tester.runAsync(
        () => (e.db.select(
          e.db.eventos,
        )..where((x) => x.sujeto.equals(e.contexto.circuloId))).get(),
      );
      final tipos = [for (final x in fichas!) x.tipo];
      expect(tipos.first, 'ficha_creada');
      expect(tipos.skip(1).toSet(), {'ficha_modificada'});
      final ultima = jsonDecode(fichas.last.payload) as Map<String, dynamic>;
      expect(ultima['tipo'], 'ajustes_control');
      expect((ultima['fila'] as Map)['cada_horas'], 2);
    });

    testWidgets('no deja una franja vacía ni salir de 6 a 23', (tester) async {
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      await tester.runAsync(() async {
        final c = ProviderContainer(overrides: e.overrides);
        await c
            .read(controlHorasRepositorioProvider)
            .guardarAjustes(const AjustesControl(desde: 22, hasta: 23));
        c.dispose();
      });
      await montarApp(tester, e, rutaInicial: '/familia/alarmas/control-horas');
      await pasar(tester, const Duration(seconds: 1));
      IconButton boton(String campo, String accion) => tester
          .widget<IconButton>(find.byKey(ClavesUi.controlHora(campo, accion)));
      expect(boton('desde', 'mas').onPressed, isNull);
      expect(boton('hasta', 'menos').onPressed, isNull);
      expect(boton('hasta', 'mas').onPressed, isNull);
      expect(boton('desde', 'menos').onPressed, isNotNull);
    });

    testWidgets('al 200 %, en oscuro: sin desbordes, contraste y toques', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final manejador = tester.ensureSemantics();
      final e = (await tester.runAsync(
        () => prepararEntorno(perfil: PerfilApp.familia),
      ))!;
      await montarApp(tester, e, rutaInicial: '/familia/alarmas/control-horas');
      await pasar(tester, const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      manejador.dispose();
    });
  });

  group('cartero', () {
    test('los ajustes viajan y cambian las rondas en el móvil de la persona; '
        'gana el cambio más reciente', () async {
      final servidor = ServidorMemoria();
      final clave = ClaveCirculo.generar(Random(5));
      final familia = await _Movil.crear(
        servidor,
        'movil-fam',
        PerfilApp.familia,
        clave,
      );
      final persona = await _Movil.crear(
        servidor,
        'movil-per',
        PerfilApp.persona,
        clave,
      );
      addTearDown(() async {
        await familia.cerrar();
        await persona.cerrar();
      });
      final alarmas = _Alarmas();
      final programador = ProgramadorAlarmas(
        servicio: alarmas,
        medicacion: persona.c.read(medicacionRepositorioProvider),
        eventos: persona.c.read(eventosRepositorioProvider),
        reloj: RelojFijo(instantePrueba),
        contexto: persona.c.read(contextoProvider),
        control: persona.c.read(controlHorasRepositorioProvider),
      );
      await programador.reprogramar();
      expect(alarmas.rondas, contains('ronda_20261013_1300'));

      await familia.c
          .read(controlHorasRepositorioProvider)
          .guardarAjustes(
            const AjustesControl(desde: 10, hasta: 20, cadaHoras: 2),
          );
      await familia.servicio.iniciar();
      await persona.servicio.iniciar();
      final repoPersona = persona.c.read(controlHorasRepositorioProvider);
      await _esperarA(() async => (await repoPersona.ajustes()).cadaHoras == 2);
      expect(
        await repoPersona.ajustes(),
        const AjustesControl(desde: 10, hasta: 20, cadaHoras: 2),
      );
      await programador.reprogramar();
      final horas = {
        for (final id in alarmas.rondas)
          int.parse(id.substring(id.length - 4, id.length - 2)),
      };
      expect(horas, {10, 12, 14, 16, 18, 20});
      expect(alarmas.rondas, isNot(contains('ronda_20261013_1300')));
      expect(alarmas.canceladas, contains('ronda_20261013_1300'));

      // Desactivado en la familia: el móvil de la persona deja de preguntar.
      await familia.c
          .read(controlHorasRepositorioProvider)
          .guardarAjustes(
            const AjustesControl(
              desde: 10,
              hasta: 20,
              cadaHoras: 2,
              activado: false,
            ),
          );
      await _esperarA(() async => !(await repoPersona.ajustes()).activado);
      await programador.reprogramar();
      expect(alarmas.rondas, isEmpty);

      // Un cambio más viejo que llega tarde no pisa al nuevo.
      final fila = await persona.db
          .select(persona.db.ajustesControlHoras)
          .getSingle();
      final viejo = Evento(
        ulid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
        circuloId: fila.id,
        autor: 'otro',
        dispositivo: 'otro',
        tipo: 'ficha_modificada',
        sujeto: fila.id,
        ocurridoEn: 1,
        registradoEn: 1,
        payload: jsonEncode({
          'tipo': 'ajustes_control',
          'fila': {
            ...FilasFicha.ajustesControl(fila),
            'activado': true,
            'cada_horas': 3,
            'modificado_en': fila.modificadoEn - 1000,
          },
        }),
      );
      await persona.db.into(persona.db.eventos).insert(viejo);
      await MaterializadorFichas(
        persona.db,
        persona.c.read(contextoProvider),
      ).alRecibir(viejo);
      expect((await repoPersona.ajustes()).activado, isFalse);
      expect((await repoPersona.ajustes()).cadaHoras, 2);
    });
  });

  test(
    'migración 3→4: crea los ajustes del control sin tocar los hechos',
    () async {
      final dir = await Directory.systemTemp.createTemp('newera_migracion4_');
      addTearDown(() => dir.delete(recursive: true));
      final archivo = File('${dir.path}/v3.db');
      final v3 = AppDatabase(NativeDatabase(archivo));
      await v3
          .into(v3.circulos)
          .insert(
            CirculosCompanion.insert(id: 'c1', nombre: 'Familia', creadoEn: 1),
          );
      await v3
          .into(v3.eventos)
          .insert(
            EventosCompanion.insert(
              ulid: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
              circuloId: 'c1',
              autor: 'a',
              dispositivo: 'd',
              tipo: 'pregunta_respondida',
              ocurridoEn: 1,
              registradoEn: 1,
            ),
          );
      await v3.customStatement('DROP TABLE ajustes_control_horas');
      await v3.customStatement('PRAGMA user_version = 3');
      await v3.close();

      final v4 = AppDatabase(NativeDatabase(archivo));
      addTearDown(v4.close);
      final version = await v4.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 4);
      expect(v4.schemaVersion, 4);
      expect(await v4.select(v4.eventos).get(), hasLength(1));
      expect(await v4.select(v4.ajustesControlHoras).get(), isEmpty);
      await v4
          .into(v4.ajustesControlHoras)
          .insert(
            AjustesControlHorasCompanion.insert(
              id: 'c1',
              activado: true,
              desdeHora: 9,
              hastaHora: 21,
              cadaHoras: 1,
              modificadoPor: 'm',
              modificadoEn: 2,
            ),
          );
      // Los ajustes cambian; los hechos siguen siendo de solo inserción.
      await (v4.update(v4.ajustesControlHoras))
          .write(const AjustesControlHorasCompanion(cadaHoras: Value(2)));
      await expectLater(
        v4.customStatement('DELETE FROM eventos'),
        throwsA(predicate((e) => e.toString().contains('solo_insercion'))),
      );
    },
  );
}

/// Espera (de verdad) a que se cumpla [condicion].
Future<void> _esperarA(Future<bool> Function() condicion) async {
  final reloj = Stopwatch()..start();
  while (!await condicion()) {
    if (reloj.elapsed > const Duration(seconds: 10)) {
      fail('tiempo agotado esperando la sincronización');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// Un móvil del círculo con su base en memoria y su cartero.
class _Movil {
  _Movil(this.c, this.servicio);

  final ProviderContainer c;
  final ServicioSync servicio;

  AppDatabase get db => c.read(baseDatosProvider);

  static Future<_Movil> crear(
    ServidorMemoria servidor,
    String dispositivo,
    PerfilApp perfil,
    String clave,
  ) async {
    final almacen = AlmacenSeguroMemoria({
      ClavesAlmacen.dispositivoId: dispositivo,
      ClavesAlmacen.circuloId: 'circulo-control',
      ClavesAlmacen.personaId: 'persona-control',
      ClavesAlmacen.circuloClave: clave,
      ClavesAlmacen.circuloClaveVersion: '1',
      ClavesAlmacen.perfil: perfil.nombre,
    });
    final overrides = await Arranque.iniciar(
      almacen: almacen,
      ejecutor: ejecutorEnMemoria(),
      reloj: RelojFijo(instantePrueba),
      plataforma: 'android',
      demoWeb: false,
      sembrarDemo: false,
      azar: Random(dispositivo.length * 31),
    );
    final transporte = TransporteMemoria(servidor);
    final c = ProviderContainer(
      overrides: [
        ...overrides,
        syncTransportProvider.overrideWithValue(transporte),
      ],
    );
    final servicio = ServicioSync(
      db: c.read(baseDatosProvider),
      transporte: transporte,
      llaves: () => c.read(llavesCirculoProvider.future),
      contexto: c.read(contextoProvider),
      reloj: c.read(relojProvider),
      pausaNuevos: const Duration(milliseconds: 1),
      esperaMinima: const Duration(milliseconds: 10),
      esperaMaxima: const Duration(milliseconds: 50),
    );
    return _Movil(c, servicio);
  }

  Future<void> cerrar() async {
    await servicio.detener();
    final base = db;
    c.dispose();
    await base.close();
  }
}
