import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/semilla_demo.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/tarjeta_grande.dart';

/// Ajustes mínimos de la semana 1: cambiar perfil y cargar datos de ejemplo.
class AjustesPantalla extends ConsumerWidget {
  const AjustesPantalla({super.key});

  Future<void> _cargarEjemplo(BuildContext context, WidgetRef ref) async {
    final l = context.l;
    final mensajero = ScaffoldMessenger.of(context);
    final db = ref.read(baseDatosProvider);
    if (await SemillaDemo.hayMedicamentos(db)) {
      mensajero.showSnackBar(SnackBar(content: Text(l.ejemploYaCargado)));
      return;
    }
    await SemillaDemo.sembrar(
      db: db,
      contexto: ref.read(contextoProvider),
      reloj: ref.read(relojProvider),
      azar: ref.read(azarProvider),
    );
    mensajero.showSnackBar(SnackBar(content: Text(l.ejemploCargado)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final contexto = ref.watch(contextoProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.pestanaAjustes)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TarjetaGrande(
            onTap: () async {
              await ref.read(sesionProvider.notifier).cambiarPerfil();
              if (context.mounted) context.go(Rutas.perfil);
            },
            child: ListTile(
              leading: const Icon(Icons.switch_account),
              title: Text(l.cambiarPerfil),
              subtitle: Text(l.cambiarPerfilAyuda),
            ),
          ),
          const SizedBox(height: 12),
          TarjetaGrande(
            onTap: () => _cargarEjemplo(context, ref),
            child: ListTile(
              leading: const Icon(Icons.dataset),
              title: Text(l.cargarEjemplo),
              subtitle: Text(l.cargarEjemploAyuda),
            ),
          ),
          const SizedBox(height: 12),
          TarjetaGrande(
            color: const Color(0xFFF5F5F5),
            child: Text(
              l.ajustesPlataforma(contexto.plataforma),
              style: t.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          TarjetaGrande(
            color: const Color(0xFFF5F5F5),
            child: Text(l.ajustesMas, style: t.bodyLarge),
          ),
        ],
      ),
    );
  }
}
