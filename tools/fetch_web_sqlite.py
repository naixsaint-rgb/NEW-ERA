#!/usr/bin/env python3
"""Descarga sqlite3.wasm y drift_worker.js a app/web/ segun las versiones de app/pubspec.lock.

Patrones de URL verificados el 12/10/2026 (HTTP 200):
  https://github.com/simolus3/drift/releases/download/drift-<ver>/drift_worker.js
  https://github.com/simolus3/drift/releases/download/drift-<ver>/sqlite3.wasm   (compatible con ese drift)
  https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-<ver>/sqlite3.wasm  (alternativa)

Uso: python3 -I tools/fetch_web_sqlite.py [--drift X.Y.Z] [--sqlite3 X.Y.Z]
Sin lock ni argumentos usa las versiones por defecto de abajo. Sale con 1 si no puede descargar.
"""
import argparse
import os
import re
import sys
import urllib.request

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOCK = os.path.join(RAIZ, 'app', 'pubspec.lock')
DESTINO = os.path.join(RAIZ, 'app', 'web')
DRIFT_DEFECTO = '2.35.2'
SQLITE3_DEFECTO = '3.7.0'


def version_en_lock(paquete):
    if not os.path.exists(LOCK):
        return None
    txt = open(LOCK, encoding='utf-8').read()
    m = re.search(r'^  %s:\n(?:    .*\n)*?    version: "([^"]+)"' % re.escape(paquete), txt, re.M)
    return m.group(1) if m else None


def descargar(urls, destino):
    ultimo = None
    for url in urls:
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                datos = r.read()
            if not datos:
                raise ValueError('respuesta vacia')
            os.makedirs(os.path.dirname(destino), exist_ok=True)
            with open(destino, 'wb') as f:
                f.write(datos)
            print(f'OK {os.path.relpath(destino, RAIZ)} ({len(datos)} bytes) <- {url}')
            return True
        except Exception as e:  # noqa: BLE001
            ultimo = f'{url}: {e}'
            print('fallo', ultimo, file=sys.stderr)
    print('ERROR: no se pudo descargar', os.path.basename(destino), '-', ultimo, file=sys.stderr)
    return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--drift')
    ap.add_argument('--sqlite3')
    a = ap.parse_args()
    drift = a.drift or version_en_lock('drift') or DRIFT_DEFECTO
    sq = a.sqlite3 or version_en_lock('sqlite3') or SQLITE3_DEFECTO
    print(f'drift {drift}, sqlite3 {sq}')
    base_d = f'https://github.com/simolus3/drift/releases/download/drift-{drift}/'
    base_s = f'https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-{sq}/'
    ok = descargar([base_d + 'drift_worker.js'], os.path.join(DESTINO, 'drift_worker.js'))
    ok = descargar([base_d + 'sqlite3.wasm', base_s + 'sqlite3.wasm'], os.path.join(DESTINO, 'sqlite3.wasm')) and ok
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
