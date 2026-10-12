import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/eventos_repositorio.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/etiqueta_estado_toma.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import 'dominio/tomas.dart';

/// Nivel del semáforo del día.
enum NivelSemaforo { verde, naranja, rojo }

/// Rojo si hoy hay una `noConfirmada`; naranja si hay una
/// `confirmadaSinVideo`; si no, verde.
NivelSemaforo nivelSemaforo(Iterable<TomaVista> deHoy) {
  var nivel = NivelSemaforo.verde;
  for (final t in deHoy) {
    if (t.estado == EstadoToma.noConfirmada) return NivelSemaforo.rojo;
    if (t.estado == EstadoToma.confirmadaSinVideo) {
      nivel = NivelSemaforo.naranja;
    }
  }
  return nivel;
}

/// Nombres de quien firma cada evento (familiares y persona).
final nombresAutoresProvider = Provider<Map<String, String>>((ref) {
  final miembros = ref.watch(miembrosProvider).value ?? const <Miembro>[];
  final persona = ref.watch(personaProvider).value;
  return {
    for (final m in miembros) m.id: m.nombre,
    if (persona != null) persona.id: persona.alias,
  };
});

class HoyPantalla extends ConsumerWidget {
  const HoyPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final contexto = ref.watch(contextoProvider);
    final ahora =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final todas = ref.watch(tomasProvider);
    final deHoy = ref.watch(tomasDeHoyProvider).value ?? const <TomaVista>[];
    final siguiente = ref.watch(siguienteTomaProvider).value;
    final nombres = ref.watch(nombresAutoresProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.pestanaHoy)),
      body: todas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorGenerico)),
        data: (lista) {
          final pasadas = [
            for (final x in lista)
              if (!x.toma.previstaPara.isAfter(ahora)) x,
          ];
          final ultima = pasadas.isEmpty ? null : pasadas.last;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Semaforo(nivel: nivelSemaforo(deHoy)),
              const SizedBox(height: 12),
              _UltimaToma(
                toma: ultima,
                nombres: nombres,
                zona: contexto.zonaHoraria,
              ),
              const SizedBox(height: 12),
              TarjetaGrande(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.loSiguiente, style: t.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      siguiente == null
                          ? l.noHayMasPastillas
                          : l.aLasHoraPastilla(
                              siguiente.toma.horaLocal,
                              siguiente.nombreParaPersona.toLowerCase(),
                            ),
                      style: t.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(l.tomasDeHoy, style: t.titleMedium),
              const SizedBox(height: 8),
              if (deHoy.isEmpty)
                Text(l.sinTomasHoy, style: t.bodyLarge)
              else
                for (final x in deHoy) _FilaToma(toma: x),
              const SizedBox(height: 16),
              _Reservada(titulo: l.reservadaVideo, semana: l.llegaEnSemana(3)),
              _Reservada(
                titulo: l.reservadaUbicacion,
                semana: l.llegaEnSemana(10),
              ),
              _Reservada(
                titulo: l.reservadaControl,
                semana: l.llegaEnSemana(5),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Semaforo extends StatelessWidget {
  const _Semaforo({required this.nivel});

  final NivelSemaforo nivel;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final (color, icono, texto) = switch (nivel) {
      NivelSemaforo.rojo => (Colores.rojo, Icons.error, l.semaforoRojo),
      NivelSemaforo.naranja => (
        Colores.naranja,
        Icons.warning,
        l.semaforoNaranja,
      ),
      NivelSemaforo.verde => (
        Colores.verde,
        Icons.check_circle,
        l.semaforoVerde,
      ),
    };
    return Semantics(
      container: true,
      label: l.semanticaSemaforo(texto),
      excludeSemantics: true,
      child: Container(
        key: ClavesUi.semaforo,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icono, color: Colors.white, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UltimaToma extends StatelessWidget {
  const _UltimaToma({
    required this.toma,
    required this.nombres,
    required this.zona,
  });

  final TomaVista? toma;
  final Map<String, String> nombres;
  final String zona;

  /// "Confirmada por Carmen desde el móvil", etc.
  static String quienYComo(
    AppLocalizations l,
    TomaVista t,
    Map<String, String> nombres,
  ) {
    final conf = t.ultimoDe(TipoEvento.tomaConfirmada);
    if (conf != null) {
      final quien = nombres[conf.autor] ?? l.alguien;
      final origen = EventosRepositorio.payloadDe(conf)['origen'];
      final como = switch (origen) {
        'reloj' => l.origenReloj,
        'familiar' => l.origenFamiliar,
        _ => l.origenMovil,
      };
      return l.confirmadaPorDesde(quien, como);
    }
    final cierre = t.ultimoDe(TipoEvento.tomaCerradaPorFamiliar);
    if (cierre != null) {
      return l.cerradaPor(nombres[cierre.autor] ?? l.alguien);
    }
    return l.sinConfirmarAun;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final x = toma;
    return TarjetaGrande(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.ultimaToma, style: t.titleMedium),
          const SizedBox(height: 4),
          if (x == null)
            Text(l.sinTomasAun, style: t.bodyLarge)
          else ...[
            Text(
              l.aLasHoraPastilla(
                x.toma.horaLocal,
                x.nombreParaPersona.toLowerCase(),
              ),
              style: t.bodyLarge,
            ),
            const SizedBox(height: 8),
            EtiquetaEstadoToma(estado: x.estado),
            const SizedBox(height: 8),
            Text(quienYComo(l, x, nombres), style: t.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _FilaToma extends StatelessWidget {
  const _FilaToma({required this.toma});

  final TomaVista toma;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(toma.toma.horaLocal, style: t.titleMedium),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(toma.nombreParaPersona, style: t.bodyLarge),
                const SizedBox(height: 4),
                EtiquetaEstadoToma(estado: toma.estado),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Reservada extends StatelessWidget {
  const _Reservada({required this.titulo, required this.semana});

  final String titulo;
  final String semana;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TarjetaGrande(
        color: const Color(0xFFF5F5F5),
        child: Row(
          children: [
            const Icon(Icons.lock_clock),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: t.titleMedium),
                  Text(semana, style: t.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
