import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/boton_grande.dart';

/// Pregunta de la persona (maqueta C-Persona). Provisional: título, aviso de
/// que está en construcción y "Volver al inicio".
///
/// Con [prueba] (desde la familia) no guarda nada y vuelve a Medicación.
class PreguntaPantalla extends StatelessWidget {
  const PreguntaPantalla({super.key, this.prueba = false});

  final bool prueba;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      key: ClavesUi.pregunta,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(l.preguntaTitulo, style: t.headlineLarge),
              ),
              const SizedBox(height: 12),
              Text(
                l.enConstruccion,
                style: t.bodyLarge?.copyWith(color: c.textoSecundario),
              ),
              if (prueba) ...[
                const SizedBox(height: 8),
                Text(
                  l.preguntaModoPrueba,
                  style: t.bodyLarge?.copyWith(color: c.textoSecundario),
                ),
              ],
              const Spacer(),
              BotonGrande(
                key: ClavesUi.volverAlInicio,
                texto: l.volverAlInicio,
                icono: CupertinoIcons.chevron_back,
                color: c.rellenoSuave,
                altura: 72,
                tamanoTexto: 22,
                onPressed: () => context.go(
                  prueba ? Rutas.pestana('medicacion') : Rutas.persona,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
