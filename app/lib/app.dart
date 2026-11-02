import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import 'core/contexto.dart';
import 'core/db/base_datos.dart';
import 'core/db/repositorios/medicacion_repositorio.dart';
import 'core/enrutado/router.dart';
import 'core/enrutado/rutas.dart';
import 'core/providers.dart';
import 'core/tema/aspecto.dart';
import 'core/tema/tema_familia.dart';
import 'features/avisos/avisos_providers.dart';
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

  /// Lanza la siguiente ronda del control por horas con la app abierta.
  Timer? _ronda;
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
        unawaited(ref.read(planificadorAvisosProvider).reprogramar());
      }
    }, fireImmediately: true);
    // Avisos a la familia desde el móvil de la persona (ntfy): con la app
    // abierta salen al momento; el envío no repite lo ya enviado.
    ref.listenManual<List<AvisoPendiente>>(avisosQueTocanProvider, (_, l) {
      if (l.isEmpty) return;
      final envio = ref.read(envioAvisosProvider);
      for (final a in l) {
        unawaited(envio.enviar(a));
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
    // Si cambian los ajustes del control por horas (llegan por el cartero),
    // se vuelven a programar las rondas y el temporizador.
    ref.listenManual<AsyncValue<AjustesControl>>(ajustesControlProvider, (
      antes,
      ahora,
    ) {
      if (ref.read(sesionProvider).perfil != PerfilApp.persona) return;
      _planificarRonda();
      if (antes?.value == null || ahora.value == null) return;
      if (antes!.value == ahora.value) return;
      unawaited(_reprogramar());
    }, fireImmediately: true);
    ref.listenManual<AsyncValue<List<Pauta>>>(
      pautasProvider,
      (_, _) => _planificarRonda(),
    );
    ref.listenManual<Sesion>(sesionProvider, (_, _) => _planificarRonda());
    // Si suena una alarma, se abre la pantalla de esa toma (o la pregunta, si
    // es de una ronda que aún no se ha contestado).
    _sonando = ref.read(servicioAlarmasProvider).sonando().listen((id) {
      if (esIdRonda(id)) {
        unawaited(_abrirRonda(id));
      } else {
        ref.read(routerProvider).go(Rutas.toma(id));
      }
    }, onError: (_) {});
    // Cartero cifrado: solo con servidor configurado. No bloquea el arranque
    // y, al volver a primer plano, envía y recoge lo pendiente.
    // Vídeos y fotos de más de 7 días que ya no esperan a subir.
    unawaited(ref.read(clipsProvider).limpiar());
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
        await ref.read(planificadorAvisosProvider).reprogramar();
      } while (_otraVez && mounted);
    } catch (_) {
      // Lo intenta de nuevo con el siguiente cambio o al abrir la app.
    } finally {
      _reprogramando = false;
    }
  }

  /// Alarma de una ronda: abre su pregunta; si ya se contestó (el
  /// temporizador llegó antes) o la persona está con una toma, solo la para
  /// (con la toma, el temporizador la lanza al acabar, como en
  /// [_lanzarRonda]).
  Future<void> _abrirRonda(String id) async {
    var contestada = false;
    try {
      contestada = await ref
          .read(controlHorasRepositorioProvider)
          .contestada(id);
    } catch (_) {
      contestada = false;
    }
    if (!mounted) return;
    if (!contestada && !_enToma()) {
      ref.read(routerProvider).go(Rutas.pregunta(ronda: id));
      return;
    }
    try {
      await ref.read(servicioAlarmasProvider).cancelar(id);
    } catch (_) {
      // Si no se deja parar, no pasa nada más.
    }
  }

  /// Con la app de la persona abierta, la siguiente ronda se lanza a su hora
  /// sin depender de la alarma (así funciona también en la demo web).
  void _planificarRonda() {
    _ronda?.cancel();
    _ronda = null;
    if (!mounted) return;
    if (ref.read(sesionProvider).perfil != PerfilApp.persona) return;
    final ajustes = ref.read(ajustesControlProvider).value;
    final pautas = ref.read(pautasProvider).value;
    if (ajustes == null || pautas == null) return;
    final ahora = ref.read(relojProvider).ahora();
    final siguiente = siguienteRonda(
      ajustes: ajustes,
      zona: ref.read(contextoProvider).zonaHoraria,
      ahora: ahora,
      tomas: _instantesDeToma(pautas, ahora),
    );
    if (siguiente == null) return;
    _ronda = Timer(
      siguiente.hora.difference(ahora),
      () => unawaited(_lanzarRonda(siguiente)),
    );
  }

  static List<DateTime> _instantesDeToma(
    List<Pauta> pautas,
    DateTime ahora,
  ) => [
    for (final t in proximasTomas(
      versiones: [for (final p in pautas) MedicacionRepositorio.aVersion(p)],
      desde: ahora.subtract(const Duration(hours: 1)),
      hasta: ahora.add(const Duration(hours: 27)),
    ))
      t.previstaPara,
  ];

  /// Abre la pregunta de [r] si sigue tocando: ni antes de su hora, ni con
  /// más de 10 minutos de retraso, ni si ya está contestada. Si la persona
  /// está con una toma, lo intenta otra vez al minuto; una pregunta de otra
  /// ronda que se quedó abierta deja paso a esta.
  Future<void> _lanzarRonda(RondaControl r) async {
    if (!mounted) return;
    final ahora = ref.read(relojProvider).ahora();
    if (ahora.isBefore(r.hora.subtract(const Duration(seconds: 30))) ||
        ahora.difference(r.hora) > esperaRespuestaRonda) {
      _planificarRonda();
      return;
    }
    var contestada = false;
    try {
      contestada = await ref
          .read(controlHorasRepositorioProvider)
          .contestada(r.id);
    } catch (_) {
      contestada = false;
    }
    if (!mounted) return;
    if (contestada) {
      _planificarRonda();
      return;
    }
    final router = ref.read(routerProvider);
    final uri = router.routerDelegate.currentConfiguration.uri;
    if (_enToma()) {
      _ronda?.cancel();
      _ronda = Timer(
        const Duration(minutes: 1),
        () => unawaited(_lanzarRonda(r)),
      );
      return;
    }
    final yaAbierta =
        uri.path == Rutas.personaPregunta &&
        uri.queryParameters['ronda'] == r.id;
    if (!yaAbierta) router.go(Rutas.pregunta(ronda: r.id));
    _planificarRonda();
  }

  /// La persona está en la pantalla de una toma.
  bool _enToma() => ref
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .path
      .startsWith('${Rutas.persona}/toma');

  @override
  void dispose() {
    _ronda?.cancel();
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
