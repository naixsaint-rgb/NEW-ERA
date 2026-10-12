# NACHO · Especificación técnica de la semana 1: app, CI y herramientas

12/10/2026 · HIPOTENUSA dada · Base: [[planes/PLAN-v3]] (1, 2, 3, 6, 9, 10). Contrato para dos agentes en paralelo en `claude/alzheimer-caregiver-app-uxrrni`. Lo que no está aquí no se construye; si choca con el plan, esta semana manda esto.

## NACHO · 0. Reparto y reglas

|Agente|Es dueño de|
|---|---|
|A · app|`app/**` salvo lo de B|
|B · CI y herramientas|`.github/workflows/ci.yml`, `codemagic.yaml`, `tools/build_catalogo_app.py`, `tools/generar_tono.py`, `tools/fetch_web_sqlite.py`, `tools/comprobar_semana1.sh`, `app/assets/catalogo/`, `app/assets/audio/tono_alarma.wav`, `app/README.md` y una línea de `.gitignore`|

- B entrega primero catálogo y tono; A ejecuta `tools/fetch_web_sqlite.py` tras su primer `flutter pub get` y versiona lo descargado.
- Commits en castellano con ámbito (`feat(toma): …`); `git pull --rebase` antes de cada push. Solo datos ficticios.
- Flutter local: `/home/user/tools/flutter/bin/flutter` (3.47.7, Dart 3.13.5). Desde la raíz: `flutter create --org io.github.naixsaintrgb --project-name newera --platforms android,ios,web app`. Identificador `io.github.naixsaintrgb.newera`, nombre `NEW-ERA`, Android `minSdk = 24`, iOS con el mínimo de la plantilla (nunca 26; AlarmKit tras `if #available(iOS 26.0, *)`).
- `pubspec.lock` se versiona; `environment: sdk: ^3.13.0`, `flutter: ">=3.47.0"`.

## NACHO · 1. Stack y paquetes

Se añaden con `flutter pub add` (última estable compatible); el mínimo es un suelo que ya existe. A copia las versiones resueltas en `app/README.md`. En CI, Flutter 3.47.x con `subosito/flutter-action`.

|Paquete|Mínimo|Uso|
|---|---|---|
|go_router|14.0.0|Rutas, `StatefulShellRoute.indexedStack`, redirección por perfil|
|flutter_riverpod|3.0.0|Estado: `Provider`, `FutureProvider`, `StreamProvider`, `Notifier`, `AsyncNotifier`; sin API heredada ni generador|
|drift|2.20.0|Base tipada y reactiva; web con WASM|
|drift_dev, build_runner (dev)|menor de drift / 2.4.0|Único generador de código|
|sqlcipher_flutter_libs|0.6.0|SQLCipher en Android e iOS|
|sqlite3|2.4.0|`open.overrideFor` en Android|
|flutter_secure_storage|9.2.0|Clave, ids, perfil|
|intl|`any`|Fechas `es_ES` (la fija flutter_localizations)|
|flutter_localizations (SDK)|—|ARB|
|camera|0.11.0|Vídeo frontal (móvil)|
|image_picker|1.1.0|Fotos de caja y pastilla (también web)|
|url_launcher|6.3.0|`tel:` y enlaces del catálogo|
|permission_handler|11.3.0|Cámara, notificaciones, alarma exacta|
|alarm|4.0.0|Alarma en bucle en Android|
|path_provider, path|2.1.5, 1.9.0|Rutas de base y clips|
|uuid|4.5.0|Ids v4|
|timezone|0.9.4|Zonas IANA en `safety_core`|
|flutter_lints, lints, test (dev)|6.0.0, 6.0.0, 1.25.0|Análisis y tests|

**Sin freezed ni json_serializable.** Un solo generador, drift_dev, inevitable para tablas tipadas; modelos `final` inmutables con `==`, `hashCode`, `fromJson` y `toJson` a mano. Compila antes, `safety_core` no necesita build_runner y los agentes no se pisan. Los `*.g.dart` se versionan y la CI comprueba que están al día.

**Se sustituye `sqlite3_flutter_libs`** (y `drift_flutter`, que lo arrastra): choca con `sqlcipher_flutter_libs`. Si `sqlite3` se resuelve en 3.x o posterior y declara innecesarios ambos (build hooks), A usa la vía SQLCipher que documente y lo anota en el README. Contrato: en móvil, `PRAGMA cipher_version` devuelve valor.

**Pospuestos:** flutter_local_notifications (semanas 4-5: escalado y control por horas), record (8 y 12: voces y consultas), reproductor de audio (2: voz en la toma), supabase_flutter (3), cryptography con AES-GCM (3: sobres y clips), flutter_timezone (2; ahora la zona va en la pauta), geolocator (10).

## NACHO · 2. Estructura

