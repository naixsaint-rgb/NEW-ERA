import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/agenda_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'campos_agenda.dart';
import 'dominio/agenda.dart';

/// Calendario › "Nueva cita" (sin [citaId]; [fecha] es el día elegido en el
/// mes) o editar una: título, tipo, fecha y hora, lugar, notas y quién la
/// acompaña. Viaja como ficha de cita.
class CitaFormPantalla extends ConsumerStatefulWidget {
  const CitaFormPantalla({super.key, this.citaId, this.fecha});

  final String? citaId;

  /// `yyyy-MM-dd` con el que se abre una cita nueva (por defecto, hoy).
  final String? fecha;

  @override
  ConsumerState<CitaFormPantalla> createState() => _CitaFormPantallaState();
}

class _CitaFormPantallaState extends ConsumerState<CitaFormPantalla> {
  final _titulo = TextEditingController();
  final _lugar = TextEditingController();
  final _notas = TextEditingController();
  String _tipo = TipoCita.medico;
  String? _fecha;
  String _hora = '10:00';
  String? _acompanaId;
  bool _cargado = false;
  bool _guardando = false;
  String? _errorTitulo;
  bool _errorGuardar = false;

  @override
  void dispose() {
    _titulo.dispose();
    _lugar.dispose();
    _notas.dispose();
    super.dispose();
  }

  void _cargar(Cita c) {
    _cargado = true;
    _titulo.text = c.titulo;
    _lugar.text = c.lugar ?? '';
    _notas.text = c.notas ?? '';
    _tipo = TipoCita.valores.contains(c.tipo) ? c.tipo : TipoCita.otra;
    _fecha = c.fecha;
    _hora = c.hora;
    _acompanaId = c.acompanaId;
  }

  void _volver() => context.canPop()
      ? context.pop()
      : context.go(Rutas.pestana('calendario'));

  Future<void> _elegirFecha(String actual) async {
    final f = await elegirFecha(context, actual);
    if (f != null && mounted) setState(() => _fecha = f);
  }

  Future<void> _elegirHora() async {
    final h = await elegirHora(context, _hora);
    if (h != null && mounted) setState(() => _hora = h);
  }

  Future<void> _guardar(String fecha) async {
    if (_guardando) return;
    final l = context.l;
    final titulo = _titulo.text.trim();
    final error = titulo.isEmpty ? l.citaErrorTitulo : null;
    setState(() {
      _errorTitulo = error;
      _errorGuardar = false;
    });
    if (error != null) return;
    setState(() => _guardando = true);
    try {
      final repo = ref.read(agendaRepositorioProvider);
      final datos = DatosCita(
        titulo: titulo,
        tipo: _tipo,
        fecha: fecha,
        hora: _hora,
        lugar: _lugar.text,
        notas: _notas.text,
        acompanaId: _acompanaId,
      );
      if (widget.citaId == null) {
        await repo.crearCita(datos);
      } else {
        await repo.editarCita(widget.citaId!, datos);
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
        title: Text(l.citaBorrarTitulo),
        content: Text(l.citaBorrarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            child: Text(l.cancelar),
          ),
          FilledButton(
            key: ClavesUi.agBorrarConfirmar,
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
      await ref.read(agendaRepositorioProvider).borrarCita(widget.citaId!);
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
    final editando = widget.citaId != null;
    final citas = ref.watch(citasProvider).value;
    if (editando && !_cargado && citas != null) {
      final x = citas.where((q) => q.id == widget.citaId).firstOrNull;
      if (x != null) _cargar(x);
    }
    final fechas = ref.watch(fechasAgendaProvider);
    final fecha = _fecha ?? widget.fecha ?? fechas.hoy;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.agVispera,
            titulo: editando ? l.citaFormEditar : l.citaFormNueva,
            reservarBotonMas: false,
            alVolver: _volver,
          ),
          const SizedBox(height: 14),
          if (editando && !_cargado)
            GrupoLista(
              children: [FilaLista(apagada: true, titulo: l.calSinNada)],
            )
          else ...[
            GrupoLista(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: TextField(
                    key: ClavesUi.agTitulo,
                    controller: _titulo,
                    enabled: !_guardando,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    maxLength: 80,
                    style: t.bodyLarge?.copyWith(color: c.texto),
                    decoration: InputDecoration(
                      labelText: l.citaCampoTitulo,
                      errorText: _errorTitulo,
                      counterText: '',
                    ),
                    onChanged: (_) {
                      if (_errorTitulo != null) {
                        setState(() => _errorTitulo = null);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: TextField(
                    key: ClavesUi.agLugar,
                    controller: _lugar,
                    enabled: !_guardando,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    maxLength: 80,
                    style: t.bodyLarge?.copyWith(color: c.texto),
                    decoration: InputDecoration(
                      labelText: l.citaCampoLugar,
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TituloSeccion(l.citaTipoTitulo),
            SelectorSegmentos<String>(
              valores: TipoCita.valores,
              seleccionado: _tipo,
              etiqueta: (v) => etiquetaTipoCita(l, v),
              clave: ClavesUi.agTipo,
              alCambiar: (v) => setState(() => _tipo = v),
            ),
            const SizedBox(height: 14),
            GrupoLista(
              children: [
                FilaSelector(
                  key: ClavesUi.agFecha,
                  etiqueta: l.agFecha,
                  valor: fechaLargaDeTexto(fecha),
                  enLinea: false,
                  icono: CupertinoIcons.calendar,
                  alPulsar: _guardando
                      ? null
                      : () => unawaited(_elegirFecha(fecha)),
                ),
                FilaSelector(
                  key: ClavesUi.agHora,
                  etiqueta: l.agHora,
                  valor: _hora,
                  icono: CupertinoIcons.clock,
                  alPulsar: _guardando ? null : () => unawaited(_elegirHora()),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GrupoLista(
              titulo: l.citaAcompanaTitulo,
              sangria: 16,
              children: [
                FilaElegir(
                  clave: ClavesUi.agAcompana('nadie'),
                  titulo: l.citaNadie,
                  elegida: _acompanaId == null,
                  alPulsar: _guardando
                      ? null
                      : () => setState(() => _acompanaId = null),
                ),
                for (final m in miembros)
                  FilaElegir(
                    clave: ClavesUi.agAcompana(m.id),
                    titulo: m.nombre,
                    elegida: _acompanaId == m.id,
                    alPulsar: _guardando
                        ? null
                        : () => setState(() => _acompanaId = m.id),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            GrupoLista(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    key: ClavesUi.agNotas,
                    controller: _notas,
                    enabled: !_guardando,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 5,
                    maxLength: 500,
                    style: t.bodyLarge?.copyWith(color: c.texto),
                    decoration: InputDecoration(
                      labelText: l.citaCampoNotas,
                      counterText: '',
                    ),
                  ),
                ),
              ],
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
              key: ClavesUi.agGuardar,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _guardando ? null : () => unawaited(_guardar(fecha)),
              child: Text(l.agGuardar),
            ),
            if (editando) ...[
              const SizedBox(height: 18),
              GrupoLista(
                children: [
                  FilaLista(
                    key: ClavesUi.agBorrar,
                    leading: IconoCuadrado(
                      CupertinoIcons.trash,
                      fondo: c.rojo,
                      color: c.sobreRojo,
                    ),
                    titulo: l.citaBorrar,
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
