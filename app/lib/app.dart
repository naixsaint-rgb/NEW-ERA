import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/contexto.dart';
import 'core/db/base_datos.dart';
import 'core/enrutado/router.dart';
import 'core/enrutado/rutas.dart';
import 'core/providers.dart';
import 'core/tema/aspecto.dart';
import 'core/tema/tema_familia.dart';
import 'l10n/app_localizations.dart';
import 'shared/widgets/aviso_demo.dart';

/// Raíz de la app: tema, textos en español de España y rutas.
class NewEraApp extends ConsumerStatefulWidget {
  const NewEraApp({super.key});

  @override
  ConsumerState<NewEraApp> createState() => _NewEraAppState();
}

class _NewEraAppState extends ConsumerState<NewEraApp> {
  StreamSubscription<String>? _sonando;
  AppLifecycleListener? _ciclo;
  bool _programado = false;
  bool _reprogramando = false;
  bool _otraVez = false;
  final _temaClaro = temaFamilia();
  final _temaOscuro = temaFamiliaOscuro();

  @override
  void initState() {
    super.initState();
    // Al arrancar el perfil persona: programa las alarmas de las próximas 48 h.
    ref.listenManual<Sesion>(sesionProvider, (_, nueva) {
      if (nueva.perfil == PerfilApp.persona && !_programado) {
        _programado = true;
        unawaited(ref.read(programadorAlarmasProvider).reprogramar());
      }
    }, fireImmediately: true);
    // Si llegan pautas nuevas o cambiadas (de otro móvil, por el cartero), se
    // vuelven a programar. La primera carga ya la cubre lo de arriba.
    ref.listenManual<AsyncValue<List<Pauta>>>(pautasProvider, (antes, ahora) {
      if (antes?.value == null || ahora.value == null) return;
      if (ref.read(sesionProvider).perfil != PerfilApp.persona) return;
      final idsAntes = {for (final p in antes!.value!) p.id};
      final idsAhora = {for (final p in ahora.value!) p.id};
      if (idsAntes.length == idsAhora.length &&
          idsAntes.containsAll(idsAhora)) {
        return;
      }
      unawaited(_reprogramar());
    });
    // Si cambia la frase que dice la alarma (llega una voz, se aprueba otra
    // toma o se retira), se vuelven a programar.
    ref.listenManual<String?>(firmaVozTomaProvider, (antes, ahora) {
      if (antes == null || ahora == null || antes == ahora) return;
      if (ref.read(sesionProvider).perfil != PerfilApp.persona) return;
      unawaited(_reprogramar());
    });
    // Si suena una alarma, se abre la pantalla de esa toma.
    _sonando = ref.read(servicioAlarmasProvider).sonando().listen((idToma) {
      ref.read(routerProvider).go(Rutas.toma(idToma));
    }, onError: (_) {});
    // Cartero cifrado: solo con servidor configurado. No bloquea el arranque
    // y, al volver a primer plano, envía y recoge lo pendiente.
    final sync = ref.read(servicioSyncProvider);
    if (sync != null) {
      unawaited(sync.iniciar());
      _ciclo = AppLifecycleListener(
        onResume: () => unawaited(sync.sincronizarAhora()),
      );
    }
  }

  /// Una sola reprogramación a la vez; si llegan más cambios mientras tanto,
  /// otra al acabar.
  Future<void> _reprogramar() async {
    if (_reprogramando) {
      _otraVez = true;
      return;
    }
    _reprogramando = true;
    try {
      do {
        _otraVez = false;
        await ref.read(programadorAlarmasProvider).reprogramar();
      } while (_otraVez && mounted);
    } catch (_) {
      // Lo intenta de nuevo con el siguiente cambio o al abrir la app.
    } finally {
      _reprogramando = false;
    }
  }

  @override
  void dispose() {
    _sonando?.cancel();
    _ciclo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final demo = ref.watch(esDemoWebProvider);
    final modo = ref.watch(modoTemaProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitulo,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // La familia sigue el ajuste "Aspecto"; la persona va siempre en claro
      // (su árbol lleva además `temaPersona()`).
      theme: _temaClaro,
      darkTheme: _temaOscuro,
      themeMode: modo,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, hijo) {
        final contenido = hijo ?? const SizedBox.shrink();
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 2.0,
          child: demo
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AvisoDemo(
                      alCambiarPerfil: () async {
                        await ref.read(sesionProvider.notifier).cambiarPerfil();
                        router.go(Rutas.perfil);
                      },
                    ),
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: contenido,
                      ),
                    ),
                  ],
                )
              : contenido,
        );
      },
    );
  }
}
