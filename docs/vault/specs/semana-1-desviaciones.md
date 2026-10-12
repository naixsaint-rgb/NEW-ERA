# NACHO · Semana 1: desviaciones respecto a la especificación (agente A, app)

12/10/2026 · Contrato: [[specs/semana-1-app]]. Cada fila dice qué se hizo en lugar de lo previsto y por qué. Lo que no aparece aquí se hizo tal cual.

## NACHO · Paquetes y plataforma

|Qué|Previsto|Hecho|Motivo|
|---|---|---|---|
|SQLCipher|`sqlcipher_flutter_libs` 0.6 + `open.overrideFor(openCipherOnAndroid)`|Sin `sqlcipher_flutter_libs`. `sqlite3` 3.7.0 con `hooks: user_defines: sqlite3: source:` (`android: sqlcipher`, `ios: sqlcipher`, `default: sqlite3`) en `pubspec.yaml`|`sqlite3` 3.x lo trae por build hooks y `sqlcipher_flutter_libs` 0.7.0+eol ya no hace nada. Los tests en Linux usan SQLite normal. Contrato intacto: `conexion/nativa.dart` ejecuta `PRAGMA key` y `PRAGMA cipher_version` y lanza `StateError('sqlcipher_no_disponible')` si sale vacío. Sin verificar en un móvil real (no hay Android SDK ni iPhone aquí)|
|Versiones|Mínimos de la sección 1|Las resueltas en `pubspec.lock`: go_router 18.0.2, flutter_riverpod 3.4.3, drift 2.35.2, drift_dev 2.35.1, build_runner 2.16.1, sqlite3 3.7.0, flutter_secure_storage 11.2.0, intl 0.20.3, camera 0.12.1, image_picker 1.2.4, url_launcher 6.3.3, permission_handler 13.0.2, alarm 5.15.0, path_provider 2.1.6, path 1.9.1, uuid 4.6.0, timezone 0.9.4 (hay 0.11.2), test 1.31.1, lints 6.1.0, flutter_lints 6.0.0|Última estable compatible, como pedía la sección 1|
|`crypto`|No figura|`crypto` 3.0.7 en `pubspec.yaml`|La sección 7 manda comprobar el sha256 del catálogo y no hay otra forma sin escribir SHA-256 a mano|
|`cupertino_icons`|No figura|Se deja la dependencia de la plantilla de `flutter create`|Sin coste; se puede quitar|
|Info.plist|Las claves de la sección 8|Además `UIBackgroundModes` (`fetch`, `audio`) y `BGTaskSchedulerPermittedIdentifiers` (`com.gdelataillade.fetch`)|Las pide el README de `alarm`. `AppDelegate` no llama a `SwiftAlarmPlugin.registerBackgroundTasks()`: en iOS la alarma pasa por `AlarmasCanal`, no por `alarm`, y AlarmKit llega en la semana 2|
|Podfile|Con macros de permission_handler|`ios/Podfile` escrito a mano desde la plantilla de Flutter, con `PERMISSION_CAMERA=1` y `PERMISSION_PHOTOS=1`|`flutter create` no lo genera (Swift Package Manager por defecto). Con SwiftPM las macros salen de las claves `NS…UsageDescription` de Info.plist; sin verificar en macOS|
|`AlarmasCanal.swift`|En el proyecto de Xcode|Añadido a `project.pbxproj` a mano, junto a `AppDelegate.swift`|Sin Xcode aquí; sin compilar|
|`app/web/sqlite3.wasm`, `drift_worker.js`|Los descarga A con `tools/fetch_web_sqlite.py`|Descargados con ese script (drift 2.35.2 y sqlite3 3.7.0; ambos de la release `drift-2.35.2`) y versionados|Según la sección 11|

## NACHO · Código

