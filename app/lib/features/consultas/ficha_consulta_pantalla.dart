import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/consultas_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../calendario/campos_agenda.dart';
import '../hoy/dominio/tomas.dart' show nombresAutoresProvider;
import 'dominio/consultas.dart';
import 'grabacion_consulta.dart';

/// Ficha de la consulta de una cita: preguntas para llevar (cualquier
/// familiar las amplía, edita, marca y borra), lo que ha pasado desde la
/// última consulta (cifras tal cual, solo lectura), notas de lo que dijo el
/// médico, grabación con permiso (solo en el móvil que graba) y un resumen
/// para copiar. Todo viaja por el cartero como fichas, salvo el audio.
class FichaConsultaPantalla extends ConsumerStatefulWidget {
  const FichaConsultaPantalla({super.key, required this.citaId});

  final String citaId;

  @override
  ConsumerState<FichaConsultaPantalla> createState() =>
      _FichaConsultaPantallaState();
}

class _FichaConsultaPantallaState extends ConsumerState<FichaConsultaPantalla> {
  final _pregunta = TextEditingController();
  final _nota = TextEditingController();
  final _grabando = ValueNotifier<bool>(false);
  bool _ocupado = false;

  @override
  void dispose() {
    _pregunta.dispose();
    _nota.dispose();
    _grabando.dispose();
    super.dispose();
  }

