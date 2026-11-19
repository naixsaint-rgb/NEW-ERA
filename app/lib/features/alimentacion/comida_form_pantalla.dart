import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/alimentacion_repositorio.dart';
import '../../core/db/repositorios/circulo_repositorio.dart' show FotoNueva;
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/foto_imagen.dart';
import '../calendario/campos_agenda.dart';
import '../medicacion/datos/selector_foto.dart';
import 'dominio/alimentacion.dart';
import 'etiquetas_alimentacion.dart';

/// Alimentación › «Anotar comida» (sin [comidaId]; [momento] y [fecha] ya
/// elegidos si se viene de una fila o de un día) o editar una: cuál, cuánto
/// comió, día y hora, nota y foto. Lleva la firma del familiar de este móvil.
class ComidaFormPantalla extends ConsumerStatefulWidget {
  const ComidaFormPantalla({
    super.key,
    this.comidaId,
    this.momento,
    this.fecha,
  });

  final String? comidaId;

  /// Momento con el que se abre una comida nueva.
  final String? momento;

  /// `yyyy-MM-dd` con el que se abre una comida nueva (por defecto, hoy).
  final String? fecha;

  @override
  ConsumerState<ComidaFormPantalla> createState() => _ComidaFormPantallaState();
}

class _ComidaFormPantallaState extends ConsumerState<ComidaFormPantalla> {
  final _nota = TextEditingController();
  late String _momento = MomentoComida.principales.contains(widget.momento)
      ? widget.momento!
      : MomentoComida.desayuno;
  String _cuanto = CuantoComio.todo;
  String? _fecha;
  String? _hora;
  String? _fotoId;
  FotoNueva? _fotoNueva;
  bool _cargado = false;
  bool _guardando = false;
  bool _errorGuardar = false;
  Comida? _original;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  void _cargar(Comida c, String zona) {
    _cargado = true;
    _original = c;
    _momento = MomentoComida.valores.contains(c.momento)
        ? c.momento
        : MomentoComida.otro;
    _cuanto = CuantoComio.valores.contains(c.cuanto)
        ? c.cuanto
        : CuantoComio.todo;
    _nota.text = c.nota ?? '';
    _fotoId = c.fotoId;
    _fecha = fechaDeMs(c.ocurridaEn, zona);
    _hora = horaDeMs(c.ocurridaEn, zona);
  }

  void _volver() => context.canPop()
      ? context.pop()
      : context.go(Rutas.pestana('alimentacion'));

  Future<void> _elegirFecha(String actual) async {
    final f = await elegirFecha(context, actual);
    if (f != null && mounted) setState(() => _fecha = f);
  }

  Future<void> _elegirHora(String actual) async {
    final h = await elegirHora(context, actual);
    if (h != null && mounted) setState(() => _hora = h);
  }

  Future<void> _elegirFoto(ImageSource fuente) async {
    final foto = await ref.read(selectorFotoProvider)(fuente);
    if (foto == null || !mounted) return;
    setState(() => _fotoNueva = foto);
  }