|Qué|Previsto|Hecho|Motivo|
|---|---|---|---|
|`safety_core`: enum de comprobación|No se nombra|`TipoComprobacion {video, foto, ninguna}`|Evita chocar con la clase de datos de la tabla `comprobaciones`|
|Clase de datos de `comprobaciones`|`Comprobacion`|`ComprobacionToma`|Misma razón|
|`TomaPrevista`|`id`, `pautaId`, `pautaVersionId`, `medicamentoId`, `previstaPara`, `fechaLocal`, `horaLocal`|Añade `comprobacion`|`estadoDeToma` necesita saber si la pauta dice `ninguna` sin consultar la base|
|`safety_core`: tipos auxiliares|No se detallan|`EventoToma`, `PasoEscalado`, `AccionEscalado`, `ParteDelDia`; `parteDelDia(int hora)`; `accionesVencidas` devuelve `List<PasoEscalado>`|Firmas libres en la sección 3|
|`ServicioAlarmas`|`programar`, `cancelar`, `estado`|Añade `Stream<String> sonando()`|Para abrir `/persona/toma/:id` cuando suena una alarma en Android|
|`AlarmasCanal` (Dart)|Implementación provisional que registra en consola|Llama al canal y además registra con `dart:developer`|Un solo código para iOS hoy y mañana|
|`/familia/mas`|Ruta de pantalla estrecha|Ruta de primer nivel fuera del `StatefulShellRoute`, con su propia barra inferior|Mantiene las 10 ramas del shell|
|Rutas añadidas|—|`/familia/alarmas/control-horas` (pantalla `control_horas`, semana 5) y `/persona/toma/:id?prueba=1` (modo prueba: no escribe eventos)|"Alarmas enlaza a `control_horas`" y "Probar pantalla de toma" sin tocar los datos. El perfil familia puede abrir `/persona/toma/…`|
|"Lo siguiente"|Primera toma `prevista` o `noConfirmada` en 24 h|Entre 3 h antes y 24 h después de ahora|Una toma sin confirmar de ayer no debe tapar la siguiente|
|Datos de ejemplo|"Pastilla blanca pequeña", "Cápsula roja" y "Comprimido amarillo" a las 09:00, 14:00 y 21:00|Un medicamento por hora, en ese orden. La tercera pauta pide foto (para tener un caso `confirmadaSinVideo`). Hoy y ayer: la primera toma de cada día confirmada con clip, la segunda sin vídeo, la tercera sin confirmar. Fotos PNG de marcador generadas en `core/db/png_marcador.dart`|La sección 6 no fija el reparto|
|Tabla resumen|`DataTable` por grupo|Muestra un tema cada vez (el primero por defecto) con un desplegable "Todos los temas"|Un `DataTable` de 353 filas tardaba unos 30 s en un test de widgets|
|`CamaraSimulada`|Caja gris y `clip_fallido`|La cuenta atrás dura como mucho 3 pasos de 1 s|Que la demo no se haga larga|
|Etiquetas de la barra inferior|Texto de 16 pt o más en familia|14 pt solo en esas etiquetas|Con cinco destinos en 390 dp, 16 pt parte "Medicación" y "Calendario" en dos líneas|
|`Arranque.iniciar`|Sin parámetros|Parámetros opcionales (`almacen`, `ejecutor`, `reloj`, `plataforma`, `demoWeb`, `sembrarDemo`, `azar`)|Para probarlo sin dispositivo|
|Archivos extra|Lista de la sección 2|`core/contexto.dart`, `core/db/png_marcador.dart`, `shared/l10n_ext.dart`, `shared/widgets/foto_imagen.dart`, `features/catalogo/{estado_filtro,etiqueta_direccion,ficha_pantalla,resumen_pantalla,dosier_pantalla,catalogo_pantalla}.dart`, `features/medicacion/{formulario_pauta,datos/selector_foto}.dart`|Reparto interno de las pantallas|

## NACHO · Pendiente o sin verificar

- `flutter build apk --debug`, el build de iOS y SQLCipher en móvil: sin Android SDK ni macOS aquí; solo se ha compilado la web.
- La cámara frontal y las alarmas en un móvil real.
- Flutter web pide la tipografía Roboto a `fonts.gstatic.com` al arrancar (CanvasKit). Para que la demo no haga ninguna petición externa, habría que incluir la fuente en `assets/`.
- Al cargar la web aparece en la consola del navegador un `Bad state: RenderBox was not laid out` del recorrido de foco del framework; no afecta al uso.
- `assets/audio/tono_alarma.wav` lo genera B; la carpeta ya está declarada en `pubspec.yaml`.

## NACHO · Añadidos del integrador (12/10/2026)

- `tools/generar_tono.py`, `app/assets/audio/tono_alarma.wav`, `tools/comprobar_semana1.sh` y la línea `!app/assets/audio/tono_alarma.wav` de `.gitignore`: no los había entregado B; los creó el integrador según la sección 11.
- `tools/fetch_web_sqlite.py` baja `sqlite3.wasm` primero de la release de drift (la que recomienda su documentación para garantizar compatibilidad) y, si falla, de `simolus3/sqlite3.dart`. La sección 11 decía solo `sqlite3.dart`.
