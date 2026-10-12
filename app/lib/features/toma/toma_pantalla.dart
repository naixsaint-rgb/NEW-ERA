import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/plataforma/camara/camara_comprobacion.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/pictogramas/pastilla_pictograma.dart';
import '../../shared/widgets/avatar_familiar.dart';
import '../../shared/widgets/boton_grande.dart';
import '../../shared/widgets/foto_imagen.dart';
import '../hoy/dominio/tomas.dart';

enum _Fase { confirmar, camara, muyBien }

/// Pantalla de toma: foto de la pastilla, un botón enorme, la comprobación
/// con cámara y el "Muy bien" final.
class TomaPantalla extends ConsumerStatefulWidget {
  const TomaPantalla({super.key, required this.tomaId, this.prueba = false});

  final String tomaId;

  /// Desde "Probar pantalla de toma": recorre todo sin escribir eventos.
  final bool prueba;

  @override
  ConsumerState<TomaPantalla> createState() => _TomaPantallaState();
}

class _TomaPantallaState extends ConsumerState<TomaPantalla> {
  _Fase _fase = _Fase.confirmar;
  SesionCamara? _sesion;
  int _restante = 0;
  bool _cerrando = false;

  @override
  void dispose() {
    _sesion?.cerrar();
    super.dispose();
  }

  Future<void> _confirmar(TomaVista t) async {
    // Un doble toque no registra dos confirmaciones.
    if (_fase != _Fase.confirmar) return;
    final comprobacion = TipoComprobacion.desdeNombre(
      t.pauta?.comprobacion ?? 'video',
    );
    setState(
      () => _fase = comprobacion == TipoComprobacion.ninguna
          ? _Fase.muyBien
          : _Fase.camara,
    );
    if (!widget.prueba) {
      await ref.read(medicacionRepositorioProvider).asegurarToma(t.toma);
      await ref
          .read(eventosRepositorioProvider)
          .registrar(
            TipoEvento.tomaConfirmada,
            sujeto: t.toma.id,
            payload: {'origen': 'movil'},
          );
    }
    if (comprobacion == TipoComprobacion.ninguna) {
      await _terminar(t);
      return;
    }
    await _comprobar(t, comprobacion);
  }

  Future<void> _comprobar(TomaVista t, TipoComprobacion comprobacion) async {
    final camara = ref.read(camaraProvider);
    final (sesion, motivo) = await camara.abrir();
    if (!mounted) {
      await sesion?.cerrar();
      return;
    }
    if (sesion == null) {
      await _registrarFallo(t, motivo ?? MotivoClipFallido.error);
      await _terminar(t);
      return;
    }
    setState(() {
      _sesion = sesion;
      _restante = t.pauta?.segundosVideo ?? 10;
    });
    final resultado = await sesion.grabar(
      tomaId: t.toma.id,
      tipo: comprobacion,
      segundos: t.pauta?.segundosVideo ?? 10,
      restante: (s) {
        if (mounted) setState(() => _restante = s);
      },
    );
    await sesion.cerrar();
    _sesion = null;
    switch (resultado) {
      case ClipGrabado():
        if (!widget.prueba) {
          await ref
              .read(eventosRepositorioProvider)
              .registrar(
                TipoEvento.clipGrabado,
                sujeto: t.toma.id,
                payload: {
                  'tipo': resultado.tipo.nombre,
                  'ruta': resultado.ruta,
                  'duracionMs': resultado.duracionMs,
                },
              );
        }
      case ClipFallido():
        await _registrarFallo(t, resultado.motivo);
    }
    await _terminar(t);
  }

  Future<void> _registrarFallo(TomaVista t, MotivoClipFallido motivo) async {
    if (widget.prueba) return;
    await ref
        .read(eventosRepositorioProvider)
        .registrar(
          TipoEvento.clipFallido,
          sujeto: t.toma.id,
          payload: {'motivo': motivo.nombre},
        );
  }

  /// "Muy bien" durante 4 s, cancela la alarma y vuelve al inicio.
  Future<void> _terminar(TomaVista t) async {
    if (!mounted || _cerrando) return;
    _cerrando = true;
    setState(() => _fase = _Fase.muyBien);
    try {
      await ref.read(servicioAlarmasProvider).cancelar(t.toma.id);
    } catch (_) {
      // Sin alarma del sistema (web, tests): nada que cancelar.
    }
    await Future<void>.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    context.go(widget.prueba ? Rutas.pestana('medicacion') : Rutas.persona);
  }

