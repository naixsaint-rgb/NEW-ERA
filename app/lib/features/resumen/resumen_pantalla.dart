import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/eventos_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import '../hoy/hoy_pantalla.dart' show NivelSemaforo, nombresAutoresProvider;
import 'dominio/resumen.dart';

/// Radio de las tarjetas destacadas de Resumen.
const double _radio = 20;

/// Resumen de la familia (maqueta B-Familia): cómo está la persona de un
/// vistazo, con las cifras reales de hoy. Lo que aún no existe (pulso, pasos,
/// sueño, control por horas) se anuncia como "llega en la semana N".
class ResumenPantalla extends ConsumerWidget {
  const ResumenPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final ahora =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final datos = ref.watch(resumenProvider);
    return Scaffold(
      key: ClavesUi.pantallaResumen,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          CabeceraGrande(
            vispera: fechaLarga(aLocal(ahora, zona)),
            titulo: l.pestanaResumen,
          ),
          const SizedBox(height: 14),
          datos.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text(l.errorGenerico)),
            ),
            data: (d) => _Contenido(datos: d, zona: zona),
          ),
        ],
      ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.datos, required this.zona});

  final ResumenDatos datos;
  final String zona;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nombres = ref.watch(nombresAutoresProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarjetaEstado(datos: datos, nombres: nombres, zona: zona),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _CasillaTomas(datos: datos)),
              const SizedBox(width: 12),
              Expanded(child: _CasillaVideos(videos: datos.videos)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _CasillaAvisos(avisos: datos.avisos)),
              const SizedBox(width: 12),
              Expanded(
                child: _CasillaMensaje(
                  mensaje: datos.mensaje,
                  nombres: nombres,
                  zona: zona,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _FilaReloj(),
        const SizedBox(height: 14),
        _TarjetaProximaToma(datos: datos, zona: zona),
        const SizedBox(height: 14),
        const _TarjetaControlPorHoras(),
      ],
    );
  }
}

// ------------------------------------------------------------------ Héroe

class _TarjetaEstado extends StatelessWidget {
  const _TarjetaEstado({
    required this.datos,
    required this.nombres,
    required this.zona,
  });

  final ResumenDatos datos;
  final Map<String, String> nombres;
  final String zona;

