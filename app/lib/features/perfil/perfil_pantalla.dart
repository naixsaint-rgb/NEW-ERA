import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/contexto.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/tarjeta_grande.dart';

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
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
            shrinkWrap: true,
            children: [
              CabeceraGrande(titulo: l.perfilTitulo, reservarBotonMas: false),
              const SizedBox(height: 8),
              Text(
                l.perfilAyuda,
                style: t.bodyLarge?.copyWith(color: c.textoSecundario),
              ),
              const SizedBox(height: 24),
              _TarjetaPerfil(
                texto: l.perfilPersona,
                icono: CupertinoIcons.person_fill,
                fondo: c.verde,
                simbolo: c.sobreVerde,
                onTap: _ocupado ? null : () => _elegir(PerfilApp.persona),
              ),
              const SizedBox(height: 16),
              _TarjetaPerfil(
                texto: l.perfilFamilia,
                icono: CupertinoIcons.person_2_fill,
                fondo: c.azul,
                simbolo: c.sobreAzul,
                onTap: _ocupado ? null : () => _elegir(PerfilApp.familia),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una de las dos elecciones: tarjeta grande (96 de alto como mínimo) con un
/// icono, el texto y la flecha de "elegir".
class _TarjetaPerfil extends StatelessWidget {
  const _TarjetaPerfil({
    required this.texto,
    required this.icono,
    required this.fondo,
    required this.simbolo,
    required this.onTap,
  });

  final String texto;
  final IconData icono;
  final Color fondo;
  final Color simbolo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return TarjetaGrande(
      onTap: onTap,
      radio: 20,
      margen: EdgeInsets.zero,
      relleno: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      conSombra: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(
          children: [
            IconoCuadrado(icono, fondo: fondo, color: simbolo, tamano: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                texto,
                style: t.headlineSmall?.copyWith(color: c.texto),
              ),
            ),
            const SizedBox(width: 8),
            ExcludeSemantics(
              child: Icon(
                CupertinoIcons.chevron_forward,
                size: 20,
                color: c.chevron,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
