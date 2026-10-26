import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/semilla_demo.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/providers.dart';
import '../../core/tema/aspecto.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';

/// Ajustes: aspecto (claro, oscuro, noche), cambiar perfil y cargar datos de
/// ejemplo.
class AjustesPantalla extends ConsumerWidget {
  const AjustesPantalla({super.key});

  Future<void> _cargarEjemplo(BuildContext context, WidgetRef ref) async {
    final l = context.l;
    final mensajero = ScaffoldMessenger.of(context);
    final db = ref.read(baseDatosProvider);
    if (await SemillaDemo.hayMedicamentos(db)) {
      mensajero.showSnackBar(SnackBar(content: Text(l.ejemploYaCargado)));
      return;
    }
    await SemillaDemo.sembrar(
      db: db,
      contexto: ref.read(contextoProvider),
      reloj: ref.read(relojProvider),
      azar: ref.read(azarProvider),
    );
    mensajero.showSnackBar(SnackBar(content: Text(l.ejemploCargado)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final contexto = ref.watch(contextoProvider);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          CabeceraGrande(titulo: l.pestanaAjustes),
          const SizedBox(height: 14),
          const GrupoLista(children: [_FilaAspecto()]),
          const SizedBox(height: 14),
          GrupoLista(
            children: [
              FilaLista(
                leading: IconoCuadrado(
                  CupertinoIcons.arrow_2_squarepath,
                  fondo: c.azul,
                  color: c.sobreAzul,
                ),
                titulo: l.cambiarPerfil,
                subtitulo: l.cambiarPerfilAyuda,
                onTap: () async {
                  await ref.read(sesionProvider.notifier).cambiarPerfil();
                  if (context.mounted) context.go(Rutas.perfil);
                },
              ),
              FilaLista(
                leading: IconoCuadrado(
                  CupertinoIcons.tray_arrow_down_fill,
                  fondo: c.verde,
                  color: c.sobreVerde,
                ),
                titulo: l.cargarEjemplo,
                subtitulo: l.cargarEjemploAyuda,
                onTap: () => _cargarEjemplo(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GrupoLista(
            children: [
              FilaLista(
                leading: IconoCuadrado(
                  CupertinoIcons.device_phone_portrait,
                  fondo: c.gris,
                ),
                titulo: l.ajustesPlataforma(contexto.plataforma),
                apagada: true,
              ),
              FilaLista(
                leading: IconoCuadrado(
                  CupertinoIcons.clock,
                  redondo: true,
                  fondo: c.rellenoSuave,
                  color: c.textoSecundario,
                ),
                titulo: l.ajustesMas,
                apagada: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Aspecto": Automático · Claro · Oscuro · Noche (22–08). Se guarda al
/// elegir y el tema cambia al momento.
class _FilaAspecto extends ConsumerWidget {
  const _FilaAspecto();

  static String etiqueta(AppLocalizations l, Aspecto a) => switch (a) {
    Aspecto.automatico => l.aspectoAutomatico,
    Aspecto.claro => l.aspectoClaro,
    Aspecto.oscuro => l.aspectoOscuro,
    Aspecto.horas => l.aspectoHoras,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final aspecto = ref.watch(aspectoProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconoCuadrado(
                CupertinoIcons.circle_lefthalf_fill,
                fondo: c.indigo,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.aspecto,
                  style: t.titleSmall?.copyWith(color: c.texto),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectorSegmentos<Aspecto>(
            valores: Aspecto.values,
            etiqueta: (a) => etiqueta(l, a),
            seleccionado: aspecto,
            clave: (a) => ClavesUi.aspecto(a.nombre),
            alCambiar: (a) => ref.read(aspectoProvider.notifier).elegir(a),
          ),
          const SizedBox(height: 8),
          Text(
            l.aspectoAyuda,
            style: t.bodySmall?.copyWith(color: c.textoSecundario),
          ),
        ],
      ),
    );
  }
}
