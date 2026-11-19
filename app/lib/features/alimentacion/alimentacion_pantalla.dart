import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/alimentacion_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/foto_imagen.dart';
import '../calendario/campos_agenda.dart' show fechaDeTexto;
import 'dominio/alimentacion.dart';
import 'etiquetas_alimentacion.dart';

enum _Vista { hoy, semana }

/// Alimentación (familia): las cuatro comidas de hoy, los vasos de agua y la
/// semana. Es lo que la familia apunta; viaja por el cartero como fichas.
class AlimentacionPantalla extends ConsumerStatefulWidget {
  const AlimentacionPantalla({super.key});

  @override
  ConsumerState<AlimentacionPantalla> createState() =>
      _AlimentacionPantallaState();
}

class _AlimentacionPantallaState extends ConsumerState<AlimentacionPantalla> {
  _Vista _vista = _Vista.hoy;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final ahora =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final comidas = ref.watch(comidasProvider);
    final vasos = ref.watch(vasosProvider);
    final cargado = comidas.hasValue && vasos.hasValue;
    final hoy = ref.watch(fechaHoyAlimentacionProvider);
    return Scaffold(
      key: ClavesUi.pantallaAlimentacion,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          CabeceraGrande(
            vispera: fechaLarga(aLocal(ahora, zona)),
            titulo: l.pestanaAlimentacion,
          ),
          const SizedBox(height: 10),
          SelectorSegmentos<_Vista>(
            valores: _Vista.values,
            seleccionado: _vista,
            etiqueta: (v) => switch (v) {
              _Vista.hoy => l.alimHoy,
              _Vista.semana => l.alimSemana,
            },
            clave: (v) => ClavesUi.alimVista(v.name),
            alCambiar: (v) => setState(() => _vista = v),
          ),
          const SizedBox(height: 14),
          if (!cargado)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_vista == _Vista.hoy)
            _VistaHoy(
              dia: diaAlimentacion(
                comidas: comidas.requireValue,
                vasos: vasos.requireValue,
                fecha: hoy,
                zona: zona,
              ),
              zona: zona,
            )
          else
            _VistaSemana(
              dias: semanaAlimentacion(
                comidas: comidas.requireValue,
                vasos: vasos.requireValue,
                hoy: hoy,
                zona: zona,
              ),
              hoy: hoy,
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Hoy

class _VistaHoy extends ConsumerWidget {
  const _VistaHoy({required this.dia, required this.zona});

  final DiaAlimentacion dia;
  final String zona;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final filas = <Widget>[
      for (final m in MomentoComida.principales)
        ..._filasDe(context, m, dia.deMomento(m)),
      if (dia.deMomento(MomentoComida.otro).isNotEmpty)
        ..._filasDe(
          context,
          MomentoComida.otro,
          dia.deMomento(MomentoComida.otro),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GrupoLista(titulo: l.alimComidasTitulo, sangria: 58, children: filas),
        const SizedBox(height: 14),
        FilledButton.icon(
          key: ClavesUi.alimAnotar,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: () => context.push(Rutas.comidaNueva(fecha: dia.fecha)),
          icon: const Icon(CupertinoIcons.add),
          label: Text(l.alimAnotarComida),
        ),
        const SizedBox(height: 20),
        _TarjetaAgua(vasos: dia.vasos),
      ],
    );
  }

  /// Una fila por comida anotada del [momento]; si no hay ninguna, una fila
  /// «Sin anotar» (salvo en «otra comida»).
  List<Widget> _filasDe(
    BuildContext context,
    String momento,
    List<Comida> hay,
  ) {
    final l = context.l;
    final c = context.colores;
    if (hay.isEmpty) {
      if (momento == MomentoComida.otro) return const [];
      return [
        FilaLista(
          key: ClavesUi.alimFila(momento),
          leading: IconoCuadrado(
            iconoMomento(momento),
            fondo: c.rellenoSuave,
            color: c.textoSecundario,
          ),
          titulo: etiquetaMomento(l, momento),
          subtitulo: l.alimSinAnotar,
          apagada: true,
          onTap: () => context.push(
            Rutas.comidaNueva(momento: momento, fecha: dia.fecha),
          ),
        ),
      ];
    }
    return [
      for (final x in hay)
        _FilaComida(key: ClavesUi.alimComida(x.id), comida: x, zona: zona),
    ];
  }
}

/// Fila de una comida anotada: hora, cuánto comió, nota y foto.
class _FilaComida extends StatelessWidget {
  const _FilaComida({super.key, required this.comida, required this.zona});

  final Comida comida;
  final String zona;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final hora = horaDeMs(comida.ocurridaEn, zona);
    final cuanto = etiquetaCuanto(l, comida.cuanto);
    final nota = comida.nota;
    final icono = IconoCuadrado(iconoMomento(comida.momento), fondo: c.verde);
    return FilaLista(
      leading: comida.fotoId == null
          ? icono
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: 30,
                child: FotoImagen(
                  fotoId: comida.fotoId,
                  ancho: 30,
                  alto: 30,
                  alternativa: icono,
                  etiquetaSemantica: l.alimSemanticaFoto,
                ),
              ),
            ),
      titulo: etiquetaMomento(l, comida.momento),
      subtitulo: nota == null
          ? l.alimFilaDetalle(hora, cuanto)
          : l.alimFilaConNota(hora, cuanto, nota),
      onTap: () => context.push(Rutas.comida(comida.id)),
    );
  }
}

