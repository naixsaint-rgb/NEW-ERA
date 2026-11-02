import 'dart:async';

import 'package:safety_core/safety_core.dart';

import '../../contexto.dart';
import '../../db/base_datos.dart';
import '../../db/repositorios/control_horas_repositorio.dart';
import '../../db/repositorios/eventos_repositorio.dart';
import '../../db/repositorios/medicacion_repositorio.dart';
import '../../db/repositorios/voces_repositorio.dart';
import 'servicio_alarmas.dart';

/// Programa las alarmas de las tomas y de las rondas del control por horas
/// de las próximas 48 horas.
///
/// Inserta cada toma (`INSERT OR IGNORE`), programa la alarma y cancela las
/// sobrantes. Con `no_implementado` o `no_disponible` deja un solo
/// `alarma_no_programada` por arranque; nunca bloquea la pantalla ni lanza.
///
/// Sonido: la frase `toma` de la voz de la pauta (o la primera del círculo)
/// si su audio está en este móvil; si no, el tono. Cada `alarma_programada`
/// apunta el audio que lleva (`audio`); si la frase cambia, la alarma se
/// cancela y se vuelve a programar con la nueva.
///
/// Rondas (plan v3, 2.4 bis): con los ajustes del círculo ([control]), una
/// alarma por ronda con id `ronda_<yyyyMMdd>_<HHmm>` ([rondasControl]: nunca
/// fuera de la franja y retrasada si cae cerca de una toma). Suena la frase
/// `como_estas` si está en este móvil; si no, la plataforma pone su tono
/// suave. Si cambian los ajustes, las rondas que ya no tocan son sobrantes y
/// se cancelan. El id de una ronda no cambia con su retraso: su
/// `alarma_programada` apunta la hora (`hora`, ms UTC) y, si una toma nueva
/// (o retirada) la mueve, se cancela y se vuelve a programar.
class ProgramadorAlarmas {
  ProgramadorAlarmas({
    required this.servicio,
    required this.medicacion,
    required this.eventos,
    required this.reloj,
    required this.contexto,
    this.voces,
    this.control,
  });

  final ServicioAlarmas servicio;
  final MedicacionRepositorio medicacion;
  final EventosRepositorio eventos;
  final Reloj reloj;
  final ContextoApp contexto;

  /// De dónde sale la frase de cada alarma (sin él, siempre el tono).
  final VocesRepositorio? voces;

  /// Ajustes del control por horas (sin él, ninguna ronda).
  final ControlHorasRepositorio? control;

  /// Texto de la alarma de una ronda (título en iOS, cuerpo en Android).
  static const textoRonda = 'Toca para contestar';

  /// Ventana de programación.
  static const ventana = Duration(hours: 48);

  /// Una alarma de una toma que empezó hace menos de esto puede estar sonando
  /// (o a punto de abrir su pantalla): no es sobrante y no se cancela. La
  /// cancela la pantalla de toma al confirmar.
  static const margenSonando = Duration(minutes: 30);

