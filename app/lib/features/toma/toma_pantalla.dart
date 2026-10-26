import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/plataforma/camara/camara_comprobacion.dart';
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
import '../persona_inicio/llamadas.dart';

enum _Fase { confirmar, camara, muyBien }

/// Pantalla de toma (maqueta B-Persona): "Ahora toca" con la foto grande de
/// la pastilla, un botón enorme, la comprobación con cámara y el "Muy bien"
/// final. Abajo, "Llamar" y "Ayuda" como en el inicio.
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
    final c = context.colores;
    final toma = ref.watch(tomaPorIdProvider(widget.tomaId));
    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: SafeArea(
        child: toma.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _Mensaje(
            texto: l.errorGenerico,
            icono: CupertinoIcons.info_circle_fill,
            boton: l.volverAlInicio,
            alPulsar: _volver,
          ),
          data: (t) {
            if (t == null) {
              return _Mensaje(
                texto: l.tomaNoEncontrada,
                icono: CupertinoIcons.info_circle_fill,
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
                icono: CupertinoIcons.checkmark_circle_fill,
                colorIcono: c.verde,
                boton: l.volverAlInicio,
                alPulsar: _volver,
              );
            }
            return switch (_fase) {
              _Fase.confirmar => _Confirmar(
                toma: t,
                prueba: widget.prueba,
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

/// Aviso a pantalla completa ("Ya está tomada") con un solo botón.
class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.texto,
    required this.icono,
    required this.boton,
    required this.alPulsar,
    this.colorIcono,
  });

  final String texto;
  final IconData icono;
  final Color? colorIcono;
  final String boton;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: TarjetaGrande(
          color: c.tarjeta,
          radio: 28,
          margen: EdgeInsets.zero,
          relleno: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icono, size: 72, color: colorIcono ?? c.textoSecundario),
              const SizedBox(height: 16),
              Text(
                texto,
                style: t.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              BotonGrande(
                key: ClavesUi.volverAlInicio,
                texto: boton,
                icono: CupertinoIcons.chevron_back,
                color: c.azul,
                colorTexto: c.sobreAzul,
                altura: 88,
                onPressed: alPulsar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Hola, Carmen" · "Ahora toca" con la foto, el nombre, el compartimento y
/// "YA ME LA HE TOMADO"; debajo, "Llamar" y "Ayuda".
class _Confirmar extends ConsumerStatefulWidget {
  const _Confirmar({
    required this.toma,
    required this.prueba,
    required this.alConfirmar,
  });

  final TomaVista toma;
  final bool prueba;
  final VoidCallback alConfirmar;

  @override
  ConsumerState<_Confirmar> createState() => _ConfirmarState();
}

class _ConfirmarState extends ConsumerState<_Confirmar> {
  /// Aviso tras "Llamar" o "Ayuda".
  String? _aviso;

  Future<void> _llamar(Miembro? familiar, {required bool ayuda}) async {
    final l = context.l;
    if (widget.prueba) {
      setState(() => _aviso = l.preguntaModoPrueba);
      return;
    }
    setState(
      () => _aviso = familiar == null
          ? l.ayudaAvisada
          : l.ayudaLlamando(familiar.nombre),
    );
    await llamarDesdePersona(ref, familiar, ayuda: ayuda);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final toma = widget.toma;
    final med = toma.medicamento;
    final compartimento = toma.pauta?.compartimento;
    final alias = ref.watch(personaProvider).value?.alias;
    final familiar = primerFamiliar(
      ref.watch(miembrosProvider).value ?? const <Miembro>[],
    );
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final dia = DateFormat(
      'EEEE d',
      'es_ES',
    ).format(aLocal(toma.toma.previstaPara, zona));
    final aviso = _aviso;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (alias != null && alias.isNotEmpty)
            Text(
              l.personaHola(alias),
              style: t.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            l.personaDiaYHora(dia, toma.toma.horaLocal),
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: c.textoSecundario,
            ),
          ),
          const SizedBox(height: 16),
          TarjetaGrande(
            color: c.tarjeta,
            radio: 28,
            margen: EdgeInsets.zero,
            conSombra: true,
            relleno: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.bell_fill, size: 22, color: c.verde),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l.personaAhoraToca.toUpperCase(),
                        semanticsLabel: l.personaAhoraToca,
                        style: t.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.verde,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColoredBox(
                    color: c.mesa,
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
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
                            tamano: 176,
                            colorBorde: c.mesaBorde,
                            etiquetaSemantica: l.semanticaFotoPastilla(
                              toma.nombreParaPersona,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Semantics(
                  header: true,
                  child: Text(
                    toma.nombreParaPersona,
                    style: t.headlineSmall?.copyWith(
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                ),
                if (compartimento != null && compartimento.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Compartimento(compartimento: compartimento),
                ],
                const SizedBox(height: 16),
                BotonGrande(
                  key: ClavesUi.confirmarToma,
                  texto: l.yaMeLaHeTomado,
                  icono: CupertinoIcons.checkmark_alt,
                  color: c.verde,
                  colorTexto: c.sobreVerde,
                  altura: 88,
                  tamanoTexto: 26,
                  radio: 22,
                  onPressed: widget.alConfirmar,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (familiar != null) ...[
                Expanded(
                  child: BotonGrande(
                    texto: l.personaLlamar,
                    etiquetaSemantica: l.llamarA(familiar.nombre),
                    icono: CupertinoIcons.phone_fill,
                    color: c.tarjeta,
                    colorTexto: c.texto,
                    altura: 84,
                    tamanoTexto: 22,
                    radio: 22,
                    onPressed: () => _llamar(familiar, ayuda: false),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: BotonGrande(
                  texto: l.personaAyuda,
                  etiquetaSemantica: l.necesitoAyuda,
                  icono: CupertinoIcons.exclamationmark_triangle_fill,
                  color: c.tarjeta,
                  colorTexto: c.texto,
                  altura: 84,
                  tamanoTexto: 22,
                  radio: 22,
                  onPressed: () => _llamar(familiar, ayuda: true),
                ),
              ),
            ],
          ),
          if (aviso != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                aviso,
                textAlign: TextAlign.center,
                style: t.titleMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Compartimento: Mediodía" con el compartimento en negrita.
class _Compartimento extends StatelessWidget {
  const _Compartimento({required this.compartimento});

  final String compartimento;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final completo = context.l.compartimentoEs(compartimento);
    final i = completo.lastIndexOf(compartimento);
    final base = t.bodyMedium?.copyWith(color: c.textoSecundario, height: 1.3);
    if (i < 0) return Text(completo, style: base);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: completo.substring(0, i)),
          TextSpan(
            text: compartimento,
            style: TextStyle(color: c.texto, fontWeight: FontWeight.w700),
          ),
          TextSpan(text: completo.substring(i + compartimento.length)),
        ],
      ),
      style: base,
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
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final s = sesion;
    final velo = c.texto.withValues(alpha: 0.8);
    return Stack(
      fit: StackFit.expand,
      children: [
        s == null ? ColoredBox(color: c.texto) : s.vistaPrevia(context),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            color: velo,
            padding: const EdgeInsets.all(20),
            child: Text(
              l.ensenaLaPastilla,
              textAlign: TextAlign.center,
              style: t.headlineMedium?.copyWith(
                color: Colores.blanco,
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
                  color: velo,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  restante.toString(),
                  style: t.displayLarge?.copyWith(
                    color: Colores.blanco,
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
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final familiar = primerFamiliar(
      ref.watch(miembrosProvider).value ?? const <Miembro>[],
    );
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
              color: c.verde,
            ),
          ),
          const SizedBox(height: 24),
          if (familiar != null) ...[
            AvatarFamiliar(miembro: familiar, tamano: 160),
            const SizedBox(height: 8),
            Text(familiar.nombre, style: t.headlineMedium),
          ] else
            Icon(CupertinoIcons.heart_fill, size: 120, color: c.verde),
        ],
      ),
    );
  }
}
