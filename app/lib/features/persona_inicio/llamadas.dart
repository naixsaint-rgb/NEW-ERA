import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/providers.dart';

/// Llamadas de la persona (inicio y toma): a quién se llama y qué se anota.

/// Familiar 1: el de menor `ordenEscalado`; si nadie tiene orden, el primero.
Miembro? primerFamiliar(List<Miembro> miembros) {
  final conOrden = miembros.where((m) => m.ordenEscalado != null).toList()
    ..sort((a, b) => a.ordenEscalado!.compareTo(b.ordenEscalado!));
  if (conOrden.isNotEmpty) return conOrden.first;
  return miembros.isEmpty ? null : miembros.first;
}

/// Llama a [miembro] (deja `llamada_iniciada` y abre `tel:`).
///
/// Con [ayuda], antes deja `ayuda_pedida`. Si [miembro] es nulo (no hay
/// familiares), solo se anota la ayuda.
Future<void> llamarDesdePersona(
  WidgetRef ref,
  Miembro? miembro, {
  required bool ayuda,
}) async {
  final eventos = ref.read(eventosRepositorioProvider);
  if (ayuda) {
    await eventos.registrar(TipoEvento.ayudaPedida);
  }
  if (miembro == null) return;
  await eventos.registrar(
    TipoEvento.llamadaIniciada,
    payload: {'miembroId': miembro.id},
  );
  final telefono = miembro.telefono;
  if (telefono != null && telefono.isNotEmpty) {
    try {
      await ref.read(abrirEnlaceProvider)(Uri(scheme: 'tel', path: telefono));
    } catch (_) {
      // Sin teléfono en este aparato: no pasa nada.
    }
  }
}
