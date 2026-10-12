import 'dart:async';

import 'package:safety_core/safety_core.dart';

import '../../contexto.dart';
import '../../db/repositorios/eventos_repositorio.dart';
import '../../db/repositorios/medicacion_repositorio.dart';
import 'servicio_alarmas.dart';

/// Programa las alarmas de las tomas de las próximas 48 horas.
///
/// Inserta cada toma (`INSERT OR IGNORE`), programa la alarma y cancela las
/// sobrantes. Con `no_implementado` o `no_disponible` deja un solo
/// `alarma_no_programada` por arranque; nunca bloquea la pantalla ni lanza.
class ProgramadorAlarmas {
  ProgramadorAlarmas({
    required this.servicio,
    required this.medicacion,
    required this.eventos,
    required this.reloj,
    required this.contexto,
  });

  final ServicioAlarmas servicio;
  final MedicacionRepositorio medicacion;
  final EventosRepositorio eventos;
  final Reloj reloj;
  final ContextoApp contexto;

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
      final estado = await servicio.estado();
      final programadas = estado.programadas.toSet();
      final nuevas = {
        for (final t in tomas) t.id,
        for (final t in recientes) t.id,
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

      for (final t in tomas) {
        if (programadas.contains(t.id)) continue;
        try {
          await servicio.programar(
            idToma: t.id,
            fecha: t.previstaPara,
            titulo: meds[t.medicamentoId]?.nombreParaPersona ?? '',
          );
          await eventos.registrar(
            TipoEvento.alarmaProgramada,
            sujeto: t.id,
            payload: {'plataforma': contexto.plataforma},
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