```
app/
  pubspec.yaml l10n.yaml analysis_options.yaml README.md
  assets/catalogo/{catalogo,indice}.json  assets/audio/tono_alarma.wav
  store/es-ES/{titulo,descripcion_corta,descripcion}.txt
  lib/ main.dart app.dart
    core/ arranque.dart providers.dart
      db/ tablas.dart base_datos.dart base_datos.g.dart semilla_demo.dart
          conexion/{conexion,nativa,web,no_soportada}.dart
          repositorios/{eventos,medicacion,circulo}_repositorio.dart
      cripto/ almacen_seguro.dart clave_circulo.dart
      sync/ sync_transport.dart sobre_cifrado.dart noop_transport.dart supabase_transport.dart
      tema/ colores.dart tema_persona.dart tema_familia.dart
      i18n/ fechas.dart
      enrutado/ rutas.dart router.dart familia_shell.dart
      plataforma/alarmas/{servicio_alarmas,alarmas_canal,alarmas_android,alarmas_no_disponibles,programador_alarmas}.dart
      plataforma/camara/{camara_comprobacion,camara_movil,camara_simulada}.dart
    l10n/ app_es.arb app_localizations*.dart (generados, versionados)
    features/ perfil persona_inicio toma hoy medicacion calendario consultas alarmas
              voces alimentacion catalogo circulo ajustes control_horas
    shared/ claves_ui.dart
      widgets/{boton_grande,tarjeta_grande,avatar_familiar,etiqueta_estado_toma,aviso_demo,pantalla_proxima_semana}.dart
      pictogramas/pastilla_pictograma.dart
  packages/safety_core/  test/
  ios/Runner/{AlarmasCanal.swift,AppDelegate.swift,Info.plist}
  web/{sqlite3.wasm,drift_worker.js,index.html}
```

Cada `features/<x>/` tiene `<x>_pantalla.dart` y, si hace falta, `datos/` y `dominio/` (`hoy/` se añade: es una pestaña). Ningún widget lleva texto literal: todo sale de `AppLocalizations`. `claves_ui.dart` define las `Key` de los tests: `ClavesUi.loSiguiente`, `necesitoAyuda`, `confirmarToma`, `pestana(slug)`, `filaCatalogo(id)`, `enlaceFicha`.

## NACHO · 3. Paquete `safety_core`

Dart puro, solo depende de `timezone`, tests con `dart test`; la app lo usa con `safety_core: {path: packages/safety_core}`. Exporta:

- `Reloj` (`RelojSistema`, `RelojFijo`); nadie más llama a `DateTime.now()`.
- `Ulid.generar(Reloj, Random)`: 26 caracteres Crockford, 48 bits de tiempo y 80 aleatorios, monótono en el mismo milisegundo.
- `TipoEvento` (4.3), `PautaVersion` y `DiasSemana` (bit 0 lunes … bit 6 domingo; 127, todos).
- `proximasTomas({versiones, desde, hasta})` → `List<TomaPrevista>` ordenada (`id`, `pautaId`, `pautaVersionId`, `medicamentoId`, `previstaPara` UTC, `fechaLocal`, `horaLocal`). Id: `<pautaId>_<yyyyMMdd>_<HHmm>` local. La versión v aporta una toma si `v.activa` y `v.vigenteDesde ≤ previstaPara < siguiente.vigenteDesde`.
- Cambio de hora: hora inexistente → primer instante válido tras el salto; hora repetida → solo la primera vez.
- `EstadoToma {prevista, confirmada, confirmadaSinVideo, noConfirmada, cerradaPorFamiliar}` y `estadoDeToma(toma, eventos, ahora, config)`, en orden: (1) se ignoran los eventos que señala el `corrige_a` de una `anulacion`; (2) con `toma_confirmada`: `confirmada` si hay `clip_grabado` o la pauta dice `ninguna`, si no `confirmadaSinVideo` (gana al cierre aunque llegue tarde); (3) con `toma_cerrada_por_familiar`: `cerradaPorFamiliar`; (4) pasados 30 min: `noConfirmada`; (5) `prevista`.
- `ConfigEscalado` (plan 2.2: minuto 0, aviso; 2, repetir voz y subir volumen; 5, familiar 1; 10, familiar 2 y reloj; 15, llamada del reloj al familiar 1; 30, no confirmada) y `accionesVencidas(previstaPara, ahora, estado, config)`: pasos vencidos si el estado es `prevista` o `noConfirmada`.
- `parteDelDia(hora)`: 06:00-13:59 mañana, 14:00-20:59 tarde, 21:00-05:59 noche.
- `idAlarmaNumerico(String)`: FNV-1a de 32 bits sobre UTF-8, `& 0x7fffffff` (`"p1_20261013_0900"` → 1659551138).
- `inicializarZonas()`: carga `package:timezone/data/latest.dart`.

## NACHO · 4. Modelo de datos (Drift, esquema 1)

Nada derivado se guarda: estado de una toma, última señal o tiempo de respuesta se calculan. Los hechos son de solo inserción y corregir es insertar. Las fichas se actualizan, pero el repositorio escribe en la misma transacción `ficha_modificada` {tabla, id, antes, despues}.

