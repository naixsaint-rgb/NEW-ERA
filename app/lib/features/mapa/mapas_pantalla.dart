import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enrutado/rutas.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import 'gestor_mapas.dart';
import 'mapa_providers.dart';

/// Megas con una cifra decimal y coma, como se escribe en España.
String megas(AppLocalizations l, int bytes) =>
    l.mapaMegas((bytes / 1e6).toStringAsFixed(1).replaceAll('.', ','));

/// Hoy › Ubicación › Mapa de tu zona: la lista de comunidades, la descarga
/// (con progreso, reanudable y con comprobación sha256) y borrar o cambiar
/// el mapa guardado. En la web solo explica que el mapa va en el móvil.
class MapasPantalla extends ConsumerStatefulWidget {
  const MapasPantalla({super.key});

  @override
  ConsumerState<MapasPantalla> createState() => _MapasPantallaState();
}

class _MapasPantallaState extends ConsumerState<MapasPantalla> {
  Future<List<(MapaZona, int)>>? _lista;
  StreamSubscription<ProgresoMapa>? _descarga;
  String? _bajando;
  ProgresoMapa? _progreso;
  MotivoErrorMapa? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Vuelve a pedir la lista (y lo bajado de cada una). Con [limpiar] quita
  /// el aviso de error anterior.
  void _cargar({bool limpiar = false}) {
    final g = ref.read(gestorMapasProvider);
    if (g == null) return;
    setState(() {
      if (limpiar) _error = null;
      _lista = () async {
        final mapas = await g.lista();
        return [for (final m in mapas) (m, await g.parcial(m))];
      }();
    });
  }

  @override
  void dispose() {
    unawaited(_descarga?.cancel());
    super.dispose();
  }

  void _descargar(GestorMapas g, MapaZona m) {
    if (_bajando != null) return;
    setState(() {
      _bajando = m.id;
      _error = null;
      _progreso = ProgresoMapa(0, m.bytes);
    });
    _descarga = g
        .descargar(m)
        .listen(
          (p) {
            if (mounted) setState(() => _progreso = p);
          },
          onError: (Object e) {
            if (!mounted) return;
            setState(() {
              _error = e is ErrorMapa ? e.motivo : MotivoErrorMapa.red;
              _bajando = null;
              _descarga = null;
            });
            _cargar();
          },
          onDone: () {
            if (!mounted) return;
            setState(() {
              _bajando = null;
              _descarga = null;
            });
            ref.invalidate(mapaInstaladoProvider);
            _cargar();
          },
          cancelOnError: true,
        );
  }

  Future<void> _pausar() async {
    final d = _descarga;
    _descarga = null;
    await d?.cancel();
    if (!mounted) return;
    setState(() => _bajando = null);
    _cargar();
  }

