import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../core/i18n/textos_ubicacion.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'ubicacion_providers.dart';

/// Hoy › Ubicación › «Encender la ubicación»: qué se recoge, para qué, quién
/// lo ve, cuánto se guarda y cómo se apaga. «Acepto, soy …» guarda el
/// consentimiento (sobre `ubicacion`) con el texto exacto y la fecha; «Ahora
/// no» vuelve sin guardar nada. Hasta entonces, el móvil de la persona no
/// toma ninguna posición.
class ConsentimientoUbicacionPantalla extends ConsumerStatefulWidget {
  const ConsentimientoUbicacionPantalla({super.key});

  @override
  ConsumerState<ConsentimientoUbicacionPantalla> createState() =>
      _ConsentimientoUbicacionPantallaState();
}

class _ConsentimientoUbicacionPantallaState
    extends ConsumerState<ConsentimientoUbicacionPantalla> {
  bool _guardando = false;

  void _volver() =>
      context.canPop() ? context.pop() : context.go(Rutas.ubicacion);

  Future<void> _aceptar(String miembroId, String texto) async {
    if (_guardando) return;
    setState(() => _guardando = true);
    try {
      await ref
          .read(ubicacionRepositorioProvider)
          .otorgar(miembroId: miembroId, textoMostrado: texto);
      if (mounted) _volver();
    } catch (_) {
      // Se queda en la pantalla; se puede volver a intentar.
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
    final miembroId = ref.watch(sesionProvider).miembroId;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final yo = miembros.where((m) => m.id == miembroId).firstOrNull;
    final alias = ref.watch(personaProvider).value?.alias ?? '';
    final nombre = yo?.nombre ?? '';
    final parrafos = parrafosConsentimientoUbicacion(
      l,
      nombre: nombre,
      alias: alias,
    );
    final texto = parrafos.join('\n\n');

    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.ubicConsVispera,
            titulo: l.ubicConsTitulo,
            reservarBotonMas: false,
            alVolver: _volver,
          ),
          const SizedBox(height: 14),
          Container(
            key: ClavesUi.ubicConsTexto,
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
            key: ClavesUi.ubicConsAcepto,
            onPressed: _guardando || yo == null
                ? null
                : () => _aceptar(yo.id, texto),
            style: FilledButton.styleFrom(
              backgroundColor: c.azul,
              foregroundColor: c.sobreAzul,
              minimumSize: const Size.fromHeight(50),
              textStyle: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            child: Text(l.ubicConsAcepto(nombre), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: ClavesUi.ubicConsAhoraNo,
            onPressed: _guardando ? null : _volver,
            style: TextButton.styleFrom(
              foregroundColor: c.azul,
              minimumSize: const Size.fromHeight(44),
            ),
            child: Text(l.ubicConsAhoraNo),
          ),
        ],
      ),
    );
  }
}

/// Párrafo «Título: texto» con el título en negrita (el texto es el mismo).
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
