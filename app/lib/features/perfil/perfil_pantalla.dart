import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/contexto.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/boton_grande.dart';

/// "¿De quién es este móvil?": guarda el perfil y registra `perfil_elegido`.
class PerfilPantalla extends ConsumerStatefulWidget {
  const PerfilPantalla({super.key});

  @override
  ConsumerState<PerfilPantalla> createState() => _PerfilPantallaState();
}

class _PerfilPantallaState extends ConsumerState<PerfilPantalla> {
  bool _ocupado = false;

  Future<void> _elegir(PerfilApp perfil) async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    await ref.read(sesionProvider.notifier).elegirPerfil(perfil);
    if (mounted) context.go(Rutas.raiz);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l.perfilTitulo,
                    style: t.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(l.perfilAyuda, style: t.bodyLarge),
                const SizedBox(height: 32),
                BotonGrande(
                  texto: l.perfilPersona,
                  icono: Icons.person,
                  color: Colores.verde,
                  altura: 96,
                  onPressed: _ocupado ? null : () => _elegir(PerfilApp.persona),
                ),
                const SizedBox(height: 20),
                BotonGrande(
                  texto: l.perfilFamilia,
                  icono: Icons.groups,
                  color: Colores.azul,
                  altura: 96,
                  onPressed: _ocupado ? null : () => _elegir(PerfilApp.familia),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
