# ADR-0003 · Servidor gratuito que solo hace de cartero
Fecha: 2026-10-12 · Estado: aceptada
## Contexto
Coste cero; datos de salud de una familia; varios móviles que deben verse al momento.
## Decisión
Supabase Free en Frankfurt detrás de una capa abstracta. Todo se cifra en el móvil de origen con la clave del
círculo; el servidor guarda y reparte lo cifrado y dispara avisos push con texto genérico. Vídeos borrados del
servidor al entregarse o a los 7 días. Plan B: Supabase autoalojado o PocketBase.
## Consecuencias
EIPD antes de abrir a familias reales. Cambiar de proveedor es migrar una tabla.