  static String _como(AppLocalizations l, OrigenConfirmacion o) => switch (o) {
    OrigenConfirmacion.movil => l.resumenOrigenMovil,
    OrigenConfirmacion.reloj => l.resumenOrigenReloj,
    OrigenConfirmacion.familiar => l.resumenOrigenFamiliar,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final alias = datos.alias ?? '';
    final (icono, color, fondo, titulo) = switch (datos.nivel) {
      NivelSemaforo.verde => (
        CupertinoIcons.checkmark,
        c.verde,
        c.verdeClaro,
        l.resumenEstaBien(alias),
      ),
      NivelSemaforo.naranja => (
        CupertinoIcons.exclamationmark,
        c.naranja,
        c.naranjaClaro,
        l.resumenNecesitaVistazo(alias),
      ),
      NivelSemaforo.rojo => (
        CupertinoIcons.xmark,
        c.rojo,
        c.rojoClaro,
        l.resumenNecesitaAtencion(alias),
      ),
    };
    final ultima = datos.ultimaConfirmacion;
    final subtitulo = ultima == null
        ? l.resumenSinTomasAun
        : l.resumenUltimaToma(
            horaCorta(aLocal(ultima.cuando, zona)),
            ultima.medicamento.toLowerCase(),
            nombres[ultima.autorId] ?? l.alguien,
            _como(l, ultima.origen),
          );
    final senal = datos.ultimaSenal;
    return TarjetaGrande(
      radio: _radio,
      conSombra: true,
      margen: EdgeInsets.zero,
      child: MergeSemantics(
        child: Row(
          children: [
            IconoCuadrado(
              icono,
              redondo: true,
              color: color,
              fondo: fondo,
              tamano: 52,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: t.headlineSmall?.copyWith(
                      color: c.texto,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: t.bodySmall?.copyWith(
                      color: c.textoSecundario,
                      fontSize: 14,
                    ),
                  ),
                  if (senal != null) ...[
                    const SizedBox(height: 8),
                    _Chip(
                      texto: l.resumenUltimaSenal(
                        horaCorta(aLocal(senal, zona)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.rellenoSuave,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                CupertinoIcons.clock,
                size: 14,
                color: c.textoSecundario,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                texto,
                style: t.labelMedium?.copyWith(
                  color: c.textoSecundario,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Rejilla

/// Tarjeta de la rejilla 2×2: título de color con icono y [child] debajo.
class _Casilla extends StatelessWidget {
  const _Casilla({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.child,
    this.onTap,
  });

  final IconData icono;
  final Color color;
  final String titulo;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return TarjetaGrande(
      radio: _radio,
      conSombra: true,
      margen: EdgeInsets.zero,
      relleno: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(child: Icon(icono, size: 18, color: color)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: t.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Cifra grande con una línea gris debajo.
class _Cifra extends StatelessWidget {
  const _Cifra({required this.n, required this.leyenda});

  final int n;
  final String leyenda;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          n.toString(),
          style: t.headlineMedium?.copyWith(
            color: c.texto,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(leyenda, style: t.bodySmall?.copyWith(color: c.textoSecundario)),
      ],
    );
  }
}

class _CasillaTomas extends StatelessWidget {
  const _CasillaTomas({required this.datos});

  final ResumenDatos datos;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final siguiente = datos.siguiente;
    final leyenda = siguiente == null
        ? l.resumenSinMasTomas
        : l.resumenSiguiente(siguiente.toma.horaLocal);
    final sinTomas = datos.previstas == 0;
    final semantica = sinTomas
        ? l.resumenSinTomasHoy
        : l.resumenSemanticaTomas(datos.hechas, datos.previstas);
    return _Casilla(
      icono: CupertinoIcons.capsule_fill,
      color: c.verde,
      titulo: l.resumenTarjetaTomas,
      child: Semantics(
        container: true,
        label: '$semantica, $leyenda',
        excludeSemantics: true,
        child: Row(
          children: [
            IndicadorAnillo(
              datos.previstas == 0 ? 0 : datos.hechas / datos.previstas,
              key: ClavesUi.anilloTomas,
              color: c.verde,
              fondo: c.verdeClaro,
              tamano: 52,
              grosor: 7,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sinTomas)
                    Text(
                      l.resumenSinTomasHoy,
                      style: t.titleSmall?.copyWith(color: c.texto),
                    )
                  else
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text.rich(
                        TextSpan(
                          text: datos.hechas.toString(),
                          style: t.headlineMedium?.copyWith(
                            color: c.texto,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                          children: [
                            TextSpan(
                              text: l.resumenDeTotal(datos.previstas),
                              style: t.titleSmall?.copyWith(
                                color: c.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    leyenda,
                    style: t.bodySmall?.copyWith(color: c.textoSecundario),
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

class _CasillaVideos extends StatelessWidget {
  const _CasillaVideos({required this.videos});

  final int videos;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return _Casilla(
      icono: CupertinoIcons.videocam_fill,
      color: c.azul,
      titulo: l.resumenTarjetaVideos,
      onTap: () => context.go(Rutas.hoyVista('hoy')),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _Cifra(n: videos, leyenda: l.resumenHoy),
          ),
          Text(l.resumenVer, style: t.labelLarge?.copyWith(color: c.azul)),
          ExcludeSemantics(
            child: Icon(
              CupertinoIcons.chevron_forward,
              size: 14,
              color: c.azul,
            ),
          ),
        ],
      ),
    );
  }
}

class _CasillaAvisos extends StatelessWidget {
  const _CasillaAvisos({required this.avisos});

  final int avisos;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return _Casilla(
      icono: CupertinoIcons.bell_fill,
      color: context.colores.naranja,
      titulo: l.resumenTarjetaAvisos,
      child: _Cifra(n: avisos, leyenda: l.resumenAyudaYLlamadas),
    );
  }
}

class _CasillaMensaje extends StatelessWidget {
  const _CasillaMensaje({
    required this.mensaje,
    required this.nombres,
    required this.zona,
  });

  final Evento? mensaje;
  final Map<String, String> nombres;
  final String zona;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final m = mensaje;
    final texto = m == null
        ? ''
        : (EventosRepositorio.payloadDe(m)['texto'] as String? ?? '').trim();
    Widget contenido;
    if (m == null || texto.isEmpty) {
      contenido = Text(
        l.resumenSinMensajes,
        style: t.bodyMedium?.copyWith(color: c.textoSecundario),
      );
    } else {
      final cuando = DateTime.fromMillisecondsSinceEpoch(
        m.ocurridoEn,
        isUtc: true,
      );
      contenido = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.bodyMedium?.copyWith(color: c.texto),
          ),
          const SizedBox(height: 4),
          Text(
            l.resumenMensajeDe(
              nombres[m.autor] ?? l.alguien,
              horaCorta(aLocal(cuando, zona)),
            ),
            style: t.bodySmall?.copyWith(color: c.textoSecundario),
          ),
        ],
      );
    }
    return _Casilla(
      icono: CupertinoIcons.chat_bubble_fill,
      color: c.morado,
      titulo: l.resumenTarjetaMensaje,
      child: contenido,
    );
  }
}

class _FilaReloj extends StatelessWidget {
  const _FilaReloj();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    return GrupoLista(
      children: [
        FilaLista(
          leading: IconoCuadrado(
            CupertinoIcons.clock,
            redondo: true,
            fondo: c.rellenoSuave,
            color: c.textoSecundario,
          ),
          titulo: l.resumenRelojLlega,
          subtitulo: l.llegaEnSemana(6),
          apagada: true,
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ Próxima toma

class _TarjetaProximaToma extends StatelessWidget {
  const _TarjetaProximaToma({required this.datos, required this.zona});

  final ResumenDatos datos;
  final String zona;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final siguiente = datos.siguiente;
    final etiqueta = Text(
      l.resumenProximaToma.toUpperCase(),
      semanticsLabel: l.resumenProximaToma,
      style: t.labelMedium?.copyWith(
        color: c.verde,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
    if (siguiente == null) {
      return TarjetaGrande(
        radio: _radio,
        conSombra: true,
        margen: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            etiqueta,
            const SizedBox(height: 4),
            Text(l.noHayMasPastillas, style: t.titleMedium),
          ],
        ),
      );
    }
    final compartimento = siguiente.pauta?.compartimento?.trim() ?? '';
    final hora = siguiente.toma.horaLocal;
    final linea = compartimento.isEmpty
        ? hora
        : l.resumenHoraCompartimento(hora, compartimento);
    final familiar = datos.familiar1;
    final minutos = datos.minutosAvisoFamiliar1;
    final medicamentoId = siguiente.medicamento?.id;
    return TarjetaGrande(
      radio: _radio,
      conSombra: true,
      margen: EdgeInsets.zero,
      onTap: medicamentoId == null
          ? null
          : () => context.go(Rutas.medicamento(medicamentoId)),
      child: Row(
        children: [
          FotoPastilla(siguiente.medicamento, tamano: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                etiqueta,
                Text(linea, style: t.titleMedium?.copyWith(color: c.texto)),
                Text(
                  siguiente.nombreParaPersona,
                  style: t.bodyMedium?.copyWith(color: c.texto),
                ),
                if (familiar != null && minutos != null)
                  Text(
                    l.resumenAvisoA(
                      familiar.nombre,
                      horaCorta(
                        aLocal(
                          siguiente.toma.previstaPara.add(
                            Duration(minutes: minutos),
                          ),
                          zona,
                        ),
                      ),
                    ),
                    style: t.bodySmall?.copyWith(color: c.textoSecundario),
                  ),
              ],
            ),
          ),
          if (medicamentoId != null) ...[
            const SizedBox(width: 6),
            ExcludeSemantics(
              child: Icon(
                CupertinoIcons.chevron_forward,
                size: 18,
                color: c.chevron,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Control por horas

class _TarjetaControlPorHoras extends StatelessWidget {
  const _TarjetaControlPorHoras();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return TarjetaGrande(
      radio: _radio,
      conSombra: true,
      margen: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.resumenControlHoras,
                  style: t.titleSmall?.copyWith(
                    color: c.texto,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                l.resumenControlRango,
                style: t.bodySmall?.copyWith(color: c.textoSecundario),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Franja 09–21 sin respuestas: llegan en la semana 5.
          ExcludeSemantics(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var h = 9; h <= 21; h++)
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: h < 21 ? 6 : 0),
                      child: SizedBox(
                        width: 40,
                        child: CeldaDia(
                          estado: EstadoCelda.vacia,
                          texto: h.toString().padLeft(2, '0'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.llegaEnSemana(5),
            style: t.bodySmall?.copyWith(color: c.textoSecundario),
          ),
        ],
      ),
    );
  }
}
