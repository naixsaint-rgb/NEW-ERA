import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/medicacion_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../shared/l10n_ext.dart';
import 'formulario_pauta.dart';

/// Cambio de pauta: crea una versión nueva (`vigente_desde = ahora`) con un
/// motivo obligatorio.
class CambioPautaPantalla extends ConsumerStatefulWidget {
  const CambioPautaPantalla({super.key, required this.medicamentoId});

  final String medicamentoId;

  @override
  ConsumerState<CambioPautaPantalla> createState() => _CambioState();
}

class _CambioState extends ConsumerState<CambioPautaPantalla> {
  final _formulario = GlobalKey<FormState>();
  final _motivo = TextEditingController();
  PautaEditable? _pauta;
  Pauta? _base;
  bool _guardando = false;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final p = _pauta;
    final base = _base;
    if (p == null || base == null) return;
    if (!(_formulario.currentState?.validate() ?? false) || !p.valida) return;
    setState(() => _guardando = true);
    await ref
        .read(medicacionRepositorioProvider)
        .cambiarPauta(
          pautaId: base.pautaId,
          motivo: _motivo.text,
          horas: p.horas,
          diasSemana: p.diasSemana,
          dosis: p.dosis.trim(),
          compartimento: p.compartimento.trim().isEmpty
              ? null
              : p.compartimento.trim(),
          comprobacion: p.comprobacion,
          segundosVideo: base.segundosVideo,
        );
    if (mounted) context.go(Rutas.medicamento(widget.medicamentoId));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final versiones =
        [
          for (final p in ref.watch(pautasProvider).value ?? const <Pauta>[])
            if (p.medicamentoId == widget.medicamentoId) p,
        ]..sort(
          (a, b) => b.creadaEn != a.creadaEn
              ? b.creadaEn.compareTo(a.creadaEn)
              : b.version.compareTo(a.version),
        );
    if (versiones.isNotEmpty && _base == null) {
      final base = versiones.first;
      _base = base;
      _pauta = PautaEditable(
        horas: MedicacionRepositorio.horasDe(base),
        diasSemana: base.diasSemana,
        dosis: base.dosis,
        compartimento: base.compartimento ?? '',
        comprobacion: TipoComprobacion.desdeNombre(base.comprobacion),
      );
    }
    final pauta = _pauta;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.cambiarPauta),
        leading: BackButton(
          onPressed: () => context.go(Rutas.medicamento(widget.medicamentoId)),
        ),
      ),
      body: pauta == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formulario,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CamposPauta(
                    valor: pauta,
                    alCambiar: (v) => setState(() => _pauta = v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _motivo,
                    decoration: InputDecoration(
                      labelText: l.motivoDelCambio,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (s) => (s == null || s.trim().isEmpty)
                        ? l.campoObligatorio
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: const Icon(Icons.save),
                    label: Text(l.guardarCambio),
                  ),
                ],
              ),
            ),
    );
  }
}
