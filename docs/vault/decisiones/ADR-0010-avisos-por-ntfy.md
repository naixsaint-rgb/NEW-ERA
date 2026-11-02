# NACHO · ADR-0010 · Avisos reales a la familia por ntfy.sh, sin cuentas y sin datos

Fecha: 2026-11-02. Estado: aceptada (orden del promotor: "hazlo tú todo"; escalado por defecto del 12/10/2026).

## NACHO · Contexto
Hoy y Resumen anunciaban "aviso a las 14:05" pero nada llegaba a ningún móvil. El escalado decidido por el
promotor (familiar 1 a los 5 minutos, familiar 2 a los 10) y los avisos del control por horas («mal», dolor
nuevo, rondas sin respuesta, ayuda pedida) necesitan una notificación que despierte el móvil de la familia
aunque la app esté cerrada. Eso exige un servidor de notificaciones: no se puede hacer solo con el cartero.

## NACHO · Alternativas
1. **Firebase Cloud Messaging propio + función en Supabase**: gratis, pero exige crear un proyecto de Firebase
   con la cuenta de Google del promotor y una clave de servicio como secreto; en iPhone además la cuenta de
   Apple. Descartada por ahora: el promotor pidió no tener que crear cuentas.
2. **SMS o llamada automática**: coste por mensaje y, en iPhone, no se puede llamar sin tocar. Descartada.
3. **Solo con la app de la familia abierta** (Realtime): no sirve de noche ni con la app cerrada.
4. **ntfy.sh** (elegida): servicio público y gratuito, sin registro (`POST https://ntfy.sh/<tema>`). La
   familia instala la app ntfy (Google Play, F-Droid o App Store) y se suscribe a su tema. Verificado en su
   documentación: 60 peticiones de golpe por visitante y una más cada 5 s (429 si se pasa); los mensajes se
   guardan 12 h; pasan por FCM de Google y por APNS en iPhone; "el tema es la contraseña".

## NACHO · Decisión
- **Ningún dato sale.** El tema de cada familiar se deriva con HKDF de la clave del círculo (etiqueta
  `newera/v1/aviso/<miembroId>`): ntfy.sh, Google y Apple solo ven un código aleatorio y la frase fija
  «NEW-ERA: hay un aviso. Abre la app.» Al tocar, se abre la app (`newera://hoy`) y ahí está el detalle,
  cifrado por el cartero. Sin nombres, horas ni medicamentos en el aviso.
- **Quién envía:** el móvil de la persona. Toma sin confirmar: familiar 1 a los 5 minutos y familiar 2 a los
  10 (`ordenEscalado`; sin orden, a todos; con uno solo, los dos a él). Inmediatos a todos: ayuda pedida,
  respuesta «mal», dolor nuevo del día; ronda sin respuesta a los 10 minutos si su móvil está encendido.
  Cada envío deja el evento `aviso_enviado` y la familia ve «Aviso enviado a X a las 14:05» en Hoy.
- **Con la app cerrada (Android):** callbacks Dart exactos en segundo plano para los +5 y +10 minutos, que
  antes de avisar comprueban en la base local si la toma ya está confirmada. iPhone: sin ejecución en
  segundo plano hasta la capa Swift (AlarmKit); mientras, solo con la app abierta.
- **Familia:** en Círculo, orden de escalado por familiar y «Avisos en este móvil»: botón que abre
  `ntfy://ntfy.sh/<tema>` en Android, el nombre del tema para copiarlo en iPhone, y «Enviar aviso de prueba».
- Respeto del límite: cola de uno en uno, reintentos espaciados ante 429 (`Retry-After` o 5 s), 5xx y sin
  red con espera creciente; otros 4xx no se reintentan. ntfy.sh fija además 250 mensajes al día por visitante.
- Hecho tal cual (2/11): cuerpo, título (`NEW-ERA`), etiqueta `bell` y `Click` siempre idénticos, solo cambia la
  prioridad; sin puestos de aviso, los de +5 y +10 van a todos; cada envío queda en `aviso_enviado` y una reserva
  evita que la app abierta y la revisión en segundo plano lo manden a la vez; un fallo se reintenta a los 2
  minutos dentro de una ventana de 30; pasado ese margen ya no se envía. El aviso de prueba no deja evento.
  Al hacerlo apareció que al APK de release le faltaba el permiso `INTERNET` (el cartero tampoco habría
  funcionado fuera de depuración); corregido.

## NACHO · Consecuencias
- Zero coste y sin cuentas; la familia instala una app más (ntfy). Se puede cambiar a Firebase o a un ntfy
  propio más adelante sin tocar el cartero.
- Sin verificar: que el enlace `ntfy://` suscriba en iPhone; que la app ntfy abra `newera://hoy` al tocar el
  aviso; la revisión en segundo plano en un Android real (almacén seguro y base cifrada desde ese proceso,
  permiso de alarma exacta en Android 14+, Doze, fabricantes que matan apps, reprogramación tras reiniciar);
  que ntfy.sh no cambie sus límites gratuitos. El tema funciona como contraseña: quien lo conozca puede leer
  esos avisos sin datos o mandar avisos falsos a ese familiar.
- El móvil de la persona tiene que abrir la app una vez tras actualizar para programar las revisiones.
- Pendiente: vigilante en el servidor para «el móvil de la persona lleva horas sin dar señales» (pg_cron +
  pg_net con el tema derivado en SQL), y el aviso de ronda sin respuesta cuando su móvil está apagado.
