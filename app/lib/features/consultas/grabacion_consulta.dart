import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plataforma/audio/archivos_voz.dart';
import '../../core/plataforma/audio/grabadora.dart';
import '../../core/plataforma/audio/reproductor.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../hoy/dominio/tomas.dart' show nombresAutoresProvider;
import 'dominio/consultas.dart';

/// `m:ss` (o `h:mm:ss` desde la hora) de [segundos].
String duracionTexto(int segundos) {
  String dos(int n) => n.toString().padLeft(2, '0');
  final h = segundos ~/ 3600;
  final m = (segundos % 3600) ~/ 60;
  final s = segundos % 60;
  return h > 0 ? '$h:${dos(m)}:${dos(s)}' : '$m:${dos(s)}';
}

/// El audio de la consulta [citaId] está en este móvil (carpeta
/// `consultas/`). Se vuelve a mirar cuando cambia la marca.
final audioConsultaLocalProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, citaId) async {
      ref.watch(grabacionConsultaProvider(citaId));
      return ref.read(archivosVozProvider).existe(RutasVoz.consulta(citaId));
    });

/// Quién firma en este móvil (el familiar, o la persona si no hay).
String _yo(WidgetRef ref) =>
    ref.watch(sesionProvider).miembroId ??
    ref.watch(contextoProvider).personaId;

/// Ficha de consulta › «Grabación»: «Grabar la consulta» (antes, el aviso de
/// pedir permiso al médico con la casilla «Tengo su permiso»), grabación de
/// hasta 60 minutos en calidad de voz baja, guardada solo en este móvil
/// (`Documentos/consultas/`; no viaja por el cartero: no cabe), con
/// «Escuchar» y «Borrar». En los demás móviles solo sale que hay una
/// grabación y dónde está.
class TarjetaGrabacion extends ConsumerStatefulWidget {
  const TarjetaGrabacion({
    super.key,
    required this.citaId,
    required this.grabando,
  });

  final String citaId;

  /// Lo pone a `true` mientras graba: la ficha no deja salir.
  final ValueNotifier<bool> grabando;

  @override
  ConsumerState<TarjetaGrabacion> createState() => _TarjetaGrabacionState();
}