  void _avisar(String texto) {
    final mensajes = ScaffoldMessenger.of(context);
    mensajes.hideCurrentSnackBar();
    mensajes.showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 3)),
    );
  }

  void _volver() {
    if (_grabando.value) {
      _avisar(context.l.consGrabSalir);
      return;
    }
    context.canPop() ? context.pop() : context.go(Rutas.pestana('consultas'));
  }

  /// Ejecuta [accion]; si falla, lo avisa.
  Future<void> _hacer(Future<void> Function() accion) async {
    if (_ocupado) return;
    final l = context.l;
    setState(() => _ocupado = true);
    try {
      await accion();
    } catch (_) {
      if (mounted) _avisar(l.consErrorGuardar);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _anadirPregunta() async {
    final texto = _pregunta.text.trim();
    if (texto.isEmpty) return;
    await _hacer(() async {
      await ref
          .read(consultasRepositorioProvider)
          .crearPregunta(widget.citaId, texto);
      _pregunta.clear();
    });
  }

  Future<void> _anadirNota() async {
    final texto = _nota.text.trim();
    if (texto.isEmpty) return;
    await _hacer(() async {
      await ref
          .read(consultasRepositorioProvider)
          .crearNota(widget.citaId, texto);
      _nota.clear();
    });
  }

  Future<void> _editarPregunta(PreguntaConsulta p) async {
    final l = context.l;
    final nuevo = await _pedirTexto(
      context,
      titulo: l.consPreguntaEditar,
      inicial: p.texto,
      max: ConsultasRepositorio.maxPregunta,
      lineas: 3,
    );
    if (nuevo == null || !mounted) return;
    await _hacer(
      () => ref.read(consultasRepositorioProvider).editarPregunta(p.id, nuevo),
    );
  }

  Future<void> _editarNota(NotaConsulta n) async {
    final l = context.l;
    final nuevo = await _pedirTexto(
      context,
      titulo: l.consNotaEditar,
      inicial: n.texto,
      max: ConsultasRepositorio.maxNota,
      lineas: 6,
    );
    if (nuevo == null || !mounted) return;
    await _hacer(
      () => ref.read(consultasRepositorioProvider).editarNota(n.id, nuevo),
    );
  }

  Future<bool> _confirmarBorrado(String titulo, String texto) async {
    final l = context.l;
    final c = context.colores;
    final si = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            child: Text(l.cancelar),
          ),
          FilledButton(
            key: ClavesUi.consBorrarConfirmar,
            style: FilledButton.styleFrom(
              backgroundColor: c.rojo,
              foregroundColor: c.sobreRojo,
              minimumSize: const Size(44, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.consBorrarConfirmar),
          ),
        ],
      ),
    );
    return si == true && mounted;
  }

  Future<void> _borrarPregunta(PreguntaConsulta p) async {
    final l = context.l;
    if (!await _confirmarBorrado(
      l.consPreguntaBorrarTitulo,
      l.consPreguntaBorrarTexto,
    )) {
      return;
    }
    await _hacer(
      () => ref.read(consultasRepositorioProvider).borrarPregunta(p.id),
    );
  }

  Future<void> _borrarNota(NotaConsulta n) async {
    final l = context.l;
    if (!await _confirmarBorrado(
      l.consNotaBorrarTitulo,
      l.consNotaBorrarTexto,
    )) {
      return;
    }
    await _hacer(() => ref.read(consultasRepositorioProvider).borrarNota(n.id));
  }

  /// Compone el resumen y lo enseña para copiarlo (sin enviar nada).
  Future<void> _compartir(Cita cita) async {
    final l = context.l;
    final preguntas =
        ref.read(preguntasConsultaProvider(widget.citaId)).value ??
        const <PreguntaConsulta>[];
    final notas =
        ref.read(notasConsultaProvider(widget.citaId)).value ??
        const <NotaConsulta>[];
    final texto = textoResumenConsulta(
      l: l,
      cita: cita,
      fechaTexto: fechaLargaDeTexto(cita.fecha),
      preguntas: preguntas,
      notas: notas,
      nombres: ref.read(nombresAutoresProvider),
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.consResumenDialogo),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(texto, key: ClavesUi.consResumenTexto),
              const SizedBox(height: 12),
              Text(
                l.consResumenPie,
                style: Theme.of(ctx).textTheme.bodySmall
                    ?.copyWith(color: ctx.colores.textoSecundario),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            child: Text(l.consCerrar),
          ),
          FilledButton.icon(
            key: ClavesUi.consCopiar,
            style: FilledButton.styleFrom(minimumSize: const Size(44, 44)),
            icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 20),
            label: Text(l.consCopiar),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: texto));
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) _avisar(l.consCopiado);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final citasAsync = ref.watch(citasProvider);
    final cita = citasAsync.value
        ?.where((x) => x.id == widget.citaId && x.bajaEn == null)
        .firstOrNull;
    if (cita == null) {
      return Scaffold(
        key: ClavesUi.pantallaFichaConsulta,
        backgroundColor: c.fondoAgrupado,
        body: ListView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
          children: [
            CabeceraGrande(
              vispera: l.consVispera,
              titulo: l.pestanaConsultas,
              reservarBotonMas: false,
              alVolver: _volver,
            ),
            const SizedBox(height: 14),
            if (citasAsync.hasValue)
              GrupoLista(
                children: [
                  FilaLista(titulo: l.consCitaNoExiste, apagada: true),
                ],
              ),
          ],
        ),
      );
    }
    final preguntas =
        ref.watch(preguntasConsultaProvider(widget.citaId)).value ??
        const <PreguntaConsulta>[];
    final notas =
        ref.watch(notasConsultaProvider(widget.citaId)).value ??
        const <NotaConsulta>[];
    final nombres = ref.watch(nombresAutoresProvider);
    final zona = ref.watch(contextoProvider).zonaHoraria;

    String cuando(int ms) => diaYHora(
      aLocal(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true), zona),
    );

    return Scaffold(
      key: ClavesUi.pantallaFichaConsulta,
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.consVisperaFicha(
              fechaLargaDeTexto(cita.fecha),
              cita.hora,
            ),
            titulo: cita.titulo,
            reservarBotonMas: false,
            alVolver: _volver,
          ),
          const SizedBox(height: 14),
          GrupoLista(
            children: [
              FilaLista(
                key: ClavesUi.consEditarCita,
                leading: IconoCuadrado(
                  iconoTipoCita(cita.tipo),
                  fondo: c.indigo,
                  color: IconoCuadrado.simboloSobre(c.indigo),
                ),
                titulo: l.consEditarCita,
                subtitulo: [
                  etiquetaTipoCita(l, cita.tipo),
                  if (cita.lugar != null) cita.lugar!,
                ].join(' · '),
                onTap: () => context.push(Rutas.consultaCita(cita.id)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ---------------------------------------------------- Preguntas
          TituloSeccion(l.consPreguntasTitulo),
          GrupoLista(
            sangria: 16,
            children: [
              if (preguntas.isEmpty)
                FilaLista(titulo: l.consSinPreguntas, apagada: true)
              else
                for (final p in preguntas)
                  _FilaEditable(
                    key: ClavesUi.consPregunta(p.id),
                    texto: p.texto,
                    subtitulo: l.consPreguntaPor(
                      nombres[p.creadaPor] ?? l.consAlguien,
                    ),
                    estado: p.preguntada ? l.consPreguntaPreguntada : null,
                    marca: _Marca(
                      clave: ClavesUi.consPreguntaMarca(p.id),
                      hecha: p.preguntada,
                      etiqueta: p.preguntada
                          ? l.consPreguntaDesmarcar
                          : l.consPreguntaMarcar,
                      alPulsar: _ocupado
                          ? null
                          : () => _hacer(
                              () => ref
                                  .read(consultasRepositorioProvider)
                                  .marcarPreguntada(p.id, !p.preguntada),
                            ),
                    ),
                    claveEditar: ClavesUi.consPreguntaEditar(p.id),
                    claveBorrar: ClavesUi.consPreguntaBorrar(p.id),
                    etiquetaEditar: l.consPreguntaEditar,
                    etiquetaBorrar: l.consPreguntaBorrar,
                    alEditar: _ocupado ? null : () => _editarPregunta(p),
                    alBorrar: _ocupado ? null : () => _borrarPregunta(p),
                  ),
            ],
          ),
          const SizedBox(height: 10),
          _CampoAnadir(
            campo: ClavesUi.consPreguntaCampo,
            boton: ClavesUi.consPreguntaAnadir,
            controlador: _pregunta,
            etiqueta: l.consPreguntaCampo,
            textoBoton: l.consPreguntaAnadir,
            max: ConsultasRepositorio.maxPregunta,
            lineas: 2,
            alAnadir: _ocupado ? null : _anadirPregunta,
          ),
          const SizedBox(height: 20),

          // ------------------------------------- Desde la última consulta
          _BloqueDesdeUltima(citaId: widget.citaId, l: l, zona: zona),
          const SizedBox(height: 20),

          // ---------------------------------------------------- Notas
          TituloSeccion(l.consNotasTitulo),
          GrupoLista(
            sangria: 16,
            children: [
              if (notas.isEmpty)
                FilaLista(titulo: l.consSinNotas, apagada: true)
              else
                for (final n in notas)
                  _FilaEditable(
                    key: ClavesUi.consNota(n.id),
                    texto: n.texto,
                    subtitulo: l.consNotaDe(
                      nombres[n.creadaPor] ?? l.consAlguien,
                      cuando(n.creadaEn),
                    ),
                    claveEditar: ClavesUi.consNotaEditar(n.id),
                    claveBorrar: ClavesUi.consNotaBorrar(n.id),
                    etiquetaEditar: l.consNotaEditar,
                    etiquetaBorrar: l.consNotaBorrar,
                    alEditar: _ocupado ? null : () => _editarNota(n),
                    alBorrar: _ocupado ? null : () => _borrarNota(n),
                  ),
            ],
          ),
          const SizedBox(height: 10),
          _CampoAnadir(
            campo: ClavesUi.consNotaCampo,
            boton: ClavesUi.consNotaAnadir,
            controlador: _nota,
            etiqueta: l.consNotaCampo,
            textoBoton: l.consNotaAnadir,
            max: ConsultasRepositorio.maxNota,
            lineas: 3,
            alAnadir: _ocupado ? null : _anadirNota,
          ),
          const SizedBox(height: 20),

          // ---------------------------------------------------- Grabación
          TarjetaGrabacion(citaId: widget.citaId, grabando: _grabando),
          const SizedBox(height: 20),

          // ---------------------------------------------------- Resumen
          FilledButton.icon(
            key: ClavesUi.consCompartir,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: () => unawaited(_compartir(cita)),
            icon: const Icon(CupertinoIcons.doc_on_clipboard),
            label: Text(l.consCompartir),
          ),
        ],
      ),
    );
  }
}

