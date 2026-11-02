# NACHO · ADR-0008 · Vídeos y fotos de comprobación por el cartero, en trozos cifrados y sin Storage

Fecha: 2026-11-02. Estado: aceptada (orden del promotor: "hazlo tú todo"). Matiza el ADR-0003 en lo que decía de Storage.

## NACHO · Contexto
El móvil de la persona graba 10 s de vídeo (o una foto) tras la toma. La familia solo veía el recuento
("clip grabado"), nunca el vídeo. El ADR-0003 preveía un bucket privado de Storage de Supabase, pero sus
políticas no pueden comprobarse hoy: no se sabe si el servicio de Storage pasa la cabecera `x-circulo-token`
a las políticas como hace PostgREST, y el proyecto real aún no tiene el SQL ejecutado.

## NACHO · Alternativas
1. **Storage de Supabase con políticas por cabecera**: lo más limpio para archivos grandes, pero sin verificar;
   si falla habría que montar una función con `service_role` que firme URLs, y desplegarla exige un token de
   acceso del promotor. Descartada por ahora.
2. **Meter el vídeo entero en un sobre**: imposible, el sobre tiene un tope de 90 000 caracteres.
3. **Trozos en la propia tabla `sobres`**: funcionaría, pero cada móvil bajaría todos los vídeos al sincronizar.
4. **Tabla aparte `clips_trozos` con la misma RLS por cabecera y descarga perezosa** (elegida): el sobre
   `clip_grabado` lleva `clipId`, `total`, `bytes`, `mime` y el SHA-256; los trozos solo se bajan cuando
   alguien toca «Ver vídeo». Todo es SQL que ya sabemos probar en local.

## NACHO · Decisión
- Tabla `public.clips_trozos` (`circulo_token`, `clip_id`, `n`, `total` entre 1 y 64, `nonce`, `contenido`
  base64 ≤ 90 000, `creado_en`), clave primaria `(clip_id, n)`, solo insertar y leer con anon, RLS por
  cabecera como `sobres`. Caducidad a 7 días por un disparador `security definer` tras cada inserción;
  `pg_cron` solo si está disponible, sin romper el script si no lo está.
- Cada trozo de 64 KiB va cifrado con AES-256-GCM, clave HKDF de la clave del círculo con etiqueta
  `newera/v1/clips/aes-256-gcm`, nonce aleatorio y dato asociado `newera/clip/v1|clipId|n|total|versión`
  para que nadie reordene ni mezcle trozos. El SHA-256 del archivo viaja cifrado en el sobre y se comprueba
  al recomponer.
- Grabación más ligera: `camera` 0.12.1 con 15 fps y 500 kbps en `ResolutionPreset.medium`. Medido con
  ffmpeg y vídeo sintético (no con la cámara de un móvil): un clip de 10 s pesa 636–644 KB, 10 trozos; un
  trozo cifrado ocupa 87 404 caracteres. Tope de 4 MB: por encima no se envía y el evento lo anota
  (`omitido: 'tamaño'`).
- Cola local `clips_pendientes` (drift, esquema 3). Antes de subir se pregunta al servidor qué trozos tiene
  y se envían solo los que faltan, en lotes de 5 con `ON CONFLICT DO NOTHING`. El sobre `clip_grabado` sale
  solo cuando todos los trozos están arriba; después se borra el archivo del móvil de la persona (ella no lo
  ve). En la familia, el clip bajado y descifrado vive en `Documentos/clips/` y se borra a los 7 días.
- Las fotos de comprobación siguen el mismo camino («Ver foto»). Visor a pantalla completa con
  `video_player` 2.14.1. Los clips antiguos, sin `clipId`, se ven como antes.
- Se borra solo a los 7 días, no "al entregarse" como decía el ADR-0003: puede haber varios familiares que
  aún no lo han visto.

## NACHO · Consecuencias
- Sin verificar hasta tener el proyecto: el tamaño máximo de petición de Supabase (cada lote pesa unos
  437 KB), que `pg_cron` se active desde el SQL Editor y todo el camino de extremo a extremo.
- Sin verificar en móvil real: que la cámara respete 15 fps y 500 kbps, y que `video_player` reproduzca el clip.
- El cifrado y el hash corren en el hilo principal; con 10 trozos debería bastar.
- Pendiente: excluir `Documents/clips` de la copia de iCloud (Swift); cifrar los archivos en reposo (semana 3).
