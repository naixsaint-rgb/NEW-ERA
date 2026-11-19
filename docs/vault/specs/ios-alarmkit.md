# NACHO · Capa nativa de alarmas en iPhone (AlarmKit)

Fecha: 2026-11-19 · Estado: **escrito sin compilar**. Aquí no hay Xcode ni macOS: el código Swift no se
ha compilado ni probado nunca. La primera compilación será en Codemagic y la primera prueba en el
iPhone 12 mini. Nada de lo de abajo dice que funcione; dice qué se ha escrito, con qué documentación y
qué hay que mirar.

Relacionado: [[ADR-0004-ios-primero-alarmkit]], plan v3 §6.2 y §6.3, `codemagic.yaml`.

## NACHO · Qué se ha escrito

| Archivo | Qué hace |
|---|---|
| `app/ios/Runner/AlarmasCanal.swift` | Canal `newera/alarmas`: lee los argumentos, reparte entre AlarmKit (iOS 26+) y notificaciones (iOS < 26), atiende los toques en las notificaciones del plan B y guarda los avisos a Dart hasta que Dart escucha (`PuenteAlarmas`). |
| `app/ios/Runner/AlarmasAlarmKit.swift` | `MotorAlarmKit`: permiso, programar (fecha fija), cancelar, cancelar todas, listar y observar `alarmUpdates`. Dos App Intents (`PararAlarmaIntent`, `AbrirAlarmaIntent`) para los botones. Todo tras `@available(iOS 26.0, *)`. |
| `app/ios/Runner/AlarmasNotificaciones.swift` | Plan B: 3 notificaciones locales `timeSensitive` por alarma, separadas 2 min, con tope de 64 pendientes. |
| `app/ios/Runner/AlarmasSonidos.swift` | Copia los tonos de Flutter y convierte la frase grabada (`voces/….m4a`, AAC) a `.caf` PCM 16 bits en `Library/Sounds`. Ids estables (UUID derivado del id con SHA-256) y registro UUID → id en `UserDefaults`. |
| `app/ios/Runner/AppDelegate.swift` | Pone `FlutterAppDelegate` como delegado de `UNUserNotificationCenter` (lo pide también el plugin `alarm`). |
| `app/ios/Runner.xcodeproj/project.pbxproj` | Alta de los 3 `.swift` nuevos (PBXFileReference, PBXBuildFile, grupo Runner, fase Sources) y `OTHER_LDFLAGS` con `-weak_framework` para AlarmKit, ActivityKit y AppIntents (para que la app no se caiga al arrancar en iOS < 26). Comprobado con un script: llaves y paréntesis equilibrados, 68 ids declarados, ninguno repetido, ninguno sin usar ni usado sin declarar. No hay `plutil` aquí. |
| `app/ios/Runner/Info.plist` | `NSAlarmKitUsageDescription` en castellano (ya estaba; ahora menciona también las rondas). Sin cambios en los modos de fondo. |
| `app/lib/core/plataforma/alarmas/alarmas_canal.dart` | Manda además `tipo`, `cabecera`, `botonParar`, `botonAbrir`; `cancelarTodas()`, `autorizar()`; `sonando()` real; cualquier fallo del canal se convierte en `ErrorAlarma` (y el programador apunta `alarma_no_programada`). |
| `app/test/alarmas_canal_ios_test.dart` | Fija el contrato que lee el Swift (8 pruebas). |
| `codemagic.yaml` | Paso que comprueba Xcode 26.1 o posterior antes de compilar; marcadores para la firma. |

Contrato del canal (de Dart a nativo):

| Método | Argumentos | Respuesta |
|---|---|---|
| `estado` | — | `{disponible, autorizacion, programadas, implementado, motor}` |
| `autorizar` | — | `"autorizada"`, `"denegada"` o `"no_determinada"` |
| `programar` | `{idToma, fecha (ms UTC), titulo, rutaAudio?, tipo, cabecera, botonParar, botonAbrir}` | `{ok: true}` |
| `cancelar` | `{idToma}` | `bool` |
| `cancelarTodas` | — | `int` |
| `pendientes` | — | `[{metodo, idToma, origen?}]` |

De nativo a Dart: `alarmaDisparada {idToma}` y `alarmaParada {idToma, origen: parar|abrir|sistema}`.
`sonando()` emite el id con `alarmaDisparada` y con `alarmaParada` de origen `abrir`; la app abre
entonces la toma o la pregunta de la ronda. Parar en el sistema no confirma la toma.
Errores: `no_disponible`, `no_autorizado`, `argumentos`, `limite`.

