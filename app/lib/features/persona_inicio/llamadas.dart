import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/providers.dart';

/// Llamadas de la persona (inicio y toma): a quién se llama y qué se anota.

/// Familiares por orden de aviso: si alguno tiene `ordenEscalado`, solo esos,
/// de menor a mayor (los empates, en el orden de la lista); si nadie lo
/// tiene, todos en el orden de la lista. Es la única regla: la usan el
/// inicio, la toma, la pregunta, Resumen y "Quién recibe los avisos".
List<Miembro> familiaresPorOrden(List<Miembro> miembros) {
  final conOrden = [
    for (var i = 0; i < miembros.length; i++)
      if (miembros[i].ordenEscalado != null) (i, miembros[i]),
  ];
  if (conOrden.isEmpty) return List.of(miembros);
  conOrden.sort((a, b) {
    final c = a.$2.ordenEscalado!.compareTo(b.$2.ordenEscalado!);
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });
  return [for (final (_, m) in conOrden) m];
}

/// Familiar 1: el primero de [familiaresPorOrden], o nulo si no hay nadie.
Miembro? primerFamiliar(List<Miembro> miembros) {
  final orden = familiaresPorOrden(miembros);
  return orden.isEmpty ? null : orden.first;
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
