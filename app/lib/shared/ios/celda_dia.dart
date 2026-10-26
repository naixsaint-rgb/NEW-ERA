import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';

/// Estado de una [CeldaDia].
enum EstadoCelda {
  /// Todo hecho: verde, texto blanco (negro de noche).
  completa,

  /// A medias: naranja de relleno, texto oscuro.
  parcial,

  /// No confirmada: rojo, texto blanco (negro de noche).
  fallida,

  /// Hoy o ahora: azul claro con borde azul.
  hoy,

  /// Todavía no ha llegado: relleno suave.
  futura,

  /// Sin nada ese día: solo un borde fino.
  vacia,
}

/// Celda de las rejillas de semana y pastillero (34–38 de alto).
///
/// Lleva [texto] ("4/5") o [hijo] (un visto, un mini pictograma). Ningún
/// estado va solo por color: pasa [etiquetaSemantica] ("Lunes 09:00: tomada")
/// cuando la celda no tiene texto.
class CeldaDia extends StatelessWidget {
  const CeldaDia({
    super.key,
    required this.estado,
    this.texto,
    this.hijo,
    this.alto = 36,
    this.etiquetaSemantica,
  });

  final EstadoCelda estado;
  final String? texto;
  final Widget? hijo;
  final double alto;
  final String? etiquetaSemantica;

  /// Fondo, texto y borde (si lo hay) de cada estado.
  static ({Color fondo, Color texto, Color? borde}) coloresDe(
    EstadoCelda estado,
    ColoresApp c,
  ) => switch (estado) {
    EstadoCelda.completa => (fondo: c.verde, texto: c.sobreVerde, borde: null),
    EstadoCelda.parcial => (
      fondo: c.naranjaRelleno,
      texto: c.sobreNaranja,
      borde: null,
    ),
    EstadoCelda.fallida => (fondo: c.rojo, texto: c.sobreRojo, borde: null),
    EstadoCelda.hoy => (
      fondo: c.azulClaro,
      texto: c.azulSobreTinte,
      borde: c.azul,
    ),
    EstadoCelda.futura => (
      fondo: c.rellenoSuave,
      texto: c.textoSecundario,
      borde: null,
    ),
    EstadoCelda.vacia => (
      fondo: Colors.transparent,
      texto: c.textoSecundario,
      borde: c.separador,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colores = coloresDe(estado, context.colores);
    final borde = colores.borde;
    final texto = this.texto;
    Widget? contenido = hijo;
    if (contenido == null && texto != null) {
      contenido = FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          texto,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: colores.texto, fontWeight: FontWeight.w700),
        ),
      );
    }
    final celda = Container(
      height: alto,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: BorderRadius.circular(8),
        border: borde == null
            ? null
            : Border.all(
                color: borde,
                width: estado == EstadoCelda.hoy ? 2 : 1,
              ),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: colores.texto, size: 16),
        child: contenido ?? const SizedBox.shrink(),
      ),
    );
    final etiqueta = etiquetaSemantica;
    if (etiqueta == null) return celda;
    return Semantics(label: etiqueta, excludeSemantics: true, child: celda);
  }
}
