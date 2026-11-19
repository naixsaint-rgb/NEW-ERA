import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/base_datos.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/plataforma/ubicacion/ubicador.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'fila_ubicacion_hoy.dart';
import 'ubicacion_providers.dart';

/// Enlace a la app de mapas del móvil con ([lat], [lon]): `geo:` en Android,
/// Apple Maps en iPhone y OpenStreetMap en la web. La app no carga mapas de
/// ningún servidor: la posición solo sale del móvil si la familia toca el
/// botón, hacia la app de mapas que elija.
Uri enlaceMapas(double lat, double lon, {TargetPlatform? plataforma}) {
  final la = lat.toStringAsFixed(6), lo = lon.toStringAsFixed(6);
  final p = plataforma ?? (kIsWeb ? null : defaultTargetPlatform);
  return switch (p) {
    TargetPlatform.android => Uri.parse('geo:$la,$lo?q=$la,$lo'),
    TargetPlatform.iOS => Uri.https('maps.apple.com', '/', {
      'll': '$la,$lo',
      'q': '$la,$lo',
    }),
    _ => Uri.https('www.openstreetmap.org', '/', {'mlat': la, 'mlon': lo}),
  };
}

/// Hoy › Ubicación (plan v3, 7.1 a 7.3): estado, última posición, las del
/// día, «Abrir en mapas», la zona segura (centro y radio), «Buscarla ahora»
/// y la ficha para emergencias con «Llamar al 112». Con la ubicación
/// apagada, solo la explicación y «Encender la ubicación».
class UbicacionPantalla extends ConsumerStatefulWidget {
  const UbicacionPantalla({super.key});

  @override
  ConsumerState<UbicacionPantalla> createState() => _UbicacionPantallaState();
}

class _UbicacionPantallaState extends ConsumerState<UbicacionPantalla> {
  bool _verFicha = false;

  Future<void> _abrir(Uri uri) async {
    try {
      await ref.read(abrirEnlaceProvider)(uri);
    } catch (_) {
      // Sin app de mapas o de teléfono: no pasa nada.
    }
  }

  Future<void> _intentar(Future<void> Function() accion) async {
    try {
      await accion();
    } catch (_) {
      // Un fallo de la base no rompe la pantalla: se puede volver a intentar.
    }
  }

