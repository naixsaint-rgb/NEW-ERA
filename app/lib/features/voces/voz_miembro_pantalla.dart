import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/voces_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/plataforma/audio/grabadora.dart';
import '../../core/plataforma/audio/reproductor.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'textos_voz.dart';

/// Voces › un familiar: sus cinco frases. Para cada una, el texto que se
/// lee, "Grabar" (8 s como mucho, con cuenta atrás), "Escuchar", "Repetir" y
/// "Aprobar". Sin permiso del familiar no se graba: "Grabar" lleva antes a
/// la pantalla del permiso. Abajo, "Retirar la voz".
class VozMiembroPantalla extends ConsumerStatefulWidget {
  const VozMiembroPantalla({super.key, required this.miembroId});

  final String miembroId;

  @override
  ConsumerState<VozMiembroPantalla> createState() => _VozMiembroPantallaState();
}

class _VozMiembroPantallaState extends ConsumerState<VozMiembroPantalla> {
  late final Grabadora _grabadora;
  late final Reproductor _reproductor;

  /// Frase que se está grabando y su voz.
  UsoFrase? _grabando;
  String? _vozEnCurso;
  int _restante = 0;
  Timer? _temporizador;

  /// Guardando, aprobando o pidiendo permiso: los botones esperan.
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _grabadora = ref.read(grabadoraProvider);
    _reproductor = ref.read(reproductorProvider);
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    if (_grabando != null) unawaited(_grabadora.cancelar());
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

  void _volver() =>
      context.canPop() ? context.pop() : context.go(Rutas.pestana('voces'));

