import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/db/repositorios/eventos_repositorio.dart';
import '../../../core/db/repositorios/medicacion_repositorio.dart';
import '../../../core/providers.dart';
import 'tomas.dart';

// Control por horas visto por la familia (plan v3, 2.4 bis y 3.1). Lógica
// pura: el "sin respuesta" lo deduce la familia con los ajustes, las tomas
// (por el retraso de las rondas) y las respuestas que han llegado; no
// depende de que el móvil de la persona esté encendido.

/// Valores de la respuesta "¿Te duele algo?" de menos a más.
const _nivelDolor = {'nada': 0, 'poco': 1, 'mucho': 2};

/// Una respuesta recibida (evento `pregunta_respondida`).
final class RespuestaControl {
  const RespuestaControl({
    required this.ulid,
    required this.ronda,
    required this.tipo,
    required this.valor,
    required this.cuando,
    this.tiempoMs,
  });

  final String ulid;

  /// Id de la ronda (`ronda_<yyyyMMdd>_<HHmm>`).
  final String ronda;
  final TipoPreguntaControl tipo;

  /// Clave de la respuesta: `bien`, `regular`, `mal`, `nada`, `poco`,
  /// `mucho`, `pasear`, `descansar`, `tele`, `otra` o `decirlo`.
  final String valor;
  final DateTime cuando;

  /// Lo que tardó en contestar desde que vio la pregunta.
  final int? tiempoMs;

  /// La respuesta de [e], o nula si no es un `pregunta_respondida` válido.
  static RespuestaControl? desdeEvento(Evento e) {
    if (e.tipo != TipoEvento.preguntaRespondida.nombre) return null;
    final p = EventosRepositorio.payloadDe(e);
    final ronda = p['ronda'] ?? e.sujeto;
    final tipo = TipoPreguntaControl.desdeNombre(p['tipo']);
    final valor = p['respuesta'];
    if (ronda is! String || !esIdRonda(ronda) || tipo == null) return null;
    if (valor is! String || valor.isEmpty) return null;
    final t = p['tiempo_ms'];
    return RespuestaControl(
      ulid: e.ulid,
      ronda: ronda,
      tipo: tipo,
      valor: valor,
      cuando: DateTime.fromMillisecondsSinceEpoch(e.ocurridoEn, isUtc: true),
      tiempoMs: t is int ? t : null,
    );
  }
}

/// Cómo está una ronda esperada.
enum EstadoRonda {
  /// Hay al menos una respuesta.
  contestada,

  /// Pasaron más de 10 minutos de su hora y no hay ninguna respuesta.
  sinRespuesta,

  /// Ya es su hora y aún no han pasado 10 minutos.
  enEspera,

  /// Todavía no ha llegado.
  porLlegar,
}

/// Una ronda esperada del día con su estado y sus respuestas.
final class RondaDelDia {
  const RondaDelDia({
    required this.ronda,
    required this.estado,
    this.respuestas = const {},
  });

  final RondaControl ronda;
  final EstadoRonda estado;

  /// La última respuesta de cada pregunta.
  final Map<TipoPreguntaControl, RespuestaControl> respuestas;
}

/// Las respuestas de una ronda y cuándo llegó la última.
final class RespuestasDeRonda {
  const RespuestasDeRonda({
    required this.ronda,
    required this.respuestas,
    required this.cuando,
  });

  final String ronda;
  final Map<TipoPreguntaControl, RespuestaControl> respuestas;
  final DateTime cuando;
}

/// El control por horas de un día, ya calculado.
final class ControlDelDia {
  const ControlDelDia({
    required this.fecha,
    required this.ajustes,
    required this.rondas,
    required this.respuestas,
    required this.inicio,
  });

  /// `yyyy-MM-dd` local.
  final String fecha;
  final AjustesControl ajustes;

  /// Rondas esperadas (las de después de [inicio]), por hora.
  final List<RondaDelDia> rondas;

  /// Respuestas de las rondas de este día, de la primera a la última (la
  /// última de cada pregunta de cada ronda).
  final List<RespuestaControl> respuestas;

  /// Desde cuándo se esperan respuestas: el primer móvil de la persona y la
  /// activación de los ajustes. Nulo si aún no hay móvil de la persona.
  final DateTime? inicio;

