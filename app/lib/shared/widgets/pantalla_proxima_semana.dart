import 'package:flutter/material.dart';

import '../l10n_ext.dart';
import 'tarjeta_grande.dart';

/// Pantalla reservada: su título, lo que tendrá y cuándo llega.
class PantallaProximaSemana extends StatelessWidget {
  const PantallaProximaSemana({
    super.key,
    required this.titulo,
    required this.tendra,
    required this.semana,
    this.acciones = const [],
  });

  final String titulo;
  final String tendra;
  final String semana;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TarjetaGrande(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.tendraTitulo, style: t.titleMedium),
                const SizedBox(height: 8),
                Text(tendra, style: t.bodyLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.event_available),
                    const SizedBox(width: 8),
                    Flexible(child: Text(semana, style: t.titleMedium)),
                  ],
                ),
              ],
            ),
          ),
          ...acciones,
        ],
      ),
    );
  }
}