Convenciones: ids `TEXT` (UUID v4; ULID en eventos); tiempos `INTEGER` en ms UTC; JSON en `TEXT`; `?` nulo, `=` por defecto; primera columna, clave primaria; `*_id`, claves ajenas; clase en plural con `@DataClassName` singular (`Eventos` → `Evento`). `AppDatabase(QueryExecutor)` en `core/db/base_datos.dart`, `schemaVersion => 1`.

**Fichas**

|Tabla|Columnas|
|---|---|
|`circulos`|id, nombre, creado_en, version_clave INT=1|
|`personas`|id, circulo_id, alias, foto_id?, zona_horaria=`Europe/Madrid`, creada_en|
|`miembros`|id, circulo_id, nombre, relacion, telefono?, foto_id?, rol (`responsable`/`cuidador`/`apoyo`/`lectura`), orden_escalado INT?, en_mi_gente BOOL=true, creado_en|
|`dispositivos`|id, circulo_id, perfil (`persona`/`familia`), plataforma (`ios`/`android`/`web`), miembro_id?, registrado_en|
|`medicamentos`|id, persona_id, nombre, nombre_para_persona, forma (`redonda`/`ovalada`/`capsula`/`otra`), color?, foto_caja_id?, foto_pastilla_id?, registro_cima?, creado_en, retirado_en?|
|`voces`|id, miembro_id, tipo (`grabada`/`generada`), modelo?, consentimiento_id?, creada_en, retirada_en?|
|`frases`|id, voz_id, texto, uso, audio_ruta?, aprobada BOOL, creada_en|

**Hechos (solo inserción)**

|Tabla|Columnas|
|---|---|
|`fotos`|id, bytes BLOB, mime, creada_en|
|`pautas`|id (de la versión), pauta_id (lógico), version INT, medicamento_id, persona_id, dosis, horas (JSON `["09:00","14:00"]`, ordenadas y sin repetir), dias_semana INT=127, compartimento?, voz_id?, comprobacion (`video`/`foto`/`ninguna`)=`video`, segundos_video INT=10, zona_horaria, vigente_desde, activa BOOL, motivo?, creada_por, creada_en; UNIQUE(pauta_id, version)|
|`tomas`|id (el de `TomaPrevista`), pauta_version_id, persona_id, prevista_para, fecha_local, hora_local, creada_en. **Sin columna de estado.** `INSERT OR IGNORE` al programar su alarma o con su primer evento|
|`comprobaciones`|id, toma_id, clip_evento_ulid, revisor_miembro_id, veredicto (`verificada`/`dudosa`), nota?, revisada_en; vale la última de cada revisor|
|`eventos`|ulid, circulo_id, autor (miembro o persona), dispositivo, tipo, sujeto? (id de toma, medicamento…), ocurrido_en, registrado_en, payload JSON=`{}`, corrige_a?; índices (sujeto, ocurrido_en) y (tipo, ocurrido_en)|
|`preguntas_control`|id, persona_id, tipo (`estado`/`dolor`/`plan`/`si_no`), texto, frase_id?, lanzada_en, origen (`movil`/`reloj`/`cuidador`)|
|`respuestas`|id, pregunta_id, valor JSON, audio_ruta?, respondida_en, origen, latitud REAL?, longitud REAL?|
|`consentimientos`|id, circulo_id, otorgante, en_nombre_de?, sobre (`voz`/`grabacion_consulta`/`video_toma`/`ubicacion`/`datos`), texto_mostrado, documento_foto_id?, otorgado_en, revoca_a?|
|`comidas`|id, persona_id, momento (`desayuno`/`comida`/`merienda`/`cena`/`otro`), cuanto (`todo`/`mitad`/`poco`/`nada`), foto_id?, nota?, ocurrida_en, registrada_por|
|`hidrataciones`|id, persona_id, vasos INT=1, ocurrida_en, registrada_por|

`fotos` se añade al encargo: SQLCipher la cifra sin más trabajo y funciona igual en web. Entran reducidas (`maxWidth: 1280`, `imageQuality: 80`); los vídeos van a `<documentos>/clips/<tomaId>.mp4`. En `onCreate`, cada tabla de hechos recibe disparadores `BEFORE UPDATE` y `BEFORE DELETE` con `SELECT RAISE(ABORT, 'solo_insercion')`.

**Eventos de la semana 1** (en los de toma, `sujeto` es su id): `toma_confirmada` {origen: `movil`/`reloj`/`familiar`}, `clip_grabado` {tipo, ruta, duracionMs}, `clip_fallido` {motivo: `permiso`/`cancelado`/`error`/`no_disponible`}, `toma_cerrada_por_familiar` {motivo}, `alarma_programada` {plataforma}, `alarma_no_programada` {codigo}, `ayuda_pedida`, `llamada_iniciada` {miembroId}, `mensaje_familia` {texto, fotoId?}, `perfil_elegido` {perfil}, `medicamento_creado`, `ficha_modificada` y `anulacion` (con `corrige_a`).

## NACHO · 5. Cifrado y sincronización

