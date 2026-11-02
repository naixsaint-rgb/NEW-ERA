# NACHO · ADR-0007 · Voces grabadas por la familia, con consentimiento y por el cartero

Fecha: 2026-11-02. Estado: aceptada (orden del promotor: "hazlo tú todo"; decisión de voces del 12/10/2026).

## NACHO · Contexto
El promotor decidió el 12/10 que las voces las graban los familiares y que la clonación queda para una fase
posterior. La persona debe oír a alguien suyo en la toma, en el ánimo y en la pregunta de cada hora. Las
frases se graban en el móvil del familiar y tienen que llegar al móvil de la persona sin que el servidor
las oiga (ADR-0003).

## NACHO · Alternativas
1. **Texto a voz del sistema**: sin grabar nada, pero es una voz desconocida; el promotor pidió la de la familia.
2. **Grabar frases libres**: más flexible, pero sin control de duración ni de para qué sirve cada una.
3. **Cinco frases fijas por familiar** (elegida): toma, muy bien, cómo estás, te duele y qué harás; 8 s como
   mucho; escuchar, repetir y aprobar antes de que viaje.
4. **Audios por Storage**: para clips largos. Una frase de 8 s en AAC mono a 32 kbps ocupa unos 34 KB
   (medido con ffmpeg y audio sintético, no con el codificador del móvil), así que cabe en el sobre (tope
   45 KB). Elegido: dentro del sobre, como las fotos. Storage queda para los vídeos.
5. **Consentimiento implícito al grabar** o **pantalla de consentimiento guardada** (elegida): el texto
   mostrado y la fecha se guardan en Consentimientos (sobre `voz`) y viajan como ficha; sin él no se graba.

## NACHO · Decisión
- Interfaces `Grabadora` y `Reproductor` en `core/plataforma/audio/`; en móvil con `record` 7.1.2 y
  `audioplayers` 6.8.1 (versiones fijas); en web y en tests, simuladas.
- AAC-LC mono 32 kbps 22,05 kHz, `.m4a`, en `Documentos/voces/`; la base guarda la ruta relativa porque en
  iOS la absoluta cambia con cada actualización. Cada grabación nueva borra la anterior.
- Solo viajan las frases aprobadas (`ficha_creada` la primera vez, `ficha_modificada` al reaprobar). Si una
  frase no cabe, viaja sin audio con `omitidas: ['audio']` y la familia ve «Repítela más corta».
- Retirar la voz viaja como `ficha_modificada`; cada móvil borra sus audios al recibirlo y no se deshace.
- Qué voz suena: la de la pauta (`vozId`) y, si no hay, la primera voz activa del círculo según el orden de
  aviso que tenga esa frase aprobada. Sin frase no se enseña ningún texto sobre voz.
- Alarma de Android: `alarm` 5.15.0 acepta una ruta relativa a la carpeta de documentos y la reproduce en
  bucle; la alarma lleva la frase `toma` si existe y, si no, el tono. Si la frase cambia o la voz se retira,
  la alarma se cancela y se vuelve a programar. En iOS, AlarmKit sigue siendo un stub.
- El manifiesto de Android vuelve a pedir `RECORD_AUDIO` (en la semana 1 se quitaba a propósito);
  `READ_EXTERNAL_STORAGE` sigue fuera.
- El texto del consentimiento deja claro que no se crea ninguna voz artificial y que, si algún día se quiere,
  se pedirá otro permiso.

## NACHO · Consecuencias
- 14 tests nuevos (266 en total). Sin probar aún en un móvil real: grabación, reproducción y alarma con voz.
- Los audios no los cifra la app, igual que los vídeos: dependen del cifrado del móvil (código de bloqueo).
  Cifrado propio en la semana 3, junto con los vídeos. Excluir `Documents/voces` de iCloud necesita Swift.
- No hay selector de voz en la pauta: `vozId` siempre vacío por ahora.
- Si se vuelve a grabar una frase ya aprobada, los demás móviles conservan la anterior hasta la nueva aprobación.
- Pendientes del plan: medir reacciones (5.5), clonación (semana 9, Chatterbox) y reloj.
