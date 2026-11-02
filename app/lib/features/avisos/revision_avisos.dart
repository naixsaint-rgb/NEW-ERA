import 'dart:math';

import 'package:safety_core/safety_core.dart';

import '../../core/avisos/envio_avisos.dart';
import '../../core/contexto.dart';
import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/circulo_repositorio.dart';
import '../../core/db/repositorios/control_horas_repositorio.dart';
import '../../core/db/repositorios/eventos_repositorio.dart';
import '../../core/db/repositorios/medicacion_repositorio.dart';
import '../hoy/dominio/control_horas.dart';
import '../hoy/dominio/tomas.dart';
import 'dominio/que_avisar.dart';

/// Revisa los avisos leyendo la base (sin Riverpod): tomas y rondas de hoy y
/// lo que ha pasado desde las 00:00 local, y envía lo que toque
/// ([avisosQueTocan]). La usa la revisión en segundo plano de Android; con la
/// app abierta, lo mismo sale de los proveedores. Devuelve cuántos avisos
/// salieron.
Future<int> revisarAvisos({
  required AppDatabase db,
  required ContextoApp contexto,
  required Reloj reloj,
  required EnvioAvisos envio,
  ConfigEscalado config = const ConfigEscalado(),
}) async {
  final ahora = reloj.ahora();
  final zona = contexto.zonaHoraria;
  String persona() => contexto.personaId;
  final eventos = eventosDePersona(db, contexto, reloj);
  final circulo = CirculoRepositorio(
    db: db,
    reloj: reloj,
    contexto: contexto,
    eventos: eventos,
  );
  final medicacion = MedicacionRepositorio(
    db: db,
    reloj: reloj,
    contexto: contexto,
    eventos: eventos,
    circulo: circulo,
    autor: persona,
  );
  final control = ControlHorasRepositorio(
    db: db,
    reloj: reloj,
    contexto: contexto,
    eventos: eventos,
    autor: persona,
  );

  final hoy = diaLocal(ahora, zona);
  final pautas = await medicacion.observarPautas().first;
  final tomas = calcularTomas(
    pautas: pautas,
    medicamentos: await medicacion.observarMedicamentos().first,
    eventos: await eventos
        .observarEventosDeToma(hoy.inicio.subtract(const Duration(days: 1)))
        .first,
    ahora: ahora,
    config: config,
    zona: zona,
  );
  final ajustes = await control.ajustes();
  final instantes = [
    for (final t in proximasTomas(
      versiones: [for (final p in pautas) MedicacionRepositorio.aVersion(p)],
      desde: hoy.inicio.subtract(margenTomaRonda),
      hasta: hoy.fin.add(margenTomaRonda),
    ))
      t.previstaPara,
  ];
  final delDia = await eventos
      .observarEventosDesde(
        hoy.inicio,
        tipos: {
          TipoEvento.preguntaRespondida.nombre,
          TipoEvento.ayudaPedida.nombre,
        },
      )
      .first;
  final controlHoy = calcularControlDelDia(
    ajustes: ajustes,
    dia: hoy,
    zona: zona,
    tomas: instantes,
    respuestas: [for (final e in delDia) ?RespuestaControl.desdeEvento(e)],
    ahora: ahora,
    inicio: inicioDelControl(
      await control.observarPrimerMovilPersona().first,
      ajustes,
    ),
  );
  final lista = avisosQueTocan(
    tomas: tomas,
    control: controlHoy,
    situaciones: avisosDelDia(delDia, controlHoy),
    config: config,
    ahora: ahora,
  );
  var n = 0;
  for (final a in lista) {
    n += await envio.enviar(a);
  }
  return n;
}

/// Eventos firmados por la persona (los de su móvil sin pantalla).
EventosRepositorio eventosDePersona(
  AppDatabase db,
  ContextoApp contexto,
  Reloj reloj,
) => EventosRepositorio(
  db: db,
  reloj: reloj,
  azar: Random.secure(),
  contexto: contexto,
  autor: () => contexto.personaId,
);
