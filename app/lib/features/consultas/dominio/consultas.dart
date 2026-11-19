import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/db/base_datos.dart';
import '../../../core/db/repositorios/medicacion_repositorio.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../hoy/dominio/control_horas.dart';
import '../../hoy/dominio/tomas.dart';

/// Cuántos días se miran hacia atrás si no hay cita anterior.
const diasSinCitaAnterior = 30;

/// Tope de días hacia atrás aunque la cita anterior sea más vieja.
const diasMaximosDesdeUltima = 180;

// ------------------------------------------------------------ Lista de citas

/// Instante (UTC) en que empieza [c], en la hora de pared de la persona.
DateTime instanteDeCita(Cita c, String zona) => horaLocalAUtc(
  zona,
  int.parse(c.fecha.substring(0, 4)),
  int.parse(c.fecha.substring(5, 7)),
  int.parse(c.fecha.substring(8, 10)),
  int.parse(c.hora.substring(0, 2)),
  int.parse(c.hora.substring(3, 5)),
);

/// Las citas de la lista de Consultas: las [proximas] (la más cercana
/// primero) y las [pasadas] (la más reciente primero). Una cita que empieza
/// ahora aún es próxima.
({List<Cita> proximas, List<Cita> pasadas}) repartirCitas(
  Iterable<Cita> citas, {
  required String fechaHoy,
  required String horaAhora,
}) {
  String clave(Cita c) => '${c.fecha} ${c.hora}';
  final ahora = '$fechaHoy $horaAhora';
  final vigentes = [
    for (final c in citas)
      if (c.bajaEn == null) c,
  ]..sort((a, b) => clave(a).compareTo(clave(b)));
  return (
    proximas: [
      for (final c in vigentes)
        if (clave(c).compareTo(ahora) >= 0) c,
    ],
    pasadas: [
      for (final c in vigentes.reversed)
        if (clave(c).compareTo(ahora) < 0) c,
    ],
  );
}

/// La cita anterior a [cita] del mismo tipo (la última que empezó antes),
/// o nula si no hay.
Cita? citaAnterior(Iterable<Cita> citas, Cita cita) {
  String clave(Cita c) => '${c.fecha} ${c.hora}';
  Cita? mejor;
  for (final c in citas) {
    if (c.bajaEn != null || c.id == cita.id || c.tipo != cita.tipo) continue;
    if (clave(c).compareTo(clave(cita)) >= 0) continue;
    if (mejor == null || clave(c).compareTo(clave(mejor)) > 0) mejor = c;
  }
  return mejor;
}

// ------------------------------------------------- Qué ha pasado desde la última

/// Cifras tal cual de lo ocurrido entre dos instantes ([inicio] y [fin]):
/// sin interpretarlas.
final class DesdeUltima {
  const DesdeUltima({
    required this.inicio,
    required this.fin,
    required this.porCitaAnterior,
    this.tomasPrevistas = 0,
    this.tomasConfirmadas = 0,
    this.tomasSinConfirmar = 0,
    this.rondasContestadas = 0,
    this.rondasSinRespuesta = 0,
    this.vecesMal = 0,
    this.vecesDolor = 0,
    this.comidasAnotadas = 0,
  });

  final DateTime inicio;
  final DateTime fin;

  /// `true` si empieza en la cita anterior; `false`, si son los últimos días
  /// por defecto.
  final bool porCitaAnterior;

  /// Tomas de la ventana, las confirmadas ([esHecha]) y las no confirmadas.
  final int tomasPrevistas;
  final int tomasConfirmadas;
  final int tomasSinConfirmar;

  /// Rondas del control por horas con respuesta y sin respuesta.
  final int rondasContestadas;
  final int rondasSinRespuesta;

  /// Veces que contestó «mal» a «¿Cómo estás?».
  final int vecesMal;

  /// Veces que contestó «poco» o «mucho» a «¿Te duele algo?».
  final int vecesDolor;

  /// Comidas anotadas (sin las borradas).
  final int comidasAnotadas;
}

