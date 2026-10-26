import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/eventos_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/avatar_familiar.dart';
import '../../shared/widgets/boton_grande.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import '../hoy/dominio/tomas.dart';
import 'llamadas.dart';

/// Inicio de la persona (maqueta A-Persona), sin menús: hora enorme, fecha,
/// la tarjeta "ahora", "Mis pastillas", su gente, el último mensaje de la
/// familia y "Necesito ayuda" fijo abajo.
///
/// Nunca más de tres botones grandes a la vez: "Mis pastillas", "Es la hora"
/// (solo a su hora) y "Necesito ayuda".
class PersonaInicioPantalla extends ConsumerStatefulWidget {
  const PersonaInicioPantalla({super.key});

  @override
  ConsumerState<PersonaInicioPantalla> createState() => _PersonaInicioState();
}

class _PersonaInicioState extends ConsumerState<PersonaInicioPantalla> {
  /// Nombre del familiar al que se llama; vacío si se anotó la ayuda sin
  /// nadie a quien llamar; nulo si no hay aviso.
  String? _llamando;

  Future<void> _llamar(Miembro m) async {
    setState(() => _llamando = m.nombre);
    await llamarDesdePersona(ref, m, ayuda: false);
  }

  Future<void> _pedirAyuda(List<Miembro> miembros) async {
    final primero = primerFamiliar(miembros);
    setState(() => _llamando = primero?.nombre ?? '');
    await llamarDesdePersona(ref, primero, ayuda: true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final contexto = ref.watch(contextoProvider);
    final ahoraUtc =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final local = aLocal(ahoraUtc, contexto.zonaHoraria);
    final parte = switch (parteDelDia(local.hour)) {
      ParteDelDia.manana => l.parteManana,
      ParteDelDia.tarde => l.parteTarde,
      ParteDelDia.noche => l.parteNoche,
    };
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final gente = [
      for (final m in miembros)
        if (m.enMiGente) m,
    ].take(4).toList();
    final mensaje = ref.watch(ultimoMensajeProvider).value;
    final siguiente = ref.watch(siguienteTomaProvider).value;
    final esWeb = ref.watch(esDemoWebProvider);

    // Nunca en dos líneas: si no cabe (escala 1,3 en pantallas estrechas),
    // se encoge.
    final hora = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        horaCorta(local),
        maxLines: 1,
        style: t.displayLarge?.copyWith(height: 1),
      ),
    );
    final llamando = _llamando;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En móvil, una pulsación de 5 s sobre la hora saca de
                    // este perfil.
                    Center(
                      child: esWeb
                          ? hora
                          : _PulsacionLarga(
                              duracion: const Duration(seconds: 5),
                              alCompletar: () => context.go(Rutas.perfil),
                              child: hora,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      header: true,
                      child: Text(
                        fechaLarga(local),
                        textAlign: TextAlign.center,
                        style: t.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: c.textoSecundario,
                        ),
                      ),
                    ),
                    Text(
                      parte,
                      textAlign: TextAlign.center,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _Ahora(siguiente: siguiente, ahora: ahoraUtc),
                    const SizedBox(height: 16),
                    BotonGrande(
                      key: ClavesUi.misPastillas,
                      texto: l.misPastillas,
                      icono: CupertinoIcons.capsule_fill,
                      color: c.azul,
                      colorTexto: c.sobreAzul,
                      altura: 104,
                      alinear: AlineacionBoton.izquierda,
                      onPressed: () => context.push(Rutas.personaPastillas),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text(l.miGente, style: t.headlineSmall),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      key: ClavesUi.miGente,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        for (final m in gente)
                          _Cara(miembro: m, alPulsar: () => _llamar(m)),
                      ],
                    ),
                    if (llamando != null) ...[
                      const SizedBox(height: 16),
                      _AvisoLlamada(llamando: llamando),
                    ],
                    if (mensaje != null) ...[
                      const SizedBox(height: 20),
                      _MensajeFamilia(mensaje: mensaje),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: BotonGrande(
                key: ClavesUi.necesitoAyuda,
                texto: l.necesitoAyuda,
                icono: CupertinoIcons.exclamationmark_triangle_fill,
                color: c.rojo,
                colorTexto: c.sobreRojo,
                altura: 96,
                onPressed: () => _pedirAyuda(miembros),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta "ahora": "Ahora no toca nada" con la hora de la siguiente o, a su
/// hora, la foto de la pastilla y el botón "Es la hora".
class _Ahora extends StatelessWidget {
  const _Ahora({required this.siguiente, required this.ahora});

  final TomaVista? siguiente;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final s = siguiente;
    final Widget contenido;
    if (s != null && !ahora.isBefore(s.toma.previstaPara)) {
      final nombre = s.nombreParaPersona.toLowerCase();
      contenido = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FotoPastilla(s.medicamento, tamano: 104),
              const SizedBox(width: 16),
              Expanded(child: Text(l.esLaHora(nombre), style: t.headlineSmall)),
            ],
          ),
          const SizedBox(height: 16),
          BotonGrande(
            key: ClavesUi.esLaHora,
            texto: l.personaTomarlaAhora,
            icono: CupertinoIcons.bell_fill,
            color: c.verde,
            colorTexto: c.sobreVerde,
            altura: 96,
            onPressed: () => context.push(Rutas.toma(s.toma.id)),
          ),
        ],
      );
    } else {
      contenido = Row(
        children: [
          IconoCuadrado(
            CupertinoIcons.checkmark_alt,
            redondo: true,
            tamano: 48,
            fondo: c.verdeClaro,
            color: c.verde,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.personaAhoraNoTocaNada,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  s == null
                      ? l.noHayMasPastillas
                      : l.aLasHoraPastilla(
                          s.toma.horaLocal,
                          s.nombreParaPersona.toLowerCase(),
                        ),
                  style: t.bodyMedium?.copyWith(color: c.textoSecundario),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return TarjetaGrande(
      key: ClavesUi.loSiguiente,
      radio: 20,
      margen: EdgeInsets.zero,
      relleno: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: contenido,
    );
  }
}

/// Cara de un familiar (96) con su nombre; tocarla le llama.
class _Cara extends StatelessWidget {
  const _Cara({required this.miembro, required this.alPulsar});

  final Miembro miembro;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: context.l.llamarA(miembro.nombre),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              AvatarFamiliar(miembro: miembro, tamano: 96),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  miembro.nombre,
                  style: t.titleMedium,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Estoy llamando a Lucía." o "He anotado que necesitas ayuda.".
class _AvisoLlamada extends StatelessWidget {
  const _AvisoLlamada({required this.llamando});

  /// Vacío si no hay a quién llamar.
  final String llamando;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return TarjetaGrande(
      color: c.rojoClaro,
      radio: 20,
      margen: EdgeInsets.zero,
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            Icon(CupertinoIcons.phone_fill, size: 32, color: c.rojo),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                llamando.isEmpty ? l.ayudaAvisada : l.ayudaLlamando(llamando),
                style: t.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MensajeFamilia extends StatelessWidget {
  const _MensajeFamilia({required this.mensaje});

  final Evento mensaje;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final texto = (_texto(mensaje) ?? '').trim();
    return TarjetaGrande(
      radio: 20,
      margen: EdgeInsets.zero,
      relleno: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconoCuadrado(
                CupertinoIcons.envelope_fill,
                redondo: true,
                tamano: 40,
                fondo: c.azulClaro,
                color: c.azul,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.mensajeDeLaFamilia,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(texto, style: t.bodyLarge),
        ],
      ),
    );
  }

  static String? _texto(Evento e) {
    return EventosRepositorio.payloadDe(e)['texto'] as String?;
  }
}

/// Pulsación sostenida durante [duracion]; se cancela al soltar.
class _PulsacionLarga extends StatefulWidget {
  const _PulsacionLarga({
    required this.duracion,
    required this.alCompletar,
    required this.child,
  });

  final Duration duracion;
  final VoidCallback alCompletar;
  final Widget child;

  @override
  State<_PulsacionLarga> createState() => _PulsacionLargaState();
}

class _PulsacionLargaState extends State<_PulsacionLarga> {
  Timer? _temporizador;

  void _empezar() {
    _temporizador?.cancel();
    _temporizador = Timer(widget.duracion, widget.alCompletar);
  }

  void _cancelar() {
    _temporizador?.cancel();
    _temporizador = null;
  }

  @override
  void dispose() {
    _cancelar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _empezar(),
    onPointerUp: (_) => _cancelar(),
    onPointerCancel: (_) => _cancelar(),
    child: widget.child,
  );
}