// ------------------------------------------------------------------ Agua

class _TarjetaAgua extends ConsumerWidget {
  const _TarjetaAgua({required this.vasos});

  final int vasos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final objetivo =
        ref.watch(objetivoVasosProvider).value ?? objetivoVasosPorDefecto;
    final repo = ref.read(alimentacionRepositorioProvider);
    return GrupoLista(
      titulo: l.alimAguaTitulo,
      pie: l.alimAguaPie,
      sangria: 16,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IndicadorAnillo(
                objetivo == 0 ? 0 : vasos / objetivo,
                color: c.azul,
                tamano: 56,
                child: ExcludeSemantics(
                  child: Text(
                    vasos.toString(),
                    style: t.titleMedium?.copyWith(
                      color: c.texto,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.alimVasosDeObjetivo(vasos, objetivo),
                  key: ClavesUi.alimVasosTexto,
                  style: t.titleSmall?.copyWith(
                    color: c.texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _BotonPaso(
                clave: ClavesUi.alimVasoMenos,
                icono: CupertinoIcons.minus,
                etiqueta: l.alimRestarVaso,
                alPulsar: vasos == 0
                    ? null
                    : () => unawaited(repo.restarVaso()),
              ),
              const SizedBox(width: 8),
              _BotonPaso(
                clave: ClavesUi.alimVasoMas,
                icono: CupertinoIcons.add,
                etiqueta: l.alimSumarVaso,
                relleno: true,
                alPulsar: () => unawaited(repo.sumarVaso()),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.alimObjetivo,
                  style: t.titleSmall?.copyWith(
                    color: c.texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _BotonPaso(
                clave: ClavesUi.alimObjetivoMenos,
                icono: CupertinoIcons.minus,
                etiqueta: l.alimObjetivoBajar,
                alPulsar: objetivo <= objetivoVasosMinimo
                    ? null
                    : () => unawaited(
                        ref
                            .read(objetivoVasosProvider.notifier)
                            .cambiar(objetivo - 1),
                      ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 72),
                child: Text(
                  l.alimObjetivoValor(objetivo),
                  key: ClavesUi.alimObjetivoTexto,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: c.texto),
                ),
              ),
              _BotonPaso(
                clave: ClavesUi.alimObjetivoMas,
                icono: CupertinoIcons.add,
                etiqueta: l.alimObjetivoSubir,
                alPulsar: objetivo >= objetivoVasosMaximo
                    ? null
                    : () => unawaited(
                        ref
                            .read(objetivoVasosProvider.notifier)
                            .cambiar(objetivo + 1),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botón redondo de 48 con un más o un menos.
class _BotonPaso extends StatelessWidget {
  const _BotonPaso({
    required this.clave,
    required this.icono,
    required this.etiqueta,
    required this.alPulsar,
    this.relleno = false,
  });

  final Key clave;
  final IconData icono;
  final String etiqueta;
  final VoidCallback? alPulsar;
  final bool relleno;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final activo = alPulsar != null;
    return IconButton(
      key: clave,
      tooltip: etiqueta,
      onPressed: alPulsar,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: relleno ? c.azul : c.rellenoSuave,
        foregroundColor: relleno ? c.sobreAzul : c.azul,
        disabledBackgroundColor: c.rellenoSuave,
        disabledForegroundColor: c.textoSecundario,
        shape: const CircleBorder(),
      ),
      icon: Icon(icono, size: 22, semanticLabel: activo ? null : etiqueta),
    );
  }
}

// ------------------------------------------------------------------ Semana

class _VistaSemana extends ConsumerWidget {
  const _VistaSemana({required this.dias, required this.hoy});

  final List<DiaAlimentacion> dias;
  final String hoy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final objetivo =
        ref.watch(objetivoVasosProvider).value ?? objetivoVasosPorDefecto;
    return GrupoLista(
      sangria: 16,
      children: [
        for (final d in dias)
          FilaLista(
            key: ClavesUi.alimDia(d.fecha),
            titulo: fechaLarga(fechaDeTexto(d.fecha)),
            subtitulo: l.alimSemanaDetalle(d.principalesAnotadas, d.vasos),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 52,
                  child: CeldaDia(
                    estado: d.principalesAnotadas == 4
                        ? EstadoCelda.completa
                        : d.principalesAnotadas > 0
                        ? EstadoCelda.parcial
                        : (d.fecha == hoy
                              ? EstadoCelda.hoy
                              : EstadoCelda.vacia),
                    texto: '${d.principalesAnotadas}/4',
                    etiquetaSemantica: l.alimCeldaComidas(
                      d.principalesAnotadas,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 44,
                  child: CeldaDia(
                    estado: d.vasos >= objetivo
                        ? EstadoCelda.completa
                        : d.vasos > 0
                        ? EstadoCelda.parcial
                        : (d.fecha == hoy
                              ? EstadoCelda.hoy
                              : EstadoCelda.vacia),
                    texto: '${d.vasos}',
                    etiquetaSemantica: l.alimCeldaVasos(d.vasos),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