/// Un diálogo con un campo de texto: devuelve el texto (sin espacios de más)
/// o nulo si se cancela o queda vacío.
Future<String?> _pedirTexto(
  BuildContext context, {
  required String titulo,
  required String inicial,
  required int max,
  required int lineas,
}) => showDialog<String>(
  context: context,
  builder: (_) =>
      _DialogoTexto(titulo: titulo, inicial: inicial, max: max, lineas: lineas),
);

class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({
    required this.titulo,
    required this.inicial,
    required this.max,
    required this.lineas,
  });

  final String titulo;
  final String inicial;
  final int max;
  final int lineas;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  late final _c = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        key: ClavesUi.consDialogoCampo,
        controller: _c,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        minLines: 1,
        maxLines: widget.lineas,
        maxLength: widget.max,
        decoration: const InputDecoration(counterText: ''),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
          child: Text(l.cancelar),
        ),
        FilledButton(
          key: ClavesUi.consDialogoGuardar,
          style: FilledButton.styleFrom(minimumSize: const Size(44, 44)),
          onPressed: () {
            final t = _c.text.trim();
            Navigator.pop(context, t.isEmpty ? null : t);
          },
          child: Text(l.consGuardar),
        ),
      ],
    );
  }
}

/// Campo para añadir una pregunta o una nota, con su botón.
class _CampoAnadir extends StatelessWidget {
  const _CampoAnadir({
    required this.campo,
    required this.boton,
    required this.controlador,
    required this.etiqueta,
    required this.textoBoton,
    required this.max,
    required this.lineas,
    required this.alAnadir,
  });

  final Key campo;
  final Key boton;
  final TextEditingController controlador;
  final String etiqueta;
  final String textoBoton;
  final int max;
  final int lineas;
  final VoidCallback? alAnadir;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: c.tarjeta,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: campo,
            controller: controlador,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: lineas,
            maxLength: max,
            style: t.bodyLarge?.copyWith(color: c.texto),
            decoration: InputDecoration(labelText: etiqueta, counterText: ''),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: boton,
              style: FilledButton.styleFrom(minimumSize: const Size(44, 44)),
              onPressed: alAnadir,
              icon: const Icon(CupertinoIcons.add, size: 20),
              label: Text(textoBoton),
            ),
          ),
        ],
      ),
    );
  }
}