  List<RondaDelDia> get sinRespuesta => [
    for (final r in rondas)
      if (r.estado == EstadoRonda.sinRespuesta) r,
  ];

  /// Rondas con alguna respuesta (esperadas o no).
  int get contestadas => {for (final r in respuestas) r.ronda}.length;

  /// Las respuestas de la última ronda contestada.
  RespuestasDeRonda? get ultima {
    if (respuestas.isEmpty) return null;
    final ronda = respuestas.last.ronda;
    final suyas = <TipoPreguntaControl, RespuestaControl>{
      for (final r in respuestas)
        if (r.ronda == ronda) r.tipo: r,
    };
    return RespuestasDeRonda(
      ronda: ronda,
      respuestas: suyas,
      cuando: respuestas.last.cuando,
    );
  }

  /// La última respuesta a "¿Cómo estás?" del día.
  RespuestaControl? get ultimoEstado {
    for (final r in respuestas.reversed) {
      if (r.tipo == TipoPreguntaControl.estado) return r;
    }
    return null;
  }

  /// Hay dos rondas esperadas seguidas sin respuesta.
  bool get dosSeguidasSinRespuesta {
    var seguidas = 0;
    for (final r in rondas) {
      seguidas = r.estado == EstadoRonda.sinRespuesta ? seguidas + 1 : 0;
      if (seguidas >= 2) return true;
    }
    return false;
  }

  /// Rojo si la última respuesta de estado es «mal» o hay dos rondas
  /// seguidas sin respuesta; naranja si hay alguna sin respuesta.
  NivelSemaforo get nivel {
    if (ultimoEstado?.valor == 'mal' || dosSeguidasSinRespuesta) {
      return NivelSemaforo.rojo;
    }
    if (sinRespuesta.isNotEmpty) return NivelSemaforo.naranja;
    return NivelSemaforo.verde;
  }

  /// Las situaciones del plan que avisan a la familia (2.4 bis), en orden:
  /// «mal», un dolor nuevo (más que el de la respuesta anterior del día),
  /// dos rondas seguidas sin respuesta (una vez por racha) y el mismo dolor
  /// tres veces en el día (a la tercera).
  List<AvisoDelDia> get avisos {
    final r = <AvisoDelDia>[];
    var dolorAntes = 0;
    final vecesDolor = <String, int>{};
    for (final x in respuestas) {
      switch (x.tipo) {
        case TipoPreguntaControl.estado:
          if (x.valor == 'mal') {
            r.add(
              AvisoDelDia(
                tipo: TipoAviso.estadoMal,
                cuando: x.cuando,
                valor: x.valor,
                rondas: [x.ronda],
              ),
            );
          }
        case TipoPreguntaControl.dolor:
          final nivel = _nivelDolor[x.valor];
          if (nivel == null) break;
          if (nivel > dolorAntes) {
            r.add(
              AvisoDelDia(
                tipo: TipoAviso.dolorNuevo,
                cuando: x.cuando,
                valor: x.valor,
                rondas: [x.ronda],
              ),
            );
          }
          dolorAntes = nivel;
          if (nivel > 0) {
            final n = vecesDolor[x.valor] = (vecesDolor[x.valor] ?? 0) + 1;
            if (n == 3) {
              r.add(
                AvisoDelDia(
                  tipo: TipoAviso.dolorRepetido,
                  cuando: x.cuando,
                  valor: x.valor,
                  rondas: [x.ronda],
                ),
              );
            }
          }
        case TipoPreguntaControl.plan:
          break;
      }
    }
    final racha = <RondaDelDia>[];
    for (final x in rondas) {
      if (x.estado != EstadoRonda.sinRespuesta) {
        racha.clear();
        continue;
      }
      racha.add(x);
      if (racha.length == 2) {
        r.add(
          AvisoDelDia(
            tipo: TipoAviso.dosSinRespuesta,
            cuando: x.ronda.hora.add(esperaRespuestaRonda),
            rondas: [for (final y in racha) y.ronda.id],
          ),
        );
      }
    }
    r.sort((a, b) => a.cuando.compareTo(b.cuando));
    return r;
  }
}

