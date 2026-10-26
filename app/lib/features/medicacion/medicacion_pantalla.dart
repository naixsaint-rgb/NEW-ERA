import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/medicacion_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/pictogramas/pastilla_pictograma.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import '../hoy/dominio/tomas.dart';
import 'pastillero.dart';

/// Última versión de cada pauta, por medicamento.
final pautaVigentePorMedicamentoProvider = Provider<Map<String, Pauta>>((ref) {
  final pautas = ref.watch(pautasProvider).value ?? const <Pauta>[];
  return pautasVigentesDe(pautas);
});

/// Medicación de la familia (maqueta D-Medicacion): el pastillero de la
/// semana, las pruebas y las pastillas con su foto. Las tomas de hoy están en
/// Hoy.
class MedicacionPantalla extends ConsumerWidget {
  const MedicacionPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final deHoy = ref.watch(tomasDeHoyProvider).value ?? const <TomaVista>[];
    final primera = deHoy.isEmpty ? null : deHoy.first;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          CabeceraGrande(vispera: l.medicVispera, titulo: l.pestanaMedicacion),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: () => context.go(Rutas.medicacionNuevo),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(CupertinoIcons.add, size: 18),
              label: Text(l.anadirMedicamento),
            ),
          ),
          const SizedBox(height: 14),
          const _TarjetaPastillero(),
          const SizedBox(height: 14),
          GrupoLista(
            titulo: l.medicProbarTitulo,
            children: [
              FilaLista(
                titulo: l.probarPantallaToma,
                subtitulo: primera == null ? l.sinTomasHoy : null,
                apagada: primera == null,
                leading: IconoCuadrado(
                  CupertinoIcons.play_fill,
                  fondo: primera == null ? c.gris : c.azul,
                ),
                onTap: primera == null
                    ? null
                    : () => context.push(
                        Rutas.toma(primera.toma.id, prueba: true),
                      ),
              ),
              FilaLista(
                key: ClavesUi.probarPregunta,
                titulo: l.medicProbarPregunta,
                subtitulo: l.medicProbarPreguntaAyuda,
                leading: IconoCuadrado(
                  CupertinoIcons.question_circle_fill,
                  fondo: c.indigo,
                ),
                onTap: () => context.push(Rutas.pregunta(prueba: true)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _ListaPastillas(),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Pastillero

class _TarjetaPastillero extends ConsumerWidget {
  const _TarjetaPastillero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final c = context.colores;
    final datos = ref.watch(pastilleroProvider);
    return TarjetaGrande(
      key: ClavesUi.pastillero,
      margen: EdgeInsets.zero,
      relleno: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Semantics(
        explicitChildNodes: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Semantics(
                header: true,
                child: Text(
                  l.medicPastilleroTitulo,
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.texto,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            datos.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Text(l.errorGenerico),
              data: (d) => d.horas.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: Text(
                        l.medicPastilleroVacio,
                        style: t.bodyMedium?.copyWith(color: c.textoSecundario),
                      ),
                    )
                  : _Rejilla(datos: d),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ancho de la columna de las horas.
const double _anchoHora = 48;

/// Hueco entre columnas.
const double _hueco = 6;

class _Rejilla extends StatelessWidget {
  const _Rejilla({required this.datos});

  final DatosPastillero datos;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final iniciales = l.medicInicialesDias.split(' ');
    final nombres = _nombresDias(l);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(width: _anchoHora),
            for (var i = 0; i < 7; i++) ...[
              const SizedBox(width: _hueco),
              Expanded(
                child: Semantics(
                  label: i == datos.indiceHoy
                      ? l.medicDiaHoy(nombres[i])
                      : nombres[i],
                  excludeSemantics: true,
                  child: Center(
                    child: Text(
                      iniciales[i],
                      style: t.labelMedium?.copyWith(
                        fontWeight: i == datos.indiceHoy
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: i == datos.indiceHoy
                            ? c.azul
                            : c.textoSecundario,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        for (var f = 0; f < datos.horas.length; f++)
          Padding(
            padding: const EdgeInsets.only(top: _hueco),
            child: Row(
              children: [
                SizedBox(
                  width: _anchoHora,
                  child: Text(
                    datos.horas[f],
                    style: t.labelMedium?.copyWith(color: c.textoSecundario),
                  ),
                ),
                for (var i = 0; i < 7; i++) ...[
                  const SizedBox(width: _hueco),
                  Expanded(
                    child: _Celda(
                      key: clavePastilleroCelda(
                        datos.fechas[i],
                        datos.horas[f],
                      ),
                      celda: datos.celdas[f][i],
                      dia: nombres[i],
                      hora: datos.horas[f],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

List<String> _nombresDias(AppLocalizations l) => [
  l.diaLunes,
  l.diaMartes,
  l.diaMiercoles,
  l.diaJueves,
  l.diaViernes,
  l.diaSabado,
  l.diaDomingo,
];

class _Celda extends StatelessWidget {
  const _Celda({
    super.key,
    required this.celda,
    required this.dia,
    required this.hora,
  });

  final CeldaPastillero? celda;
  final String dia;
  final String hora;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    const alto = 38.0;
    final celda = this.celda;
    if (celda == null) {
      return const ExcludeSemantics(
        child: CeldaDia(estado: EstadoCelda.vacia, alto: alto),
      );
    }
    final estadoTexto = switch (celda.estado) {
      EstadoCelda.completa => l.medicEstadoTomada,
      EstadoCelda.parcial => l.medicEstadoParcial(
        celda.hechas,
        celda.tomas.length,
      ),
      EstadoCelda.fallida => l.medicEstadoNoConfirmada,
      EstadoCelda.hoy => l.medicEstadoAhora,
      _ => l.medicEstadoPrevista,
    };
    final med = celda.tomas.first.medicamento;
    final pictograma = PastillaPictograma(
      forma: med?.forma ?? 'otra',
      color: med?.color,
      tamano: 22,
      colorBorde: c.mesaBorde,
    );
    final (texto, hijo) = switch (celda.estado) {
      EstadoCelda.completa => (null, const Icon(CupertinoIcons.check_mark)),
      EstadoCelda.fallida => (null, const Icon(CupertinoIcons.xmark)),
      EstadoCelda.parcial => ('${celda.hechas}/${celda.tomas.length}', null),
      _ => (null, pictograma),
    };
    return CeldaDia(
      estado: celda.estado,
      alto: alto,
      texto: texto,
      hijo: hijo,
      etiquetaSemantica: l.medicCeldaEtiqueta(dia, hora, estadoTexto),
    );
  }
}

// ------------------------------------------------------------ Pastillas

class _ListaPastillas extends ConsumerWidget {
  const _ListaPastillas();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final medicamentos =
        ref.watch(medicamentosProvider).value ?? const <Medicamento>[];
    final vigentes = ref.watch(pautaVigentePorMedicamentoProvider);
    final altas =
        ref.watch(eventosDeAltaProvider).value ?? const <String, Evento>{};
    final autores = ref.watch(nombresAutoresProvider);
    final activos = [
      for (final m in medicamentos)
        if (m.retiradoEn == null) m,
    ];
    if (activos.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TituloSeccion(l.medicPastillasTitulo),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.sinMedicamentos,
              style: t.bodyMedium?.copyWith(color: c.textoSecundario),
            ),
          ),
        ],
      );
    }
    return GrupoLista(
      titulo: l.medicPastillasTitulo,
      pie: l.medicPastillasPie,
      sangria: 84,
      children: [
        for (final m in activos)
          _FilaPastilla(
            medicamento: m,
            pauta: vigentes[m.id],
            lineaFoto: _lineaFoto(l, m, altas[m.id], autores, zona),
          ),
      ],
    );
  }

  /// Foto de (autor) · (fecha): solo si hay foto y se sabe quién y cuándo.
  static String? _lineaFoto(
    AppLocalizations l,
    Medicamento m,
    Evento? alta,
    Map<String, String> autores,
    String zona,
  ) {
    if (m.fotoPastillaId == null || alta == null) return null;
    final autor = autores[alta.autor];
    if (autor == null) return null;
    final fecha = fechaCorta(
      aLocal(
        DateTime.fromMillisecondsSinceEpoch(alta.ocurridoEn, isUtc: true),
        zona,
      ),
    );
    return l.medicFotoDe(autor, fecha);
  }
}

class _FilaPastilla extends StatelessWidget {
  const _FilaPastilla({
    required this.medicamento,
    required this.pauta,
    required this.lineaFoto,
  });

  final Medicamento medicamento;
  final Pauta? pauta;
  final String? lineaFoto;

  /// Horas en texto: `09:00`, `09:00 y 14:00`, `09:00, 14:00 y 21:00`.
  static String _horas(AppLocalizations l, Pauta p) {
    final horas = MedicacionRepositorio.horasDe(p);
    if (horas.length < 2) return horas.join();
    return l.medicHorasUnidas(
      horas.sublist(0, horas.length - 1).join(', '),
      horas.last,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final pauta = this.pauta;
    final lineas = [
      medicamento.nombreParaPersona,
      if (pauta != null)
        pauta.activa
            ? l.resumenPauta(_horas(l, pauta), pauta.dosis)
            : l.pautaSuspendida,
      ?lineaFoto,
    ];
    return FilaLista(
      titulo: medicamento.nombre,
      subtitulo: lineas.join('\n'),
      altoMinimo: 76,
      leading: FotoPastilla(
        medicamento,
        tamano: 56,
        insigniaCamara: medicamento.fotoPastillaId != null,
      ),
      onTap: () => context.go(Rutas.medicamento(medicamento.id)),
    );
  }
}