/// Casilla redonda de «preguntada»: icono y, para el lector de pantalla, la
/// acción; 44 × 44.
class _Marca extends StatelessWidget {
  const _Marca({
    required this.clave,
    required this.hecha,
    required this.etiqueta,
    required this.alPulsar,
  });

  final Key clave;
  final bool hecha;
  final String etiqueta;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return IconButton(
      key: clave,
      tooltip: etiqueta,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      padding: EdgeInsets.zero,
      onPressed: alPulsar,
      icon: Icon(
        hecha ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
        size: 28,
        color: hecha ? c.verde : c.textoSecundario,
      ),
    );
  }
}

/// Fila de una pregunta o una nota: texto, quién y cuándo y, a la derecha,
/// editar y borrar (44 × 44). Con [marca], una casilla delante.
class _FilaEditable extends StatelessWidget {
  const _FilaEditable({
    super.key,
    required this.texto,
    required this.subtitulo,
    required this.claveEditar,
    required this.claveBorrar,
    required this.etiquetaEditar,
    required this.etiquetaBorrar,
    required this.alEditar,
    required this.alBorrar,
    this.estado,
    this.marca,
  });

  final String texto;
  final String subtitulo;

  /// Texto que acompaña al icono de estado («Preguntada»).
  final String? estado;
  final Widget? marca;
  final Key claveEditar;
  final Key claveBorrar;
  final String etiquetaEditar;
  final String etiquetaBorrar;
  final VoidCallback? alEditar;
  final VoidCallback? alBorrar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ?marca,
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: marca == null ? 10 : 4,
                  end: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texto,
                      style: t.titleSmall?.copyWith(
                        color: estado == null ? c.texto : c.textoSecundario,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      estado == null ? subtitulo : '$estado · $subtitulo',
                      style: t.bodySmall?.copyWith(color: c.textoSecundario),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              key: claveEditar,
              tooltip: etiquetaEditar,
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
              padding: EdgeInsets.zero,
              onPressed: alEditar,
              icon: Icon(CupertinoIcons.pencil, size: 22, color: c.azul),
            ),
            IconButton(
              key: claveBorrar,
              tooltip: etiquetaBorrar,
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
              padding: EdgeInsets.zero,
              onPressed: alBorrar,
              icon: Icon(CupertinoIcons.trash, size: 22, color: c.rojo),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Qué ha pasado desde la última consulta»: cifras tal cual, solo lectura.
class _BloqueDesdeUltima extends ConsumerWidget {
  const _BloqueDesdeUltima({
    required this.citaId,
    required this.l,
    required this.zona,
  });

  final String citaId;
  final AppLocalizations l;
  final String zona;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(desdeUltimaProvider(citaId));
    final d = datos.value;
    String dia(DateTime t) => fechaCorta(aLocal(t, zona));
    final rango = d == null
        ? null
        : d.porCitaAnterior
        ? l.consDesdeRangoCita(dia(d.inicio), dia(d.fin))
        : l.consDesdeRangoDias(
            d.fin.difference(d.inicio).inDays,
            dia(d.inicio),
            dia(d.fin),
          );

    FilaLista fila(String clave, String titulo, String valor) => FilaLista(
      key: ClavesUi.consCifra(clave),
      titulo: titulo,
      detalle: valor,
      etiquetaSemantica: '$titulo: $valor',
    );

    return Column(
      key: ClavesUi.consDesde,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TituloSeccion(l.consDesdeTitulo),
        GrupoLista(
          sangria: 16,
          pie: l.consDesdePie,
          children: [
            if (d == null)
              FilaLista(titulo: l.consDesdeCargando, apagada: true)
            else ...[
              FilaLista(titulo: rango!, apagada: true),
              fila(
                'tomas_ok',
                l.consTomasConfirmadas,
                l.consTomasDe(d.tomasConfirmadas, d.tomasPrevistas),
              ),
              fila(
                'tomas_sin',
                l.consTomasSinConfirmar,
                '${d.tomasSinConfirmar}',
              ),
              fila(
                'rondas_ok',
                l.consRondasContestadas,
                '${d.rondasContestadas}',
              ),
              fila(
                'rondas_sin',
                l.consRondasSinRespuesta,
                '${d.rondasSinRespuesta}',
              ),
              fila('mal', l.consVecesMal, '${d.vecesMal}'),
              fila('dolor', l.consVecesDolor, '${d.vecesDolor}'),
              fila('comidas', l.consComidasAnotadas, '${d.comidasAnotadas}'),
            ],
          ],
        ),
      ],
    );
  }
}