/// Estado de [ronda] a [ahora] con sus [respuestas].
EstadoRonda estadoDeRonda(RondaControl ronda, bool contestada, DateTime ahora) {
  if (contestada) return EstadoRonda.contestada;
  if (ahora.isAfter(ronda.hora.add(esperaRespuestaRonda))) {
    return EstadoRonda.sinRespuesta;
  }
  if (!ahora.isBefore(ronda.hora)) return EstadoRonda.enEspera;
  return EstadoRonda.porLlegar;
}

/// Calcula el control por horas del [dia] a [ahora].
///
/// - Rondas esperadas: las de [ajustes] ([rondasControl], con el retraso por
///   las [tomas], sus instantes previstos) cuya hora es posterior a
///   [inicio]. Sin [inicio] (aún no hay móvil de la persona), ninguna.
/// - Una ronda es "sin respuesta" si su hora pasó hace más de 10 minutos y
///   no hay ninguna respuesta con su id, aunque el móvil de la persona
///   estuviera apagado.
/// - [respuestas] puede traer las de otros días: se quedan las de las rondas
///   de este (por la fecha del id). De cada pregunta de cada ronda cuenta la
///   última.
ControlDelDia calcularControlDelDia({
  required AjustesControl ajustes,
  required DiaLocal dia,
  required String zona,
  required Iterable<DateTime> tomas,
  required Iterable<RespuestaControl> respuestas,
  required DateTime ahora,
  required DateTime? inicio,
}) {
  final prefijo = '$prefijoRonda${dia.fecha.replaceAll('-', '')}_';
  final ultimas = <String, RespuestaControl>{};
  final ordenadas =
      [
        for (final r in respuestas)
          if (r.ronda.startsWith(prefijo)) r,
      ]..sort((a, b) {
        final c = a.cuando.compareTo(b.cuando);
        return c != 0 ? c : a.ulid.compareTo(b.ulid);
      });
  for (final r in ordenadas) {
    ultimas['${r.ronda}|${r.tipo.nombre}'] = r;
  }
  final delDia = ultimas.values.toList()
    ..sort((a, b) {
      final c = a.cuando.compareTo(b.cuando);
      return c != 0 ? c : a.ulid.compareTo(b.ulid);
    });
  final porRonda = <String, Map<TipoPreguntaControl, RespuestaControl>>{};
  for (final r in delDia) {
    porRonda.putIfAbsent(r.ronda, () => {})[r.tipo] = r;
  }

  final rondas = <RondaDelDia>[];
  if (inicio != null && inicio.isBefore(dia.fin)) {
    final desde = DateTime.fromMillisecondsSinceEpoch(
      math.max(
        dia.inicio.millisecondsSinceEpoch,
        inicio.millisecondsSinceEpoch + 1,
      ),
      isUtc: true,
    );
    for (final r in rondasControl(
      ajustes: ajustes,
      zona: zona,
      desde: desde,
      hasta: dia.fin,
      tomas: tomas,
    )) {
      final suyas = porRonda[r.id];
      rondas.add(
        RondaDelDia(
          ronda: r,
          estado: estadoDeRonda(r, suyas != null, ahora),
          respuestas: suyas ?? const {},
        ),
      );
    }
  }
  return ControlDelDia(
    fecha: dia.fecha,
    ajustes: ajustes,
    rondas: rondas,
    respuestas: delDia,
    inicio: inicio,
  );
}

/// Tras activar (o añadir horas), el móvil de la persona se entera por el
/// cartero y los relojes de los móviles pueden diferir unos minutos: una
/// ronda que cae en este margen puede no lanzarse y no se espera.
const margenActivacionControl = Duration(minutes: 10);

/// Desde cuándo se esperan respuestas: lo más tarde entre el primer móvil de
/// la persona ([primerMovil]) y la activación de los ajustes más
/// [margenActivacionControl]. Nulo si aún no hay móvil de la persona.
DateTime? inicioDelControl(DateTime? primerMovil, AjustesControl ajustes) {
  if (primerMovil == null) return null;
  final activo = ajustes.activoDesde?.add(margenActivacionControl);
  if (activo == null || activo.isBefore(primerMovil)) return primerMovil;
  return activo;
}

