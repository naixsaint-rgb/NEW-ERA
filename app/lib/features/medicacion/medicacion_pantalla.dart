import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/medicacion_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/pictogramas/pastilla_pictograma.dart';
import '../../shared/widgets/etiqueta_estado_toma.dart';
import '../../shared/widgets/foto_imagen.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import '../hoy/dominio/tomas.dart';
import 'formulario_pauta.dart';

/// Última versión de cada pauta, por medicamento.
final pautaVigentePorMedicamentoProvider = Provider<Map<String, Pauta>>((ref) {
  final pautas = ref.watch(pautasProvider).value ?? const <Pauta>[];
  final r = <String, Pauta>{};
  for (final p in pautas) {
    final actual = r[p.medicamentoId];
    if (actual == null ||
        (p.pautaId == actual.pautaId && p.version > actual.version) ||
        p.creadaEn >= actual.creadaEn) {
      r[p.medicamentoId] = p;
    }
  }
  return r;
});

class MedicacionPantalla extends ConsumerWidget {
  const MedicacionPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final deHoy = ref.watch(tomasDeHoyProvider).value ?? const <TomaVista>[];
    final medicamentos =
        ref.watch(medicamentosProvider).value ?? const <Medicamento>[];
    final vigentes = ref.watch(pautaVigentePorMedicamentoProvider);
    final activos = [
      for (final m in medicamentos)
        if (m.retiradoEn == null) m,
    ];
    final primera = deHoy.isEmpty ? null : deHoy.first;

    return Scaffold(
      appBar: AppBar(title: Text(l.pestanaMedicacion)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Rutas.medicacionNuevo),
        icon: const Icon(Icons.add),
        label: Text(l.anadirMedicamento),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(l.tomasDeHoy, style: t.titleLarge),
          const SizedBox(height: 8),
          if (deHoy.isEmpty)
            Text(l.sinTomasHoy, style: t.bodyLarge)
          else
            for (final x in deHoy)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TarjetaGrande(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(x.toma.horaLocal, style: t.titleMedium),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(x.nombreParaPersona, style: t.bodyLarge),
                            const SizedBox(height: 4),
                            EtiquetaEstadoToma(estado: x.estado),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: primera == null
                  ? null
                  : () =>
                        context.push(Rutas.toma(primera.toma.id, prueba: true)),
              icon: const Icon(Icons.play_circle),
              label: Text(l.probarPantallaToma),
            ),
          ),
          const SizedBox(height: 24),
          Text(l.medicamentos, style: t.titleLarge),
          const SizedBox(height: 8),
          if (activos.isEmpty)
            Text(l.sinMedicamentos, style: t.bodyLarge)
          else
            for (final m in activos)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FilaMedicamento(medicamento: m, pauta: vigentes[m.id]),
              ),
        ],
      ),
    );
  }
}

class _FilaMedicamento extends StatelessWidget {
  const _FilaMedicamento({required this.medicamento, required this.pauta});

  final Medicamento medicamento;
  final Pauta? pauta;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final horas = pauta == null
        ? ''
        : MedicacionRepositorio.horasDe(pauta!).join(', ');
    return TarjetaGrande(
      onTap: () => context.go(Rutas.medicamento(medicamento.id)),
      etiquetaSemantica: l.verMedicamento(medicamento.nombre),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FotoImagen(
                fotoId: medicamento.fotoPastillaId,
                ancho: 64,
                alto: 64,
                alternativa: PastillaPictograma(
                  forma: medicamento.forma,
                  color: medicamento.color,
                  tamano: 64,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicamento.nombre, style: t.titleMedium),
                Text(medicamento.nombreParaPersona, style: t.bodyMedium),
                if (pauta != null)
                  Text(
                    pauta!.activa
                        ? l.resumenPauta(horas, pauta!.dosis)
                        : l.pautaSuspendida,
                    style: t.bodyMedium,
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

/// Resumen corto de días para otras pantallas.
String resumenDiasDe(BuildContext context, Pauta p) =>
    resumenDias(context, p.diasSemana);
