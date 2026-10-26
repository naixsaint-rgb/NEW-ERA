import 'package:flutter/material.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/repositorios/medicacion_repositorio.dart';
import '../../shared/l10n_ext.dart';

/// Valores editables de una pauta.
final class PautaEditable {
  const PautaEditable({
    this.horas = const ['09:00'],
    this.diasSemana = DiasSemana.todos,
    this.dosis = '',
    this.compartimento = '',
    this.comprobacion = TipoComprobacion.video,
  });

  final List<String> horas;
  final int diasSemana;
  final String dosis;
  final String compartimento;
  final TipoComprobacion comprobacion;

  PautaEditable copiar({
    List<String>? horas,
    int? diasSemana,
    String? dosis,
    String? compartimento,
    TipoComprobacion? comprobacion,
  }) => PautaEditable(
    horas: horas ?? this.horas,
    diasSemana: diasSemana ?? this.diasSemana,
    dosis: dosis ?? this.dosis,
    compartimento: compartimento ?? this.compartimento,
    comprobacion: comprobacion ?? this.comprobacion,
  );

  /// Válida si hay al menos una hora, un día y una dosis.
  bool get valida =>
      horas.isNotEmpty && diasSemana != 0 && dosis.trim().isNotEmpty;
}

/// Campos de la pauta: horas de 24 h, días de lunes a domingo, dosis,
/// compartimento y comprobación (vídeo de 10 s, foto o ninguna).
class CamposPauta extends StatefulWidget {
  const CamposPauta({super.key, required this.valor, required this.alCambiar});

  final PautaEditable valor;
  final ValueChanged<PautaEditable> alCambiar;

  @override
  State<CamposPauta> createState() => _CamposPautaState();
}

class _CamposPautaState extends State<CamposPauta> {
  late final TextEditingController _dosis;
  late final TextEditingController _compartimento;

  @override
  void initState() {
    super.initState();
    _dosis = TextEditingController(text: widget.valor.dosis);
    _compartimento = TextEditingController(text: widget.valor.compartimento);
  }

  @override
  void dispose() {
    _dosis.dispose();
    _compartimento.dispose();
    super.dispose();
  }

  Future<void> _anadirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, hijo) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: hijo!,
      ),
    );
    if (elegida == null) return;
    final hh = elegida.hour.toString().padLeft(2, '0');
    final mm = elegida.minute.toString().padLeft(2, '0');
    widget.alCambiar(
      widget.valor.copiar(
        horas: normalizarHoras([...widget.valor.horas, '$hh:$mm']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final v = widget.valor;
    final dias = [
      l.diaLunes,
      l.diaMartes,
      l.diaMiercoles,
      l.diaJueves,
      l.diaViernes,
      l.diaSabado,
      l.diaDomingo,
    ];
    final diasCortos = l.medicInicialesDias.split(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.horasDeToma, style: t.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final h in v.horas)
              InputChip(
                label: Text(h),
                deleteButtonTooltipMessage: l.quitarHora(h),
                onDeleted: v.horas.length > 1
                    ? () => widget.alCambiar(
                        v.copiar(horas: [...v.horas]..remove(h)),
                      )
                    : null,
              ),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(l.anadirHora),
              onPressed: _anadirHora,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l.diasDeToma, style: t.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (var i = 0; i < 7; i++)
              Tooltip(
                message: dias[i],
                child: FilterChip(
                  label: Text(diasCortos[i]),
                  selected: DiasSemana.incluye(v.diasSemana, i + 1),
                  onSelected: (sel) {
                    final bit = 1 << i;
                    widget.alCambiar(
                      v.copiar(
                        diasSemana: sel
                            ? v.diasSemana | bit
                            : v.diasSemana & ~bit,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dosis,
          decoration: InputDecoration(
            labelText: l.dosis,
            border: const OutlineInputBorder(),
          ),
          onChanged: (s) => widget.alCambiar(v.copiar(dosis: s)),
          validator: (s) =>
              (s == null || s.trim().isEmpty) ? l.campoObligatorio : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _compartimento,
          decoration: InputDecoration(
            labelText: l.compartimentoEtiqueta,
            border: const OutlineInputBorder(),
          ),
          onChanged: (s) => widget.alCambiar(v.copiar(compartimento: s)),
        ),
        const SizedBox(height: 16),
        Text(l.comprobacionTitulo, style: t.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<TipoComprobacion>(
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: TipoComprobacion.video,
              label: Text(l.comprobacionVideo),
              icon: const Icon(Icons.videocam),
            ),
            ButtonSegment(
              value: TipoComprobacion.foto,
              label: Text(l.comprobacionFoto),
              icon: const Icon(Icons.photo_camera),
            ),
            ButtonSegment(
              value: TipoComprobacion.ninguna,
              label: Text(l.comprobacionNinguna),
              icon: const Icon(Icons.block),
            ),
          ],
          selected: {v.comprobacion},
          onSelectionChanged: (s) =>
              widget.alCambiar(v.copiar(comprobacion: s.first)),
        ),
      ],
    );
  }
}

/// Texto de los días ("Todos los días", "L, J").
String resumenDias(BuildContext context, int mascara) {
  final l = context.l;
  if (mascara == DiasSemana.todos) return l.todosLosDias;
  final letras = l.medicInicialesDias.split(' ');
  return [
    for (var i = 0; i < 7; i++)
      if (DiasSemana.incluye(mascara, i + 1)) letras[i],
  ].join(', ');
}

/// Texto de la comprobación.
String textoComprobacion(BuildContext context, TipoComprobacion c) {
  final l = context.l;
  return switch (c) {
    TipoComprobacion.video => l.comprobacionVideo,
    TipoComprobacion.foto => l.comprobacionFoto,
    TipoComprobacion.ninguna => l.comprobacionNinguna,
  };
}
