import 'package:safety_core/safety_core.dart';

import '../../core/avisos/programador_avisos.dart';
import '../../core/contexto.dart';
import '../../core/db/repositorios/control_horas_repositorio.dart';
import '../../core/db/repositorios/medicacion_repositorio.dart';
import 'dominio/que_avisar.dart';

/// Programa las revisiones de avisos de las próximas 48 horas en el móvil de
/// la persona ([instantesDeRevision]), con las mismas tomas y rondas que sus
/// alarmas. Se llama cada vez que se reprograman las alarmas. Sin segundo
/// plano (iOS, web) no hace nada: los avisos salen con la app abierta.
///
/// Las revisiones que sobran (una pauta retirada) no se cancelan: al saltar
/// miran la base y no encuentran nada que avisar.
class PlanificadorAvisos {
  PlanificadorAvisos({
    required this.programador,
    required this.medicacion,
    required this.control,
    required this.reloj,
    required this.contexto,
    this.config = const ConfigEscalado(),
  });

  final ProgramadorAvisos programador;
  final MedicacionRepositorio medicacion;
  final ControlHorasRepositorio control;
  final Reloj reloj;
  final ContextoApp contexto;
  final ConfigEscalado config;

  static const ventana = Duration(hours: 48);

  /// Devuelve cuántas revisiones quedaron programadas. Nunca lanza.
  Future<int> reprogramar() async {
    if (!programador.enSegundoPlano) return 0;
    try {
      final ahora = reloj.ahora();
      final desde = ahora.subtract(const Duration(minutes: 15));
      final versiones = [
        for (final p in await medicacion.observarPautas().first)
          MedicacionRepositorio.aVersion(p),
      ];
      final instantes = [
        for (final t in proximasTomas(
          versiones: versiones,
          desde: desde.subtract(margenTomaRonda),
          hasta: ahora.add(ventana + margenTomaRonda),
        ))
          t.previstaPara,
      ];
      final rondas = rondasControl(
        ajustes: await control.ajustes(),
        zona: contexto.zonaHoraria,
        desde: desde,
        hasta: ahora.add(ventana),
        tomas: instantes,
      );
      return await programador.programar(
        instantesDeRevision(
          tomas: [
            for (final t in instantes)
              if (!t.isBefore(desde) && t.isBefore(ahora.add(ventana))) t,
          ],
          rondas: rondas,
          config: config,
          ahora: ahora,
        ),
      );
    } catch (_) {
      return 0;
    }
  }
}
