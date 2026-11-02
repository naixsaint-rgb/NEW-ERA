import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';

/// Texto del permiso de voz de [nombre] tal como se muestra: un encabezado y
/// párrafos separados por una línea en blanco. Es lo que se guarda en
/// `consentimientos.texto_mostrado`.
List<String> parrafosConsentimientoVoz(
  AppLocalizations l, {
  required String nombre,
  required String alias,
}) => [
  l.vozConsEncabezado(nombre),
  l.vozConsQue(nombre, alias),
  l.vozConsPara(alias),
  l.vozConsDonde(alias),
  l.vozConsQuien(alias),
  l.vozConsRetirar(nombre),
  l.vozConsClon,
  l.vozConsGuardar(nombre),
];

/// Voces › un familiar › "Antes de grabar": qué se graba, para qué, dónde se
/// guarda, quién lo oye y cómo se retira. "Acepto, soy …" guarda el
/// consentimiento con el texto exacto y crea su voz; "Ahora no" vuelve sin
/// guardar nada.
class ConsentimientoVozPantalla extends ConsumerStatefulWidget {
  const ConsentimientoVozPantalla({super.key, required this.miembroId});

  final String miembroId;

  @override
  ConsumerState<ConsentimientoVozPantalla> createState() =>
      _ConsentimientoVozPantallaState();
}

class _ConsentimientoVozPantallaState
    extends ConsumerState<ConsentimientoVozPantalla> {
  bool _guardando = false;

  void _volver() => context.canPop()
      ? context.pop()
      : context.go(Rutas.voz(widget.miembroId));

  Future<void> _aceptar(String texto) async {
    if (_guardando) return;
    setState(() => _guardando = true);
    try {
      await ref
          .read(vocesRepositorioProvider)
          .otorgarConsentimiento(
            miembroId: widget.miembroId,
            textoMostrado: texto,
          );
      if (mounted) _volver();
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
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final m = miembros.where((x) => x.id == widget.miembroId).firstOrNull;
    final alias = ref.watch(personaProvider).value?.alias ?? '';
    if (m == null) {
      return Scaffold(
        backgroundColor: c.fondoAgrupado,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            CabeceraGrande(
              titulo: l.vozPermisoTitulo,
              reservarBotonMas: false,
              alVolver: _volver,
            ),
          ],
        ),
      );
    }
    final parrafos = parrafosConsentimientoVoz(
      l,
      nombre: m.nombre,
      alias: alias,
    );
    final texto = parrafos.join('\n\n');

    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.vozConsVispera(m.nombre),
            titulo: l.vozPermisoTitulo,
            reservarBotonMas: false,
            alVolver: _volver,
          ),
          const SizedBox(height: 14),
          Container(
            key: ClavesUi.vozConsTexto,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.tarjeta,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    parrafos.first,
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.texto,
                    ),
                  ),
                ),
                for (final p in parrafos.skip(1)) ...[
                  const SizedBox(height: 12),
                  _Parrafo(p),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            key: ClavesUi.vozConsAcepto,
            onPressed: _guardando ? null : () => _aceptar(texto),
            style: FilledButton.styleFrom(
              backgroundColor: c.azul,
              foregroundColor: c.sobreAzul,
              minimumSize: const Size.fromHeight(50),
              textStyle: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            child: Text(l.vozConsAcepto(m.nombre), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: ClavesUi.vozConsAhoraNo,
            onPressed: _guardando ? null : _volver,
            style: TextButton.styleFrom(
              foregroundColor: c.azul,
              minimumSize: const Size.fromHeight(44),
            ),
            child: Text(l.vozConsAhoraNo),
          ),
        ],
      ),
    );
  }
}

/// Párrafo "Título: texto" con el título en negrita (el texto es el mismo).
class _Parrafo extends StatelessWidget {
  const _Parrafo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final estilo = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(color: c.texto, height: 1.35);
    final i = texto.indexOf(': ');
    if (i <= 0 || i > 40) return Text(texto, style: estilo);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: texto.substring(0, i + 1),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: texto.substring(i + 1)),
        ],
      ),
      style: estilo,
    );
  }
}
