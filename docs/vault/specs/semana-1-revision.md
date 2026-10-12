# NACHO · Semana 1: revisión de código (revisor Opus)

12/10/2026 · Contrato: [[specs/semana-1-app]] · Desviaciones: [[specs/semana-1-desviaciones]] · Verificación: [[specs/semana-1-verificacion]].

Se revisó `app/` con tres lentes. Se corrigió en el sitio, con cambios mínimos y un test por corrección cuando se podía probar. Al terminar: `flutter analyze --no-fatal-infos` sin problemas, `flutter test` 64/64, `dart analyze` y `dart test` de `safety_core` 35/35 (99 en total). `flutter build web --release --base-href /NEW-ERA/` compila. La demo en Chromium, con el perfil familia, siembra los datos y enseña Hoy con las 10 pestañas.

## NACHO · 1. safety_core y base de datos

**Correcto, sin cambios**
- `proximasTomas`: aplica bien la ventana `vigenteDesde ≤ t < siguiente.vigenteDesde`, también con la pauta suspendida. Una hora que no existe pasa al primer instante válido (02:30 del 29-3 da 01:00Z). Una hora repetida sale solo la primera vez (02:30 del 25-10 da 00:30Z). Los ids van en hora local. Tiene tests de los cinco casos de la sección 12 y de Canarias.
- `estadoDeToma`: sigue el orden (1) a (5). Una anulación que a su vez está anulada deja de contar, y una confirmación tardía gana al cierre. `accionesVencidas` no devuelve nada si la toma ya está confirmada o cerrada.
- Hay disparadores `BEFORE UPDATE` y `BEFORE DELETE` en las 10 tablas de hechos. `tomas` se escribe con `INSERT OR IGNORE`.
- Móvil: `PRAGMA key`, después `PRAGMA cipher_version`, y si sale vacío, `StateError('sqlcipher_no_disponible')`. Nunca abre sin cifrar. Web: WASM sin cifrar y el banner fijo con el texto de la especificación.

**Corregido**

|Hallazgo|Riesgo|Corrección|Test|
|---|---|---|---|
|`INSERT OR REPLACE` sobre una tabla de hechos borraba la fila vieja sin disparar `BEFORE DELETE`, porque SQLite no lanza disparadores en el borrado implícito si `recursive_triggers` está apagado|El "solo inserción" se podía saltar|`PRAGMA recursive_triggers = ON` en `beforeOpen` (`core/db/base_datos.dart`)|`base_datos_solo_insercion_test`: "INSERT OR REPLACE no se salta el solo inserción"|
|`ProgramadorAlarmas` cancelaba como sobrante toda alarma cuya toma ya había pasado, también la que estaba sonando. Si la persona abría la app desde la alarma, el aviso se cortaba antes de confirmar|Una alarma sin confirmar se apagaba sola|Se toman como vigentes también las tomas de los últimos 30 min (`margenSonando`). Esa alarma la cancela la pantalla de toma al confirmar|`alarmas_test`: "no cancela la alarma de una toma que empezó hace menos de 30 min"|
|Un doble toque en "YA ME LA HE TOMADO" podía registrar dos `toma_confirmada`|Ruido en el historial|Se sale de `_confirmar` si la fase ya no es `confirmar` (`features/toma/toma_pantalla.dart`)|Sin test: depende de dos toques en el mismo fotograma|
|Al convertir el "Responsable" en Lucía, `SemillaDemo` cambiaba esa ficha sin escribir `ficha_modificada`|Se rompía la regla de la sección 4|Escribe `ficha_modificada` con el antes y el después (`core/db/semilla_demo.dart`)|Lo cubren los tests de semilla, que siguen en verde|

## NACHO · 2. Seguridad y privacidad

**Correcto, sin cambios**
- Los datos de ejemplo son ficticios: "Carmen", Lucía, Javier y Marta, teléfonos `000000001`-`000000003` y medicamentos "(ejemplo)". No hay nombres, teléfonos ni correos reales en `lib/` ni en `test/`.
- No hay analítica, Firebase, Sentry ni ningún otro SDK de terceros en `pubspec.yaml`. `SyncTransport` es `NoopTransport`.
- La clave del círculo usa `Random.secure()` y vive en `flutter_secure_storage` (iOS: `first_unlock_this_device`). No va a la base, a los registros ni a los eventos.
- `Info.plist` tiene las cuatro descripciones en castellano y `UISupportsFullScreenInAssistiveAccess`.

**Corregido**

