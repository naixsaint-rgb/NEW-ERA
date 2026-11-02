import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/avisos/canal_avisos.dart';
import '../../core/avisos/envio_avisos.dart';
import '../../core/avisos/programador_avisos.dart';
import '../../core/contexto.dart';
import '../../core/cripto/tema_aviso.dart';
import '../../core/providers.dart';
import '../hoy/dominio/control_horas.dart';
import '../hoy/dominio/tomas.dart';
import 'dominio/que_avisar.dart';
import 'planificador_avisos.dart';
import 'segundo_plano.dart';

/// ntfy.sh en el móvil; en la demo web, el simulado (no sale nada).
final canalAvisosProvider = Provider<CanalAvisos>(
  (ref) => kIsWeb ? CanalAvisosSimulado() : CanalNtfy(),
);

/// Tema de ntfy de un familiar (nulo sin clave del círculo, como en la demo
/// web).
final temaAvisoProvider = FutureProvider.family<String?, String>(
  (ref, miembroId) =>
      TemaAviso.desdeAlmacen(ref.watch(almacenSeguroProvider), miembroId),
);

/// Envío de avisos (idempotente) y aviso de prueba.
final envioAvisosProvider = Provider<EnvioAvisos>((ref) {
  final almacen = ref.watch(almacenSeguroProvider);
  return EnvioAvisos(
    db: ref.watch(baseDatosProvider),
    eventos: ref.watch(eventosRepositorioProvider),
    canal: ref.watch(canalAvisosProvider),
    reloj: ref.watch(relojProvider),
    contexto: ref.watch(contextoProvider),
    tema: (id) => TemaAviso.desdeAlmacen(almacen, id),
  );
});

/// Revisiones con la app cerrada: en Android, con
/// `android_alarm_manager_plus`; en iOS y web, ninguna.
final programadorAvisosProvider = Provider<ProgramadorAvisos>((ref) {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return const ProgramadorAvisosAndroid(revisarAvisosEnSegundoPlano);
  }
  return const ProgramadorAvisosNulo();
});

final planificadorAvisosProvider = Provider<PlanificadorAvisos>(
  (ref) => PlanificadorAvisos(
    programador: ref.watch(programadorAvisosProvider),
    medicacion: ref.watch(medicacionRepositorioProvider),
    control: ref.watch(controlHorasRepositorioProvider),
    reloj: ref.watch(relojProvider),
    contexto: ref.watch(contextoProvider),
    config: ref.watch(configEscaladoProvider),
  ),
);

/// Lo que toca avisar ahora ([avisosQueTocan]), solo en el móvil de la
/// persona: se recalcula cada 15 segundos y con cada cambio de la base.
final avisosQueTocanProvider = Provider<List<AvisoPendiente>>((ref) {
  if (ref.watch(sesionProvider).perfil != PerfilApp.persona) return const [];
  final tomas = ref.watch(tomasProvider).value;
  final situaciones = ref.watch(avisosDeHoyProvider).value;
  final ahora = ref.watch(ahoraProvider).value;
  if (tomas == null || situaciones == null || ahora == null) return const [];
  return avisosQueTocan(
    tomas: tomas,
    control: ref.watch(controlDeHoyProvider).value,
    situaciones: situaciones,
    config: ref.watch(configEscaladoProvider),
    ahora: ahora,
  );
});