- `AlmacenSeguro` (interfaz): `AlmacenSeguroFlutter` sobre flutter_secure_storage (en iOS, `KeychainAccessibility.first_unlock_this_device`, para leer la clave en segundo plano) y `AlmacenSeguroMemoria` para tests. Entradas: `newera.dispositivo.id`, `newera.circulo.id`, `newera.circulo.clave` (64 hex), `newera.circulo.clave.version`, `newera.perfil`.
- `ClaveCirculo.generar()`: 32 bytes de `Random.secure()` en hex. La genera el primer móvil que arranca (esta semana cada móvil es su propio círculo y su usuario, el responsable); en la semana 3, quien entre por invitación la recibirá y re-cifrará con `PRAGMA rekey`. Nunca va a la base, a logs ni a eventos.
- Móvil (`conexion/nativa.dart`): `NativeDatabase.createInBackground(File('<applicationSupport>/newera.db'))`; `isolateSetup`: `open.overrideFor(OperatingSystem.android, openCipherOnAndroid)`; `setup`: `PRAGMA key = "x'<hex>'";`, `PRAGMA cipher_version;` y `PRAGMA foreign_keys = ON;`. Si `cipher_version` sale vacío, `StateError('sqlcipher_no_disponible')`: nunca se sigue sin cifrar.
- Web (`conexion/web.dart`): `WasmDatabase.open(databaseName: 'newera_demo', sqlite3Uri: Uri.parse('sqlite3.wasm'), driftWorkerUri: Uri.parse('drift_worker.js'))`, sin cifrado ni clave (sin COOP/COEP en GitHub Pages, drift usará IndexedDB). Banner fijo `AvisoDemo`: "Demo con datos de ejemplo. Sin cifrar: no escribas datos reales.", con enlace "Cambiar perfil".
- `conexion/conexion.dart`: `export 'no_soportada.dart' if (dart.library.ffi) 'nativa.dart' if (dart.library.js_interop) 'web.dart';`. Tests: `AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true))`.
- Clips: esta semana, en el almacenamiento privado de la app; AES-GCM en la semana 3.

```dart
abstract interface class SyncTransport {
  EstadoTransporte get estado; // desconectado, conectando, conectado, sinConfigurar
  Future<void> conectar();
  Future<ResultadoEnvio> enviar(List<SobreCifrado> sobres); // ulids aceptados y rechazados
  Stream<SobreCifrado> recibidos();
  Future<void> desconectar();
}
final class SobreCifrado { final String ulid, circuloId; final int versionClave; final Uint8List nonce, contenido; }
```

`NoopTransport` (el de `syncTransportProvider` esta semana): siempre `desconectado`, `enviar` no acepta nada, `recibidos()` vacío. `SupabaseTransport(url, claveAnonima)`: esqueleto `sinConfigurar` que lanza `UnimplementedError('semana 3')`, sin paquete de Supabase ni credenciales.

## NACHO · 6. Perfiles, navegación y pantallas

Rutas en `core/enrutado/rutas.dart`, con URL por almohadilla (la de Flutter por defecto; en GitHub Pages no da 404).

|Ruta|Pantalla|
|---|---|
|`/`|A `/perfil` si no hay `newera.perfil`; si no, a `/persona` o `/familia/hoy`|
|`/perfil`|"¿De quién es este móvil?": "De la persona" o "De un familiar o cuidador"; guarda y registra `perfil_elegido`|
|`/persona`, `/persona/toma/:id`|Inicio y toma|
|`/familia/<slug>`|`StatefulShellRoute.indexedStack`, 10 ramas: `hoy`, `medicacion`, `calendario`, `consultas`, `alarmas`, `voces`, `alimentacion`, `ideas`, `circulo`, `ajustes`|
|`/familia/medicacion/nuevo`, `…/:medicamentoId`, `…/:medicamentoId/pauta`|Alta, detalle, cambio de pauta|
|`/familia/ideas/fila/:filaId`, `…/resumen`, `…/tema/:temaKey`|Ficha, tabla por grupo, dosier|
|`/familia/mas`|Solo en pantalla estrecha|

`FamiliaShell`: desde 840 dp, `NavigationRail` con las 10 pestañas (desplazable); por debajo, `NavigationBar` con Hoy, Medicación, Calendario, Ideas y tablas y Más (cuadrícula con las otras seis). Etiquetas: Hoy, Medicación, Calendario, Consultas, Alarmas, Voces, Alimentación, Ideas y tablas, Círculo, Ajustes.

**Arranque.** `main.dart` pasa a `ProviderScope` los `overrides` de `Arranque.iniciar()`, que lee o crea ids y clave, abre la base y crea lo que falte: círculo, `Persona` "Persona", `Dispositivo` y, en perfil familia, `Miembro` "Responsable" (`orden_escalado` 1). En web, con la base vacía, `sembrarDemo()` carga datos ficticios: "Carmen"; Lucía, Javier y Marta (teléfonos `000000001`-`000000003`); "Pastilla blanca pequeña", "Cápsula roja" y "Comprimido amarillo" a las 09:00, 14:00 y 21:00; tomas de hoy y ayer (confirmada, sin vídeo, no confirmada) y un `mensaje_familia`. En móvil, desde Ajustes.

