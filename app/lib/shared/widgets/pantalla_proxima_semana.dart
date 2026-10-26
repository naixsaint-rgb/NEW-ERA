import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/tema/colores.dart';
import '../ios/ios.dart';
import '../l10n_ext.dart';

/// Pantalla reservada: su título, lo que tendrá y cuándo llega.
///
/// Aspecto iOS: cabecera grande y una lista agrupada con dos filas apagadas
/// ("Lo que tendrá" y "Llega en la semana N"). Si se llegó con un push (hay
/// adónde volver), la cabecera trae el botón "Volver". Las [acciones] van
/// debajo.
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
    final l = context.l;
    final c = context.colores;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final router = GoRouter.maybeOf(context);
    final puedeVolver = router != null && router.canPop();
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            titulo: titulo,
            alVolver: puedeVolver ? router.pop : null,
          ),
          const SizedBox(height: 14),
          GrupoLista(
            children: [
              FilaLista(
                apagada: true,
                leading: IconoCuadrado(CupertinoIcons.sparkles, fondo: c.gris),
                titulo: l.tendraTitulo,
                subtitulo: tendra,
              ),
              FilaLista(
                apagada: true,
                leading: IconoCuadrado(CupertinoIcons.calendar, fondo: c.gris),
                titulo: semana,
              ),
            ],
          ),
          ...acciones,
        ],
      ),
    );
  }
}
