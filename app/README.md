# NEW-ERA · app

Un solo código Flutter con dos perfiles (persona y familia) para Android, iOS y web. Licencia Apache-2.0.
Flutter 3.47.x estable (Dart 3.13). Versiones resueltas de los paquetes: `pubspec.lock` (versionado).

**Aviso:** la demo web no está cifrada y no admite datos reales. Solo datos de ejemplo.

## Preparación

Desde `app/`:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # código de drift
python3 -I ../tools/build_catalogo_app.py                  # catálogo (ver abajo)
python3 -I ../tools/fetch_web_sqlite.py                    # solo web: sqlite3.wasm y drift_worker.js
```

## Ejecutar en local

- **Web (Chrome):** `flutter run -d chrome`. Necesita `web/sqlite3.wasm` y `web/drift_worker.js`.
- **Android:** con un móvil o emulador, `flutter run -d <id>` (`flutter devices`). APK de depuración: `flutter build apk --debug`.
- **iOS (simulador, solo macOS con Xcode):** `open -a Simulator` y `flutter run -d <id>`. En un iPhone real con Apple ID gratuito, firma en Xcode (`ios/Runner.xcworkspace`); la app caduca a los 7 días.
- **Tests:** `flutter test` en `app/` y `dart test` en `app/packages/safety_core`. Análisis: `flutter analyze --no-fatal-infos`.

## Regenerar el catálogo

`catalogo/data/*.json` y `catalogo/grupos/*.json` son la fuente. Desde la raíz del repositorio:

```bash
python3 -I tools/build_catalogo_app.py
```

Escribe `app/assets/catalogo/catalogo.json` e `indice.json` (salida determinista, solo biblioteca estándar). Sale con código 1 si `grupos` y `rows` difieren en longitud, falta un `enlace` o hay una dirección desconocida. Los archivos generados se versionan; la CI comprueba con `git diff --exit-code` que están al día.

## CI (`.github/workflows/ci.yml`)

Se dispara con push a `main` y a `claude/alzheimer-caregiver-app-uxrrni`, con pull requests a `main` y a mano (`workflow_dispatch`).

1. `pruebas`: regenera el catálogo y comprueba que no hay diferencias; `pub get`; `build_runner` y comprobación de diferencias; `flutter analyze`; `flutter test`; `dart analyze` y `dart test` de `safety_core`.
2. `web`: `flutter build web --release --base-href /NEW-ERA/`, comprueba la salida y la sube como artefacto de Pages.
3. `desplegar`: solo en push; publica en GitHub Pages.
4. `apk`: `flutter build apk --debug` y sube `newera-debug-apk` (14 días).

iOS: `codemagic.yaml` (flujo `ios-simulador`, sin firma). Hace falta una cuenta de Codemagic conectada al repositorio; el flujo firmado está comentado hasta que haya cuenta de Apple Developer.

## Activar GitHub Pages

En el repositorio: Settings > Pages > Source: **GitHub Actions**. Si el entorno `github-pages` rechaza la rama de trabajo, añadirla en Settings > Environments > github-pages > Deployment branches. La demo queda en `https://naixsaint-rgb.github.io/NEW-ERA/`.