class _TarjetaGrabacionState extends ConsumerState<TarjetaGrabacion>
    with AutomaticKeepAliveClientMixin {
  late final Grabadora _grabadora;
  late final Reproductor _reproductor;
  Timer? _temporizador;
  DateTime? _inicio;
  int _segundos = 0;
  bool _ocupado = false;
  bool _sonando = false;

  bool get _grabandoAhora => _inicio != null;

  /// Mientras graba, la tarjeta sigue viva aunque se desplace la ficha: si se
  /// descartara, se cancelaría la grabación.
  @override
  bool get wantKeepAlive => _grabandoAhora || _ocupado;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    updateKeepAlive();
  }

  @override
  void initState() {
    super.initState();
    _grabadora = ref.read(grabadoraProvider);
    _reproductor = ref.read(reproductorProvider);
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    if (_grabandoAhora) unawaited(_grabadora.cancelar());
    unawaited(_reproductor.parar());
    super.dispose();
  }

  void _avisar(String texto) {
    final mensajes = ScaffoldMessenger.of(context);
    mensajes.hideCurrentSnackBar();
    mensajes.showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 3)),
    );
  }

  Future<bool> _pedirPermiso() async {
    final l = context.l;
    final c = context.colores;
    final si = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        var tengo = false;
        return StatefulBuilder(
          builder: (ctx, setEstado) => AlertDialog(
            title: Text(l.consGrabAvisoTitulo),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.consGrabAvisoTexto),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    key: ClavesUi.consGrabPermiso,
                    value: tengo,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l.consGrabPermiso),
                    onChanged: (v) => setEstado(() => tengo = v ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                child: Text(l.cancelar),
              ),
              FilledButton(
                key: ClavesUi.consGrabEmpezar,
                style: FilledButton.styleFrom(
                  backgroundColor: c.rojo,
                  foregroundColor: c.sobreRojo,
                  minimumSize: const Size(44, 44),
                ),
                onPressed: tengo ? () => Navigator.pop(ctx, true) : null,
                child: Text(l.consGrabEmpezar),
              ),
            ],
          ),
        );
      },
    );
    return si == true;
  }

  Future<void> _grabar() async {
    if (_ocupado || _grabandoAhora) return;
    if (!await _pedirPermiso() || !mounted) return;
    final l = context.l;
    final reloj = ref.read(relojProvider);
    setState(() => _ocupado = true);
    try {
      await _reproductor.parar();
      if (!await _grabadora.pedirPermiso()) {
        if (mounted) _avisar(l.consGrabSinMic);
        return;
      }
      await _grabadora.empezar(RutasVoz.consulta(widget.citaId));
      if (!mounted) {
        await _grabadora.cancelar();
        return;
      }
      setState(() {
        _inicio = reloj.ahora();
        _segundos = 0;
        _sonando = false;
      });
      widget.grabando.value = true;
      _temporizador = Timer.periodic(const Duration(seconds: 1), (_) {
        final inicio = _inicio;
        if (!mounted || inicio == null) return;
        final s = reloj.ahora().difference(inicio).inSeconds;
        if (s >= FormatoConsulta.segundosMaximos) {
          unawaited(_parar());
        } else {
          setState(() => _segundos = s < 0 ? 0 : s);
        }
      });
    } catch (_) {
      if (mounted) _avisar(l.consGrabError);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _parar() async {
    final inicio = _inicio;
    if (inicio == null || _ocupado) return;
    _temporizador?.cancel();
    _temporizador = null;
    final l = context.l;
    final segundos = ref
        .read(relojProvider)
        .ahora()
        .difference(inicio)
        .inSeconds
        .clamp(0, FormatoConsulta.segundosMaximos);
    setState(() {
      _inicio = null;
      _ocupado = true;
    });
    widget.grabando.value = false;
    final repo = ref.read(consultasRepositorioProvider);
    final archivos = ref.read(archivosVozProvider);
    try {
      final ruta = await _grabadora.parar();
      if (ruta == null) {
        if (mounted) _avisar(l.consGrabError);
        return;
      }
      try {
        await repo.marcarGrabacion(widget.citaId, segundos);
      } catch (_) {
        await archivos.borrar(ruta);
        rethrow;
      }
    } catch (_) {
      if (mounted) _avisar(l.consGrabError);
    } finally {
      ref.invalidate(audioConsultaLocalProvider(widget.citaId));
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _escuchar() async {
    if (_sonando) {
      setState(() => _sonando = false);
      await _reproductor.parar();
      return;
    }
    setState(() => _sonando = true);
    await _reproductor.reproducir(RutasVoz.consulta(widget.citaId));
  }

  Future<void> _borrar() async {
    final l = context.l;
    final c = context.colores;
    final si = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.consGrabBorrarTitulo),
        content: Text(l.consGrabBorrarTexto),
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
    if (si != true || !mounted) return;
    final repo = ref.read(consultasRepositorioProvider);
    final archivos = ref.read(archivosVozProvider);
    setState(() {
      _ocupado = true;
      _sonando = false;
    });
    try {
      await _reproductor.parar();
      await archivos.borrar(RutasVoz.consulta(widget.citaId));
      await repo.quitarGrabacion(widget.citaId);
    } catch (_) {
      if (mounted) _avisar(l.consGrabError);
    } finally {
      ref.invalidate(audioConsultaLocalProvider(widget.citaId));
      if (mounted) setState(() => _ocupado = false);
    }
  }

  ButtonStyle _relleno(Color fondo, Color frente) => FilledButton.styleFrom(
    backgroundColor: fondo,
    foregroundColor: frente,
    minimumSize: const Size(44, 44),
    padding: const EdgeInsets.symmetric(horizontal: 14),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final marca = ref.watch(grabacionConsultaProvider(widget.citaId)).value;
    final hayArchivo =
        ref.watch(audioConsultaLocalProvider(widget.citaId)).value ?? false;
    final nombres = ref.watch(nombresAutoresProvider);
    final yo = _yo(ref);
    final libre = !_ocupado && !_grabandoAhora;

    final Widget estado;
    if (_grabandoAhora) {
      estado = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(CupertinoIcons.mic_fill, size: 22, color: c.rojo),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l.consGrabando(duracionTexto(_segundos)),
                    key: ClavesUi.consGrabTiempo,
                    style: t.titleSmall?.copyWith(
                      color: c.texto,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: ClavesUi.consGrabParar,
              onPressed: _ocupado ? null : _parar,
              icon: const Icon(CupertinoIcons.stop_fill, size: 20),
              label: Text(l.consGrabParar),
              style: _relleno(c.rojo, c.sobreRojo),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.consGrabLimite,
            style: t.bodySmall?.copyWith(color: c.textoSecundario),
          ),
        ],
      );
    } else if (marca == null) {
      estado = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: ClavesUi.consGrabar,
              onPressed: libre ? _grabar : null,
              icon: const Icon(CupertinoIcons.mic_fill, size: 20),
              label: Text(l.consGrabar),
              style: _relleno(c.azul, c.sobreAzul),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.consGrabLocal,
            style: t.bodySmall?.copyWith(color: c.textoSecundario),
          ),
        ],
      );
    } else if (marca.grabadaPor != yo) {
      estado = Row(
        children: [
          ExcludeSemantics(
            child: Icon(CupertinoIcons.mic_fill, size: 20, color: c.azul),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.consGrabEnMovil(nombres[marca.grabadaPor] ?? l.consAlguien),
              key: ClavesUi.consGrabEstado,
              style: t.titleSmall?.copyWith(
                color: c.texto,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    } else {
      estado = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  hayArchivo
                      ? CupertinoIcons.checkmark_seal_fill
                      : CupertinoIcons.exclamationmark_circle_fill,
                  size: 20,
                  color: hayArchivo ? c.verde : c.naranja,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hayArchivo
                      ? l.consGrabHay(duracionTexto(marca.segundos))
                      : l.consGrabNoEsta,
                  key: ClavesUi.consGrabEstado,
                  style: t.titleSmall?.copyWith(
                    color: c.texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (hayArchivo)
                FilledButton.icon(
                  key: ClavesUi.consGrabEscuchar,
                  onPressed: libre ? _escuchar : null,
                  icon: Icon(
                    _sonando
                        ? CupertinoIcons.stop_fill
                        : CupertinoIcons.play_fill,
                    size: 20,
                  ),
                  label: Text(
                    _sonando ? l.consGrabParaEscucha : l.consGrabEscuchar,
                  ),
                  style: _relleno(c.azulClaro, c.azulSobreTinte),
                ),
              FilledButton.icon(
                key: ClavesUi.consGrabBorrar,
                onPressed: libre ? _borrar : null,
                icon: const Icon(CupertinoIcons.trash, size: 20),
                label: Text(l.consGrabBorrar),
                style: _relleno(c.rojo, c.sobreRojo),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.consGrabLocal,
            style: t.bodySmall?.copyWith(color: c.textoSecundario),
          ),
        ],
      );
    }

    return PopScope(
      canPop: !_grabandoAhora,
      onPopInvokedWithResult: (salio, _) {
        if (!salio) _avisar(l.consGrabSalir);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TituloSeccion(l.consGrabTitulo),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.tarjeta,
              borderRadius: BorderRadius.circular(14),
            ),
            child: estado,
          ),
        ],
      ),
    );
  }
}
