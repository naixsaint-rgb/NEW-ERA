#!/usr/bin/env python3
"""Genera app/assets/catalogo/{catalogo,indice}.json a partir de catalogo/data y catalogo/grupos.

Solo biblioteca estandar. Salida determinista. Codigo 1 si hay incoherencias.
Uso: python3 -I tools/build_catalogo_app.py
"""
import glob
import hashlib
import json
import os
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(RAIZ, 'catalogo', 'data')
GRUPOS = os.path.join(RAIZ, 'catalogo', 'grupos')
SALIDA = os.path.join(RAIZ, 'app', 'assets', 'catalogo')

# Mismo orden que ORDER de tools/build_catalogo.py; el resto, alfabetico.
ORDER = ['cobre_metales', 'psicodelicos', 'nicotina_colinergicos', 'infecciones', 'metabolico_cetonas',
         'luz_energia', 'plantas_tradiciones', 'protocolos_heterodoxos', 'hormonas_peptidos',
         'sangre_plasma_quelacion', 'cuerpo_mente', 'ambiente_toxicos', 'nutricion_alimentos',
         'farmacos_reposicionados', 'relatos_familias']
COLUMNAS = ['id', 'tema', 'grupo', 'intervencion', 'tradicion_o_angulo', 'estudio', 'tipo_fuente', 'diseno', 'n',
            'poblacion', 'duracion', 'dosis_o_protocolo', 'que_midio', 'resultado_reportado',
            'direccion_segun_la_fuente', 'efectos_adversos_reportados', 'financiacion_y_conflictos',
            'como_probarlo_en_casa', 'coste_aprox', 'enlace', 'identificador', 'verificacion']
DIRECCIONES = ['mejora', 'sin cambio', 'empeora', 'mixto', 'no aplica']
# Prefijos de verificacion, como en la hoja "Resumen" de build_catalogo.py
PREF_OK = ('cita encontrada', 'página existe')
PREF_KO = ('cita no encontrada', 'página no accesible')


def error(msg):
    print('ERROR:', msg, file=sys.stderr)
    sys.exit(1)


def vacio(v):
    return v is None or (isinstance(v, str) and v.strip() == '')


def cargar(ruta):
    with open(ruta, 'rb') as f:
        crudo = f.read()
    return crudo, json.loads(crudo.decode('utf-8'))


def main():
    rutas_data = sorted(glob.glob(os.path.join(DATA, '*.json')))
    rutas_grupos = sorted(glob.glob(os.path.join(GRUPOS, '*.json')))
    if not rutas_data:
        error('no hay catalogo/data/*.json')
    sha = hashlib.sha256()
    for r in sorted(rutas_data + rutas_grupos):
        sha.update(open(r, 'rb').read())
    fuente_sha = sha.hexdigest()

    datos = {os.path.basename(r)[:-5]: r for r in rutas_data}
    claves = [k for k in ORDER if k in datos] + sorted(k for k in datos if k not in ORDER)

    temas, filas = [], []
    por_dir, por_tipo = {}, {}
    grupos_res = {}  # (tema, grupo) -> contadores, en orden de primera aparicion
    for pos, k in enumerate(claves):
        _, d = cargar(datos[k])
        rg = os.path.join(GRUPOS, k + '.json')
        if not os.path.exists(rg):
            error(f'falta catalogo/grupos/{k}.json')
        _, g = cargar(rg)
        lista = g.get('grupos') if isinstance(g, dict) else g
        rows = d.get('rows', [])
        if lista is None or len(lista) != len(rows):
            error(f'{k}: grupos ({None if lista is None else len(lista)}) y rows ({len(rows)}) difieren')
        for i, (row, gn) in enumerate(zip(rows, lista)):
            fid = f'{k}-{i:03d}'
            if vacio(row.get('enlace')):
                error(f'{fid}: falta enlace')
            dire = row.get('direccion_segun_la_fuente')
            if dire not in DIRECCIONES:
                error(f'{fid}: direccion desconocida {dire!r}')
            grupo = None if vacio(gn) else gn.strip()
            fila = []
            for c in COLUMNAS:
                if c == 'id':
                    fila.append(fid)
                elif c == 'tema':
                    fila.append(pos)
                elif c == 'grupo':
                    fila.append(grupo)
                else:
                    v = row.get(c)
                    fila.append(None if vacio(v) else v)
            filas.append(fila)
            por_dir[dire] = por_dir.get(dire, 0) + 1
            tf = row.get('tipo_fuente')
            if not vacio(tf):
                por_tipo[tf] = por_tipo.get(tf, 0) + 1
            if grupo:
                e = grupos_res.setdefault((k, grupo), {'tema': k, 'grupo': grupo, 'n': 0,
                                                       **{x: 0 for x in DIRECCIONES},
                                                       'citas_encontradas': 0, 'citas_no_encontradas': 0})
                e['n'] += 1
                e[dire] += 1
                ver = (row.get('verificacion') or '').lower()
                if ver.startswith(PREF_KO):
                    e['citas_no_encontradas'] += 1
                elif ver.startswith(PREF_OK):
                    e['citas_encontradas'] += 1
        temas.append({'key': k, 'titulo': d.get('title', k), 'n_filas': len(rows),
                      'dosier': d.get('dosier', {})})

    catalogo = {'esquema': 1, 'fuente_sha256': fuente_sha, 'columnas': COLUMNAS, 'temas': temas, 'filas': filas}
    texto = json.dumps(catalogo, ensure_ascii=False, separators=(',', ':'))
    cat_bytes = (texto + '\n').encode('utf-8')

    ordenar = lambda dic: dict(sorted(dic.items(), key=lambda kv: (-kv[1], kv[0])))
    indice = {'esquema': 1, 'catalogo_sha256': hashlib.sha256(cat_bytes).hexdigest(),
              'total_filas': len(filas),
              'temas': [{'key': t['key'], 'titulo': t['titulo'], 'n_filas': t['n_filas']} for t in temas],
              'por_direccion': ordenar(por_dir), 'por_tipo_fuente': ordenar(por_tipo),
              'grupos': list(grupos_res.values())}
    os.makedirs(SALIDA, exist_ok=True)
    with open(os.path.join(SALIDA, 'catalogo.json'), 'wb') as f:
        f.write(cat_bytes)
    with open(os.path.join(SALIDA, 'indice.json'), 'wb') as f:
        f.write((json.dumps(indice, ensure_ascii=False, separators=(',', ':')) + '\n').encode('utf-8'))
    print(f'catalogo.json: {len(filas)} filas, {len(temas)} temas, {len(cat_bytes)} bytes')


if __name__ == '__main__':
    main()
