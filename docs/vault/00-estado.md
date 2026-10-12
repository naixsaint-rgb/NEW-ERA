# NACHO · Estado del proyecto

Actualizado: 2026-10-12 (sesión 1). Plan vigente: [[planes/PLAN-v3]].

## Dónde estamos
- HIPOTENUSA dada el 12/10/2026 para la semana 1 del plan v3.
- Hecho en esta sesión: investigación (ronda 1, 18 dimensiones; catálogo contrario al consenso, 15 temas,
  647 filas), plan v2 (tres líneas), plan v3 (app de la persona y app de la familia) con las decisiones
  del promotor, repositorio con memoria, bóveda y catálogo.
- Hecho (sesión 1, tarde): app Flutter con dos perfiles, safety_core (35 tests) y app (64 tests) en verde,
  catálogo dentro de la app, CI con demo web y APK, codemagic.yaml. Commit 05e1e81.
- CI en verde (análisis, 99 tests, build web, APK de Android) desde el commit 4d36143; solo falla el despliegue
  a Pages porque Pages no está activado en el repositorio (el token del flujo no puede activarlo).
- Demo web publicada por vía alternativa (artefacto privado de claude.ai) el 12/10/2026; la vía definitiva es
  GitHub Pages en https://naixsaint-rgb.github.io/NEW-ERA/ cuando el promotor lo active.

## Qué sigue (semana 2 del plan v3)
1. Confirmar la demo web publicada y el APK de la CI.
2. AlarmKit real en iOS 26 (capa Swift) y alarma Android con el paquete alarm; voz grabada en la toma.
3. Pendientes de la revisión de Opus: pantalla de error si falla el cifrado, pérdida de clave con base existente,
   excluir vídeos de la copia de iCloud, alarma que sigue sonando mientras se graba el vídeo.
4. Decisión del promotor: en /persona hay más de tres botones a la vez (la especificación pedía tres).

## Bloqueos y pendientes
- Alta en Apple Developer: la familia la hará después de la demo (hoy en desarrollo).
- Orden de familiares para las alarmas: lo fijará el promotor.
- GitHub Pages: hay que activarlo una vez en Settings > Pages > Source: GitHub Actions (el flujo ya despliega solo).
- Conocido en la demo web: aviso "RenderBox was not laid out" en consola al cargar; no bloquea, pero se corrige en la semana 2.
- Sin verificar: que AlarmKit suene en bucle indefinido y acepte audio propio; límites de TestFlight con Apple ID gratuito.

## Preguntas abiertas al promotor
- Orden de familiares para alarmas y quién está de guardia de noche.
