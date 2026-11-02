import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/cripto/tema_aviso.dart';
import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../avisos/avisos_providers.dart';

/// Círculo › un familiar: su puesto en el orden de aviso (lo cambia
/// cualquiera de la familia; viaja como ficha) y, si es el familiar de este
/// móvil, «Avisos en este móvil»: suscribirse a su tema de ntfy, copiarlo y
/// enviarse un aviso de prueba.
class FamiliarPantalla extends ConsumerWidget {
  const FamiliarPantalla({super.key, required this.miembroId});

  final String miembroId;

  /// Puestos que se ofrecen: ninguno (0) y del 1 al número de familiares
  /// (como mucho 5).
  static List<int> puestos(int familiares) => [
    for (var i = 0; i <= math.min(math.max(familiares, 1), 5); i++) i,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final m = miembros.where((x) => x.id == miembroId).firstOrNull;
    final propio = ref.watch(sesionProvider).miembroId == miembroId;
    void volver() =>
        context.canPop() ? context.pop() : context.go(Rutas.pestana('circulo'));

    if (m == null) {
      return Scaffold(
        backgroundColor: c.fondoAgrupado,
        body: ListView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
          children: [
            CabeceraGrande(
              titulo: l.pestanaCirculo,
              reservarBotonMas: false,
              alVolver: volver,
            ),
            GrupoLista(
              children: [FilaLista(apagada: true, titulo: l.sinFamiliares)],
            ),
          ],
        ),
      );
    }
    final opciones = puestos(miembros.length);
    final actual = m.ordenEscalado ?? 0;
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.pestanaCirculo,
            titulo: m.nombre,
            reservarBotonMas: false,
            alVolver: volver,
          ),
          const SizedBox(height: 14),
          TituloSeccion(l.circOrdenTitulo),
          SelectorSegmentos<int>(
            valores: opciones.contains(actual)
                ? opciones
                : [...opciones, actual],
            seleccionado: actual,
            etiqueta: (v) => v == 0 ? l.circSinPuesto : '$v',
            clave: (v) => ClavesUi.circPuesto(v),
            alCambiar: (v) => unawaited(_cambiarPuesto(ref, v)),
          ),
          _Pie(l.circOrdenPie),
          const SizedBox(height: 18),
          if (propio)
            _AvisosEsteMovil(miembroId: m.id)
          else
            GrupoLista(
              titulo: l.circAvisosTitulo,
              children: [
                FilaLista(
                  apagada: true,
                  leading: const IconoCuadrado(CupertinoIcons.bell),
                  titulo: l.circAvisosOtro(m.nombre),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _cambiarPuesto(WidgetRef ref, int puesto) async {
    try {
      await ref
          .read(circuloRepositorioProvider)
          .cambiarOrdenEscalado(miembroId, puesto == 0 ? null : puesto);
    } catch (_) {
      // Se queda como estaba; se puede volver a intentar.
    }
  }
}

/// Texto pequeño bajo un grupo.
class _Pie extends StatelessWidget {
  const _Pie(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        texto,
        style: t.bodySmall?.copyWith(color: c.textoSecundario),
      ),
    );
  }
}

/// «Avisos en este móvil»: abrir ntfy con el tema, el tema para copiarlo,
/// el aviso de prueba, los tres pasos y qué ve ntfy.sh.
class _AvisosEsteMovil extends ConsumerStatefulWidget {
  const _AvisosEsteMovil({required this.miembroId});

  final String miembroId;

  @override
  ConsumerState<_AvisosEsteMovil> createState() => _AvisosEsteMovilState();
}

class _AvisosEsteMovilState extends ConsumerState<_AvisosEsteMovil> {
  bool _enviando = false;

  void _mensaje(String texto) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _abrir(String tema) async {
    final texto = context.l.circAvisosNoAbre;
    var ok = false;
    try {
      ok = await ref.read(abrirEnlaceProvider)(
        TemaAviso.enlaceSuscripcion(tema),
      );
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) _mensaje(texto);
  }

  Future<void> _copiar(String tema) async {
    final texto = context.l.circAvisosCopiado;
    await Clipboard.setData(ClipboardData(text: tema));
    if (mounted) _mensaje(texto);
  }

  Future<void> _probar() async {
    if (_enviando) return;
    final l = context.l;
    setState(() => _enviando = true);
    ResultadoAviso? r;
    try {
      r = await ref.read(envioAvisosProvider).enviarPrueba(widget.miembroId);
    } catch (_) {
      r = ResultadoAviso.fallido;
    }
    if (!mounted) return;
    setState(() => _enviando = false);
    _mensaje(
      r == ResultadoAviso.enviado
          ? l.circAvisosPruebaOk
          : l.circAvisosPruebaFallo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final temaAsync = ref.watch(temaAvisoProvider(widget.miembroId));
    final tema = temaAsync.value;
    if (temaAsync.isLoading) return const SizedBox.shrink();
    if (tema == null) {
      return GrupoLista(
        titulo: l.circAvisosTitulo,
        children: [FilaLista(apagada: true, titulo: l.circAvisosSinClave)],
      );
    }
    final explicacion = t.bodyMedium?.copyWith(color: c.textoSecundario);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GrupoLista(
          titulo: l.circAvisosTitulo,
          children: [
            FilaLista(
              key: ClavesUi.circAvisosAbrir,
              leading: IconoCuadrado(
                CupertinoIcons.bell_fill,
                fondo: c.naranjaRelleno,
                color: c.sobreNaranja,
              ),
              titulo: l.circAvisosAbrir,
              subtitulo: l.circAvisosAbrirDetalle,
              onTap: () => unawaited(_abrir(tema)),
            ),
            FilaLista(
              key: ClavesUi.circAvisosPrueba,
              leading: IconoCuadrado(
                CupertinoIcons.paperplane_fill,
                fondo: c.verde,
                color: c.sobreVerde,
              ),
              titulo: l.circAvisosPrueba,
              subtitulo: l.circAvisosPruebaDetalle,
              conChevron: false,
              trailing: _enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: () => unawaited(_probar()),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GrupoLista(
          titulo: l.circAvisosTema,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: SelectableText(
                tema,
                key: ClavesUi.circAvisosTema,
                style: t.bodyMedium?.copyWith(
                  color: c.texto,
                  fontFamily: 'monospace',
                  fontFamilyFallback: const ['Menlo', 'Roboto Mono'],
                  height: 1.4,
                ),
              ),
            ),
            FilaLista(
              key: ClavesUi.circAvisosCopiar,
              leading: const IconoCuadrado(CupertinoIcons.doc_on_doc),
              titulo: l.circAvisosCopiar,
              conChevron: false,
              onTap: () => unawaited(_copiar(tema)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final paso in [
                l.circAvisosPaso1,
                l.circAvisosPaso2,
                l.circAvisosPaso3,
              ]) ...[
                Text(paso, style: t.bodyMedium?.copyWith(color: c.texto)),
                const SizedBox(height: 6),
              ],
              const SizedBox(height: 8),
              Text(l.circAvisosComoSalen, style: explicacion),
              const SizedBox(height: 8),
              Text(l.circAvisosPrivacidad, style: explicacion),
            ],
          ),
        ),
      ],
    );
  }
}