  Future<void> _guardar(String fecha, String hora) async {
    if (_guardando) return;
    setState(() {
      _guardando = true;
      _errorGuardar = false;
    });
    try {
      final zona = ref.read(contextoProvider).zonaHoraria;
      final repo = ref.read(alimentacionRepositorioProvider);
      final datos = DatosComida(
        momento: _momento,
        cuanto: _cuanto,
        ocurridaEn: horaLocalAUtc(
          zona,
          int.parse(fecha.substring(0, 4)),
          int.parse(fecha.substring(5, 7)),
          int.parse(fecha.substring(8, 10)),
          int.parse(hora.substring(0, 2)),
          int.parse(hora.substring(3, 5)),
        ),
        nota: _nota.text,
        fotoId: _fotoNueva == null ? _fotoId : null,
        fotoNueva: _fotoNueva,
      );
      if (widget.comidaId == null) {
        await repo.crearComida(datos);
      } else {
        await repo.editarComida(widget.comidaId!, datos);
      }
      if (mounted) _volver();
    } catch (_) {
      if (mounted) setState(() => _errorGuardar = true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _borrar() async {
    final l = context.l;
    final c = context.colores;
    final si = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.alimBorrarTitulo),
        content: Text(l.alimBorrarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            child: Text(l.cancelar),
          ),
          FilledButton(
            key: ClavesUi.alimBorrarConfirmar,
            style: FilledButton.styleFrom(
              backgroundColor: c.rojo,
              foregroundColor: c.sobreRojo,
              minimumSize: const Size(44, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.agBorrarConfirmar),
          ),
        ],
      ),
    );
    if (si != true || !mounted) return;
    try {
      await ref
          .read(alimentacionRepositorioProvider)
          .borrarComida(widget.comidaId!);
      if (mounted) _volver();
    } catch (_) {
      if (mounted) setState(() => _errorGuardar = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final editando = widget.comidaId != null;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    if (editando && !_cargado) {
      final comidas = ref.watch(comidasProvider).value;
      final x = comidas?.where((q) => q.id == widget.comidaId).firstOrNull;
      if (x != null) _cargar(x, zona);
    }
    final ahora = aLocal(ref.read(relojProvider).ahora(), zona);
    final String hoy = ref.watch(fechaHoyAlimentacionProvider);
    final String fecha = _fecha ?? widget.fecha ?? hoy;
    final String hora = _hora ?? horaCorta(ahora);
    final esWeb = ref.watch(esDemoWebProvider);
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final anotador = _original == null
        ? null
        : miembros
              .where((m) => m.id == _original!.registradaPor)
              .firstOrNull
              ?.nombre;
    final valoresMomento = [
      ...MomentoComida.principales,
      if (_momento == MomentoComida.otro) MomentoComida.otro,
    ];
    final tieneFoto = _fotoNueva != null || _fotoId != null;
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.pestanaAlimentacion,
            titulo: editando ? l.alimFormEditar : l.alimFormNueva,
            reservarBotonMas: false,
            alVolver: _volver,
          ),
          const SizedBox(height: 14),
          if (editando && !_cargado)
            GrupoLista(
              children: [FilaLista(apagada: true, titulo: l.alimSinAnotar)],
            )
          else ...[
            TituloSeccion(l.alimFormMomento),
            SelectorSegmentos<String>(
              valores: valoresMomento,
              seleccionado: _momento,
              etiqueta: (v) => etiquetaMomento(l, v),
              clave: ClavesUi.alimMomento,
              alCambiar: (v) => setState(() => _momento = v),
            ),
            const SizedBox(height: 14),
            TituloSeccion(l.alimFormCuanto),
            SelectorSegmentos<String>(
              valores: CuantoComio.valores,
              seleccionado: _cuanto,
              etiqueta: (v) => etiquetaCuanto(l, v),
              clave: ClavesUi.alimCuanto,
              alCambiar: (v) => setState(() => _cuanto = v),
            ),
            const SizedBox(height: 14),
            GrupoLista(
              children: [
                FilaSelector(
                  key: ClavesUi.alimFecha,
                  etiqueta: l.alimFormDia,
                  valor: fechaLargaDeTexto(fecha),
                  enLinea: false,
                  icono: CupertinoIcons.calendar,
                  alPulsar: _guardando
                      ? null
                      : () => unawaited(_elegirFecha(fecha)),
                ),
                FilaSelector(
                  key: ClavesUi.alimHora,
                  etiqueta: l.alimFormHora,
                  valor: hora,
                  icono: CupertinoIcons.clock,
                  alPulsar: _guardando
                      ? null
                      : () => unawaited(_elegirHora(hora)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GrupoLista(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    key: ClavesUi.alimNota,
                    controller: _nota,
                    enabled: !_guardando,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 300,
                    style: t.bodyLarge?.copyWith(color: c.texto),
                    decoration: InputDecoration(
                      labelText: l.alimFormNota,
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TituloSeccion(l.alimFormFoto),
            GrupoLista(
              sangria: 16,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MiniaturaFoto(fotoId: _fotoId, nueva: _fotoNueva),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (!esWeb)
                              OutlinedButton.icon(
                                key: ClavesUi.alimFotoHacer,
                                style: _estiloBoton,
                                onPressed: _guardando
                                    ? null
                                    : () => unawaited(
                                        _elegirFoto(ImageSource.camera),
                                      ),
                                icon: const Icon(Icons.photo_camera),
                                label: Text(l.hacerFoto),
                              ),
                            OutlinedButton.icon(
                              key: ClavesUi.alimFotoElegir,
                              style: _estiloBoton,
                              onPressed: _guardando
                                  ? null
                                  : () => unawaited(
                                      _elegirFoto(ImageSource.gallery),
                                    ),
                              icon: const Icon(Icons.photo_library),
                              label: Text(l.elegirDeLaGaleria),
                            ),
                            if (tieneFoto)
                              TextButton(
                                key: ClavesUi.alimFotoQuitar,
                                style: _estiloBoton,
                                onPressed: _guardando
                                    ? null
                                    : () => setState(() {
                                        _fotoId = null;
                                        _fotoNueva = null;
                                      }),
                                child: Text(l.alimFormQuitarFoto),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (anotador != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  l.alimFormAnotadaPor(anotador),
                  style: t.bodySmall?.copyWith(color: c.textoSecundario),
                ),
              ),
            if (_errorGuardar)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  l.agErrorGuardar,
                  style: t.bodyMedium?.copyWith(color: c.rojo),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton(
              key: ClavesUi.alimGuardar,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _guardando
                  ? null
                  : () => unawaited(_guardar(fecha, hora)),
              child: Text(l.agGuardar),
            ),
            if (editando) ...[
              const SizedBox(height: 18),
              GrupoLista(
                children: [
                  FilaLista(
                    key: ClavesUi.alimBorrar,
                    leading: IconoCuadrado(
                      CupertinoIcons.trash,
                      fondo: c.rojo,
                      color: c.sobreRojo,
                    ),
                    titulo: l.alimBorrar,
                    colorTitulo: c.rojo,
                    conChevron: false,
                    onTap: _guardando ? null : () => unawaited(_borrar()),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

const ButtonStyle _estiloBoton = ButtonStyle(
  minimumSize: WidgetStatePropertyAll(Size(48, 48)),
);

/// La foto de la comida (la guardada o la recién hecha), o un marco vacío.
class _MiniaturaFoto extends StatelessWidget {
  const _MiniaturaFoto({required this.fotoId, required this.nueva});

  final String? fotoId;
  final FotoNueva? nueva;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final vacia = Icon(Icons.image_outlined, size: 40, color: c.texto);
    final nueva = this.nueva;
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: c.mesa,
        border: Border.all(color: c.mesaBorde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: nueva != null
            ? Image.memory(
                nueva.bytes,
                fit: BoxFit.cover,
                semanticLabel: context.l.alimSemanticaFoto,
              )
            : Center(
                child: FotoImagen(
                  fotoId: fotoId,
                  ancho: 88,
                  alto: 88,
                  alternativa: vacia,
                  etiquetaSemantica: context.l.alimSemanticaFoto,
                ),
              ),
      ),
    );
  }
}
