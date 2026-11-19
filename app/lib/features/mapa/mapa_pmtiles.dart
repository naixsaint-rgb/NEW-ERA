import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../core/tema/colores.dart';
import '../../shared/claves_ui.dart';
import '../../shared/l10n_ext.dart';
import 'estilo_mapa.dart';
import 'pmtiles_lector.dart';
import 'vista_mapa.dart';

/// Teselas vectoriales leídas del archivo PMTiles del móvil. No hay red:
/// [provide] solo lee del archivo.
class ProveedorPmtiles extends vmt.VectorTileProvider {
  ProveedorPmtiles(this.lector);

  final LectorPmtiles lector;

  /// Teselas pedidas (para los tests).
  int lecturas = 0;

  @override
  int get maximumZoom => lector.cabecera.zoomMaximo;

  @override
  int get minimumZoom => lector.cabecera.zoomMinimo;

  @override
  vmt.TileOffset get tileOffset => vmt.TileOffset.DEFAULT;

  @override
  Future<Uint8List> provide(vmt.TileIdentity tile) async {
    lecturas++;
    final b = await lector.tesela(tile.z, tile.x, tile.y);
    if (b == null) {
      throw vmt.ProviderException(
        message: 'sin tesela ${tile.z}/${tile.x}/${tile.y}',
        retryable: vmt.Retryable.none,
        statusCode: 404,
      );
    }
    return b;
  }
}

/// Mapa de calles del archivo descargado, con la zona «Casa», el círculo de
/// precisión, el recorrido y el punto de la última posición. Botones para
/// centrar en ella y en casa; atribución «© OpenStreetMap» siempre visible.
class MapaPmtiles extends StatefulWidget {
  const MapaPmtiles({super.key, required this.datos});

  final DatosMapa datos;

  @override
  State<MapaPmtiles> createState() => MapaPmtilesState();
}

class MapaPmtilesState extends State<MapaPmtiles> {
  final _control = MapController();
  LectorPmtiles? _lector;
  ProveedorPmtiles? _proveedor;
  bool _fallo = false;
  final _temas = <bool, vtr.Theme>{};

  /// Proveedor de teselas (para los tests); nulo hasta abrir el archivo.
  ProveedorPmtiles? get proveedor => _proveedor;

  /// Control del mapa (para los tests).
  MapController get control => _control;

  @override
  void initState() {
    super.initState();
    unawaited(_abrir());
  }

  Future<void> _abrir() async {
    try {
      final l = await LectorPmtiles.abrir(File(widget.datos.rutaArchivo));
      if (!mounted) {
        await l.cerrar();
        return;
      }
      setState(() {
        _lector = l;
        _proveedor = ProveedorPmtiles(l);
      });
    } catch (_) {
      if (mounted) setState(() => _fallo = true);
    }
  }

  @override
  void dispose() {
    final l = _lector;
    if (l != null) unawaited(l.cerrar());
    _control.dispose();
    super.dispose();
  }

  vtr.Theme _tema(bool oscuro) => _temas.putIfAbsent(
    oscuro,
    () => vtr.ThemeReader().read(estiloMapa(oscuro: oscuro)),
  );

  LatLng? get _ella {
    final u = widget.datos.ultima;
    return u == null ? null : LatLng(u.lat, u.lon);
  }

  LatLng? get _casa {
    final z = widget.datos.zona;
    return z == null ? null : LatLng(z.lat, z.lon);
  }

