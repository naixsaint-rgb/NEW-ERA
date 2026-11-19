# NACHO · ADR-0013 · Mapa de calles descargado en el móvil, sin teselas remotas

Fecha: 2026-11-19. Estado: aceptada (HIPOTENUSA del promotor del 19/11/2026 para el mapa).

## NACHO · Contexto
El promotor pidió un mapa propio para ubicarla. Un mapa en línea pide trozos a un servidor cada vez que se
mueve, y ese servidor ve qué calles se miran. La regla del proyecto es que nada de la familia salga fuera.

## NACHO · Alternativas
1. **Mapa en línea de tile.openstreetmap.org**: sus normas prohíben la descarga masiva y el uso sin conexión,
   y cada consulta delata la zona. Descartada. ([política](https://operations.osmfoundation.org/policies/tiles/))
2. **`flutter_map_tile_caching`**: licencia GPL-3.0, incompatible con Apache-2.0 del proyecto. Descartada.
3. **Solo enlace a la app de mapas del móvil**: es lo que había (ADR-0012); se mantiene como botón.
4. **Mapa generado una vez en el PC del promotor y copiado a mano**: no publica nada, pero es manual.
5. **Mapa vectorial PMTiles descargado una vez por comunidad autónoma** (elegida): la app solo lee un
   archivo local; lo único que se ve desde fuera es qué comunidad se descargó.

## NACHO · Decisión
- Datos: builds diarios de Protomaps (OpenStreetMap, licencia ODbL). «© OpenStreetMap» siempre visible sobre
  el mapa, con enlace a su página de licencia.
- Flujo manual `.github/workflows/mapas.yml` (`workflow_dispatch`, sin permisos arriba y `contents: write` solo
  en su job, sin acciones de terceros): genera un PMTiles por cada una de las 19 comunidades y ciudades
  autónomas con `pmtiles extract` y los sube a la Release `mapas` con un índice (nombre, tamaño, sha256). Si
  un archivo pasa de 1,9 GiB baja el zoom (15, 14, 13); si a zoom 12 no cabe, se para y pide partir por
  provincias. Son todas las comunidades, no solo una, para que el repositorio no diga dónde vive nadie.
- App: `flutter_map` 8.3.2, `vector_map_tiles` 9.0.0-beta.13 y `vector_tile_renderer` 6.1.0 (BSD-3),
  `latlong2` 0.10.1 (Apache-2.0), versiones fijas. Lector PMTiles propio (unas 250 líneas) porque
  `vector_map_tiles_pmtiles` no se puede instalar junto al resto de dependencias; solo abre el archivo local.
  Estilo propio corto, claro y oscuro. Un solo mapa por móvil; descarga reanudable con comprobación de sha256.
- En Ubicación: punto con círculo de precisión, zona «Casa», rastro, centrar en ella o en casa, y pulsación
  larga para fijar «Casa». Un test fija que mover el mapa no abre ninguna conexión.
- En web no hay mapa (los lectores de archivo local no funcionan allí): se ve la pantalla de siempre.

## NACHO · Consecuencias
- 22 tests nuevos (546). Probado solo con un archivo PMTiles mínimo de prueba.
- **Sin verificar, porque desde la sesión no se pudo descargar la herramienta ni leer el build**: cuánto pesa
  cada comunidad y cuánto tarda, si los rótulos y capas salen bien con datos reales (nombres de capas del
  esquema 4 de Protomaps), el sha256 del binario `pmtiles`, y si Protomaps pide atribución propia.
- Riesgos: `vector_map_tiles` es una beta; rendimiento y memoria con archivos de 1 a 2 GB en el iPhone 12 mini.
- Pendiente del promotor: lanzar una vez el flujo «Mapas» en GitHub Actions. Tras la primera ejecución,
  rellenar `PMTILES_SHA256` en el flujo con el valor que imprime.