|Hallazgo|Riesgo|Corrección|Test|
|---|---|---|---|
|`Arranque` usaba en móvil `AlmacenSeguroConReserva`. Si fallaba la lectura del llavero, devolvía nulo desde memoria, `Arranque` generaba una clave nueva y podía escribirla encima de la buena|Base cifrada ilegible: pérdida de datos|La reserva en memoria queda solo para la web. En móvil, `AlmacenSeguroFlutter` directo: si el llavero falla, el arranque se para (`Arranque.almacenPorDefecto`)|`arranque_test`: "en móvil el almacén no tiene reserva en memoria; en web sí"|
|`android:allowBackup` tenía el valor por defecto (`true`)|Google Drive copiaba los clips de vídeo, que esta semana van sin cifrar, y las preferencias de `flutter_secure_storage`, que fallan al restaurarse|`android:allowBackup="false"` y `android:fullBackupContent="false"` en `AndroidManifest.xml`|Sin test: es configuración de Android|
|`camera` y `alarm` añaden `RECORD_AUDIO` y `READ_EXTERNAL_STORAGE` al manifiesto combinado. El vídeo se graba sin audio y el tono sale de `assets`|Permisos de más|`tools:node="remove"` para los dos|Sin test: se comprueba con el APK de la CI|
|`CamaraMovil` copiaba el clip a `clips/` y dejaba el original en la caché. Además llamaba a `DateTime.now()`|Una copia suelta del vídeo, y se incumplía la regla del `Reloj`|Borra el temporal tras copiarlo y mide la duración con `Stopwatch`|Sin test: necesita la cámara de un móvil|

## NACHO · 3. Textos y accesibilidad

**Correcto, sin cambios**
- `textos_prohibidos_test` revisa los ARB, los literales de `lib/`, `Info.plist` y `store/es-ES`, con control positivo y negativo. Pasa: ninguna palabra de la sección 10. Los textos están en español de España: "móvil" y "vídeo", sin formas latinoamericanas.
- La persona tiene texto de 28 pt o más (títulos de 40 a 48), botones de 96 y 120 dp y la escala de texto limitada a 1,0-1,3. La familia, a 2,0. Los colores de la sección 9 son los tokens de `colores.dart`.
- Ningún estado va solo por color: `EtiquetaEstadoToma` y `EtiquetaDireccion` llevan color, icono y texto, y el semáforo, icono y texto.
- El catálogo no juzga. Lleva la cabecera literal de la sección 7. Cada tarjeta enseña `resultado_reportado` tal cual, la dirección "según la fuente" (en el filtro, la ficha y la etiqueta accesible) y "No consta" donde falta el dato. No se ordena por dirección. La ficha da el enlace visible.

**Sin corregir (choque con la especificación)**
- La sección 9 pide tres botones a la vez como mucho en la persona. La sección 6 pone en `/persona` hasta 4 contactos de "Mi gente", "Necesito ayuda" y, a la hora, "Es la hora". Lo decide el promotor.
- La tarjeta del catálogo dice "Mejora" sin "según la fuente". Ese matiz solo está en el filtro, en la ficha y en la etiqueta de accesibilidad. Puede añadirse si se quiere.

## NACHO · 4. Para la semana 2

- **Clave perdida con la base existente.** Si el llavero vuelve vacío y `newera.db` existe, ahora se genera otra clave y la base no se abre. Hay que detectarlo y avisar, sin crear una base nueva encima.
- **Error de arranque en móvil.** Si falla SQLCipher o el llavero, `main` lanza y la persona ve una pantalla vacía. Hace falta una pantalla de error con un texto claro, sin abrir nunca sin cifrar.
- **Copias de seguridad en iOS.** Los clips de `Documents/clips` entran en la copia de iCloud. Hay que marcarlos con `isExcludedFromBackup` desde Swift, o cifrarlos en la semana 3.
- **Alarma y cámara.** La alarma de Android sigue sonando mientras se graba el vídeo de 10 s, porque se cancela al final. Encaja con "alarma hasta confirmar" de la semana 2: conviene silenciarla al pulsar el botón.
- **Hora inexistente en pantalla.** Una toma a las 02:30 del día del salto de primavera suena a las 03:00, pero en pantalla pone "A las 02:30".
- **Tomas antiguas.** `eventosDeTomaProvider` lee 4 días de eventos. Una toma más antigua abierta por enlace saldría sin su historial.
- **`SemillaDemo.sembrar` sin transacción.** Si se corta a medias en la web, la siembra queda incompleta.
- **Pendientes ya anotados por el integrador:** APK y SQLCipher en un móvil real, Roboto pedida a `fonts.gstatic.com`, el error de consola `RenderBox was not laid out` (que sigue saliendo, sin efecto visible) y GitHub Pages por activar.

## NACHO · Archivos tocados

- `app/lib/core/arranque.dart`
- `app/lib/core/db/base_datos.dart`
- `app/lib/core/db/semilla_demo.dart`
- `app/lib/core/plataforma/alarmas/programador_alarmas.dart`
- `app/lib/core/plataforma/camara/camara_movil.dart`
- `app/lib/features/toma/toma_pantalla.dart`
- `app/android/app/src/main/AndroidManifest.xml`
- `app/test/alarmas_test.dart`
- `app/test/arranque_test.dart`
- `app/test/base_datos_solo_insercion_test.dart`

Se pasó `dart format` por `lib/` y `test/`. No se tocó nada de B, ni `.gitignore` ni `tools/`.
