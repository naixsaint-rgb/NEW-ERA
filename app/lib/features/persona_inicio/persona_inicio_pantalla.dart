import 'dart:async';

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
import '../../shared/l10n_ext.dart';
import '../../shared/pictogramas/pastilla_pictograma.dart';
import '../../shared/widgets/avatar_familiar.dart';
import '../../shared/widgets/boton_grande.dart';
import '../../shared/widgets/foto_imagen.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import '../hoy/dominio/tomas.dart';

/// Inicio de la persona, sin menús: fecha, hora, lo siguiente, su gente,
/// ayuda y el último mensaje de la familia.
class PersonaInicioPantalla extends ConsumerStatefulWidget {
  const PersonaInicioPantalla({super.key});

  @override
  ConsumerState<PersonaInicioPantalla> createState() => _PersonaInicioState();
}

class _PersonaInicioState extends ConsumerState<PersonaInicioPantalla> {
  String? _llamando;

  Future<void> _llamar(Miembro m, {required bool ayuda}) async {
    final eventos = ref.read(eventosRepositorioProvider);
    if (ayuda) {
      await eventos.registrar(TipoEvento.ayudaPedida);
    }
    await eventos.registrar(
      TipoEvento.llamadaIniciada,
      payload: {'miembroId': m.id},
    );
    final telefono = m.telefono;
    if (telefono != null && telefono.isNotEmpty) {
      try {
        await ref.read(abrirEnlaceProvider)(Uri(scheme: 'tel', path: telefono));
      } catch (_) {
        // Sin teléfono en este aparato: no pasa nada.
      }
    }
  }

  Future<void> _pedirAyuda(List<Miembro> miembros) async {
    final primero = _primerFamiliar(miembros);
    if (primero == null) {
      await ref
          .read(eventosRepositorioProvider)
          .registrar(TipoEvento.ayudaPedida);
      setState(() => _llamando = '');
      return;
    }
    setState(() => _llamando = primero.nombre);
    await _llamar(primero, ayuda: true);
  }

  static Miembro? _primerFamiliar(List<Miembro> miembros) {
    final conOrden = miembros.where((m) => m.ordenEscalado != null).toList()
      ..sort((a, b) => a.ordenEscalado!.compareTo(b.ordenEscalado!));
    if (conOrden.isNotEmpty) return conOrden.first;
    return miembros.isEmpty ? null : miembros.first;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
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

    final hora = Text(
      horaCorta(local),
      style: t.displaySmall?.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        fechaLarga(local),
                        style: t.displaySmall?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(parte, style: t.headlineLarge?.copyWith(fontSize: 40)),
                    const SizedBox(height: 4),
                    // En móvil, una pulsación de 5 s sobre la hora saca de este perfil.
                    esWeb
                        ? hora
                        : _PulsacionLarga(
                            duracion: const Duration(seconds: 5),
                            alCompletar: () => context.go(Rutas.perfil),
                            child: hora,
                          ),
                    const SizedBox(height: 20),
                    _LoSiguiente(
                      siguiente: siguiente,
                      ahora: ahoraUtc,
                      zona: contexto.zonaHoraria,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.miGente,
                      style: t.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      key: ClavesUi.miGente,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        for (final m in gente)
                          Semantics(
                            button: true,
                            label: l.llamarA(m.nombre),
                            excludeSemantics: true,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _llamar(m, ayuda: false),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  children: [
                                    AvatarFamiliar(miembro: m, tamano: 96),
                                    const SizedBox(height: 4),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 140,
                                      ),
                                      child: Text(
                                        m.nombre,
                                        style: t.titleLarge,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_llamando != null) ...[
                      const SizedBox(height: 16),
                      TarjetaGrande(
                        color: const Color(0xFFFDECEA),
                        child: Text(
                          _llamando!.isEmpty
                              ? l.ayudaAvisada
                              : l.ayudaLlamando(_llamando!),
                          style: t.titleLarge,
                        ),
                      ),
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
                icono: Icons.sos,
                color: Colores.rojo,
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

class _LoSiguiente extends ConsumerWidget {
  const _LoSiguiente({
    required this.siguiente,
    required this.ahora,
    required this.zona,
  });

  final TomaVista? siguiente;
  final DateTime ahora;
  final String zona;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final s = siguiente;
    return TarjetaGrande(
      key: ClavesUi.loSiguiente,
      relleno: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.loSiguiente,
            style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (s == null)
            Text(l.noHayMasPastillas, style: t.titleLarge)
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FotoImagen(
                      fotoId: s.medicamento?.fotoPastillaId,
                      ancho: 96,
                      alto: 96,
                      alternativa: PastillaPictograma(
                        forma: s.medicamento?.forma ?? 'otra',
                        color: s.medicamento?.color,
                        tamano: 96,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l.aLasHoraPastilla(
                      s.toma.horaLocal,
                      s.nombreParaPersona.toLowerCase(),
                    ),
                    style: t.titleLarge,
                  ),
                ),
              ],
            ),
            if (!ahora.isBefore(s.toma.previstaPara)) ...[
              const SizedBox(height: 16),
              BotonGrande(
                key: ClavesUi.esLaHora,
                texto: l.esLaHora(s.nombreParaPersona.toLowerCase()),
                icono: Icons.alarm,
                color: Colores.verde,
                altura: 96,
                onPressed: () => context.push(Rutas.toma(s.toma.id)),
              ),
            ],
          ],
        ],
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
    final t = Theme.of(context).textTheme;
    final texto = (_texto(mensaje) ?? '').trim();
    return TarjetaGrande(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail, size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.mensajeDeLaFamilia,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(texto, style: t.headlineSmall),
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