  void _centrar(LatLng? p) {
    if (p == null) return;
    _control.move(p, _control.camera.zoom < 15 ? 16 : _control.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final l = context.l;
    final t = Theme.of(context).textTheme;
    final lector = _lector;
    final proveedor = _proveedor;
    if (_fallo) {
      return _Aviso(texto: l.mapaNoAbre);
    }
    if (lector == null || proveedor == null) {
      return ColoredBox(
        color: c.rellenoSuave,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }
    final cab = lector.cabecera;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final d = widget.datos;
    final ella = _ella, casa = _casa;
    final centro = ella ?? casa ?? LatLng(cab.latCentro, cab.lonCentro);
    final dentro = ella == null || cab.contiene(ella.latitude, ella.longitude);
    final rastro = [for (final x in d.rastro) LatLng(x.lat, x.lon)];
    final carpeta = File(d.rutaArchivo).parent.path;

    return Stack(
      children: [
        Semantics(
          label: l.mapaEtiqueta,
          child: FlutterMap(
            key: ClavesUi.mapaVista,
            mapController: _control,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: 16,
              minZoom: cab.zoomMinimo.toDouble().clamp(4, 10),
              maxZoom: 19,
              backgroundColor: oscuro
                  ? const Color(0xFF1C1C1E)
                  : const Color(0xFFF2EFE9),
              cameraConstraint: CameraConstraint.containCenter(
                bounds: LatLngBounds(
                  LatLng(cab.sur, cab.oeste),
                  LatLng(cab.norte, cab.este),
                ),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onLongPress: (_, p) => d.alFijarCasa(p.latitude, p.longitude),
            ),
            children: [
              vmt.VectorTileLayer(
                tileProviders: vmt.TileProviders({fuenteMapa: proveedor}),
                theme: _tema(oscuro),
                layerMode: vmt.VectorTileLayerMode.vector,
                // Caché de dibujo junto al mapa (se borra con él). `dynamic`
                // porque el tipo `Directory` de vector_map_tiles depende de
                // la plataforma.
                cacheFolder: () async {
                  final dir = Directory('$carpeta/cache');
                  if (!dir.existsSync()) await dir.create(recursive: true);
                  return dir as dynamic;
                },
              ),
              if (casa != null && d.zona != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: casa,
                      radius: d.zona!.radio.toDouble(),
                      useRadiusInMeter: true,
                      color: c.verde.withValues(alpha: 0.14),
                      borderColor: c.verde,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              if (rastro.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: rastro,
                      strokeWidth: 4,
                      color: c.morado.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              if (ella != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: ella,
                      radius: d.ultima!.precision,
                      useRadiusInMeter: true,
                      color: c.azul.withValues(alpha: 0.16),
                      borderColor: c.azul.withValues(alpha: 0.6),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (casa != null)
                    Marker(
                      point: casa,
                      width: 28,
                      height: 28,
                      child: _Pin(
                        icono: CupertinoIcons.house_fill,
                        fondo: c.verde,
                        color: c.sobreVerde,
                      ),
                    ),
                  if (ella != null)
                    Marker(
                      point: ella,
                      width: 22,
                      height: 22,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.azul,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(blurRadius: 3, color: Color(0x55000000)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Column(
            children: [
              _BotonMapa(
                clave: ClavesUi.mapaCentrarElla,
                icono: CupertinoIcons.location_fill,
                etiqueta: l.mapaCentrarElla,
                alPulsar: ella == null ? null : () => _centrar(ella),
              ),
              const SizedBox(height: 8),
              _BotonMapa(
                clave: ClavesUi.mapaCentrarCasa,
                icono: CupertinoIcons.house_fill,
                etiqueta: l.mapaCentrarCasa,
                alPulsar: casa == null ? null : () => _centrar(casa),
              ),
            ],
          ),
        ),
        if (!dentro)
          Positioned(
            left: 8,
            right: 60,
            top: 8,
            child: _Aviso(texto: l.mapaFuera, compacto: true),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Semantics(
            link: true,
            label: l.mapaAtribucionSemantica,
            excludeSemantics: true,
            child: Material(
              color: c.tarjeta.withValues(alpha: 0.92),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
              ),
              child: InkWell(
                key: ClavesUi.mapaAtribucion,
                onTap: d.alAtribucion,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        l.mapaAtribucion,
                        style: t.bodySmall?.copyWith(
                          fontSize: 13,
                          color: c.texto,
                        ),
                      ),
                    ),
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

class _Pin extends StatelessWidget {
  const _Pin({required this.icono, required this.fondo, required this.color});

  final IconData icono;
  final Color fondo;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: fondo,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Icon(icono, size: 15, color: color),
  );
}

class _BotonMapa extends StatelessWidget {
  const _BotonMapa({
    required this.clave,
    required this.icono,
    required this.etiqueta,
    required this.alPulsar,
  });

  final Key clave;
  final IconData icono;
  final String etiqueta;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Semantics(
      button: true,
      enabled: alPulsar != null,
      label: etiqueta,
      excludeSemantics: true,
      child: Material(
        color: c.tarjeta,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          key: clave,
          customBorder: const CircleBorder(),
          onTap: alPulsar,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icono,
              size: 22,
              color: alPulsar == null ? c.textoSecundario : c.azul,
            ),
          ),
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto, this.compacto = false});

  final String texto;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return Material(
      color: compacto ? c.tarjeta.withValues(alpha: 0.95) : c.rellenoSuave,
      borderRadius: BorderRadius.circular(compacto ? 10 : 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: c.texto),
          ),
        ),
      ),
    );
  }
}
