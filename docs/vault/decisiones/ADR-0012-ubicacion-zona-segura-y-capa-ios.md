# NACHO · ADR-0012 · Ubicación con permiso, zona segura, modo perdida y capa nativa de iPhone

Fecha: 2026-11-19. Estado: aceptada (HIPOTENUSA del promotor del 19/11/2026 para los puntos 3 y 1).

## NACHO · Contexto
Quedaban sin empezar la ubicación (plan v3 §2.5 y §7) y la alarma real del iPhone (§6.2, ADR-0004). El
promotor pidió las dos. No hay Xcode ni cuenta de Apple, así que la capa de iPhone se escribe sin compilar.

## NACHO · Ubicación: alternativas y decisiones
1. **Sin permiso no hay posición.** Consentimiento propio guardado en `Consentimientos` (sobre `ubicacion`).
   Encendida = queda alguna alta sin revocar. Apagar borra las posiciones en todos los móviles, y no se
   aceptan posiciones tomadas mientras estaba apagada aunque luego se vuelva a encender.
2. **Dónde viven las posiciones: tabla aparte o eventos.** Eventos `ubicacion_registrada` cifrados por el
   cartero. Para poder borrarlas a los 7 días, el disparador de solo inserción de `eventos` admite un único
   borrado, el de ese tipo (esquema 9). El resto de eventos sigue sin poder borrarse ni cambiarse.
3. **Zona segura.** Ajuste del círculo (centro, radio 100/200/500 m) que viaja como ficha. Para salir hay que
   pasar el radio más max(25 m, 15 %): dos lecturas seguidas fuera, o una de precisión ≤50 m cuyo círculo de
   error queda entero fuera. Se ignoran lecturas con más de 1 km de error. «Sin posición» a los 90 minutos.
   Elegir o cambiar la zona no avisa por salidas anteriores a esa elección.
4. **Aviso.** Motivo `fuera_de_zona`, prioridad 5, a todos, con el texto fijo sin datos del ADR-0010; uno por salida.
5. **Mapa: teselas en línea, enlace externo o mapa descargado.** Hoy solo hay enlace externo (`geo:`, Apple
   Maps, OpenStreetMap), que solo sale al tocar. Sin teselas remotas, para que ningún servidor vea por dónde
   se mueve. El promotor ha pedido un mapa propio: será descargado en el móvil (pendiente, con investigación previa).
6. **Modo perdida.** «Buscarla ahora» es un evento `busqueda_pedida {hasta}` de 30 minutos; manda la última
   pedida. Ficha para emergencias y llamada al 112 con confirmación. La petición de ayuda adjunta posición.
7. **Segundo plano en Android.** Dentro de la revisión que ya existía para los avisos, que ahora recoge antes
   lo pendiente del cartero. Con búsqueda activa, una revisión cada 5 minutos en rejilla fija. Sin servicio
   en primer plano.

## NACHO · Capa de iPhone: decisiones
- `AlarmasCanal.swift` real: AlarmKit en iOS 26 o posterior (fecha fija, botones Parar y Abrir con App
  Intents, solo estado de alerta para no necesitar extensión de widget) y plan B con notificaciones locales
  time-sensitive en versiones anteriores. Enlace débil de AlarmKit, ActivityKit y AppIntents.
- Cada uso de API con su enlace a la documentación de Apple y su estado en `specs/ios-alarmkit.md`. Lo no
  confirmado va marcado `// SIN VERIFICAR:` y aislado.
- El proyecto de Xcode se editó a mano. `codemagic.yaml` exige Xcode 26.1 o posterior.

## NACHO · Consecuencias
- 524 tests y 51 en safety_core. La ubicación pasó una revisión crítica de Opus con tres fallos corregidos.
- **La capa de iPhone no se ha compilado nunca.** No se puede dar por buena hasta compilar en Codemagic y
  probar en el iPhone 12 mini (lista de 12 comprobaciones en la espec). Necesita cuenta de Apple.
- Sin verificar en móvil real: `geolocator` en el proceso de segundo plano, «Permitir todo el tiempo» en
  Android 11+, límites de Android y fabricantes que matan apps. Google Play exige justificar el permiso de
  ubicación en segundo plano.
- Límites conocidos: en iPhone la ubicación solo va con la app abierta; con la app de la persona cerrada la
  búsqueda llega en su siguiente revisión (alrededor de una hora, de noche ninguna); el seguimiento seguido
  necesita un servicio en primer plano; con lecturas peores que el radio la vuelta a casa no se confirma
  hasta una lectura precisa; los sobres con posiciones no caducan en el servidor (van cifrados).
- Ideas del promotor apuntadas, sin decidir: mapa propio descargado, presencia por habitación con balizas, y
  mensaje o llamada de una hija cuando tiene un mal rato.
