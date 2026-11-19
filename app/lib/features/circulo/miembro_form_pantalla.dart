import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/circulo_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'papel_familiar.dart';

/// Círculo › "Añadir familiar" (sin [miembroId]) o editar los datos de uno
/// (también el de este móvil): nombre, papel y teléfono opcional. Viaja como
/// ficha de miembro.
class MiembroFormPantalla extends ConsumerStatefulWidget {
  const MiembroFormPantalla({super.key, this.miembroId});

  final String? miembroId;

  @override
  ConsumerState<MiembroFormPantalla> createState() =>
      _MiembroFormPantallaState();
}

class _MiembroFormPantallaState extends ConsumerState<MiembroFormPantalla> {
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  String? _papel = PapelFamiliar.otro;
  Miembro? _original;
  bool _cargado = false;
  bool _guardando = false;
  String? _errorNombre;
  String? _errorTelefono;
  bool _errorGuardar = false;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _cargar(Miembro m) {
    _cargado = true;
    _original = m;
    _nombre.text = m.nombre == CirculoRepositorio.nombreProvisional
        ? ''
        : m.nombre;
    _telefono.text = m.telefono ?? '';
    // Un texto libre de antes que no es ningún papel se conserva si no se
    // elige otro.
    _papel = PapelFamiliar.codigo(m.relacion);
  }

  void _volver() =>
      context.canPop() ? context.pop() : context.go(Rutas.pestana('circulo'));

  Future<void> _guardar() async {
    if (_guardando) return;
    final l = context.l;
    final nombre = _nombre.text.trim();
    final tel = CirculoRepositorio.telefonoLimpio(_telefono.text);
    final cifras = tel?.replaceAll(RegExp(r'\D'), '').length ?? 0;
    final errorNombre = nombre.isEmpty ? l.circErrorNombre : null;
    final errorTelefono = tel != null && (cifras < 6 || cifras > 15)
        ? l.circErrorTelefono
        : null;
    setState(() {
      _errorNombre = errorNombre;
      _errorTelefono = errorTelefono;
      _errorGuardar = false;
    });
    if (errorNombre != null || errorTelefono != null) return;
    setState(() => _guardando = true);
    try {
      final repo = ref.read(circuloRepositorioProvider);
      final original = _original;
      if (widget.miembroId == null) {
        await repo.crearMiembro(
          NuevoMiembro(
            nombre: nombre,
            relacion: _papel ?? PapelFamiliar.otro,
            telefono: tel,
          ),
        );
      } else if (original != null) {
        await repo.editarMiembro(
          original.id,
          nombre: nombre,
          relacion: _papel ?? original.relacion,
          telefono: tel,
        );
      }
      if (mounted) _volver();
    } catch (_) {
      if (mounted) setState(() => _errorGuardar = true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final editando = widget.miembroId != null;
    final miembros = ref.watch(miembrosProvider).value;
    if (editando && !_cargado && miembros != null) {
      final m = miembros.where((x) => x.id == widget.miembroId).firstOrNull;
      if (m != null) _cargar(m);
    }
    final propio = ref.watch(sesionProvider).miembroId == widget.miembroId;
    final opciones = [
      ...PapelFamiliar.valores,
      // El texto libre de un familiar anterior no se pierde.
      if (_papel == null && _original != null) _original!.relacion,
    ];
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: editando && propio ? l.circEsteMovil : l.pestanaCirculo,
            titulo: editando ? l.circEditarTitulo : l.circNuevoTitulo,
            reservarBotonMas: false,
            alVolver: _volver,
          ),
          const SizedBox(height: 14),
          if (editando && !_cargado)
            GrupoLista(
              children: [FilaLista(apagada: true, titulo: l.sinFamiliares)],
            )
          else ...[
            GrupoLista(
              pie: l.circTelefonoPie,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: TextField(
                    key: ClavesUi.circNombre,
                    controller: _nombre,
                    enabled: !_guardando,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    maxLength: 40,
                    style: t.bodyLarge?.copyWith(color: c.texto),
                    decoration: InputDecoration(
                      labelText: l.circCampoNombre,
                      errorText: _errorNombre,
                      counterText: '',
                    ),
                    onChanged: (_) {
                      if (_errorNombre != null) {
                        setState(() => _errorNombre = null);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: TextField(
                    key: ClavesUi.circTelefono,
                    controller: _telefono,
                    enabled: !_guardando,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ()-]')),
                    ],
                    maxLength: 20,
                    style: t.bodyLarge?.copyWith(color: c.texto),
                    decoration: InputDecoration(
                      labelText: l.circCampoTelefono,
                      errorText: _errorTelefono,
                      counterText: '',
                    ),
                    onChanged: (_) {
                      if (_errorTelefono != null) {
                        setState(() => _errorTelefono = null);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GrupoLista(
              titulo: l.circPapelTitulo,
              children: [
                for (final p in opciones)
                  FilaLista(
                    key: ClavesUi.circPapel(p),
                    titulo: PapelFamiliar.etiqueta(l, p),
                    conChevron: false,
                    trailing: (_papel ?? _original?.relacion) == p
                        ? Icon(CupertinoIcons.checkmark_alt, color: c.azul)
                        : null,
                    etiquetaSemantica: (_papel ?? _original?.relacion) == p
                        ? '${PapelFamiliar.etiqueta(l, p)}, ${l.circSeleccionado}'
                        : null,
                    onTap: _guardando
                        ? null
                        : () => setState(
                            () => _papel = PapelFamiliar.codigo(p) ?? _papel,
                          ),
                  ),
              ],
            ),
            if (_errorGuardar)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  l.circErrorGuardar,
                  style: t.bodyMedium?.copyWith(color: c.rojo),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton(
              key: ClavesUi.circGuardar,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _guardando ? null : () => unawaited(_guardar()),
              child: Text(l.circGuardar),
            ),
          ],
        ],
      ),
    );
  }
}