/// Calcula las cifras entre [inicio] y [fin] (UTC, [fin] exclusivo) con los
/// datos que ya existen: las tomas ([calcularTomas] y [contarTomas]), el
/// control por horas ([calcularControlDelDia] por cada día) y las comidas.
/// [ahora] es el instante de hoy (el estado de cada toma y ronda se mide a
/// él). Solo cuenta: no interpreta ni aconseja.
DesdeUltima calcularDesdeUltima({
  required DateTime inicio,
  required DateTime fin,
  required bool porCitaAnterior,
  required DateTime ahora,
  required String zona,
  required List<Pauta> pautas,
  required List<Medicamento> medicamentos,
  required List<Evento> eventosToma,
  required AjustesControl ajustes,
  required Iterable<RespuestaControl> respuestas,
  required DateTime? primerMovil,
  required Iterable<Comida> comidas,
  ConfigEscalado config = const ConfigEscalado(),
}) {
  if (!fin.isAfter(inicio)) {
    return DesdeUltima(
      inicio: inicio,
      fin: fin,
      porCitaAnterior: porCitaAnterior,
    );
  }
  final tomas = calcularTomas(
    pautas: pautas,
    medicamentos: medicamentos,
    eventos: eventosToma,
    ahora: ahora,
    config: config,
    zona: zona,
    desde: inicio,
    hasta: fin,
  );
  final cuenta = contarTomas(tomas);

  final instantes = [
    for (final t in proximasTomas(
      versiones: [for (final p in pautas) MedicacionRepositorio.aVersion(p)],
      desde: inicio.subtract(margenTomaRonda),
      hasta: fin.add(margenTomaRonda),
    ))
      t.previstaPara,
  ];
  final inicioControl = inicioDelControl(primerMovil, ajustes);
  bool dentro(DateTime t) => !t.isBefore(inicio) && t.isBefore(fin);
  var contestadas = 0, sinRespuesta = 0, mal = 0, dolor = 0;
  for (var k = 0; ; k++) {
    final dia = diaLocal(inicio, zona, k);
    if (!dia.inicio.isBefore(fin)) break;
    final control = calcularControlDelDia(
      ajustes: ajustes,
      dia: dia,
      zona: zona,
      tomas: instantes,
      respuestas: respuestas,
      ahora: ahora,
      inicio: inicioControl,
    );
    for (final r in control.rondas) {
      if (!dentro(r.ronda.hora)) continue;
      if (r.estado == EstadoRonda.contestada) contestadas++;
      if (r.estado == EstadoRonda.sinRespuesta) sinRespuesta++;
    }
    for (final r in control.respuestas) {
      if (!dentro(r.cuando)) continue;
      if (r.tipo == TipoPreguntaControl.estado && r.valor == 'mal') mal++;
      if (r.tipo == TipoPreguntaControl.dolor &&
          (r.valor == 'poco' || r.valor == 'mucho')) {
        dolor++;
      }
    }
  }
  final n = comidas.where((c) {
    if (c.bajaEn != null) return false;
    final t = DateTime.fromMillisecondsSinceEpoch(c.ocurridaEn, isUtc: true);
    return dentro(t);
  }).length;
  return DesdeUltima(
    inicio: inicio,
    fin: fin,
    porCitaAnterior: porCitaAnterior,
    tomasPrevistas: cuenta.previstas,
    tomasConfirmadas: cuenta.hechas,
    tomasSinConfirmar: cuenta.noConfirmadas,
    rondasContestadas: contestadas,
    rondasSinRespuesta: sinRespuesta,
    vecesMal: mal,
    vecesDolor: dolor,
    comidasAnotadas: n,
  );
}

// ------------------------------------------------------------ Resumen

/// Texto del resumen para la familia: título, fecha, preguntas (con las
/// marcadas como preguntadas) y notas. Sin IA, sin cifras interpretadas.
String textoResumenConsulta({
  required AppLocalizations l,
  required Cita cita,
  required String fechaTexto,
  required List<PreguntaConsulta> preguntas,
  required List<NotaConsulta> notas,
  required Map<String, String> nombres,
}) {
  final b = StringBuffer()
    ..writeln(l.consResumenTitulo(cita.titulo))
    ..writeln(l.consResumenFecha(fechaTexto, cita.hora));
  if (cita.lugar != null) b.writeln(cita.lugar);
  b
    ..writeln()
    ..writeln(l.consResumenPreguntas);
  if (preguntas.isEmpty) {
    b.writeln(l.consResumenSinPreguntas);
  } else {
    for (final p in preguntas) {
      b.writeln(
        p.preguntada
            ? l.consResumenPreguntada(p.texto)
            : l.consResumenPendiente(p.texto),
      );
    }
  }
  b
    ..writeln()
    ..writeln(l.consResumenNotas);
  if (notas.isEmpty) {
    b.writeln(l.consResumenSinNotas);
  } else {
    for (final n in notas) {
      b.writeln(
        l.consResumenNota(n.texto, nombres[n.creadaPor] ?? l.consAlguien),
      );
    }
  }
  return b.toString().trimRight();
}

