#!/usr/bin/env bash
# Comprueba los criterios de hecho de la sección 12 de docs/vault/specs/semana-1-app.md.
# Código 0 solo si se cumple todo lo que se puede comprobar en esta máquina.
# El criterio 5 (APK) se omite si no hay Android SDK y se avisa; con CI_APK=1 es obligatorio.
set -u
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
cd "$RAIZ" || exit 1
export PATH="/home/user/tools/flutter/bin:$PATH"
fallos=0
ok()   { echo "OK    $1"; }
falla() { echo "FALLA $1"; fallos=$((fallos + 1)); }
huella() { find app/assets/catalogo app/lib -name '*.json' -o -name '*.g.dart' | sort | xargs sha256sum | sha256sum; }

antes="$(huella)"
python3 -I tools/build_catalogo_app.py >/dev/null && ok "catálogo regenerado" || falla "catálogo no se regenera"
( cd app && flutter pub get >/dev/null 2>&1 && dart run build_runner build --delete-conflicting-outputs >/dev/null 2>&1 ) \
  && ok "pub get y build_runner" || falla "pub get o build_runner"
[ "$antes" = "$(huella)" ] && ok "6. regenerar catálogo y drift no cambia nada" || falla "6. la regeneración cambia archivos"

( cd app && flutter analyze --no-fatal-infos >/dev/null 2>&1 ) && ok "1. flutter analyze" || falla "1. flutter analyze"
( cd app/packages/safety_core && dart pub get >/dev/null 2>&1 && dart analyze >/dev/null 2>&1 ) \
  && ok "1. dart analyze (safety_core)" || falla "1. dart analyze (safety_core)"

contar() { python3 -I -c '
import json,sys
n=bad=0
for l in sys.stdin:
    try: e=json.loads(l)
    except ValueError: continue
    if e.get("type")=="testDone" and not e.get("hidden"):
        n+=1
        bad+= e["result"]!="success"
print(n,bad)'; }
read -r na fa < <(cd app && flutter test --reporter json 2>/dev/null | contar)
read -r ns fs < <(cd app/packages/safety_core && dart test --reporter json 2>/dev/null | contar)
echo "      tests app: $na (fallos $fa); safety_core: $ns (fallos $fs)"
[ "${fa:-1}" = 0 ] && [ "${fs:-1}" = 0 ] && [ $(( ${na:-0} + ${ns:-0} )) -ge 10 ] \
  && ok "2. tests en verde y 10 o más" || falla "2. tests"

( cd app && flutter build web --release --base-href /NEW-ERA/ >/dev/null 2>&1 ) && {
  for f in index.html sqlite3.wasm drift_worker.js assets/assets/catalogo/catalogo.json; do
    [ -s "app/build/web/$f" ] || falla "3. falta build/web/$f"
  done
  ok "3. flutter build web"
} || falla "3. flutter build web"

if command -v java >/dev/null 2>&1 && { [ -n "${ANDROID_HOME:-}" ] || [ -n "${ANDROID_SDK_ROOT:-}" ]; }; then
  ( cd app && flutter build apk --debug >/dev/null 2>&1 ) && ok "5. flutter build apk --debug" || falla "5. flutter build apk --debug"
elif [ "${CI_APK:-0}" = 1 ]; then
  falla "5. no hay Android SDK"
else
  echo "OMITE 5. flutter build apk --debug (no hay Android SDK; lo hace la CI)"
fi

echo "4. La demo publicada se mira a mano en la URL (los tests de widget cubren el contenido)."
[ "$fallos" = 0 ] && { echo "TODO OK"; exit 0; } || { echo "$fallos fallo(s)"; exit 1; }