**`/persona`** (sin menús): (1) "Martes 13 de octubre" a 48 pt y "Por la mañana" a 40; (2) hora a 48 pt; (3) "Lo siguiente": primera toma `prevista` o `noConfirmada` en 24 h, con foto ("A las 14:00, pastilla blanca pequeña"); a su hora, botón verde "Es la hora: …" que abre la toma; (4) "Mi gente": hasta 4 miembros `en_mi_gente`, por `orden_escalado`, foto o iniciales de 96 dp; un toque llama por `tel:` (`llamada_iniciada`); (5) botón rojo "Necesito ayuda" de 96 dp: `ayuda_pedida` y llamada al familiar 1; (6) último `mensaje_familia`. Salir: pulsación de 5 s sobre la hora (móvil) o el banner (web).

**`/persona/toma/:id`**: (1) foto de la pastilla a pantalla completa (o pictograma), `nombre_para_persona` a 40 pt, compartimento a 28 y botón verde "YA ME LA HE TOMADO" de todo el ancho y 120 dp → `toma_confirmada` {origen: `movil`}; (2) con vídeo, cámara frontal a pantalla completa sin tocar nada, `segundos_video` con cuenta atrás y "Enséñame la pastilla y tómatela delante del móvil" → `clip_grabado` (o `clip_fallido`); con `foto`, una a los 3 s; en web, `CamaraSimulada` (caja gris "Demo: aquí se vería la cámara frontal" y `clip_fallido` {motivo: `no_disponible`}); (3) "Muy bien" a 48 pt con el familiar 1 durante 4 s, cancela la alarma y vuelve a `/persona`. Si ya está confirmada o cerrada: "Ya está tomada" y "Volver al inicio".

**Familia, funcional esta semana:**
- **Hoy**: semáforo con icono y texto (rojo si hoy hay una `noConfirmada`; naranja, una `confirmadaSinVideo`; si no, verde); última toma (hora, pastilla, estado, quién y cómo); "Lo siguiente"; tomas de hoy; tarjetas reservadas: vídeo (semana 3), ubicación (10), respuesta de control (5).
- **Medicación**: "Tomas de hoy" con `EtiquetaEstadoToma` y "Probar pantalla de toma"; lista de medicamentos; alta con nombre, nombre para la persona, forma, color, fotos de caja y pastilla ("Hacer foto", no en web, y "Elegir de la galería") y pauta (horas de 24 h, días L-D, dosis, compartimento y comprobación: vídeo de 10 s, foto o ninguna). Guardar inserta en una transacción fotos, medicamento, pauta v1 y `medicamento_creado`. Cambiar la pauta crea otra versión (motivo obligatorio, `vigente_desde = ahora`); suspender, una con `activa = false`.
- **Ideas y tablas**: sección 7. **Ajustes** mínimo: "Cambiar perfil" y "Cargar datos de ejemplo".
- **Resto**, con `PantallaProximaSemana` (título, lo que tendrá y "Llega en la semana N"): Calendario 13, Consultas 12, Alarmas 4 y 5 (enlaza a `control_horas`, 5), Voces 8 y 9, Alimentación 14, Círculo 16 (lista de miembros, solo lectura), resto de Ajustes 16.

**Alarmas.** Al arrancar el perfil persona, `ProgramadorAlarmas` inserta y programa las tomas de las próximas 48 h y cancela las sobrantes. Con `no_implementado` o `no_disponible`, un solo `alarma_no_programada` por arranque; nunca bloquea la pantalla.

## NACHO · 7. Catálogo en la app

`tools/build_catalogo_app.py` (B), solo biblioteca estándar: lee `catalogo/data/*.json` y `catalogo/grupos/*.json` y escribe `app/assets/catalogo/catalogo.json` e `indice.json`. Temas en el orden de `ORDER` de `tools/build_catalogo.py` y el resto, alfabético. Código 1 si `grupos` y `rows` difieren en longitud, falta un `enlace` o hay una dirección desconocida. Salida determinista (sin fechas, `ensure_ascii=False`, `separators=(',',':')`). No reescribe texto: "dosier resumido" es quitar las `notas` y dejar los 9 apartados tal cual.

```json
{"esquema":1,"fuente_sha256":"<sha256 de data/*.json y grupos/*.json en orden de ruta>",
 "columnas":["id","tema","grupo","intervencion","tradicion_o_angulo","estudio","tipo_fuente","diseno","n",
   "poblacion","duracion","dosis_o_protocolo","que_midio","resultado_reportado","direccion_segun_la_fuente",
   "efectos_adversos_reportados","financiacion_y_conflictos","como_probarlo_en_casa","coste_aprox",
   "enlace","identificador","verificacion"],
 "temas":[{"key":"cobre_metales","titulo":"Cobre, zinc y metales","n_filas":44,
   "dosier":{"tesis":"…","defensores":["…"],"…":"los 9 apartados, con nombre y tipo del origen"}}],
 "filas":[["cobre_metales-000",0,"Cobre","…"]]}
```

