import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/tema/colores.dart';
import 'titulo_seccion.dart';

/// Lista agrupada de iOS: contenedor de la tarjeta (blanco; oscuro de noche)
/// con radio 14 y separadores sangrados [sangria] px desde la izquierda.
///
/// Con [titulo] pone un [TituloSeccion] encima; con [pie], un texto gris
/// debajo.
class GrupoLista extends StatelessWidget {
  const GrupoLista({
    super.key,
    required this.children,
    this.titulo,
    this.pie,
    this.sangria = 58,
    this.radio = 14,
    this.color,
  });

  final List<Widget> children;
  final String? titulo;
  final String? pie;

  /// Sangría del separador: 58 con icono de 30; 84 con foto de 56.
  final double sangria;
  final double radio;

  /// Fondo; por defecto, `tarjeta`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final filas = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        filas.add(
          Padding(
            padding: EdgeInsetsDirectional.only(start: sangria),
            child: SizedBox(height: 1, child: ColoredBox(color: c.separador)),
          ),
        );
      }
      filas.add(children[i]);
    }
    final grupo = Material(
      color: color ?? c.tarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radio)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: filas,
      ),
    );
    final titulo = this.titulo;
    final pie = this.pie;
    if (titulo == null && pie == null) return grupo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titulo != null) TituloSeccion(titulo),
        grupo,
        if (pie != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 0),
            child: Text(
              pie,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: c.textoSecundario),
            ),
          ),
      ],
    );
  }
}

/// Fila de una [GrupoLista]: 56 de alto mínimo (76 con foto), relleno 16 a
/// los lados.
///
/// - [leading]: un `IconoCuadrado`, una `FotoPastilla`...
/// - [titulo] 15/600 y [subtitulo] 13 gris.
/// - [detalle]: texto gris a la derecha ("Automático").
/// - [trailing]: un widget a la derecha (interruptor, etiqueta de estado).
/// - [conChevron]: flecha de "ver más"; por defecto, si hay [onTap].
/// - [apagada]: fila gris de algo que aún no existe ("Llega en la semana 5").
///
/// Se lee como un solo elemento (título y subtítulo juntos).
class FilaLista extends StatelessWidget {
  const FilaLista({
    super.key,
    required this.titulo,
    this.leading,
    this.subtitulo,
    this.detalle,
    this.trailing,
    this.onTap,
    this.conChevron,
    this.apagada = false,
    this.altoMinimo = 56,
    this.colorTitulo,
    this.etiquetaSemantica,
  });

  final String titulo;
  final Widget? leading;
  final String? subtitulo;
  final String? detalle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool? conChevron;
  final bool apagada;
  final double altoMinimo;

  /// Color del título (por defecto `texto`; gris si [apagada]).
  final Color? colorTitulo;

  /// Sustituye a lo que se leería (título y subtítulo).
  final String? etiquetaSemantica;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final chevron = conChevron ?? onTap != null;
    final leading = this.leading;
    final subtitulo = this.subtitulo;
    final detalle = this.detalle;
    final trailing = this.trailing;
    final contenido = ConstrainedBox(
      constraints: BoxConstraints(minHeight: altoMinimo),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: t.titleSmall?.copyWith(
                      color: apagada
                          ? c.textoSecundario
                          : (colorTitulo ?? c.texto),
                      fontWeight: apagada ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                  if (subtitulo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitulo,
                        style: t.bodySmall?.copyWith(color: c.textoSecundario),
                      ),
                    ),
                ],
              ),
            ),
            if (detalle != null) ...[
              const SizedBox(width: 8),
              Text(
                detalle,
                style: t.bodyMedium?.copyWith(color: c.textoSecundario),
              ),
            ],
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
            if (chevron) ...[
              const SizedBox(width: 6),
              ExcludeSemantics(
                child: Icon(
                  CupertinoIcons.chevron_forward,
                  size: 18,
                  color: c.chevron,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    final etiqueta = etiquetaSemantica;
    final conTap = onTap == null
        ? contenido
        : InkWell(onTap: onTap, child: contenido);
    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        label: etiqueta,
        excludeSemantics: etiqueta != null,
        onTap: etiqueta != null ? onTap : null,
        child: conTap,
      ),
    );
  }
}
