import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/base_datos.dart';
import '../../core/providers.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/avatar_familiar.dart';
import '../../shared/widgets/tarjeta_grande.dart';

/// Lista de familiares, solo lectura (la gestión llega en la semana 16).
class CirculoPantalla extends ConsumerWidget {
  const CirculoPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    String rol(String r) => switch (r) {
      'responsable' => l.rolResponsable,
      'cuidador' => l.rolCuidador,
      'apoyo' => l.rolApoyo,
      _ => l.rolLectura,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.pestanaCirculo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (miembros.isEmpty) Text(l.sinFamiliares, style: t.bodyLarge),
          for (final m in miembros)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TarjetaGrande(
                child: Row(
                  children: [
                    AvatarFamiliar(miembro: m, tamano: 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.nombre, style: t.titleMedium),
                          Text(
                            l.relacionYRol(m.relacion, rol(m.rol)),
                            style: t.bodyMedium,
                          ),
                          if (m.ordenEscalado != null)
                            Text(
                              l.ordenDeAviso(m.ordenEscalado!),
                              style: t.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          TarjetaGrande(
            color: const Color(0xFFF5F5F5),
            child: Text(l.circuloGestion, style: t.bodyLarge),
          ),
        ],
      ),
    );
  }
}