Cada fila es un array en el orden de `columnas` (la app busca por nombre); `id` = `<tema>-<índice de 3 cifras en el origen>`; `tema` = posición en `temas`; `grupo` = valor paralelo de `catalogo/grupos/<tema>.json`; ausente o vacío = `null` ("No consta").

```json
{"esquema":1,"catalogo_sha256":"<sha256 de catalogo.json>","total_filas":647,
 "temas":[{"key":"…","titulo":"…","n_filas":44}],"por_direccion":{"mejora":322,"mixto":120,"no aplica":106,"sin cambio":61,"empeora":38},
 "por_tipo_fuente":{"ensayo aleatorizado":241},
 "grupos":[{"tema":"nutricion_alimentos","grupo":"Dieta MIND","n":3,"mejora":0,"sin cambio":0,"empeora":0,
   "mixto":0,"no aplica":0,"citas_encontradas":0,"citas_no_encontradas":0}]}
```

`grupos` sigue la primera aparición de cada par (tema, grupo), como la hoja "Resumen" del Excel; las citas se cuentan con los prefijos de `build_catalogo.py`. Cifras de hoy.

En `features/catalogo/`: `datos/catalogo_repositorio.dart` carga ambos con `rootBundle` y comprueba el sha; `dominio/modelo.dart` (`Catalogo`, `TemaCatalogo`, `Dosier`, `FilaCatalogo`, `GrupoResumen`); `dominio/filtro.dart` (`FiltroCatalogo {temas, direcciones, tiposFuente, texto, grupo}` y `filtrarFilas`, pura: conjunto vacío no filtra; "y" entre campos, "o" dentro; texto sin mayúsculas ni tildes contra grupo, intervención, estudio, resultado, población, dosis, financiación e identificador).

Pantallas: lista con chips de tema, dirección y tipo de fuente, buscador y "N de <total>"; tarjetas con grupo, estudio, tipo, dirección (color, icono y texto) y resultado. Ficha con los 21 campos (etiquetas de `COLS` en `build_catalogo.py`) y "Abrir la fuente" (`url_launcher`) con la URL seleccionable. Tabla resumen (`DataTable`) por grupo, ordenable por n; un toque filtra la lista. Dosier con sus 9 apartados. Cabecera: "Cada fila dice lo que reporta su fuente, con su cifra tal cual y quién lo pagó. Nadie hace de juez." Es texto citado: la sección 10 no lo revisa.

## NACHO · 8. Capa nativa iOS (solo contrato)

`ServicioAlarmas` (Dart): `programar({idToma, fecha, titulo, rutaAudio})`, `cancelar(idToma)`, `estado()`. `servicioAlarmasProvider` elige `AlarmasCanal` (iOS), `AlarmasAndroid` (paquete `alarm`) o `AlarmasNoDisponibles` (web y tests). Canal `MethodChannel('newera/alarmas')`:

|Método|Argumentos|Respuesta|
|---|---|---|
|`programar`|`{idToma: String, fecha: int (ms UTC), titulo: String, rutaAudio: String?}`|`{ok: bool}`|
|`cancelar`|`{idToma: String}`|`bool`|
|`estado`|—|`{disponible: bool, autorizacion: "no_determinada"/"autorizada"/"denegada", programadas: [String], implementado: bool}`|

Errores (`PlatformException.code`): `no_implementado`, `no_disponible` (iOS < 26), `no_autorizado`, `argumentos`, `limite`. Reservados para la semana 2, de nativo a Dart: `alarmaDisparada {idToma}` y `alarmaParada {idToma, origen}`; parar en el sistema no confirma la toma.

Swift esta semana: `ios/Runner/AlarmasCanal.swift`, registrado con `registrar(forPlugin: "AlarmasCanal")` donde la plantilla de Flutter 3.47 registra los plugins; `estado` devuelve `disponible` según `#available(iOS 26.0, *)`, `implementado: false`, `programadas: []`; `programar` y `cancelar`, `FlutterError(code: "no_implementado")`. AlarmKit, en la semana 2.

Android: `AlarmasAndroid` usa como id `idAlarmaNumerico(idToma)`, `assets/audio/tono_alarma.wav` en bucle, vibración y la notificación "Es la hora de la pastilla"; `Alarm.init()` solo en Android. Al sonar, la app recalcula las tomas, busca la del id y abre `/persona/toma/:id`.

Plataforma: `Info.plist` con `UISupportsFullScreenInAssistiveAccess` = `true`, `CFBundleDevelopmentRegion` = `es` y textos en castellano para `NSAlarmKitUsageDescription`, `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` y `NSMicrophoneUsageDescription`; `Podfile` con las macros de permission_handler para cámara y fotos (y las claves mínimas que pida `alarm`, si las pide). `AndroidManifest.xml`: `CAMERA` y los permisos del README de `alarm`.

## NACHO · 9. Accesibilidad y tema

