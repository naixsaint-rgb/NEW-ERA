# CLAUDE.md · Memoria del proyecto NEW-ERA

Lee esto entero antes de hacer nada. Después lee `docs/vault/00-estado.md`.

## Qué es este proyecto
Dos apps sobre un mismo sistema para una persona con Alzheimer y su familia, pensadas desde el
principio para muchas familias. Plan vigente: `docs/vault/planes/PLAN-v3.md`. Catálogo de
estudios: `catalogo/`. Decisiones del promotor: `docs/vault/01-promotor/`.

## Palabras clave del promotor (obligatorias)
- **HIPOTENUSA**: autoriza a escribir código o tocar el repositorio. Sin ella, solo se planifica,
  se investiga y se explica. Se dio el 12/10/2026 para la semana 1 del plan v3.
- **ENOLA**: parar todo y explicar con detalle qué se estaba haciendo, por qué y qué falta.
- **NACHO**: cada respuesta al promotor empieza por NACHO (una vez por respuesta). En documentos,
  el título y los encabezados `##` empiezan por "NACHO · ". Es un canario de memoria.

## Postura de investigación (la fija el promotor; no se discute)
- El promotor investiga por su cuenta y saca sus propias conclusiones. Nadie de la industria médica
  o farmacéutica hace de juez, ni ningún agente con ese papel. Sin "niveles de evidencia", sin
  "no funciona", sin descartar nada por pequeño, antiguo, animal, heterodoxo o anecdótico.
- Si un estudio reporta una mejora, va a la tabla con su cifra tal cual, su dirección según la
  propia fuente, quién lo pagó y su enlace. Seguir el dinero. Buscar donde el consenso no mira.
  Rescatar lo enterrado (ensayos sin resultados, tratamientos abandonados por baratos).
- La única regla propia: **no inventar**. Lo que no exista no aparece. Cada afirmación lleva enlace.
  La comprobación es documental (la cita existe, la cifra aparece), nunca un juicio.
- La app no promete curas: presenta lo que cada fuente reporta y deja probar y medir.

## Reglas de trabajo
- Coste cero o casi cero en servicios. Lo inevitable: Google Play 25 USD, Apple Developer 99 USD/año
  (o exención ONG). El hardware lo compra la familia.
- Regla máxima de modelos: Fable piensa y orquesta; Opus diseña datos, cifrado, consentimientos y
  lo crítico; Sonnet investiga y construye; Haiku consolida, formatea y comprueba citas. Cada uno
  hace lo que mejor se le da gastando menos tokens. Recuentos y agregados los hace Python.
- Respuestas al promotor: cortas, en español de España, sin sermones. Él decide la línea.
- No se hacen preguntas sobre su familiar concreto; se toman decisiones de producto con valores por
  defecto que él puede cambiar.
- Nada de datos reales de la familia en el repositorio ni en prompts: nombres, diagnóstico, audios,
  vídeos, exportaciones. `.gitignore` y revisión antes de cada commit.
- Commits en castellano, Conventional Commits con ámbito: `feat(medicacion): ...`.
- Rama de trabajo: `claude/alzheimer-caregiver-app-uxrrni`. Nunca se hace push a otra rama sin permiso.

## Decisiones vigentes (12/10/2026, detalle en docs/vault/01-promotor/)
- Persona: iPhone 12 mini (admite iOS 26 → AlarmKit). Reloj: Apple Watch. App de familia: Android e iPhone.
- Voces: grabadas por familiares; clonación viable (hay PC con GPU NVIDIA), fase posterior, Chatterbox (MIT).
- Alarma de pastilla: la apaga el botón; comprobación por vídeo de 10 s; NFC opción futura.
- Pastillero semanal que llena la familia. Control por horas de 9 a 21, tres preguntas cada hora, ajustable.
- Escalado por defecto: familiar 1 a los 5 min, familiar 2 a los 10. El orden lo fijará el promotor.
- Web de referencia del promotor: Open Negative Results Registry ("Dark Data Medicine",
  github.com/Ciprian-LocalPulse/open-negative-results-registry). Examine.com y GreenMedInfo como fuentes.

## Estructura del repositorio
- `app/` Flutter, un solo código, dos perfiles (persona y familia), Android, iOS y web. Licencia Apache-2.0.
- `app/ios/` capa nativa Swift (AlarmKit, Acceso Asistido). `watch/` app watchOS (Swift) cuando toque.
- `catalogo/data/*.json` los 15 temas verificados (una fila por estudio); `catalogo/grupos/` nombres
  canónicos; `catalogo/out/` Excel y markdown; `tools/build_catalogo.py` los regenera.
- `docs/vault/` bóveda Obsidian: `00-estado.md`, `01-promotor/`, `decisiones/ADR-NNNN.md`,
  `planes/`, `investigacion/`, `catalogo/`, `sesiones/`, `specs/`, `glosario.md`.
- `.github/workflows/` CI: análisis, tests, web a GitHub Pages, APK de Android. `codemagic.yaml` para iOS.

## Ritual de sesión
1. Leer `CLAUDE.md` y `docs/vault/00-estado.md`.
2. Decir al promotor en una línea qué se va a hacer (empezando por NACHO).
3. Trabajar por entregas pequeñas; commit y push de cada una.
4. Al cerrar: actualizar `00-estado.md` y escribir `docs/vault/sesiones/AAAA-MM-DD.md`.
   Cada decisión con alternativas → un ADR nuevo.

## Líneas que no se cruzan
- No inventar datos, cifras, URLs ni precios. Lo no verificado se marca "sin verificar".
- No prometer curas en textos de la app ni de las tiendas.
- No subir datos reales. No usar IA en la nube con datos de la familia.
- No tocar el repo sin HIPOTENUSA para la tarea en curso.
