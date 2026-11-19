import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/i18n/fechas.dart';
import '../../../core/tema/colores.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../../../shared/widgets/tarjeta_grande.dart';
import '../dominio/control_horas.dart';
import '../dominio/tomas.dart';
import 'control_hoy.dart' show textoRespuestaControl;
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

/// Estado de la celda "Respondió" de un día: todas las rondas pasadas
/// contestadas (completa), algunas (parcial), ninguna (fallida) o sin rondas
/// (vacía); hoy, siempre en azul.
EstadoCelda estadoCeldaRespuestas(ControlDelDia d, {required bool esHoy}) {
  if (esHoy) return EstadoCelda.hoy;
  if (d.contestadas + d.sinRespuesta.length == 0) return EstadoCelda.vacia;
  if (d.sinRespuesta.isEmpty) return EstadoCelda.completa;
  return d.contestadas > 0 ? EstadoCelda.parcial : EstadoCelda.fallida;
}

/// Vista "Semana" (maqueta D-Semana): los últimos 7 días, hoy a la derecha,
/// con las tomas y el control por horas.
class VistaSemana extends ConsumerWidget {
  const VistaSemana({super.key, required this.datos});

  /// Ancho de la columna de etiquetas de la rejilla.
  static const anchoEtiqueta = 64.0;

  final TomasPorDia datos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final control = ref.watch(controlSemanaProvider).value;
    final cuentaControl = control?.cuentaSemana ?? const CuentaControl();
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
                    child: Text(
                      l.hoyControlCuenta(
                        cuentaControl.contestadas,
                        cuentaControl.sinRespuesta,
                      ),
                      style: secundario,
                    ),
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
                    child: TextoQueCabe(
                      l.hoyFilaTomas,
                      estilo: t.labelMedium?.copyWith(color: c.texto),
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
              if (control != null) ...[
                _FilaControl(
                  etiqueta: l.hoyFilaRespondio,
                  celdas: [
                    for (final d in control.dias)
                      _celdaRespondio(l, d, esHoy: d == control.hoy),
                  ],
                ),
                const SizedBox(height: 10),
                _FilaControl(
                  etiqueta: l.hoyFilaEstuvo,
                  celdas: [for (final d in control.dias) _celdaEstuvo(l, c, d)],
                ),
              ],
            ],
          ),
        ),
        if (control != null) ...[
          separacionBloques,
          _GrupoDiaADia(control: control),
          separacionBloques,
          _GrupoLoQueDijo(control: control),
        ],
      ],
    );
  }

  CeldaDia _celdaRespondio(
    AppLocalizations l,
    ControlDelDia d, {
    required bool esHoy,
  }) {
    final sin = d.sinRespuesta.length;
    final hechas = d.contestadas;
    final dia = fechaLarga(_pared(d));
    if (hechas + sin == 0) {
      return CeldaDia(
        estado: estadoCeldaRespuestas(d, esHoy: esHoy),
        etiquetaSemantica: l.hoySemanticaDiaSinRondas(dia),
      );
    }
    return CeldaDia(
      estado: estadoCeldaRespuestas(d, esHoy: esHoy),
      texto: '$hechas/${hechas + sin}',
      etiquetaSemantica: l.hoySemanticaRondasDia(dia, hechas, sin),
    );
  }

  CeldaDia _celdaEstuvo(AppLocalizations l, ColoresApp c, ControlDelDia d) {
    final estado = d.estadoDelDia;
    final dia = fechaLarga(_pared(d));
    if (estado == null) {
      return CeldaDia(
        estado: EstadoCelda.vacia,
        etiquetaSemantica: l.hoySemanticaDiaSinRondas(dia),
      );
    }
    final (celda, icono) = switch (estado) {
      'mal' => (EstadoCelda.fallida, CupertinoIcons.exclamationmark),
      'regular' => (EstadoCelda.parcial, CupertinoIcons.minus),
      _ => (EstadoCelda.completa, CupertinoIcons.checkmark_alt),
    };
    final colores = CeldaDia.coloresDe(celda, c);
    return CeldaDia(
      estado: celda,
      hijo: Icon(icono, size: 18, color: colores.texto),
      etiquetaSemantica: l.hoySemanticaEstuvo(
        dia,
        textoRespuestaControl(l, TipoPreguntaControl.estado, estado),
      ),
    );
  }

  /// La fecha de [d] (`yyyy-MM-dd`) sin zona, para formatearla.
  static DateTime _pared(ControlDelDia d) => DateTime.parse('${d.fecha}T00:00');
}

/// Una fila de la rejilla de la semana: la etiqueta y siete celdas.
class _FilaControl extends StatelessWidget {
  const _FilaControl({required this.etiqueta, required this.celdas});

  final String etiqueta;
  final List<Widget> celdas;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: VistaSemana.anchoEtiqueta,
          child: TextoQueCabe(
            etiqueta,
            estilo: t.labelMedium?.copyWith(color: c.texto),
          ),
        ),
        for (final x in celdas)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: x,
            ),
          ),
      ],
    );
  }
}

/// Por día: las rondas contestadas y sin respuesta, cómo estuvo y el dolor.
class _GrupoDiaADia extends StatelessWidget {
  const _GrupoDiaADia({required this.control});

  final ControlSemana control;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final filas = <Widget>[];
    for (final d in control.dias.reversed) {
      final cuenta = contarControl([d]);
      if (cuenta.contestadas + cuenta.sinRespuesta == 0) continue;
      final estado = d.estadoDelDia;
      final dolor = d.dolorDelDia;
      final partes = [
        if (estado != null)
          textoRespuestaControl(l, TipoPreguntaControl.estado, estado),
        if (dolor != null)
          textoRespuestaControl(l, TipoPreguntaControl.dolor, dolor),
      ];
      final resumen = l.hoyControlCuenta(
        cuenta.contestadas,
        cuenta.sinRespuesta,
      );
      filas.add(
        FilaLista(
          titulo: fechaLarga(VistaSemana._pared(d)),
          subtitulo: partes.isEmpty
              ? resumen
              : '${partes.join(' · ')}\n$resumen',
        ),
      );
    }
    return GrupoLista(
      titulo: l.hoyDiaADia,
      children: filas.isEmpty
          ? [FilaLista(titulo: l.hoySinRondasSemana, apagada: true)]
          : filas,
    );
  }
}

/// Lo que contestó a «¿Qué harás?» cada día de la semana.
class _GrupoLoQueDijo extends StatelessWidget {
  const _GrupoLoQueDijo({required this.control});

  final ControlSemana control;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final filas = <Widget>[];
    for (final d in control.dias.reversed) {
      final veces = d.vecesDe(TipoPreguntaControl.plan);
      if (veces.isEmpty) continue;
      final ordenadas = veces.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      filas.add(
        FilaLista(
          titulo: fechaLarga(VistaSemana._pared(d)),
          subtitulo: [
            for (final e in ordenadas)
              l.hoyLoQueDijoVeces(
                textoRespuestaControl(l, TipoPreguntaControl.plan, e.key),
                e.value,
              ),
          ].join(' · '),
        ),
      );
    }
    return GrupoLista(
      titulo: l.hoyLoQueDijo,
      children: filas.isEmpty
          ? [FilaLista(titulo: l.hoySinLoQueDijo, apagada: true)]
          : filas,
    );
  }
}