Tokens en `core/tema/colores.dart` (contraste con blanco, todos por encima de 6:1):

|Token|Color|Uso|
|---|---|---|
|texto / fondoPersona|`#1A1A1A` / `#FFFDF7`|17,1:1 entre ellos|
|verde|`#1B5E20`|confirmar, verificada|
|azul|`#0D47A1`|confirmada|
|naranja|`#A84300`|sin vídeo, dudosa|
|rojo|`#B71C1C`|no confirmada, ayuda|
|morado|`#4A148C`|cerrada por un familiar|
|gris|`#555555`|prevista|

Persona: texto de 28 pt o más (títulos 40-48), botones de 64 dp o más (principales 96-120), tres botones a la vez como mucho, escala del sistema entre 1,0 y 1,3. Familia: texto de 16 pt o más, botones de 48 dp, escala hasta 2,0. Contraste AA. Ningún estado va solo por color: color, icono y texto (`EtiquetaEstadoToma`); el azul nunca va solo. `Semantics` en castellano. Pictogramas propios (`PastillaPictograma`, `CustomPaint`); ARASAAC, en la semana 5 tras revisar su licencia.

## NACHO · 10. Textos y palabras prohibidas

Español de España, solo `es_ES` (`supportedLocales: [Locale('es','ES')]`), fechas con `initializeDateFormatting('es_ES')` y mayúscula inicial. Plantilla `lib/l10n/app_es.arb`; `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_es.arb`, `output-localization-file: app_localizations.dart`, `output-class: AppLocalizations`, `nullable-getter: false`.

Prohibidas en la app y en la tienda (`test/textos_prohibidos_test.dart`):

```
cura|curas|curan|curar|curación|curaciones
revierte|revierten|revertir
trata|tratan|tratar
funciona|funcionan
milagro\w*
sustituye a|sustituyen a
sin necesidad de (un )?médico
natural|naturales
```

Frontera `(?<![\p{L}\p{N}])` antes y `(?![\p{L}\p{N}])` después, `unicode: true`, `caseSensitive: false`: "tratamiento", "función" o "naturaleza" pasan. Revisa los valores de `lib/l10n/*.arb`, los literales de `lib/**/*.dart` (sin comentarios), `ios/Runner/Info.plist`, `*.strings`, `android/**/strings.xml` y `store/es-ES/*.txt`; falla con archivo, línea y palabra; lleva control positivo y negativo. `test/textos_literales_test.dart` falla si en `lib/` hay `Text('…')` o `Text("…")` con letras.

## NACHO · 11. CI y herramientas (agente B)

**`.github/workflows/ci.yml`.** Disparo: `push` a `main` y a `claude/alzheimer-caregiver-app-uxrrni`, `pull_request` a `main`, `workflow_dispatch`. Permisos globales `contents: read`; `concurrency: ci-${{ github.ref }}` con cancelación.

1. `pruebas` (ubuntu-latest): `actions/checkout@v4`; `python3 tools/build_catalogo_app.py` y `git diff --exit-code app/assets/catalogo`; `sudo apt-get install -y libsqlite3-dev`; `subosito/flutter-action@v2` (`channel: stable`, `flutter-version: 3.47.x`, `cache: true`); en `app/`: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs` y `git diff --exit-code`, `flutter analyze --no-fatal-infos`, `flutter test`; en `app/packages/safety_core`: `dart pub get`, `dart analyze`, `dart test`.
2. `web` (tras `pruebas`): `flutter build web --release --base-href /NEW-ERA/`; comprueba `build/web/index.html`, `build/web/sqlite3.wasm` y `build/web/assets/assets/catalogo/catalogo.json`; sube con `actions/upload-pages-artifact@v3` (`path: app/build/web`).
3. `desplegar` (tras `web`, solo en `push`): `permissions: {pages: write, id-token: write}`, `environment: github-pages` con `url: ${{ steps.despliegue.outputs.page_url }}`, `actions/deploy-pages@v4` (`id: despliegue`). Pages, con origen "GitHub Actions" (pendiente en `00-estado.md`); sin verificar si el entorno admite la rama de trabajo (si no, se añade en Settings → Environments). URL: `https://naixsaint-rgb.github.io/NEW-ERA/`.
4. `apk` (tras `pruebas`): `actions/setup-java@v4` (temurin 17, o la que pida Gradle), `flutter build apk --debug` y `actions/upload-artifact@v4` (`name: newera-debug-apk`, `path: app/build/app/outputs/flutter-apk/app-debug.apk`, `retention-days: 14`).

**`codemagic.yaml`** (raíz): flujo `ios-simulador` (`instance_type: mac_mini_m2`, `flutter: 3.47.7`, `xcode: latest`, 26 o posterior por AlarmKit) con `push` en las dos ramas; en `app/`: `flutter pub get`, `flutter test`, `flutter build ios --simulator --debug`; artefacto `Runner.app` de `app/build/ios/iphonesimulator/` en zip. Flujo `ios-firmado` comentado para cuando haya cuenta. Sin secretos.

