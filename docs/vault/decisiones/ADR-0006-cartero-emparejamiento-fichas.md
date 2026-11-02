# NACHO · ADR-0006 · Cartero cifrado, emparejamiento por código y fichas como eventos

Fecha: 2026-11-02. Estado: aceptada (orden del promotor: "hazlo tú todo").

## NACHO · Contexto
Hasta hoy la app solo vivía en cada móvil. Para que la familia vea lo de la persona hacen falta tres cosas:
un servidor que reparta datos sin poder leerlos (ADR-0003), que dos móviles compartan la misma clave, y que
las fichas (medicamentos, pautas, fotos) viajen, no solo los hechos.

## NACHO · Alternativas
1. **Realtime de Supabase sobre la tabla** (`postgres_changes`): comprueba las políticas con el JWT, no con
   la cabecera del círculo; habría que abrir una política y expondría los sobres de todos los círculos.
2. **Aviso por Broadcast sin datos + consulta por REST** (elegida): un disparador avisa en un canal derivado
   del token; el móvil pide lo nuevo; cada 2 minutos consulta por si falla el aviso.
3. **Emparejar por cuenta de usuario** (correo y contraseña): más seguro frente a copias del código, pero
   obliga a cuentas y correos a cada familiar y a la persona. Descartado por ahora.
4. **Emparejar por código mostrado en persona** (elegida): QR y código `NEWERA1-…` en base 32 con suma de
   comprobación; lleva la clave, así que solo se enseña cara a cara.
5. **Sincronizar tablas de fichas con su propio mecanismo**: duplicaría el cartero. En su lugar, las fichas
   viajan como eventos `ficha_creada` y `ficha_modificada` con la fila completa (elegida).

## NACHO · Decisión
- Sobres AES-256-GCM; de la clave del círculo salen por HKDF el token de círculo (cabecera) y la clave de
  cifrado, con etiquetas distintas. El servidor solo ve el token y bytes.
- Paquete `supabase` (Dart puro), no `supabase_flutter`.
- Fotos dentro del sobre, reducidas (512 px, JPEG) con tope de 45 KB porque el esquema limita el contenido a
  90 000 caracteres; si no caben, la ficha viaja sin foto y lo anota.
- Un móvil que se une borra su base local (iba cifrada con otra clave) tras confirmarlo y recibe todo desde 0.
- URL y clave anon del proyecto en `supabase/proyecto.json` (públicas por diseño); la escritura de secretos
  de GitHub está bloqueada desde la sesión.

## NACHO · Consecuencias
- Dos móviles con el mismo código comparten fichas y hechos en cuanto el SQL esté ejecutado en el proyecto.
- Pendiente: vídeos y fotos grandes por Storage, rotación de clave y expulsar un móvil, segundo plano en iOS,
  nombre del círculo y voces por el cartero.