  Future<bool> _confirmar({
    required String titulo,
    required String texto,
    required String si,
    required Key clave,
  }) async {
    final c = context.colores;
    final l = context.l;
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            child: Text(l.cancelar),
          ),
          FilledButton(
            key: clave,
            style: FilledButton.styleFrom(
              backgroundColor: c.rojo,
              foregroundColor: c.sobreRojo,
              minimumSize: const Size(44, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(si),
          ),
        ],
      ),
    );
    return r == true;
  }

  Future<void> _llamar112() async {
    final l = context.l;
    if (!await _confirmar(
      titulo: l.ubicLlamar112Titulo,
      texto: l.ubicLlamar112Texto,
      si: l.ubicLlamar112Si,
      clave: ClavesUi.ubicLlamar112Si,
    )) {
      return;
    }
    await _abrir(Uri(scheme: 'tel', path: '112'));
  }

  Future<void> _apagar(String alias) async {
    final l = context.l;
    final texto = l.ubicApagarTexto(alias);
    if (!await _confirmar(
      titulo: l.ubicApagarTitulo,
      texto: texto,
      si: l.ubicApagarSi,
      clave: ClavesUi.ubicApagarSi,
    )) {
      return;
    }
    final miembro = ref.read(sesionProvider).miembroId;
    if (miembro == null) return;
    await _intentar(
      () => ref
          .read(ubicacionRepositorioProvider)
          .revocar(miembroId: miembro, textoMostrado: texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final zonaHoraria = ref.watch(contextoProvider).zonaHoraria;
    final ahora =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final alias = ref.watch(personaProvider).value?.alias ?? '';
    final activa = ref.watch(ubicacionActivaProvider);
    final zona = ref.watch(zonaSeguraProvider).value;
    final radio = ref.watch(radioZonaProvider).value ?? radioZonaPorDefecto;
    final situacion = ref.watch(situacionZonaProvider);
    final lecturas =
        ref.watch(lecturasUbicacionProvider).value ??
        const <LecturaUbicacion>[];
    final busqueda = ref.watch(busquedaActivaProvider);
    final permiso = ref.watch(permisoMovilPersonaProvider).value;
    final repo = ref.read(ubicacionRepositorioProvider);
    final explicacion = t.bodyMedium?.copyWith(color: c.textoSecundario);
    String hora(DateTime x) => horaCorta(aLocal(x, zonaHoraria));
    void volver() =>
        context.canPop() ? context.pop() : context.go(Rutas.pestana('hoy'));

    final cabecera = CabeceraGrande(
      vispera: l.ubicVispera(alias),
      titulo: l.ubicTitulo,
      reservarBotonMas: false,
      alVolver: volver,
    );

    if (!activa) {
      return Scaffold(
        backgroundColor: c.fondoAgrupado,
        body: ListView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
          children: [
            cabecera,
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.ubicApagadaExplica(alias),
                style: t.bodyLarge?.copyWith(color: c.texto, height: 1.35),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: ClavesUi.ubicEncender,
              onPressed: () => context.push(Rutas.ubicacionPermiso),
              style: FilledButton.styleFrom(
                backgroundColor: c.azul,
                foregroundColor: c.sobreAzul,
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(l.ubicEncender),
            ),
          ],
        ),
      );
    }

    final estado = estadoUbicacion(
      l,
      activa: activa,
      zona: zona,
      situacion: situacion,
      zonaHoraria: zonaHoraria,
      ahora: ahora,
    );
    final ultima = situacion?.ultima ?? lecturas.lastOrNull;
    final hoy = fechaLocalTexto(ahora, zonaHoraria);
    final deHoy = [
      for (final x in lecturas.reversed)
        if (fechaLocalTexto(x.instante, zonaHoraria) == hoy) x,
    ].take(50).toList();
    final fuera = situacion?.fuera ?? false;
    final conFicha = fuera || busqueda != null || _verFicha;

    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          cabecera,
          const SizedBox(height: 14),
          GrupoLista(
            titulo: l.ubicAhora,
            pie: switch (permiso) {
              PermisoUbicacion.siempre => l.ubicPermisoSiempre,
              PermisoUbicacion.conAppAbierta => l.ubicPermisoAbierta,
              _ => null,
            },
            children: [
              FilaLista(
                key: ClavesUi.ubicEstado,
                leading: iconoUbicacion(context, estado.tono),
                titulo: estado.titulo,
                subtitulo: estado.subtitulo,
                colorTitulo: estado.tono == TonoUbicacion.alerta
                    ? c.rojo
                    : null,
              ),
              if (ultima != null) ...[
                FilaLista(
                  leading: IconoCuadrado(
                    CupertinoIcons.location_circle,
                    redondo: true,
                    fondo: c.azulClaro,
                    color: c.azul,
                  ),
                  titulo: l.ubicUltimaPosicion,
                  subtitulo: [
                    l.ubicPrecision(
                      hora(ultima.instante),
                      ultima.precision.round(),
                    ),
                    if (ultima.bateria != null) l.ubicBateria(ultima.bateria!),
                  ].join('\n'),
                ),
                FilaLista(
                  key: ClavesUi.ubicAbrirMapas,
                  leading: IconoCuadrado(
                    CupertinoIcons.map_fill,
                    fondo: c.verde,
                    color: c.sobreVerde,
                  ),
                  titulo: l.ubicAbrirMapas,
                  subtitulo: l.ubicMapasPie,
                  onTap: () => _abrir(enlaceMapas(ultima.lat, ultima.lon)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          _ModoPerdida(
            busqueda: busqueda,
            hora: hora,
            alBuscar: () => _intentar(() async {
              await repo.pedirBusqueda();
            }),
            alParar: () => _intentar(() async {
              await repo.pararBusqueda();
            }),
          ),
          const SizedBox(height: 14),
          if (conFicha)
            _FichaEmergencias(
              alias: alias,
              ultima: ultima,
              hora: hora,
              alLlamar: _llamar112,
            )
          else
            GrupoLista(
              children: [
                FilaLista(
                  key: ClavesUi.ubicVerFicha,
                  leading: IconoCuadrado(
                    CupertinoIcons.doc_text_fill,
                    fondo: c.rojo,
                    color: c.sobreRojo,
                  ),
                  titulo: l.ubicVerFicha,
                  onTap: () => setState(() => _verFicha = true),
                ),
              ],
            ),
          const SizedBox(height: 14),
          GrupoLista(
            titulo: l.ubicZonaTitulo,
            pie: l.ubicZonaPie,
            children: [
              FilaLista(
                leading: IconoCuadrado(
                  CupertinoIcons.house_fill,
                  fondo: c.verde,
                  color: c.sobreVerde,
                ),
                titulo: l.ubicZonaCasa,
                subtitulo: zona == null
                    ? l.ubicZonaSinElegir
                    : l.ubicZonaRadio(zona.radio),
              ),
              FilaLista(
                key: ClavesUi.ubicUsarComoCasa,
                leading: IconoCuadrado(
                  CupertinoIcons.location_fill,
                  fondo: c.azul,
                  color: c.sobreAzul,
                ),
                titulo: l.ubicUsarComoCasa,
                subtitulo: ultima == null
                    ? l.ubicUsarSinPosicion
                    : l.ubicPrecision(
                        hora(ultima.instante),
                        ultima.precision.round(),
                      ),
                apagada: ultima == null,
                conChevron: false,
                onTap: ultima == null
                    ? null
                    : () => _intentar(
                        () =>
                            repo.guardarZona(lat: ultima.lat, lon: ultima.lon),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TituloSeccion(l.ubicRadioTitulo),
          SelectorSegmentos<int>(
            valores: radiosZona,
            seleccionado: radiosZona.contains(radio)
                ? radio
                : radioZonaPorDefecto,
            etiqueta: l.ubicRadioMetros,
            clave: ClavesUi.ubicRadio,
            alCambiar: (v) =>
                unawaited(_intentar(() => repo.guardarZona(radio: v))),
          ),
          const SizedBox(height: 14),
          GrupoLista(
            titulo: l.ubicLecturasHoy,
            children: [
              if (deHoy.isEmpty)
                FilaLista(titulo: l.ubicSinLecturasHoy, apagada: true)
              else
                for (final x in deHoy)
                  _FilaLectura(lectura: x, zona: zona, hora: hora(x.instante)),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            key: ClavesUi.ubicApagar,
            onPressed: () => _apagar(alias),
            style: TextButton.styleFrom(
              foregroundColor: c.rojo,
              minimumSize: const Size.fromHeight(44),
            ),
            child: Text(l.ubicApagar),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.ubicConsCuanto, style: explicacion),
          ),
        ],
      ),
    );
  }
}

/// Una posición del día: hora, precisión, de dónde salió y si estaba en
/// casa (o a cuántos metros).
class _FilaLectura extends StatelessWidget {
  const _FilaLectura({
    required this.lectura,
    required this.zona,
    required this.hora,
  });

  final LecturaUbicacion lectura;
  final ZonaSegura? zona;
  final String hora;

  static String origen(AppLocalizations l, OrigenUbicacion? o) => switch (o) {
    OrigenUbicacion.segundoPlano => l.ubicOrigenFondo,
    OrigenUbicacion.alarma => l.ubicOrigenAlarma,
    OrigenUbicacion.ayuda => l.ubicOrigenAyuda,
    OrigenUbicacion.busqueda => l.ubicOrigenBusqueda,
    _ => l.ubicOrigenApp,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final z = zona;
    String? detalle;
    if (z != null) {
      final d = distanciaMetros(z.lat, z.lon, lectura.lat, lectura.lon);
      detalle = d <= z.radio
          ? l.ubicLecturaDentro
          : l.ubicLecturaFuera(d.round());
    }
    return FilaLista(
      key: ClavesUi.ubicLectura(lectura.id),
      titulo: hora,
      subtitulo: l.ubicLecturaDetalle(
        lectura.precision.round(),
        origen(l, lectura.origen),
      ),
      detalle: detalle,
      altoMinimo: 48,
    );
  }
}

/// «Si no la encontráis»: «Buscarla ahora» (30 minutos de posiciones
/// frecuentes) o, si ya se está buscando, hasta cuándo y «Parar».
class _ModoPerdida extends StatelessWidget {
  const _ModoPerdida({
    required this.busqueda,
    required this.hora,
    required this.alBuscar,
    required this.alParar,
  });

  final BusquedaPedida? busqueda;
  final String Function(DateTime) hora;
  final VoidCallback alBuscar;
  final VoidCallback alParar;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final b = busqueda;
    return GrupoLista(
      titulo: l.ubicPerdidaTitulo,
      pie: l.ubicBuscarPie,
      children: [
        if (b == null)
          FilaLista(
            key: ClavesUi.ubicBuscar,
            leading: IconoCuadrado(
              CupertinoIcons.search,
              fondo: c.naranja,
              color: c.sobreNaranja,
            ),
            titulo: l.ubicBuscar,
            subtitulo: l.ubicBuscarSub,
            conChevron: false,
            onTap: alBuscar,
          )
        else ...[
          FilaLista(
            leading: IconoCuadrado(
              CupertinoIcons.dot_radiowaves_left_right,
              redondo: true,
              fondo: c.naranjaClaro,
              color: c.naranja,
            ),
            titulo: l.ubicBuscando(hora(b.hasta)),
            subtitulo: l.ubicBuscarSub,
          ),
          FilaLista(
            key: ClavesUi.ubicPararBusqueda,
            titulo: l.ubicPararBusqueda,
            colorTitulo: c.azul,
            conChevron: false,
            onTap: alParar,
          ),
        ],
      ],
    );
  }
}

/// Ficha para emergencias con lo que ya hay en la app: nombre (alias),
/// medicación activa y última posición; y «Llamar al 112».
class _FichaEmergencias extends ConsumerWidget {
  const _FichaEmergencias({
    required this.alias,
    required this.ultima,
    required this.hora,
    required this.alLlamar,
  });

  final String alias;
  final LecturaUbicacion? ultima;
  final String Function(DateTime) hora;
  final VoidCallback alLlamar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final meds = [
      for (final m
          in ref.watch(medicamentosProvider).value ?? const <Medicamento>[])
        if (m.retiradoEn == null) m.nombre,
    ];
    final u = ultima;
    return Column(
      key: ClavesUi.ubicFicha,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GrupoLista(
          titulo: l.ubicFichaTitulo,
          children: [
            FilaLista(titulo: l.ubicFichaNombre, subtitulo: alias),
            FilaLista(
              titulo: l.ubicFichaMedicacion,
              subtitulo: meds.isEmpty
                  ? l.ubicFichaSinMedicacion
                  : meds.join(', '),
            ),
            FilaLista(
              titulo: l.ubicFichaPosicion,
              subtitulo: u == null
                  ? l.ubicFichaSinPosicion
                  : l.ubicFichaPosicionValor(
                      hora(u.instante),
                      u.lat.toStringAsFixed(5),
                      u.lon.toStringAsFixed(5),
                      u.precision.round(),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: ClavesUi.ubicLlamar112,
          onPressed: alLlamar,
          icon: const Icon(CupertinoIcons.phone_fill),
          label: Text(l.ubicLlamar112),
          style: FilledButton.styleFrom(
            backgroundColor: c.rojo,
            foregroundColor: c.sobreRojo,
            minimumSize: const Size.fromHeight(50),
            textStyle: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
