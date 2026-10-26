# NACHO · Estado del proyecto

Actualizado: 2026-10-26 (sesión 2). Plan vigente: [[planes/PLAN-v3]]. Interfaz: [[specs/interfaz-ios]].

## Dónde estamos
- HIPOTENUSA dada el 12/10/2026 para la semana 1 del plan v3.
- Hecho en esta sesión: investigación (ronda 1, 18 dimensiones; catálogo contrario al consenso, 15 temas,
  647 filas), plan v2 (tres líneas), plan v3 (app de la persona y app de la familia) con las decisiones
  del promotor, repositorio con memoria, bóveda y catálogo.
- Hecho (sesión 1, tarde): app Flutter con dos perfiles, safety_core (35 tests) y app (64 tests) en verde,
  catálogo dentro de la app, CI con demo web y APK, codemagic.yaml. Commit 05e1e81.
- CI en verde (análisis, 99 tests, build web, APK de Android) desde el commit 4d36143; solo falla el despliegue
  a Pages porque Pages no está activado en el repositorio (el token del flujo no puede activarlo).
- Demo web servida desde el repo con githack (carpeta demo/web, base href relativa) mientras Pages no está activo:
  https://rawcdn.githack.com/naixsaint-rgb/NEW-ERA/b4d375777cd0ffceedac249a1ba8df092f89b661/demo/web/index.html
  (githack muestra un aviso "One more step" la primera vez; hay que pulsar "Open the page"). El artefacto de claude.ai
  no sirve: su visor bloquea WebAssembly o los workers y la app queda en blanco. La vía definitiva sigue siendo
  GitHub Pages en https://naixsaint-rgb.github.io/NEW-ERA/ cuando el promotor lo active; entonces se borra demo/web.

- Sesión 2 (26/10): el promotor pidió una interfaz "tipo Apple iOS" para todos y más sencilla para la persona.
  Vio tres opciones con maquetas y una propuesta de conjunto, dijo que se usen todas y dio **TRIÁNGULO**.
  Hecho: tema claro y oscuro con tokens, ajuste de aspecto (automático, claro, oscuro, noche 22–08), componentes
  iOS (`app/lib/shared/ios/`), cinco pestañas (Hoy, Resumen, Medicación, Alimentación, Ideas y tablas) con botón
  "Más", Hoy con Ayer · Hoy · Mañana · Semana, Resumen con cifras reales, Medicación con pastillero semanal y
  pastillas con foto, persona (inicio, Mis pastillas, toma) y pregunta en modo prueba. 155 tests en verde.
  ADR-0005. Capturas de cada pantalla en `specs/capturas-ios/`.
- Pendiente de la sesión 2: lo que no existe sigue marcado "llega en la semana N" (pulso, pasos y sueño con el reloj;
  control por horas en la semana 5; voces grabadas). La pantalla de pregunta no guarda nada hasta la semana 5.

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
- La demo web ya no depende de gstatic.com para el motor gráfico (CanvasKit va en la propia carpeta).
- Chromium sin cabeza sin idioma del sistema anuncia "en-US@posix" y el motor web de Flutter falla al arrancar;
  no afecta a navegadores reales. El guion de capturas fija el idioma es-ES.
- Sin verificar: que AlarmKit suene en bucle indefinido y acepte audio propio; límites de TestFlight con Apple ID gratuito.

## Preguntas abiertas al promotor
- Orden de familiares para alarmas y quién está de guardia de noche.
