import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../../core/i18n/fechas.dart';
import '../../../core/providers.dart';
import '../../../core/tema/colores.dart';
import '../../../shared/claves_ui.dart';
import '../../../shared/ios/ios.dart';
import '../../../shared/l10n_ext.dart';
import '../../../shared/widgets/etiqueta_estado_toma.dart';
import '../../../shared/widgets/tarjeta_grande.dart';
import '../dominio/tomas.dart';
import 'piezas_hoy.dart';

/// Vista "Hoy" de la pestaña Hoy de la familia (maqueta A-Familia).
class VistaHoy extends ConsumerWidget {
  const VistaHoy({super.key, required this.datos, required this.ahora});

  final TomasPorDia datos;
  final DateTime ahora;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final deHoy = datos.de(datos.hoy);
    final todas = [for (final d in datos.dias) ...datos.de(d)];
    TomaVista? ultima;
    for (final x in todas) {
      if (!x.toma.previstaPara.isAfter(ahora)) ultima = x;
    }
    final siguiente = siguienteToma(todas, ahora);
    final cuenta = contarTomas(deHoy);
    final avisos = ref.watch(avisosDeHoyProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _TarjetaEstado(
          nivel: nivelSemaforo(deHoy),
          ultima: ultima,
          cuenta: cuenta,
          videos: clipsDe(deHoy).length,
          avisos: avisos,
        ),
        separacionBloques,
        TituloSeccion(l.hoyProximaToma),
        _ProximaToma(toma: siguiente),
        separacionBloques,
        GrupoTomas(titulo: l.tomasDeHoy, tomas: deHoy, vacio: l.sinTomasHoy),
        separacionBloques,
        GrupoComprobaciones(tomas: deHoy, vacio: l.hoySinComprobacionesHoy),
        separacionBloques,
        GrupoLista(
          titulo: l.hoyLlegaPronto,
          children: [
            FilaLlegaPronto(
              titulo: l.reservadaVideo,
              subtitulo: l.llegaEnSemana(3),
            ),
            FilaLlegaPronto(
              titulo: l.reservadaUbicacion,
              subtitulo: l.llegaEnSemana(10),
            ),
            FilaLlegaPronto(
              titulo: l.reservadaControl,
              subtitulo: l.llegaEnSemana(5),
            ),
          ],
        ),
      ],
    );
  }
}

/// Semáforo (color + icono + texto), la última toma y tres casillas.
class _TarjetaEstado extends ConsumerWidget {
  const _TarjetaEstado({
    required this.nivel,
    required this.ultima,
    required this.cuenta,
    required this.videos,
    required this.avisos,
  });

  final NivelSemaforo nivel;
  final TomaVista? ultima;
  final CuentaTomas cuenta;
  final int videos;
  final int? avisos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final nombres = ref.watch(nombresAutoresProvider);
    final (color, fondo, icono, texto) = switch (nivel) {
      NivelSemaforo.rojo => (
        c.rojo,
        c.rojoClaro,
        CupertinoIcons.exclamationmark_octagon_fill,
        l.semaforoRojo,
      ),
      NivelSemaforo.naranja => (
        c.naranja,
        c.naranjaClaro,
        CupertinoIcons.exclamationmark_triangle_fill,
        l.semaforoNaranja,
      ),
      NivelSemaforo.verde => (
        c.verde,
        c.verdeClaro,
        CupertinoIcons.checkmark_alt,
        l.semaforoVerde,
      ),
    };
    final x = ultima;
    return TarjetaGrande(
      margen: EdgeInsets.zero,
      relleno: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            key: ClavesUi.semaforo,
            container: true,
            label: l.semanticaSemaforo(texto),
            excludeSemantics: true,
            child: Row(
              children: [
                IconoCuadrado(
                  icono,
                  redondo: true,
                  fondo: fondo,
                  color: color,
                  tamano: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: t.titleMedium?.copyWith(color: c.texto),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 1, child: ColoredBox(color: c.separador)),
          const SizedBox(height: 12),
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.ultimaToma,
                  style: t.labelMedium?.copyWith(color: c.textoSecundario),
                ),
                const SizedBox(height: 2),
                if (x == null)
                  Text(
                    l.sinTomasAun,
                    style: t.bodyMedium?.copyWith(color: c.texto),
                  )
                else ...[
                  Text(
                    l.aLasHoraPastilla(
                      x.toma.horaLocal,
                      x.nombreParaPersona.toLowerCase(),
                    ),
                    style: t.titleSmall?.copyWith(color: c.texto),
                  ),
                  const SizedBox(height: 6),
                  EtiquetaEstadoToma(estado: x.estado, tamanoTexto: 13),
                  const SizedBox(height: 4),
                  Text(
                    quienYComo(l, x, nombres),
                    style: t.bodySmall?.copyWith(color: c.textoSecundario),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Casilla(
                  titulo: l.hoyCasillaTomas,
                  valor: '${cuenta.hechas}',
                  resto: l.hoyDeTotal(cuenta.previstas),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Casilla(titulo: l.hoyCasillaVideos, valor: '$videos'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Casilla(
                  titulo: l.hoyCasillaAvisos,
                  valor: avisos == null ? '–' : '$avisos',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Casilla pequeña de la tarjeta de estado: "Tomas · 1 de 3".
class _Casilla extends StatelessWidget {
  const _Casilla({required this.titulo, required this.valor, this.resto});

  final String titulo;
  final String valor;
  final String? resto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final resto = this.resto;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: c.rellenoSuave,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.labelMedium?.copyWith(color: c.textoSecundario),
            ),
            Text.rich(
              TextSpan(
                text: valor,
                children: [
                  if (resto != null)
                    TextSpan(
                      text: ' $resto',
                      style: t.labelMedium?.copyWith(color: c.textoSecundario),
                    ),
                ],
              ),
              style: t.titleLarge?.copyWith(color: c.texto),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Próxima toma": foto, "14:00 · Mediodía", nombre y cuándo se avisa.
class _ProximaToma extends ConsumerWidget {
  const _ProximaToma({required this.toma});

  final TomaVista? toma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final x = toma;
    if (x == null) {
      return GrupoLista(
        children: [FilaLlegaPronto(titulo: l.noHayMasPastillas)],
      );
    }
    final config = ref.watch(configEscaladoProvider);
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final minutos = minutoDePaso(
      config,
      AccionEscalado.avisarFamiliar1,
      porDefecto: 5,
    );
    final aviso = horaCorta(
      aLocal(x.toma.previstaPara.add(Duration(minutes: minutos)), zona),
    );
    return TarjetaGrande(
      margen: EdgeInsets.zero,
      relleno: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: MergeSemantics(
        child: Row(
          children: [
            FotoPastilla(x.medicamento, insigniaCamara: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    horaYCompartimento(l, x),
                    style: t.titleMedium?.copyWith(color: c.texto),
                  ),
                  Text(
                    x.nombreParaPersona,
                    style: t.bodySmall?.copyWith(color: c.textoSecundario),
                  ),
                  Text(
                    l.hoySiNoLaToma(aviso),
                    style: t.bodySmall?.copyWith(
                      color: c.naranja,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