  void _volver() =>
      context.go(widget.prueba ? Rutas.pestana('medicacion') : Rutas.persona);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final toma = ref.watch(tomaPorIdProvider(widget.tomaId));
    return Scaffold(
      body: SafeArea(
        child: toma.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _Mensaje(
            texto: l.errorGenerico,
            boton: l.volverAlInicio,
            alPulsar: _volver,
          ),
          data: (t) {
            if (t == null) {
              return _Mensaje(
                texto: l.tomaNoEncontrada,
                boton: l.volverAlInicio,
                alPulsar: _volver,
              );
            }
            final yaTomada =
                t.estado == EstadoToma.confirmada ||
                t.estado == EstadoToma.confirmadaSinVideo ||
                t.estado == EstadoToma.cerradaPorFamiliar;
            if (_fase == _Fase.confirmar && yaTomada && !widget.prueba) {
              return _Mensaje(
                texto: l.yaEstaTomada,
                boton: l.volverAlInicio,
                alPulsar: _volver,
              );
            }
            return switch (_fase) {
              _Fase.confirmar => _Confirmar(
                toma: t,
                alConfirmar: () => _confirmar(t),
              ),
              _Fase.camara => _Camara(
                sesion: _sesion,
                restante: _restante,
                tipo: TipoComprobacion.desdeNombre(
                  t.pauta?.comprobacion ?? 'video',
                ),
              ),
              _Fase.muyBien => const _MuyBien(),
            };
          },
        ),
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.texto,
    required this.boton,
    required this.alPulsar,
  });

  final String texto;
  final String boton;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            texto,
            style: t.displaySmall?.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          BotonGrande(
            texto: boton,
            color: Colores.azul,
            altura: 96,
            onPressed: alPulsar,
          ),
        ],
      ),
    );
  }
}

class _Confirmar extends StatelessWidget {
  const _Confirmar({required this.toma, required this.alConfirmar});

  final TomaVista toma;
  final VoidCallback alConfirmar;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final med = toma.medicamento;
    final compartimento = toma.pauta?.compartimento;
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF3EEE2),
            child: FotoImagen(
              fotoId: med?.fotoPastillaId,
              ajuste: BoxFit.contain,
              etiquetaSemantica: l.semanticaFotoPastilla(
                toma.nombreParaPersona,
              ),
              alternativa: Center(
                child: PastillaPictograma(
                  forma: med?.forma ?? 'otra',
                  color: med?.color,
                  tamano: 240,
                  etiquetaSemantica: l.semanticaFotoPastilla(
                    toma.nombreParaPersona,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Semantics(
                header: true,
                child: Text(
                  toma.nombreParaPersona,
                  textAlign: TextAlign.center,
                  style: t.displaySmall?.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (compartimento != null && compartimento.isNotEmpty)
                Text(
                  l.compartimentoEs(compartimento),
                  textAlign: TextAlign.center,
                  style: t.headlineSmall?.copyWith(fontSize: 28),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: BotonGrande(
            key: ClavesUi.confirmarToma,
            texto: l.yaMeLaHeTomado,
            icono: Icons.check_circle,
            color: Colores.verde,
            altura: 120,
            onPressed: alConfirmar,
          ),
        ),
      ],
    );
  }
}

class _Camara extends StatelessWidget {
  const _Camara({
    required this.sesion,
    required this.restante,
    required this.tipo,
  });

  final SesionCamara? sesion;
  final int restante;
  final TipoComprobacion tipo;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final s = sesion;
    return Stack(
      fit: StackFit.expand,
      children: [
        s == null
            ? const ColoredBox(color: Color(0xFF1A1A1A))
            : s.vistaPrevia(context),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            color: const Color(0xCC000000),
            padding: const EdgeInsets.all(20),
            child: Text(
              l.ensenaLaPastilla,
              textAlign: TextAlign.center,
              style: t.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Center(
            child: Semantics(
              liveRegion: true,
              label: l.cuentaAtras(restante),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC000000),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  restante.toString(),
                  style: t.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MuyBien extends ConsumerWidget {
  const _MuyBien();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
    final conOrden = miembros.where((m) => m.ordenEscalado != null).toList()
      ..sort((a, b) => a.ordenEscalado!.compareTo(b.ordenEscalado!));
    final familiar = conOrden.isNotEmpty
        ? conOrden.first
        : (miembros.isEmpty ? null : miembros.first);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l.muyBien,
            key: ClavesUi.muyBien,
            style: t.displayMedium?.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Colores.verde,
            ),
          ),
          const SizedBox(height: 24),
          if (familiar != null) ...[
            AvatarFamiliar(miembro: familiar, tamano: 160),
            const SizedBox(height: 8),
            Text(familiar.nombre, style: t.headlineMedium),
          ] else
            const Icon(Icons.favorite, size: 120, color: Colores.verde),
        ],
      ),
    );
  }
}