/// Contestadas y sin respuesta de un grupo de días.
final class CuentaControl {
  const CuentaControl({this.contestadas = 0, this.sinRespuesta = 0});

  final int contestadas;
  final int sinRespuesta;
}

CuentaControl contarControl(Iterable<ControlDelDia> dias) {
  var contestadas = 0, sin = 0;
  for (final d in dias) {
    contestadas += d.contestadas;
    sin += d.sinRespuesta.length;
  }
  return CuentaControl(contestadas: contestadas, sinRespuesta: sin);
}

/// El control de los últimos 7 días (hoy el último).
final class ControlSemana {
  const ControlSemana({required this.dias});

  /// De hace 6 días a hoy.
  final List<ControlDelDia> dias;

  ControlDelDia get hoy => dias.last;
  CuentaControl get cuentaHoy => contarControl([hoy]);
  CuentaControl get cuentaSemana => contarControl(dias);
}

// ------------------------------------------------------------ Proveedores

/// Día (desde la época) del reloj: cambia a medianoche UTC.
final _diaControlProvider = Provider<int>((ref) {
  final ahora = ref.watch(ahoraProvider.select((v) => v.value));
  final t = ahora ?? ref.read(relojProvider).ahora();
  return t.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
});

/// Respuestas de los últimos 8 días.
final respuestasControlProvider = StreamProvider<List<RespuestaControl>>((ref) {
  final dia = ref.watch(_diaControlProvider);
  final desde = DateTime.fromMillisecondsSinceEpoch(
    (dia - 8) * Duration.millisecondsPerDay,
    isUtc: true,
  );
  return ref
      .watch(eventosRepositorioProvider)
      .observarEventosDesde(
        desde,
        tipos: {TipoEvento.preguntaRespondida.nombre},
      )
      .map((l) => [for (final e in l) ?RespuestaControl.desdeEvento(e)]);
});

/// Primer móvil de la persona (su `perfil_elegido`).
final primerMovilPersonaProvider = StreamProvider<DateTime?>(
  (ref) =>
      ref.watch(controlHorasRepositorioProvider).observarPrimerMovilPersona(),
);

/// El control por horas de los últimos 7 días, con el estado de ahora.
final controlSemanaProvider = Provider<AsyncValue<ControlSemana>>((ref) {
  final ajustes = ref.watch(ajustesControlProvider);
  final respuestas = ref.watch(respuestasControlProvider);
  final primer = ref.watch(primerMovilPersonaProvider);
  final pautas = ref.watch(pautasProvider);
  final ahoraAsync = ref.watch(ahoraProvider);
  final zona = ref.watch(contextoProvider).zonaHoraria;
  for (final a in [ajustes, respuestas, primer, pautas, ahoraAsync]) {
    if (a.hasError && !a.hasValue) {
      return AsyncValue.error(a.error!, a.stackTrace ?? StackTrace.empty);
    }
  }
  if (!ajustes.hasValue ||
      !respuestas.hasValue ||
      !primer.hasValue ||
      !pautas.hasValue ||
      !ahoraAsync.hasValue) {
    return const AsyncValue.loading();
  }
  final ahora = ahoraAsync.requireValue;
  final dias = [for (var d = -6; d <= 0; d++) diaLocal(ahora, zona, d)];
  final tomas = [
    for (final t in proximasTomas(
      versiones: [
        for (final p in pautas.requireValue) MedicacionRepositorio.aVersion(p),
      ],
      desde: dias.first.inicio.subtract(margenTomaRonda),
      hasta: dias.last.fin.add(margenTomaRonda),
    ))
      t.previstaPara,
  ];
  final a = ajustes.requireValue;
  final inicio = inicioDelControl(primer.requireValue, a);
  return AsyncValue.data(
    ControlSemana(
      dias: [
        for (final d in dias)
          calcularControlDelDia(
            ajustes: a,
            dia: d,
            zona: zona,
            tomas: tomas,
            respuestas: respuestas.requireValue,
            ahora: ahora,
            inicio: inicio,
          ),
      ],
    ),
  );
});

/// El control por horas de hoy.
final controlDeHoyProvider = Provider<AsyncValue<ControlDelDia>>(
  (ref) => ref.watch(controlSemanaProvider).whenData((s) => s.hoy),
);