  Future<void> _grabar(Voz? voz, UsoFrase uso) async {
    if (_grabando != null || _ocupado) return;
    if (voz == null) {
      context.go(Rutas.vozPermiso(widget.miembroId));
      return;
    }
    final l = context.l;
    setState(() => _ocupado = true);
    try {
      await _reproductor.parar();
      if (!await _grabadora.pedirPermiso()) {
        if (mounted) _avisar(l.vozSinMicrofono);
        return;
      }
      final ruta = ref.read(vocesRepositorioProvider).rutaNueva(voz.id, uso);
      await _grabadora.empezar(ruta);
      if (!mounted) {
        await _grabadora.cancelar();
        return;
      }
      setState(() {
        _grabando = uso;
        _vozEnCurso = voz.id;
        _restante = FormatoVoz.segundosMaximos;
      });
      _temporizador = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_restante <= 1) {
          unawaited(_parar());
        } else {
          setState(() => _restante--);
        }
      });
    } catch (_) {
      if (mounted) _avisar(l.vozErrorGrabar);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _parar() async {
    final uso = _grabando;
    final vozId = _vozEnCurso;
    if (uso == null || vozId == null) return;
    _temporizador?.cancel();
    _temporizador = null;
    final l = context.l;
    final texto = textoFrase(
      l,
      uso,
      ref.read(personaProvider).value?.alias ?? '',
    );
    setState(() {
      _grabando = null;
      _vozEnCurso = null;
      _ocupado = true;
    });
    try {
      final ruta = await _grabadora.parar();
      if (ruta == null) {
        if (mounted) _avisar(l.vozErrorGrabar);
        return;
      }
      await ref
          .read(vocesRepositorioProvider)
          .guardarGrabacion(vozId: vozId, uso: uso, texto: texto, ruta: ruta);
    } catch (_) {
      if (mounted) _avisar(l.vozErrorGrabar);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _aprobar(Frase f) async {
    if (_ocupado || _grabando != null) return;
    final l = context.l;
    setState(() => _ocupado = true);
    try {
      final r = await ref.read(vocesRepositorioProvider).aprobar(f.id);
      if (r == AprobacionFrase.sinAudio && mounted) _avisar(l.vozNoCabe);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _retirar(Voz voz, Miembro m) async {
    final l = context.l;
    final c = context.colores;
    final si = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.vozRetirarTitulo(m.nombre)),
        content: Text(l.vozRetirarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            child: Text(l.cancelar),
          ),
          FilledButton(
            key: ClavesUi.vozRetirarConfirmar,
            style: FilledButton.styleFrom(
              backgroundColor: c.rojo,
              foregroundColor: c.sobreRojo,
              minimumSize: const Size(44, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.vozRetirarConfirmar),
          ),
        ],
      ),
    );
    if (si != true || !mounted) return;
    await _reproductor.parar();
    await ref.read(vocesRepositorioProvider).retirar(voz.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final voces = ref.watch(vocesProvider).value ?? const <Voz>[];
    final frases = ref.watch(frasesProvider).value ?? const <Frase>[];
    final alias = ref.watch(personaProvider).value?.alias ?? '';
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final m = miembros.where((x) => x.id == widget.miembroId).firstOrNull;
    if (m == null) {
      return Scaffold(
        backgroundColor: c.fondoAgrupado,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            CabeceraGrande(
              titulo: l.pestanaVoces,
              reservarBotonMas: false,
              alVolver: _volver,
            ),
          ],
        ),
      );
    }
    final voz = vozActivaDe(m.id, voces);
    final retirada = voz == null ? vozRetiradaDe(m.id, voces) : null;
    final suyas = voz == null
        ? const <UsoFrase, Frase>{}
        : frasesDeVoz(voz.id, frases);
    final libre = !_ocupado && _grabando == null;

    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.vozDe,
            titulo: m.nombre,
            reservarBotonMas: false,
            alVolver: _volver,
          ),
          const SizedBox(height: 14),
          if (voz == null) ...[
            _TarjetaPermiso(
              titulo: l.vozPermisoTitulo,
              texto: retirada == null
                  ? l.vozPermisoFalta(m.nombre)
                  : l.vozRetiradaEl(
                      diaYHora(
                        aLocal(
                          DateTime.fromMillisecondsSinceEpoch(
                            retirada.retiradaEn!,
                            isUtc: true,
                          ),
                          zona,
                        ),
                      ),
                    ),
              boton: retirada == null ? l.vozLeerYAceptar : l.vozVolverAGrabar,
              alPulsar: () => context.go(Rutas.vozPermiso(m.id)),
            ),
            const SizedBox(height: 14),
          ],
          TituloSeccion(l.vozFrases),
          for (final (i, uso) in UsoFrase.values.indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            _TarjetaFrase(
              key: ClavesUi.vozFrase(uso.nombre),
              uso: uso,
              texto: textoFrase(l, uso, alias),
              cuando: cuandoSuena(l, uso),
              frase: suyas[uso],
              grabando: _grabando == uso,
              restante: _restante,
              habilitado: libre,
              alGrabar: () => _grabar(voz, uso),
              alParar: _parar,
              alEscuchar: (f) => _reproductor.reproducir(f.audioRuta!),
              alAprobar: _aprobar,
            ),
          ],
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
            child: Text(
              l.vozFrasesPie,
              style: t.bodySmall?.copyWith(color: c.textoSecundario),
            ),
          ),
          if (voz != null) ...[
            const SizedBox(height: 24),
            GrupoLista(
              children: [
                FilaLista(
                  key: ClavesUi.vozRetirar,
                  leading: IconoCuadrado(CupertinoIcons.trash, fondo: c.rojo),
                  titulo: l.vozRetirar,
                  colorTitulo: c.rojo,
                  conChevron: false,
                  onTap: libre ? () => _retirar(voz, m) : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// "Antes de grabar": el familiar aún no ha dado permiso (o lo retiró).
class _TarjetaPermiso extends StatelessWidget {
  const _TarjetaPermiso({
    required this.titulo,
    required this.texto,
    required this.boton,
    required this.alPulsar,
  });

  final String titulo;
  final String texto;
  final String boton;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.tarjeta,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconoCuadrado(CupertinoIcons.hand_raised_fill, fondo: c.morado),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.texto,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(texto, style: t.bodyMedium?.copyWith(color: c.texto)),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: ClavesUi.vozLeerYAceptar,
              onPressed: alPulsar,
              icon: const Icon(CupertinoIcons.doc_text, size: 20),
              label: Text(boton),
              style: FilledButton.styleFrom(
                backgroundColor: c.azul,
                foregroundColor: c.sobreAzul,
                minimumSize: const Size(44, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una frase: texto, cuándo suena, su estado (icono + texto) y sus botones.
class _TarjetaFrase extends StatelessWidget {
  const _TarjetaFrase({
    super.key,
    required this.uso,
    required this.texto,
    required this.cuando,
    required this.frase,
    required this.grabando,
    required this.restante,
    required this.habilitado,
    required this.alGrabar,
    required this.alParar,
    required this.alEscuchar,
    required this.alAprobar,
  });

  final UsoFrase uso;
  final String texto;
  final String cuando;
  final Frase? frase;
  final bool grabando;
  final int restante;
  final bool habilitado;
  final VoidCallback alGrabar;
  final VoidCallback alParar;
  final ValueChanged<Frase> alEscuchar;
  final ValueChanged<Frase> alAprobar;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final f = frase;
    final conAudio = f != null && f.audioRuta != null;
    final (icono, color, estado) = !conAudio
        ? (CupertinoIcons.circle, c.textoSecundario, l.vozSinGrabar)
        : f.aprobada
        ? (CupertinoIcons.checkmark_seal_fill, c.verde, l.vozEstadoAprobada)
        : (CupertinoIcons.clock_fill, c.naranja, l.vozEstadoPendiente);

    ButtonStyle relleno(Color fondo, Color frente) => FilledButton.styleFrom(
      backgroundColor: fondo,
      foregroundColor: frente,
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 14),
    );

    final botones = <Widget>[
      if (!conAudio)
        FilledButton.icon(
          key: ClavesUi.vozGrabar(uso.nombre),
          onPressed: habilitado ? alGrabar : null,
          icon: const Icon(CupertinoIcons.mic_fill, size: 20),
          label: Text(l.vozGrabar),
          style: relleno(c.azul, c.sobreAzul),
        )
      else ...[
        FilledButton.icon(
          key: ClavesUi.vozEscuchar(uso.nombre),
          onPressed: habilitado ? () => alEscuchar(f) : null,
          icon: const Icon(CupertinoIcons.play_fill, size: 20),
          label: Text(l.vozEscuchar),
          style: relleno(c.azulClaro, c.azulSobreTinte),
        ),
        FilledButton.icon(
          key: ClavesUi.vozGrabar(uso.nombre),
          onPressed: habilitado ? alGrabar : null,
          icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 20),
          label: Text(l.vozRepetir),
          style: relleno(c.azulClaro, c.azulSobreTinte),
        ),
        if (!f.aprobada)
          FilledButton.icon(
            key: ClavesUi.vozAprobar(uso.nombre),
            onPressed: habilitado ? () => alAprobar(f) : null,
            icon: const Icon(CupertinoIcons.checkmark_alt, size: 20),
            label: Text(l.vozAprobar),
            style: relleno(c.verde, c.sobreVerde),
          ),
      ],
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.tarjeta,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            texto,
            style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: c.texto,
            ),
          ),
          const SizedBox(height: 2),
          Text(cuando, style: t.bodySmall?.copyWith(color: c.textoSecundario)),
          const SizedBox(height: 10),
          if (grabando)
            Row(
              children: [
                Icon(CupertinoIcons.mic_fill, size: 22, color: c.rojo),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l.vozGrabando(restante),
                      key: ClavesUi.vozCuentaAtras,
                      style: t.titleSmall?.copyWith(
                        color: c.texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: ClavesUi.vozParar(uso.nombre),
                  onPressed: alParar,
                  icon: const Icon(CupertinoIcons.stop_fill, size: 20),
                  label: Text(l.vozParar),
                  style: relleno(c.rojo, c.sobreRojo),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                ExcludeSemantics(child: Icon(icono, size: 18, color: color)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    estado,
                    style: t.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: botones),
          ],
        ],
      ),
    );
  }
}