  Future<void> _borrar(GestorMapas g) async {
    final l = context.l;
    final c = context.colores;
    final si = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.mapaBorrarTitulo),
        content: Text(l.mapaBorrarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
            child: Text(l.cancelar),
          ),
          FilledButton(
            key: ClavesUi.mapaBorrarSi,
            style: FilledButton.styleFrom(
              backgroundColor: c.rojo,
              foregroundColor: c.sobreRojo,
              minimumSize: const Size(44, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.mapaBorrarSi),
          ),
        ],
      ),
    );
    if (si != true) return;
    try {
      await g.borrar();
    } catch (_) {
      // Si falla, el mapa sigue y se puede volver a intentar.
    }
    ref.invalidate(mapaInstaladoProvider);
    _cargar();
  }

  String _textoError(AppLocalizations l, MotivoErrorMapa m) => switch (m) {
    MotivoErrorMapa.red => l.mapaErrorRed,
    MotivoErrorMapa.huella => l.mapaErrorHuella,
    MotivoErrorMapa.indice => l.mapaErrorIndice,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    final g = ref.watch(gestorMapasProvider);
    final instalado = ref.watch(mapaInstaladoProvider).value;
    final explicacion = t.bodyMedium?.copyWith(color: c.textoSecundario);
    void volver() =>
        context.canPop() ? context.pop() : context.go(Rutas.ubicacion);

    return Scaffold(
      backgroundColor: c.fondoAgrupado,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(
            vispera: l.mapaVispera,
            titulo: l.mapaTitulo,
            reservarBotonMas: false,
            alVolver: volver,
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              g == null ? l.mapaWeb : l.mapaExplica,
              style: t.bodyLarge?.copyWith(color: c.texto, height: 1.35),
            ),
          ),
          if (g != null) ...[
            if (instalado != null) ...[
              const SizedBox(height: 20),
              GrupoLista(
                titulo: l.mapaEnEsteMovil,
                children: [
                  FilaLista(
                    leading: IconoCuadrado(
                      CupertinoIcons.map_fill,
                      fondo: c.verde,
                      color: c.sobreVerde,
                    ),
                    titulo: instalado.nombre,
                    subtitulo: l.mapaInstaladoSub(megas(l, instalado.bytes)),
                  ),
                  FilaLista(
                    key: ClavesUi.mapaBorrar,
                    titulo: l.mapaBorrar,
                    colorTitulo: c.rojo,
                    conChevron: false,
                    onTap: _bajando == null ? () => _borrar(g) : null,
                  ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _textoError(l, _error!),
                  style: t.bodyMedium?.copyWith(color: c.rojo),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FutureBuilder<List<(MapaZona, int)>>(
              future: _lista,
              builder: (context, s) {
                if (s.hasError) {
                  final e = s.error;
                  return GrupoLista(
                    titulo: l.mapaComunidades,
                    children: [
                      FilaLista(
                        titulo: _textoError(
                          l,
                          e is ErrorMapa ? e.motivo : MotivoErrorMapa.red,
                        ),
                      ),
                      FilaLista(
                        key: ClavesUi.mapaReintentar,
                        titulo: l.mapaReintentar,
                        colorTitulo: c.azul,
                        conChevron: false,
                        onTap: () => _cargar(limpiar: true),
                      ),
                    ],
                  );
                }
                final filas = s.data;
                if (filas == null) {
                  return GrupoLista(
                    titulo: l.mapaComunidades,
                    children: [
                      FilaLista(
                        leading: const CupertinoActivityIndicator(),
                        titulo: l.mapaCargando,
                        apagada: true,
                      ),
                    ],
                  );
                }
                return GrupoLista(
                  titulo: l.mapaComunidades,
                  pie: l.mapaComunidadesPie,
                  children: [
                    for (final (m, parcial) in filas)
                      _filaZona(context, g, m, parcial, instalado),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.mapaAtribucionSemantica, style: explicacion),
          ),
        ],
      ),
    );
  }

  Widget _filaZona(
    BuildContext context,
    GestorMapas g,
    MapaZona m,
    int parcial,
    MapaInstalado? instalado,
  ) {
    final l = context.l;
    final c = context.colores;
    final esta = instalado?.id == m.id;
    if (_bajando == m.id) {
      final p = _progreso ?? ProgresoMapa(0, m.bytes);
      return Column(
        key: ClavesUi.mapaProgreso,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilaLista(
            key: ClavesUi.mapaZona(m.id),
            titulo: m.nombre,
            subtitulo: p.comprobando
                ? l.mapaComprobando
                : l.mapaDescargando((p.fraccion * 100).floor()),
            trailing: p.comprobando
                ? null
                : TextButton(
                    key: ClavesUi.mapaPausar,
                    onPressed: _pausar,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      foregroundColor: c.azul,
                    ),
                    child: Text(l.mapaPausar),
                  ),
            conChevron: false,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: p.fraccion,
                minHeight: 6,
                color: c.azul,
                backgroundColor: c.rellenoSuave,
              ),
            ),
          ),
        ],
      );
    }
    final porcentaje = m.bytes == 0 ? 0 : (parcial * 100 / m.bytes).floor();
    return FilaLista(
      key: ClavesUi.mapaZona(m.id),
      leading: IconoCuadrado(
        esta ? CupertinoIcons.checkmark_alt : CupertinoIcons.cloud_download,
        fondo: esta ? c.verde : c.azul,
        color: esta ? c.sobreVerde : c.sobreAzul,
      ),
      titulo: m.nombre,
      subtitulo: esta
          ? l.mapaActual
          : parcial > 0
          ? l.mapaAMedias(megas(l, m.bytes), porcentaje)
          : megas(l, m.bytes),
      conChevron: false,
      apagada: _bajando != null && !esta,
      onTap: esta || _bajando != null ? null : () => _descargar(g, m),
    );
  }
}