Decisiones de producto tomadas por defecto (cambiables):
- Solo estado de alerta, sin cuenta atrás ni pausa: así no hace falta extensión de widget.
- Título único de AlarmKit: «Es la hora de la pastilla · <nombre>» o «¿Cómo estás? · Toca para contestar».
- Botón secundario «Abrir» (comportamiento `custom`), que trae la app al frente.
- Color verde #1B5E20 en las tomas, azul en las rondas.
- Una fecha ya pasada devuelve `argumentos` (no se programa).

## NACHO · Cada API usada y su estado

Base de los enlaces: `https://developer.apple.com/documentation/`. Leídos el 19/11/2026 desde los JSON
de la documentación oficial.

| Uso | Enlace | Estado |
|---|---|---|
| AlarmKit existe desde iOS 26.0 | [alarmkit](https://developer.apple.com/documentation/alarmkit) | Verificado en documentación |
| `NSAlarmKitUsageDescription` obligatoria; sin ella no se programa | [scheduling-an-alarm-with-alarmkit](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit) | Verificado |
| AlarmKit no lleva entitlement | [foro de Apple, hilo 797950](https://developer.apple.com/forums/thread/797950) (un ingeniero de Apple avisa de entitlements inventados) | Foro, no documentación de referencia |
| `AlarmManager.shared`, `authorizationState`, `requestAuthorization()` | [alarmmanager](https://developer.apple.com/documentation/alarmkit/alarmmanager), [requestauthorization()](https://developer.apple.com/documentation/alarmkit/alarmmanager/requestauthorization()) | Verificado |
| Estados `authorized`, `denied`, `notDetermined` | [authorizationstate-swift.enum](https://developer.apple.com/documentation/alarmkit/alarmmanager/authorizationstate-swift.enum) | Verificado |
| `schedule(id:configuration:) async throws -> Alarm`, `Alarm.ID` es `UUID` | [schedule(id:configuration:)](https://developer.apple.com/documentation/alarmkit/alarmmanager/schedule(id:configuration:)), [alarm/id](https://developer.apple.com/documentation/alarmkit/alarm/id) | Verificado |
| `AlarmConfiguration.alarm(schedule:attributes:stopIntent:secondaryIntent:sound:)` | [alarm(schedule:…)](https://developer.apple.com/documentation/alarmkit/alarmmanager/alarmconfiguration/alarm(schedule:attributes:stopintent:secondaryintent:sound:)) | Verificado (firma) |
| `Alarm.Schedule.fixed(Date)` (alarma de una vez a hora fija) | [fixed(_:)](https://developer.apple.com/documentation/alarmkit/alarm/schedule-swift.enum/fixed(_:)) | Verificado |
| `AlarmAttributes(presentation:metadata:tintColor:)`, `AlarmMetadata` | [alarmattributes](https://developer.apple.com/documentation/alarmkit/alarmattributes), [alarmmetadata](https://developer.apple.com/documentation/alarmkit/alarmmetadata) | Verificado |
| `AlarmPresentation(alert:)`; `Alert(title:secondaryButton:secondaryButtonBehavior:)` desde 26.1 (parar lo pone el sistema) | [alert-swift.struct](https://developer.apple.com/documentation/alarmkit/alarmpresentation/alert-swift.struct) | Verificado |
| `Alert(title:stopButton:…)` en 26.0, obsoleto en 26.1 (da aviso al compilar) | misma página | Verificado |
| `AlarmButton(text:textColor:systemImageName:)` | [alarmbutton](https://developer.apple.com/documentation/alarmkit/alarmbutton) | Verificado. Que existan los símbolos `hand.tap` y `stop.circle`: sin verificar |
| `SecondaryButtonBehavior.custom` muestra «Abrir» | [scheduling-an-alarm-with-alarmkit](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit) | Verificado |
| `cancel(id:)` borra; `stop(id:)` para (y borra si es de una vez) | [cancel(id:)](https://developer.apple.com/documentation/alarmkit/alarmmanager/cancel(id:)), [stop(id:)](https://developer.apple.com/documentation/alarmkit/alarmmanager/stop(id:)) | Verificado |
| `alarms` (las del cliente actual; las que sonaron y se pararon desaparecen) | [alarms](https://developer.apple.com/documentation/alarmkit/alarmmanager/alarms) | Verificado |
| `alarmUpdates` avisa al sonar, posponer o quitar; lo que no está ya no está programado | [alarmupdates](https://developer.apple.com/documentation/alarmkit/alarmmanager/alarmupdates-swift.property) | Verificado |
| `Alarm.State.alerting` y demás | [state-swift.enum](https://developer.apple.com/documentation/alarmkit/alarm/state-swift.enum) | Verificado |
| `AlarmError.maximumLimitReached` → `limite` | [alarmerror](https://developer.apple.com/documentation/alarmkit/alarmmanager/alarmerror) | Verificado. **Cuántas alarmas admite: sin verificar** (no lo dice) |
| Extensión de widget solo si hay cuenta atrás | [scheduling-an-alarm-with-alarmkit](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit) | Verificado. Que una alarma solo de alerta funcione del todo sin extensión: sin verificar |
| Reenvío al Apple Watch emparejado | misma página (nota) | Verificado. Parar desde el reloj: sin verificar |
| `AlertConfiguration.AlertSound.named(_:)`: archivo en el bundle o en `Library/Sounds` | [alertsound/named(_:)](https://developer.apple.com/documentation/activitykit/alertconfiguration/alertsound/named(_:)) | Verificado (página de ActivityKit; AlarmKit usa ese tipo) |
| Formatos y duración del sonido para AlarmKit; si se repite en bucle | — | **Sin verificar** (se usa el formato de las notificaciones) |
| `LocalizedStringResource(stringLiteral:)` con texto que llega de Dart | [localizedstringresource](https://developer.apple.com/documentation/foundation/localizedstringresource) | Existe; que muestre la clave tal cual: **sin verificar** |
| `LiveActivityIntent`, `perform()`, `.result()`, `title`, `isDiscoverable` | [liveactivityintent](https://developer.apple.com/documentation/appintents/liveactivityintent), [appintent](https://developer.apple.com/documentation/appintents/appintent) | Verificado |
| `supportedModes` (`.background`, `.foreground(.immediate)`), iOS 26; sustituye a `openAppWhenRun` | [supportedmodes](https://developer.apple.com/documentation/appintents/appintent/supportedmodes), [intentmodes](https://developer.apple.com/documentation/appintents/intentmodes) | Verificado. Que los intents en el target Runner (sin extensión) se ejecuten al tocar los botones: **sin verificar** |
| Sonido de notificación: PCM, IMA4, µLaw, aLaw en aiff/wav/caf, < 30 s; busca en `Library/Sounds` y en el bundle | [unnotificationsound](https://developer.apple.com/documentation/usernotifications/unnotificationsound), [init(named:)](https://developer.apple.com/documentation/usernotifications/unnotificationsound/init(named:)) | Verificado |
| `interruptionLevel = .timeSensitive` (iOS 15) | [timesensitive](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/timesensitive) | Verificado. Que necesite la capacidad «Time Sensitive Notifications»: sin verificar en documentación (lo dicen foros) |
| `UNUserNotificationCenter.add(_:) async throws` | [add(_:withcompletionhandler:)](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/add(_:withcompletionhandler:)) | Verificado |
| Tope de 64 notificaciones pendientes | — | **Sin verificar** en la documentación actual |
| `AVAudioFile(forReading:)`, `(forWriting:settings:commonFormat:interleaved:)`, `read(into:)`, `write(from:)` | [avaudiofile](https://developer.apple.com/documentation/avfaudio/avaudiofile) | Verificado |
| Que `-weak_framework` evite el fallo de arranque en iOS < 26 | — | Sin verificar (práctica habitual del enlazador) |

En el código, lo no confirmado lleva `// SIN VERIFICAR:` y está en funciones pequeñas
(`recurso(_:)`, `sonido(_:)`, la cancelación previa en `programar`, `limiteSistema`).

## NACHO · Primera compilación en Codemagic (en orden)

1. **Xcode.** El paso «Comprobar Xcode y SDK» falla si el SDK es anterior a 26.1. Si falla: fijar en
   `codemagic.yaml` una versión de Xcode 26.1 o posterior en vez de `latest`.
2. **Proyecto.** Si Xcode dice que no puede abrir `project.pbxproj`, el fallo es mío al editarlo a
   mano: comparar con `git show HEAD~:app/ios/Runner.xcodeproj/project.pbxproj` y rehacer el alta de
   los tres archivos desde Xcode (arrastrarlos al grupo Runner, target Runner).
3. **«Cannot find type» de AlarmKit, AppIntents o ActivityKit.** SDK antiguo (punto 1).
4. **Errores probables en Swift** (por orden de sospecha) y dónde tocar:
   - `AlarmasAlarmKit.swift`, `PararAlarmaIntent`/`AbrirAlarmaIntent`: aislamiento de actor en
     `perform()` o en `@Parameter`. Si se queja, quitar `MainActor.run` y llamar a `DispatchQueue.main.async`.
   - `MotorAlarmKit.observar()`: el `for await` sobre `alarmUpdates` (tipo opaco) o avisos de `Sendable`.
   - `presentacion(_:)`: el inicializador obsoleto de 26.0 da aviso (no error). Si diera error, dejar solo la rama de 26.1 y subir el `#available` a 26.1 en `AlarmasCanal.swift`.
   - `AlarmasCanal.swift`: los dos métodos `userNotificationCenter` deben casar con el protocolo de
     `FlutterPlugin`, igual que en el plugin `alarm`.
   - `AlarmasSonidos.swift`: diccionario de ajustes de `AVAudioFile` (tipos `Int`/`Bool`).
5. **Avisos de concurrencia** (Swift 5): se aceptan en la primera pasada; no son errores.
6. **Tests de Flutter** del flujo: deben pasar igual que en Linux.
7. **Runner.app.zip**: se puede abrir en el simulador de un Mac, si hay uno a mano.

## NACHO · Primera prueba en el iPhone 12 mini (iOS 26)

1. Instalar (Apple ID gratuito desde Xcode, 7 días, o firma con cuenta). Abrir el perfil de la persona.
2. **Permiso.** Debe salir el aviso del sistema con el texto de `NSAlarmKitUsageDescription`. Si no sale y
   `estado` dice `no_determinada`: mirar la consola (`newera.alarmas`) y `MotorAlarmKit.autorizar()`.
3. **Alarma de prueba a 2 minutos**, con el móvil en silencio y en modo Concentración. Mirar: que suene;
   el título; el color; que aparezcan Parar y Abrir; que llegue al Apple Watch.
4. **Sonido.** Primero sin frase grabada (debe sonar `newera_tono_alarma.wav`); luego con frase. Si con
   frase suena el sonido del sistema o nada: el formato o la duración no valen para AlarmKit → tocar
   `AlarmasSonidos.convertirACaf` (probar IMA4 o el tono) o volver al tono en `AlarmasSonidos.preparar`.
5. **¿Cuánto dura sonando?** Cronometrar sin tocar nada (sin verificar si es en bucle sin límite).
6. **Abrir.** Debe traer la app al frente y abrir la pantalla de esa toma. Si no abre: `AbrirAlarmaIntent`
   (probar `.foreground(.deferred)`) o el reenvío de `pendientes` en `alarmas_canal.dart`.
7. **Parar.** La alarma se calla y la toma NO queda confirmada. Con la app abierta debe llegar
   `alarmaParada` origen `parar`.
8. **Con la app cerrada del todo**: repetir 3, 6 y 7.
9. **Ronda.** Programar una ronda: azul, «¿Cómo estás?», frase `como_estas` o `tono_suave`; Abrir lleva a la pregunta.
10. **Reprogramar.** Cambiar una pauta: la alarma vieja desaparece (`estado.programadas`) y sale la nueva.
11. **Límite.** Con 48 h de tomas y rondas (~30 alarmas): si aparece `alarma_no_programada` con `limite`, apuntar la cifra que admite.
12. **Desde el reloj**: parar en el Apple Watch y ver si la app lo nota.

## NACHO · Pasos manuales pendientes del promotor

1. **Cuenta**: Apple ID gratuito para pruebas de 7 días o Apple Developer (99 USD/año o exención ONG).
2. **Firma**: equipo de desarrollo en Xcode (Runner → Signing & Capabilities) o, en Codemagic, la
   integración de App Store Connect y descomentar `ios-firmado` cambiando `PENDIENTE_INTEGRACION`.
   El bundle id es el que ya está en `project.pbxproj`.
3. **Plan B (solo iOS < 26)**: añadir en Xcode la capacidad «Time Sensitive Notifications» (crea un
   `.entitlements`). No se ha creado a mano para no romper la firma gratuita. El iPhone 12 mini con iOS 26
   no lo necesita.
4. **Extensión de widget**: no hace falta mientras no haya cuenta atrás. Si la prueba 3 o la 8 fallan
   (la alarma desaparece sin sonar), crearla en Xcode: File → New → Target → Widget Extension, marcar
   «Include Live Activity», añadir `AlarmasAlarmKit.swift` a los dos targets (para `MetadatosAlarmaNewEra`
   y los intents) y en el widget un `ActivityConfiguration(for: AlarmAttributes<MetadatosAlarmaNewEra>.self)`.
   Estos pasos siguen el ejemplo de Apple; los nombres exactos de los menús de Xcode: sin verificar.
5. **Critical Alerts**: solicitud a Apple solo si el plan B se queda corto (ADR-0004).
