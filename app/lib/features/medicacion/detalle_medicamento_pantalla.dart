import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/medicacion_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/pictogramas/pastilla_pictograma.dart';
import '../../shared/widgets/foto_imagen.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import 'formulario_pauta.dart';

class DetalleMedicamentoPantalla extends ConsumerWidget {
  const DetalleMedicamentoPantalla({super.key, required this.medicamentoId});

  final String medicamentoId;

  Future<void> _suspender(
    BuildContext context,
    WidgetRef ref,
    Pauta actual,
  ) async {
    final l = context.l;
    final controlador = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.suspenderPauta),
        content: TextField(
          controller: controlador,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.motivo,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controlador.text.trim()),
            child: Text(l.suspender),
          ),
        ],
      ),
    );
    controlador.dispose();
    if (motivo == null || motivo.isEmpty) return;
    await ref
        .read(medicacionRepositorioProvider)
        .suspender(pautaId: actual.pautaId, motivo: motivo);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final med = ref
        .watch(medicamentosProvider)
        .value
        ?.where((m) => m.id == medicamentoId)
        .firstOrNull;
    final versiones =
        [
          for (final p in ref.watch(pautasProvider).value ?? const <Pauta>[])
            if (p.medicamentoId == medicamentoId) p,
        ]..sort(
          (a, b) => b.creadaEn != a.creadaEn
              ? b.creadaEn.compareTo(a.creadaEn)
              : b.version.compareTo(a.version),
        );
    if (med == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.medicamentoNoEncontrado)),
      );
    }
    final actual = versiones.isEmpty ? null : versiones.first;
    return Scaffold(
      appBar: AppBar(
        title: Text(med.nombre),
        leading: BackButton(
          onPressed: () => context.go(Rutas.pestana('medicacion')),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _Foto(
                  titulo: l.fotoCaja,
                  fotoId: med.fotoCajaId,
                  med: med,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Foto(
                  titulo: l.fotoPastilla,
                  fotoId: med.fotoPastillaId,
                  med: med,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(med.nombreParaPersona, style: t.headlineSmall),
          Text(
            l.formaYColor(_forma(l, med.forma), med.color ?? l.sinColor),
            style: t.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (actual != null)
            TarjetaGrande(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.pautaActual, style: t.titleMedium),
                  const SizedBox(height: 8),
                  if (!actual.activa)
                    Text(l.pautaSuspendida, style: t.titleMedium)
                  else ...[
                    Text(
                      l.lineaHoras(
                        MedicacionRepositorio.horasDe(actual).join(', '),
                      ),
                    ),
                    Text(l.lineaDias(resumenDias(context, actual.diasSemana))),
                    Text(l.lineaDosis(actual.dosis)),
                    if (actual.compartimento != null)
                      Text(l.lineaCompartimento(actual.compartimento!)),
                    Text(
                      l.lineaComprobacion(
                        textoComprobacion(
                          context,
                          TipoComprobacion.desdeNombre(actual.comprobacion),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => context.go(Rutas.pauta(med.id)),
                icon: const Icon(Icons.edit_calendar),
                label: Text(
                  actual?.activa == false ? l.reanudarPauta : l.cambiarPauta,
                ),
              ),
              if (actual != null && actual.activa)
                OutlinedButton.icon(
                  onPressed: () => _suspender(context, ref, actual),
                  icon: const Icon(Icons.pause_circle),
                  label: Text(l.suspenderPauta),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l.historialPauta, style: t.titleMedium),
          const SizedBox(height: 8),
          for (final v in versiones)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TarjetaGrande(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.versionDesde(
                        v.version,
                        diaYHora(
                          aLocal(
                            DateTime.fromMillisecondsSinceEpoch(
                              v.vigenteDesde,
                              isUtc: true,
                            ),
                            zona,
                          ),
                        ),
                      ),
                      style: t.titleSmall,
                    ),
                    Text(
                      v.activa
                          ? l.resumenPauta(
                              MedicacionRepositorio.horasDe(v).join(', '),
                              v.dosis,
                            )
                          : l.pautaSuspendida,
                    ),
                    if (v.motivo != null) Text(l.motivoDe(v.motivo!)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _forma(dynamic l, String forma) => switch (forma) {
    'redonda' => l.formaRedonda,
    'ovalada' => l.formaOvalada,
    'capsula' => l.formaCapsula,
    _ => l.formaOtra,
  };
}

class _Foto extends StatelessWidget {
  const _Foto({required this.titulo, required this.fotoId, required this.med});

  final String titulo;
  final String? fotoId;
  final Medicamento med;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: t.titleSmall),
        const SizedBox(height: 4),
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FotoImagen(
              fotoId: fotoId,
              alternativa: Container(
                color: const Color(0xFFF3EEE2),
                alignment: Alignment.center,
                child: PastillaPictograma(
                  forma: med.forma,
                  color: med.color,
                  tamano: 96,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
