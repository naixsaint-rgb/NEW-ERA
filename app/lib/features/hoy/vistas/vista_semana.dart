import 'package:flutter/material.dart';

import '../../../core/i18n/fechas.dart';
import '../../../core/tema/colores.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../../../shared/widgets/tarjeta_grande.dart';
import '../dominio/tomas.dart';
import 'piezas_hoy.dart';

/// Estado de la celda de un día en la fila "Tomas".
EstadoCelda estadoCeldaDia(CuentaTomas c, {required bool esHoy}) {
  if (esHoy) return EstadoCelda.hoy;
  if (c.previstas == 0) return EstadoCelda.vacia;
  if (c.hechas == c.previstas) return EstadoCelda.completa;
  if (c.hechas > 0) return EstadoCelda.parcial;
  if (c.noConfirmadas > 0 && c.pendientes == 0) return EstadoCelda.fallida;
  return EstadoCelda.futura;
}

String _inicial(AppLocalizations l, int diaSemana) => switch (diaSemana) {
  DateTime.monday => l.hoyInicialLunes,
  DateTime.tuesday => l.hoyInicialMartes,
  DateTime.wednesday => l.hoyInicialMiercoles,
  DateTime.thursday => l.hoyInicialJueves,
  DateTime.friday => l.hoyInicialViernes,
  DateTime.saturday => l.hoyInicialSabado,
  _ => l.hoyInicialDomingo,
};

/// Vista "Semana" (maqueta D-Semana): los últimos 7 días, hoy a la derecha.
class VistaSemana extends StatelessWidget {
  const VistaSemana({super.key, required this.datos});

  /// Ancho de la columna de etiquetas de la rejilla.
  static const anchoEtiqueta = 64.0;

  final TomasPorDia datos;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final dias = datos.ultimos7;
    final cuentas = [for (final d in dias) contarTomas(datos.de(d))];
    var hechas = 0, previstas = 0;
    for (final x in cuentas) {
      hechas += x.hechas;
      previstas += x.previstas;
    }
    final quedan = contarTomas(datos.de(datos.hoy)).pendientes;
    final primero = dias.first.pared;
    final ultimo = dias.last.pared;
    final desde = primero.month == ultimo.month
        ? '${primero.day}'
        : fechaCorta(primero);
    final secundario = t.bodySmall?.copyWith(color: c.textoSecundario);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TarjetaGrande(
          margen: EdgeInsets.zero,
          relleno: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.hoyUltimos7Dias(desde, fechaCorta(ultimo)),
                style: t.labelMedium?.copyWith(color: c.textoSecundario),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Semantics(
                      container: true,
                      label: l.hoySemanticaTotales(hechas, previstas, quedan),
                      excludeSemantics: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: '$hechas',
                              children: [
                                TextSpan(
                                  text: ' ${l.hoyDeTotal(previstas)}',
                                  style: t.titleSmall?.copyWith(
                                    color: c.textoSecundario,
                                  ),
                                ),
                              ],
                            ),
                            style: t.displayMedium?.copyWith(
                              color: c.texto,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.hoyTomasHechasQuedan(quedan),
                            style: secundario,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.hoyRespuestasLlega(5), style: secundario),
                  ),
                ],
              ),
            ],
          ),
        ),
        separacionBloques,
        TarjetaGrande(
          margen: EdgeInsets.zero,
          relleno: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Row(
                  children: [
                    const SizedBox(width: anchoEtiqueta),
                    for (final d in dias)
                      Expanded(
                        child: Text(
                          _inicial(l, d.diaSemana),
                          textAlign: TextAlign.center,
                          style: t.labelMedium?.copyWith(
                            color: d == datos.hoy ? c.azul : c.textoSecundario,
                            fontWeight: d == datos.hoy
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: anchoEtiqueta,
                    child: Text(
                      l.hoyFilaTomas,
                      style: t.labelMedium?.copyWith(color: c.texto),
                    ),
                  ),
                  for (var i = 0; i < dias.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: CeldaDia(
                          estado: estadoCeldaDia(
                            cuentas[i],
                            esHoy: dias[i] == datos.hoy,
                          ),
                          texto: cuentas[i].previstas == 0
                              ? null
                              : '${cuentas[i].hechas}/${cuentas[i].previstas}',
                          etiquetaSemantica: cuentas[i].previstas == 0
                              ? l.hoySemanticaCeldaSinTomas(
                                  fechaLarga(dias[i].pared),
                                )
                              : l.hoySemanticaCeldaDia(
                                  fechaLarga(dias[i].pared),
                                  cuentas[i].hechas,
                                  cuentas[i].previstas,
                                ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              MergeSemantics(
                child: Row(
                  children: [
                    SizedBox(
                      width: anchoEtiqueta,
                      child: Text(l.hoyFilaRespondio, style: secundario),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(l.llegaEnSemana(5), style: secundario),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        separacionBloques,
        GrupoLista(
          titulo: l.hoyLoQueDijo,
          children: [
            FilaLlegaPronto(
              titulo: l.hoyLoQueDijoAviso,
              subtitulo: l.llegaEnSemana(5),
            ),
          ],
        ),
      ],
    );
  }
}