  Future<void> reprogramar() async {
    try {
      final ahora = reloj.ahora();
      final pautas = await medicacion.observarPautas().first;
      final pautaDeVersion = <String, Pauta>{for (final p in pautas) p.id: p};
      final meds = {
        for (final m in await medicacion.observarMedicamentos().first) m.id: m,
      };
      final versiones = [
        for (final p in pautas) MedicacionRepositorio.aVersion(p),
      ];
      final tomas = proximasTomas(
        versiones: versiones,
        desde: ahora,
        hasta: ahora.add(ventana),
      );
      final recientes = proximasTomas(
        versiones: versiones,
        desde: ahora.subtract(margenSonando),
        hasta: ahora,
      );
      for (final t in tomas) {
        await medicacion.asegurarToma(t);
      }

      // Rondas del control por horas en la misma ventana.
      final zona = contexto.zonaHoraria;
      var rondas = const <RondaControl>[];
      var rondasRecientes = const <RondaControl>[];
      final control = this.control;
      if (control != null) {
        final ajustes = await control.ajustes();
        final instantes = [
          for (final t in proximasTomas(
            versiones: versiones,
            desde: ahora.subtract(margenSonando + margenTomaRonda),
            hasta: ahora.add(ventana + margenTomaRonda),
          ))
            t.previstaPara,
        ];
        rondas = rondasControl(
          ajustes: ajustes,
          zona: zona,
          desde: ahora,
          hasta: ahora.add(ventana),
          tomas: instantes,
        );
        rondasRecientes = rondasControl(
          ajustes: ajustes,
          zona: zona,
          desde: ahora.subtract(margenSonando),
          hasta: ahora,
          tomas: instantes,
        );
      }

      final estado = await servicio.estado();
      final programadas = estado.programadas.toSet();
      final previo = {
        for (final MapEntry(:key, :value) in (await eventos.ultimosPorSujeto(
          TipoEvento.alarmaProgramada,
          [
            for (final t in tomas)
              if (programadas.contains(t.id)) t.id,
            for (final r in rondas)
              if (programadas.contains(r.id)) r.id,
          ],
        )).entries)
          key: EventosRepositorio.payloadDe(value),
      };
      final audioDeVoz = <String?, String?>{};
      Future<String?> frase(UsoFrase uso, String? vozId) async {
        final clave = '${uso.nombre}:$vozId';
        if (audioDeVoz.containsKey(clave)) return audioDeVoz[clave];
        String? ruta;
        try {
          ruta = (await voces?.fraseSonora(uso, vozPreferida: vozId))?.ruta;
        } catch (_) {
          ruta = null;
        }
        return audioDeVoz[clave] = ruta;
      }

      final alarmas = <_Alarma>[
        for (final t in tomas)
          (
            id: t.id,
            fecha: t.previstaPara,
            titulo: meds[t.medicamentoId]?.nombreParaPersona ?? '',
            audio: () =>
                frase(UsoFrase.toma, pautaDeVersion[t.pautaVersionId]?.vozId),
            ronda: false,
          ),
        for (final r in rondas)
          (
            id: r.id,
            fecha: r.hora,
            titulo: textoRonda,
            audio: () => frase(UsoFrase.comoEstas, null),
            ronda: true,
          ),
      ]..sort((a, b) => a.fecha.compareTo(b.fecha));

      final nuevas = {
        for (final t in tomas) t.id,
        for (final t in recientes) t.id,
        for (final r in rondas) r.id,
        for (final r in rondasRecientes) r.id,
      };

      var avisado = false;
      Future<void> noProgramada(CodigoAlarma codigo) async {
        if (avisado) return;
        avisado = true;
        await eventos.registrar(
          TipoEvento.alarmaNoProgramada,
          payload: {'codigo': codigo.codigo},
          autor: contexto.personaId,
        );
      }

      for (final a in alarmas) {
        final ruta = await a.audio();
        if (programadas.contains(a.id)) {
          // Ya programada: solo se rehace si cambió la frase que suena o, en
          // una ronda, su hora.
          final p = previo[a.id];
          if (p == null ||
              (p['audio'] == ruta &&
                  (!a.ronda || p['hora'] == a.fecha.millisecondsSinceEpoch))) {
            continue;
          }
          try {
            await servicio.cancelar(a.id);
          } catch (_) {
            continue;
          }
        }
        try {
          await servicio.programar(
            idToma: a.id,
            fecha: a.fecha,
            titulo: a.titulo,
            rutaAudio: ruta,
          );
          await eventos.registrar(
            TipoEvento.alarmaProgramada,
            sujeto: a.id,
            payload: {
              'plataforma': contexto.plataforma,
              'audio': ?ruta,
              if (a.ronda) 'tipo': 'ronda',
              if (a.ronda) 'hora': a.fecha.millisecondsSinceEpoch,
            },
            autor: contexto.personaId,
          );
        } on ErrorAlarma catch (e) {
          await noProgramada(e.codigo);
          if (e.codigo == CodigoAlarma.noImplementado ||
              e.codigo == CodigoAlarma.noDisponible) {
            break;
          }
        } catch (_) {
          await noProgramada(CodigoAlarma.noDisponible);
          break;
        }
      }
      for (final sobrante in programadas.difference(nuevas)) {
        try {
          await servicio.cancelar(sobrante);
        } catch (_) {
          // Una alarma que no se deja cancelar no debe romper nada.
        }
      }
    } catch (_) {
      // Las alarmas nunca bloquean la pantalla.
    }
  }
}

/// Una alarma que hay que programar: de una toma o de una ronda.
typedef _Alarma = ({
  String id,
  DateTime fecha,
  String titulo,
  Future<String?> Function() audio,
  bool ronda,
});
