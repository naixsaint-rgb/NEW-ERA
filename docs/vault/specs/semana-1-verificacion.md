# NACHO · Semana 1: verificación de los criterios de hecho

12/10/2026 · Integrador. Contrato: [[specs/semana-1-app]] sección 12. Desviaciones: [[specs/semana-1-desviaciones]]. Lo repite `tools/comprobar_semana1.sh` (código 0 con todo lo comprobable aquí).

## NACHO · Criterios

|Criterio|Resultado|Cómo se comprobó|
|---|---|---|
|1. `flutter analyze --no-fatal-infos` y `dart analyze` en `safety_core` con 0|Cumple|`No issues found!` en los dos|
|2. `flutter test` y `dart test` en verde, 10 o más|Cumple: 64 + 35 = 99, 0 fallos|`flutter test --reporter json` y `dart test --reporter json`, contando `testDone` visibles. Existen todos los archivos de test que cita la sección 12|
|3. `flutter build web --release --base-href /NEW-ERA/` genera `index.html`, `sqlite3.wasm`, `drift_worker.js` y el catálogo|Cumple|Build terminado (45 MB). Presentes `build/web/{index.html,sqlite3.wasm,drift_worker.js,assets/assets/catalogo/catalogo.json,indice.json,assets/assets/audio/tono_alarma.wav}`|
|4. La demo muestra perfil, banner, `/persona`, `/persona/toma/:id`, las 10 pestañas con datos de ejemplo; el catálogo filtra y abre fichas|Cumple en local, sin verificar en la URL publicada|`build/web` servido con `python3 -m http.server` bajo `/NEW-ERA/` y abierto con Chromium (Playwright). Capturas en `capturas/`: elección de perfil con banner, `/persona` con "Lo siguiente", "Mi gente" y "Necesito ayuda", familia a 1280 px con las 10 pestañas, Hoy con semáforo naranja y tomas de ejemplo, Ideas y tablas con 647 filas y los cinco filtros de dirección. `/persona/toma/:id`, la ficha y el filtro del catálogo: por tests de widget (`persona_widget_test`, `catalogo_widget_test`)|
|5. `flutter build apk --debug` termina y se sube|Sin comprobar aquí|No hay Android SDK. Lo hará el job `apk` de la CI. `tono_alarma.wav` ya existe, que el APK lo necesita|
|6. `git diff --exit-code` limpio tras regenerar catálogo y drift|Cumple (equivalente)|Los archivos aún no están en git; se compara la huella sha256 de los `*.json` de catálogo y los `*.g.dart` antes y después de regenerar: idéntica. `build_runner` escribe 0 salidas|

## NACHO · Comprobaciones del integrador

- `python3 -I tools/build_catalogo_app.py`: 647 filas, 15 temas, 623 696 bytes, salida idéntica a la que había. El cargador de la app comprueba el `catalogo_sha256` de `indice.json` contra `catalogo.json` y usa el esquema de la sección 7 (`columnas`, `temas`, `filas`), así que no hizo falta cambiar el script ni el cargador.
- `python3 -I tools/fetch_web_sqlite.py`: `drift_worker.js` (360 104 bytes) y `sqlite3.wasm` (750 007 bytes) de la release `drift-2.35.2`, versiones de `pubspec.lock`.
- Faltaban `tools/generar_tono.py`, `app/assets/audio/tono_alarma.wav`, `tools/comprobar_semana1.sh` y la línea de `.gitignore`: los he creado yo (880 Hz, 2 s, mono, 22 050 Hz, salida determinista).

## NACHO · Chromium y consola

Chromium (`/opt/pw-browsers/chromium-1194`) funciona. Con `--headless --screenshot` a secas la captura sale en blanco porque se toma antes de que cargue Flutter; por eso se usó Playwright, esperando 12-15 s. La consola no muestra ningún error fatal. Solo aparece `Bad state: RenderBox was not laid out` (recorrido de foco del framework, también en la pantalla de perfil), ya anotado en las desviaciones, y avisos de rendimiento de WebGL por usar renderizado por software.

## NACHO · Pendiente

- APK de depuración, build de iOS, SQLCipher en móvil, cámara y alarmas en móvil real.
- Publicar en GitHub Pages (origen "GitHub Actions") y mirar la URL.
- Tipografía Roboto pedida a `fonts.gstatic.com` al arrancar.
- Revisar el error `RenderBox was not laid out` de consola.
- Decidir si se anota como desviación que `sqlite3.wasm` sale de la release de drift y no de `sqlite3.dart` (hay respaldo en `sqlite3.dart`).

## NACHO · Verificación final (12/10/2026, tras la revisión)

`flutter pub get` y `build_runner` sin errores; `flutter analyze`: No issues found; `flutter test`: 64 en verde (más 35 de `safety_core`); `flutter build web --release --base-href /NEW-ERA/` correcto, `build/web` 45 MB; `build_catalogo_app.py`: 647 filas, 15 temas, 623 696 bytes. La URL publicada sigue sin verificar. Pendiente del promotor: más de tres botones en `/persona` frente a la especificación.