// ------------------------------------------------------------ Proveedores

/// Preguntas sin borrar de una cita.
final preguntasConsultaProvider =
    StreamProvider.family<List<PreguntaConsulta>, String>(
      (ref, citaId) =>
          ref.watch(consultasRepositorioProvider).observarPreguntas(citaId),
    );

/// Todas las preguntas sin borrar (la lista cuenta las de cada cita).
final todasLasPreguntasProvider = StreamProvider<List<PreguntaConsulta>>(
  (ref) => ref.watch(consultasRepositorioProvider).observarTodasLasPreguntas(),
);

/// Notas sin borrar de una cita.
final notasConsultaProvider = StreamProvider.family<List<NotaConsulta>, String>(
  (ref, citaId) =>
      ref.watch(consultasRepositorioProvider).observarNotas(citaId),
);

/// La marca de grabación de una cita (nula si no hay).
final grabacionConsultaProvider =
    StreamProvider.family<GrabacionConsulta?, String>(
      (ref, citaId) =>
          ref.watch(consultasRepositorioProvider).observarGrabacion(citaId),
    );

/// Todas las marcas de grabación vigentes (la lista).
final grabacionesConsultaProvider = StreamProvider<List<GrabacionConsulta>>(
  (ref) => ref.watch(consultasRepositorioProvider).observarGrabaciones(),
);

/// Las cifras de lo ocurrido desde la cita anterior (o desde hace 30 días)
/// hasta la cita [citaId] (o hasta ahora, si aún no ha llegado). Se calcula
/// al abrir la ficha con el reloj inyectado. Nula si la cita no existe.
final desdeUltimaProvider = FutureProvider.autoDispose
    .family<DesdeUltima?, String>((ref, citaId) async {
      final citas = await ref.watch(citasProvider.future);
      final cita = citas.where((c) => c.id == citaId).firstOrNull;
      if (cita == null) return null;
      final zona = ref.read(contextoProvider).zonaHoraria;
      final ahora = ref.read(relojProvider).ahora();
      final instante = instanteDeCita(cita, zona);
      final fin = instante.isBefore(ahora) ? instante : ahora;
      final anterior = citaAnterior(citas, cita);
      var inicio = anterior == null
          ? fin.subtract(const Duration(days: diasSinCitaAnterior))
          : instanteDeCita(anterior, zona);
      final tope = fin.subtract(const Duration(days: diasMaximosDesdeUltima));
      if (inicio.isBefore(tope)) inicio = tope;

      final desde = inicio.subtract(const Duration(days: 1));
      final medicacion = ref.read(medicacionRepositorioProvider);
      final eventos = ref.read(eventosRepositorioProvider);
      final pautas = await medicacion.observarPautas().first;
      final medicamentos = await medicacion.observarMedicamentos().first;
      final eventosToma = await eventos.observarEventosDeToma(desde).first;
      final respuestas = [
        for (final e
            in await eventos
                .observarEventosDesde(
                  desde,
                  tipos: {TipoEvento.preguntaRespondida.nombre},
                )
                .first)
          ?RespuestaControl.desdeEvento(e),
      ];
      final control = ref.read(controlHorasRepositorioProvider);
      final ajustes = await control.observarAjustes().first;
      final primerMovil = await control.observarPrimerMovilPersona().first;
      final comidas = await ref
          .read(alimentacionRepositorioProvider)
          .observarComidas(desde: inicio)
          .first;
      return calcularDesdeUltima(
        inicio: inicio,
        fin: fin,
        porCitaAnterior: anterior != null,
        ahora: ahora,
        zona: zona,
        pautas: pautas,
        medicamentos: medicamentos,
        eventosToma: eventosToma,
        ajustes: ajustes,
        respuestas: respuestas,
        primerMovil: primerMovil,
        comidas: comidas,
      );
    });