**Herramientas:**
- `tools/generar_tono.py`: WAV propio con `wave` en `app/assets/audio/tono_alarma.wav` (pitidos de 880 Hz, 2 s, mono, 22 050 Hz); en `.gitignore`, `!app/assets/audio/tono_alarma.wav` tras `*.wav`.
- `tools/fetch_web_sqlite.py`: lee `app/pubspec.lock` y descarga a `app/web/` `sqlite3.wasm` (releases de `simolus3/sqlite3.dart`) y `drift_worker.js` (releases de `simolus3/drift`) de las versiones resueltas. Patrón de URL sin verificar: si falla, sale con código 1 y lo dice.
- `tools/comprobar_semana1.sh`: ejecuta la sección 12; código 0 solo si se cumple todo.
- `app/README.md`: preparación (`flutter pub get`, `dart run build_runner build`, `python3 tools/build_catalogo_app.py`), ejecución en Chrome, Android y simulador iOS, Apple ID gratuito (7 días), tests, URL de la demo, versiones resueltas y aviso de que la demo no admite datos reales.

## NACHO · 12. Criterios de hecho

Los comprueban `tools/comprobar_semana1.sh` y la CI:

1. `flutter analyze --no-fatal-infos` sale con 0 en `app/` (sin errores ni avisos), igual que `dart analyze` en `safety_core`.
2. `flutter test` y `dart test` en verde, con 10 tests o más en total (contados con `--reporter json`), entre ellos:
   - `safety_core`: `proximas_tomas_test` (tres horas diarias; lunes y jueves; versión nueva desde `vigente_desde`; pauta suspendida); `cambio_hora_test` (09:00 del 28-3-2026 → 08:00Z; del 29-3 → 07:00Z; 02:30 del 29-3 → 01:00Z; 02:30 del 25-10 → solo 00:30Z; 09:00 del 25-10 → 08:00Z); `estado_toma_test` (cinco estados y anulación); `escalado_test` (a 4:59, pasos 0 y 2; a 5:00, familiar 1; a 10:00, familiar 2; confirmada a los 3 min, ninguno más); `ulid_test`, `id_alarma_test`, `parte_del_dia_test`.
   - `app`: `textos_prohibidos_test`; `textos_literales_test`; `catalogo_carga_test` (sha, filas y temas como el índice; todo `enlace` empieza por `http`); `catalogo_filtro_test` (`nutricion_alimentos` da su `n_filas`; `mejora`, su `por_direccion`; "mind" sin importar tildes ni mayúsculas); `base_datos_solo_insercion_test` (`UPDATE` y `DELETE` fallan en `eventos` y `pautas`); `noop_transport_test`; `persona_widget_test` (con semilla: `ClavesUi.loSiguiente`, "Mi gente", `ClavesUi.necesitoAyuda`; en la toma, `ClavesUi.confirmarToma` y, tras la cámara simulada, "Muy bien"); `familia_pestanas_test` (a 1280×800, 10 etiquetas; a 390×844, cuatro y Más con seis); `catalogo_widget_test` (filtra y abre una ficha con `ClavesUi.enlaceFicha`); `accesibilidad_persona_test` (`textContrastGuideline`, `androidTapTargetGuideline`).
3. `flutter build web --release --base-href /NEW-ERA/` genera `build/web/index.html`, `sqlite3.wasm`, `drift_worker.js` y el catálogo.
4. La demo publicada muestra elección de perfil, banner, `/persona`, `/persona/toma/:id` y las 10 pestañas con datos de ejemplo, y el catálogo filtra y abre fichas con enlace (tests de widget, más una mirada a la URL).
5. `flutter build apk --debug` termina y el artefacto se sube.
6. `git diff --exit-code` sale limpio tras regenerar el catálogo y el código de drift.

## NACHO · 13. Qué no se hace en la semana 1

|Fuera|Dónde queda|
|---|---|
|AlarmKit real, voz de la familia, alarma que sigue hasta confirmar, cámara probada en el iPhone real|Semana 2; con ella pasa el criterio de la semana 1 del roadmap (alarma en su iPhone): no hay cuenta de Apple|
|Cámara en web|No previsto: la demo la simula|
|Supabase conectado, cifrado de sobres y clips, CIMA, lectura de la hoja del médico|Semana 3|
|Escalado real, cierre a distancia, asistente de instalación, notificaciones locales|Semana 4|
|Control por horas|Semana 5|
|Reloj (watchOS)|Semanas 5-6|
|Voces grabadas y clonadas|Semanas 8 y 9|
|Localización y "me he perdido" completo|Semanas 10 y 11|
|Consultas, Calendario, Alimentación, motor de pruebas|Semanas 12, 13, 14 y 15|
|Invitaciones, roles, exportar, borrar, consentimientos|Semana 16|
|Ruta Android completa (pantalla completa sobre el bloqueo, servicio en primer plano, asistente por marca)|Sin semana fija|
|Acceso Asistido en un iPhone real|Con cuenta de Apple o Apple ID gratuito|
