import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/db/repositorios/circulo_repositorio.dart';
import '../../core/db/repositorios/medicacion_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/pictogramas/pastilla_pictograma.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import 'datos/selector_foto.dart';
import 'formulario_pauta.dart';

/// Alta de un medicamento con fotos y su primera pauta.
class AltaMedicamentoPantalla extends ConsumerStatefulWidget {
  const AltaMedicamentoPantalla({super.key});

  @override
  ConsumerState<AltaMedicamentoPantalla> createState() => _AltaState();
}

class _AltaState extends ConsumerState<AltaMedicamentoPantalla> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _nombrePersona = TextEditingController();
  String _forma = 'redonda';
  String? _color;
  FotoNueva? _fotoCaja;
  FotoNueva? _fotoPastilla;
  PautaEditable _pauta = const PautaEditable();
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _nombrePersona.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto(ImageSource fuente, {required bool caja}) async {
    final foto = await ref.read(selectorFotoProvider)(fuente);
    if (foto == null || !mounted) return;
    setState(() {
      if (caja) {
        _fotoCaja = foto;
      } else {
        _fotoPastilla = foto;
      }
    });
  }

  Future<void> _guardar() async {
    if (!(_formulario.currentState?.validate() ?? false) || !_pauta.valida) {
      return;
    }
    setState(() => _guardando = true);
    final id = await ref
        .read(medicacionRepositorioProvider)
        .crear(
          NuevoMedicamento(
            nombre: _nombre.text.trim(),
            nombreParaPersona: _nombrePersona.text.trim(),
            forma: _forma,
            color: _color,
            fotoCaja: _fotoCaja,
            fotoPastilla: _fotoPastilla,
            horas: _pauta.horas,
            diasSemana: _pauta.diasSemana,
            dosis: _pauta.dosis.trim(),
            compartimento: _pauta.compartimento.trim().isEmpty
                ? null
                : _pauta.compartimento.trim(),
            comprobacion: _pauta.comprobacion,
          ),
        );
    if (mounted) context.go(Rutas.medicamento(id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final esWeb = ref.watch(esDemoWebProvider);
    final formas = {
      'redonda': l.formaRedonda,
      'ovalada': l.formaOvalada,
      'capsula': l.formaCapsula,
      'otra': l.formaOtra,
    };
    final nombresColor = {
      'blanco': l.colorBlanco,
      'amarillo': l.colorAmarillo,
      'rojo': l.colorRojo,
      'rosa': l.colorRosa,
      'naranja': l.colorNaranja,
      'verde': l.colorVerde,
      'azul': l.colorAzul,
      'marron': l.colorMarron,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.altaTitulo)),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            TarjetaGrande(
              margen: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nombre,
                    decoration: InputDecoration(
                      labelText: l.nombreMedicamento,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (s) => (s == null || s.trim().isEmpty)
                        ? l.campoObligatorio
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombrePersona,
                    decoration: InputDecoration(
                      labelText: l.nombreParaPersona,
                      helperText: l.nombreParaPersonaAyuda,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (s) => (s == null || s.trim().isEmpty)
                        ? l.campoObligatorio
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(l.formaTitulo, style: t.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final e in formas.entries)
                        ChoiceChip(
                          label: Text(e.value),
                          selected: _forma == e.key,
                          onSelected: (_) => setState(() => _forma = e.key),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l.colorTitulo, style: t.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final e in nombresColor.entries)
                        ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: coloresPastilla[e.key],
                            radius: 10,
                          ),
                          label: Text(e.value),
                          selected: _color == e.key,
                          onSelected: (_) => setState(() => _color = e.key),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TarjetaGrande(
              margen: EdgeInsets.zero,
              child: Column(
                children: [
                  _BloqueFoto(
                    titulo: l.fotoCaja,
                    foto: _fotoCaja,
                    hacerFoto: esWeb
                        ? null
                        : () => _elegirFoto(ImageSource.camera, caja: true),
                    elegir: () => _elegirFoto(ImageSource.gallery, caja: true),
                  ),
                  const SizedBox(height: 12),
                  _BloqueFoto(
                    titulo: l.fotoPastilla,
                    foto: _fotoPastilla,
                    hacerFoto: esWeb
                        ? null
                        : () => _elegirFoto(ImageSource.camera, caja: false),
                    elegir: () => _elegirFoto(ImageSource.gallery, caja: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TarjetaGrande(
              margen: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.pautaTitulo, style: t.titleLarge),
                  const SizedBox(height: 8),
                  CamposPauta(
                    valor: _pauta,
                    alCambiar: (v) => setState(() => _pauta = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(l.guardarMedicamento),
            ),
          ],
        ),
      ),
    );
  }
}

class _BloqueFoto extends StatelessWidget {
  const _BloqueFoto({
    required this.titulo,
    required this.foto,
    required this.hacerFoto,
    required this.elegir,
  });

  final String titulo;
  final FotoNueva? foto;
  final VoidCallback? hacerFoto;
  final VoidCallback elegir;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final c = context.colores;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: c.mesa,
            border: Border.all(color: c.mesaBorde),
            borderRadius: BorderRadius.circular(12),
          ),
          child: foto == null
              ? Icon(Icons.image_outlined, size: 40, color: c.texto)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.memory(foto!.bytes, fit: BoxFit.cover),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: t.titleMedium),
              Wrap(
                spacing: 8,
                children: [
                  if (hacerFoto != null)
                    OutlinedButton.icon(
                      onPressed: hacerFoto,
                      icon: const Icon(Icons.photo_camera),
                      label: Text(l.hacerFoto),
                    ),
                  OutlinedButton.icon(
                    onPressed: elegir,
                    icon: const Icon(Icons.photo_library),
                    label: Text(l.elegirDeLaGaleria),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
