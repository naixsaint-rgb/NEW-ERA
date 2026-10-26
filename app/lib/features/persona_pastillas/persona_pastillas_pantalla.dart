import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/boton_grande.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import '../hoy/dominio/tomas.dart';

/// Alto del botón fijo "Volver al inicio".
const double _altoBotonVolver = 72;

/// "Mis pastillas" de la persona (maqueta D-Persona-Pastillas): las tomas de
/// hoy con la foto de cada una y su estado en palabras; la de ahora (o la
/// siguiente) resaltada con borde azul y, si ya es su hora, el botón "Ya me la
/// he tomado", que abre la pantalla de toma.
class PersonaPastillasPantalla extends ConsumerWidget {
  const PersonaPastillasPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final contexto = ref.watch(contextoProvider);
    final ahora =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final local = aLocal(ahora, contexto.zonaHoraria);
    final dia = DateFormat('EEEE', 'es_ES').format(local);
    final tomas = ref.watch(tomasDeHoyProvider);
    final siguiente = ref.watch(siguienteTomaProvider).value;
    // Si lo siguiente ya es de mañana, se dice al final: "Mañana a las 09:00,
    // pastilla blanca pequeña".
    final manana =
        siguiente == null ||
            !esDeOtroDia(siguiente, ahora, contexto.zonaHoraria)
        ? null
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l.fixMananaALasHoraPastilla(
                siguiente.toma.horaLocal,
                siguiente.nombreParaPersona.toLowerCase(),
              ),
              style: t.titleMedium?.copyWith(color: c.textoSecundario),
            ),
          );

    final Widget contenido = tomas.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Text(l.errorGenerico, style: t.titleMedium),
      data: (lista) {
        if (lista.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l.personaHoyNoHayPastillas, style: t.headlineSmall),
              ),
              ?manana,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final toma in lista) ...[
              _TarjetaToma(
                toma: toma,
                actual: _esActual(toma, siguiente),
                esSuHora: !ahora.isBefore(toma.toma.previstaPara),
              ),
              const SizedBox(height: 14),
            ],
            ?manana,
          ],
        );
      },
    );

    return Scaffold(
      key: ClavesUi.pantallaMisPastillas,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Hueco al final del alto del botón fijo + 24: la última
                // tarjeta y su botón nunca quedan pegados a "Volver al
                // inicio", ni con la letra al 130 %.
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  _altoBotonVolver + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CabeceraGrande(
                      titulo: l.misPastillas,
                      vispera: l.personaHoyDia(dia),
                      alVolver: () => context.go(Rutas.persona),
                      reservarBotonMas: false,
                    ),
                    const SizedBox(height: 16),
                    contenido,
                  ],
                ),
              ),
            ),
            // Fijo abajo, siempre a mano.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: BotonGrande(
                key: ClavesUi.volverAlInicio,
                texto: l.volverAlInicio,
                icono: CupertinoIcons.chevron_back,
                color: c.rellenoSuave,
                colorTexto: c.texto,
                altura: _altoBotonVolver,
                tamanoTexto: 22,
                onPressed: () => context.go(Rutas.persona),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `true` si [toma] es "la de ahora": a la misma hora que [siguiente] y aún
/// pendiente (dos pastillas a la misma hora van las dos resaltadas).
bool _esActual(TomaVista toma, TomaVista? siguiente) =>
    siguiente != null &&
    toma.toma.previstaPara == siguiente.toma.previstaPara &&
    (toma.estado == EstadoToma.prevista ||
        toma.estado == EstadoToma.noConfirmada);

/// Una toma de hoy: foto, "09:00 · Mañana", nombre y estado. La [actual]
/// lleva borde azul, foto de 104 y, si [esSuHora], el botón para tomarla.
class _TarjetaToma extends StatelessWidget {
  const _TarjetaToma({
    required this.toma,
    required this.actual,
    required this.esSuHora,
  });

  final TomaVista toma;
  final bool actual;
  final bool esSuHora;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final compartimento = toma.pauta?.compartimento;
    final cuando = compartimento == null || compartimento.isEmpty
        ? toma.toma.horaLocal
        : l.personaHoraCompartimento(toma.toma.horaLocal, compartimento);
    final estado = _Estado.de(toma.estado, esSuHora: esSuHora);
    final nombre = Text(
      toma.nombreParaPersona,
      style: t.titleMedium?.copyWith(
        fontSize: actual ? 24 : 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );

    if (!actual) {
      return TarjetaGrande(
        radio: 24,
        margen: EdgeInsets.zero,
        color: estado == _Estado.sinTomar ? c.rojoClaro : c.rellenoSuave,
        relleno: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            FotoPastilla(toma.medicamento, tamano: 72),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cuando,
                    style: t.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: estado == _Estado.sinTomar
                          ? c.texto
                          : c.textoSecundario,
                    ),
                  ),
                  nombre,
                  if (estado != null) ...[
                    const SizedBox(height: 4),
                    _LineaEstado(estado: estado),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    final ahoraYa = esSuHora && toma.estado == EstadoToma.prevista;
    final cabecera = esSuHora ? l.personaAhoraCon(cuando) : cuando;
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: c.azul, width: 3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TarjetaGrande(
        radio: 24,
        margen: EdgeInsets.zero,
        color: c.tarjeta,
        relleno: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              cabecera.toUpperCase(),
              semanticsLabel: cabecera,
              style: t.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: c.azul,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FotoPastilla(toma.medicamento, tamano: 104),
                const SizedBox(width: 16),
                Expanded(child: nombre),
              ],
            ),
            if (estado != null && !ahoraYa) ...[
              const SizedBox(height: 12),
              _LineaEstado(estado: estado),
            ],
            if (esSuHora && !esHecha(toma.estado)) ...[
              const SizedBox(height: 14),
              BotonGrande(
                texto: l.personaYaMeLaHeTomado,
                icono: CupertinoIcons.checkmark_alt,
                color: c.verde,
                colorTexto: c.sobreVerde,
                altura: 80,
                tamanoTexto: 24,
                radio: 20,
                onPressed: () => context.push(Rutas.toma(toma.toma.id)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de una toma en palabras para la persona.
enum _Estado {
  tomada,
  luego,
  sinTomar;

  /// Nulo si la toma está prevista y ya ha llegado su hora (es "ahora").
  static _Estado? de(EstadoToma e, {required bool esSuHora}) {
    if (esHecha(e)) return _Estado.tomada;
    if (e == EstadoToma.noConfirmada) return _Estado.sinTomar;
    return esSuHora ? null : _Estado.luego;
  }
}

/// Icono + palabras grandes: nunca un estado solo por color.
class _LineaEstado extends StatelessWidget {
  const _LineaEstado({required this.estado});

  final _Estado estado;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final (icono, color, texto) = switch (estado) {
      _Estado.tomada => (
        CupertinoIcons.checkmark_circle_fill,
        c.verde,
        l.personaYaTomada,
      ),
      _Estado.luego => (
        CupertinoIcons.clock,
        c.textoSecundario,
        l.personaLuego,
      ),
      _Estado.sinTomar => (
        CupertinoIcons.xmark_circle_fill,
        c.rojo,
        l.personaSinTomar,
      ),
    };
    return Row(
      children: [
        Icon(icono, size: 28, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            texto,
            style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
