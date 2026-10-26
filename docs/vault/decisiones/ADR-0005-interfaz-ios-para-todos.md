# NACHO · ADR-0005 · Interfaz iOS para todos, con tres pantallas distintas para la persona

Fecha: 2026-10-26. Estado: aceptada (TRIÁNGULO del promotor).

## NACHO · Contexto
La primera versión de la app (semana 1) era funcional pero el promotor la encontró "no muy agradable". Pidió una
interfaz "más bonita tipo Apple iOS para todos", con la de la persona más sencilla, y opciones antes de tocar nada.
Se le presentaron tres direcciones con maquetas (A "Ajustes", B "Salud", C "Noche") y una propuesta de conjunto.

## NACHO · Alternativas
1. **Material 3 tal cual** (lo que había): rápido, pero con aspecto Android en el iPhone de la persona y en los de la familia.
2. **Widgets Cupertino puros**: aspecto iOS exacto en iPhone, pero muchos componentes (listas agrupadas, barra de
   pestañas, formularios) habría que rehacerlos a mano y en Android se ven extraños.
3. **Material 3 con tema y componentes propios de aspecto iOS** (elegida): mismo código en iPhone, Android y web; la
   letra del sistema en cada plataforma; componentes propios pequeños (`lib/shared/ios/`) que reproducen las maquetas.

## NACHO · Decisión
- Opción 3. Tema claro y oscuro de la familia con los tokens de `docs/vault/specs/interfaz-ios.md`; la persona
  siempre en claro y con texto grande.
- Se usan las tres direcciones a la vez, cada una donde encaja: A en Hoy y en el inicio de la persona; B en Resumen
  y en la pantalla de toma; C como modo noche de la familia y como pantalla de pregunta de la persona.
- Cinco pestañas de familia (Hoy, Resumen, Medicación, Alimentación, Ideas y tablas) y "Más" arriba a la derecha.
- Hoy lleva Ayer · Hoy · Mañana · Semana. La foto de cada pastilla la hace la familia una vez y aparece en todas
  partes (alarma, pastillero, lista, vídeo de comprobación).
- Mínimos de texto: familia 13 pt (antes 16) para permitir jerarquía; persona 19 pt (antes 28) en secundarios, con
  los principales entre 24 y 76. El contraste 4,5:1 y los objetivos táctiles de 44 (familia) y 64 (persona) no cambian.

## NACHO · Consecuencias
- Los datos, el cifrado, el catálogo, las alarmas y `safety_core` no cambian; solo la capa visual y las rutas nuevas.
- Lo que no existe aún (pulso, pasos, sueño, control por horas) se muestra como "llega en la semana N", sin cifras.
- La pantalla de pregunta existe solo en modo prueba hasta la semana 5 del plan v3.
