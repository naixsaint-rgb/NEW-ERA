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

/// Calendario › "Nuevo turno" (sin [turnoId]; [fecha] es el día elegido en
/// el mes) o editar uno: quién está con ella, el día, de qué hora a qué hora
/// (con una hora de fin que no es posterior a la de inicio, acaba al día
/// siguiente: guardia de noche), si se repite cada semana y una nota.
class TurnoFormPantalla extends ConsumerStatefulWidget {
  const TurnoFormPantalla({super.key, this.turnoId, this.fecha});

  final String? turnoId;

  /// `yyyy-MM-dd` con el que se abre un turno nuevo (por defecto, hoy).
  final String? fecha;

  @override
  ConsumerState<TurnoFormPantalla> createState() => _TurnoFormPantallaState();
}

class _TurnoFormPantallaState extends ConsumerState<TurnoFormPantalla> {
  final _nota = TextEditingController();
  String? _miembroId;
  String? _fecha;
  String _desde = '09:00';
  String _hasta = '15:00';
  bool _repetir = false;
  bool _cargado = false;
  bool _guardando = false;
  bool _errorHoras = false;
  bool _errorGuardar = false;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  void _cargar(Turno t) {
    _cargado = true;
    _nota.text = t.nota ?? '';
    _miembroId = t.miembroId;
    _fecha = t.fecha;
    _desde = t.desdeHora;
    _hasta = t.hastaHora;
    _repetir = t.repetirSemanal;
  }

  void _volver() => context.canPop()
      ? context.pop()
      : context.go(Rutas.pestana('calendario'));

  Future<void> _elegirFecha(String actual) async {
    final f = await elegirFecha(context, actual);
    if (f != null && mounted) setState(() => _fecha = f);
  }

  Future<void> _elegirDesde() async {
    final h = await elegirHora(context, _desde);
    if (h != null && mounted) {
      setState(() {
        _desde = h;
        _errorHoras = false;
      });
    }
  }

  Future<void> _elegirHasta() async {
    final h = await elegirHora(context, _hasta);
    if (h != null && mounted) {
      setState(() {
        _hasta = h;
        _errorHoras = false;
      });
    }
  }

  Future<void> _guardar(String fecha, String miembro) async {
    if (_guardando) return;
    if (_desde == _hasta) {
      setState(() => _errorHoras = true);
      return;
    }
    setState(() {
      _guardando = true;
      _errorGuardar = false;
    });
    try {
      final repo = ref.read(agendaRepositorioProvider);
      final datos = DatosTurno(
        miembroId: miembro,
        fecha: fecha,
        desde: _desde,
        hasta: _hasta,
        repetirSemanal: _repetir,
        nota: _nota.text,
      );
      if (widget.turnoId == null) {
        await repo.crearTurno(datos);
      } else {
        await repo.editarTurno(widget.turnoId!, datos);
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
        title: Text(l.turnoBorrarTitulo),
        content: Text(l.turnoBorrarTexto),
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
      await ref.read(agendaRepositorioProvider).borrarTurno(widget.turnoId!);
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
    final editando = widget.turnoId != null;
    final turnos = ref.watch(turnosProvider).value;
    if (editando && !_cargado && turnos != null) {
      final x = turnos.where((q) => q.id == widget.turnoId).firstOrNull;
      if (x != null) _cargar(x);
    }
    final fechas = ref.watch(fechasAgendaProvider);
    final fecha = _fecha ?? widget.fecha ?? fechas.hoy;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final propio = ref.watch(sesionProvider).miembroId;
    // Quién: el elegido; si no, el familiar de este móvil o el primero.
    final miembro =
        _miembroId ??
        (miembros.any((m) => m.id == propio)
            ? propio
            : miembros.firstOrNull?.id);
    final cruza =
        _desde != _hasta && minutosDeHora(_hasta) < minutosDeHora(_desde);
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.agVispera,
            titulo: editando ? l.turnoFormEditar : l.turnoFormNuevo,
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
              titulo: l.turnoQuien,
              sangria: 16,
              children: [
                if (miembros.isEmpty)
                  FilaLista(apagada: true, titulo: l.turnoSinFamiliares),
                for (final m in miembros)
                  FilaElegir(
                    clave: ClavesUi.agMiembro(m.id),
                    titulo: m.nombre,
                    elegida: miembro == m.id,
                    alPulsar: _guardando
                        ? null
                        : () => setState(() => _miembroId = m.id),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            GrupoLista(
              pie: cruza ? l.turnoNochePie : null,
              children: [
                FilaSelector(
                  key: ClavesUi.agFecha,
                  etiqueta: _repetir ? l.turnoPrimerDia : l.turnoDia,
                  valor: fechaLargaDeTexto(fecha),
                  enLinea: false,
                  icono: CupertinoIcons.calendar,
                  alPulsar: _guardando
                      ? null
                      : () => unawaited(_elegirFecha(fecha)),
                ),
                FilaSelector(
                  key: ClavesUi.agDesde,
                  etiqueta: l.turnoDesde,
                  valor: _desde,
                  icono: CupertinoIcons.clock,
                  alPulsar: _guardando ? null : () => unawaited(_elegirDesde()),
                ),
                FilaSelector(
                  key: ClavesUi.agHasta,
                  etiqueta: l.turnoHasta,
                  valor: _hasta,
                  icono: CupertinoIcons.clock_fill,
                  alPulsar: _guardando ? null : () => unawaited(_elegirHasta()),
                ),
              ],
            ),
            if (_errorHoras)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  l.turnoErrorHoras,
                  style: t.bodyMedium?.copyWith(color: c.rojo),
                ),
              ),
            const SizedBox(height: 14),
            GrupoLista(
              pie: l.turnoRepetirPie,
              children: [
                FilaLista(
                  key: ClavesUi.agRepetir,
                  leading: const IconoCuadrado(CupertinoIcons.repeat),
                  titulo: l.turnoRepetir,
                  conChevron: false,
                  onTap: _guardando
                      ? null
                      : () => setState(() => _repetir = !_repetir),
                  etiquetaSemantica: _repetir
                      ? '${l.turnoRepetir}, ${l.circSeleccionado}'
                      : null,
                  trailing: ExcludeSemantics(
                    child: CupertinoSwitch(
                      value: _repetir,
                      activeTrackColor: c.verde,
                      onChanged: _guardando
                          ? null
                          : (v) => setState(() => _repetir = v),
                    ),
                  ),
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
                    controller: _nota,
                    enabled: !_guardando,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 200,
                    style: t.bodyLarge?.copyWith(color: c.texto),
                    decoration: InputDecoration(
                      labelText: l.turnoCampoNota,
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
              onPressed: _guardando || miembro == null
                  ? null
                  : () => unawaited(_guardar(fecha, miembro)),
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
                    titulo: l.turnoBorrar,
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
