# NACHO · ADR-0009 · Control por horas: rondas en el móvil de la persona, «sin respuesta» deducido por la familia

Fecha: 2026-11-02. Estado: aceptada (decisiones del promotor 7 y 8 del 12/10/2026; orden "hazlo tú todo").

## NACHO · Contexto
El promotor pidió preguntarle cada hora, de 9 a 21, las tres preguntas (cómo estás, te duele, qué harás) y que
la respuesta aparezca al momento en los móviles de la familia (plan v3 §2.4 bis). Hasta hoy la pregunta era
una pantalla de prueba que no guardaba nada.

## NACHO · Alternativas
1. **Ajustes fijos en el código**: más simple, pero el promotor pidió franja y ritmo ajustables desde la familia.
2. **Ajustes en el servidor**: el cartero no tiene estado legible; irían a una tabla más. Descartado.
3. **Ajustes como ficha del círculo por el cartero** (elegida): tabla propia con una fila por círculo
   (esquema 4); sin fila valen los de por defecto (activado, 9–21, cada hora); gana el cambio más reciente,
   llegue en el orden que llegue.
4. **Evento "sin respuesta" emitido por el móvil de la persona**: no vale si su móvil está apagado, que es
   justo el caso que importa.
5. **"Sin respuesta" deducido por la familia** (elegida): a partir de los ajustes y de las respuestas, una ronda
   cuya hora pasó hace más de 10 minutos sin respuesta cuenta como sin respuesta. Se espera respuesta desde
   que existe el móvil de la persona (su primer `perfil_elegido`) y desde la última activación del control.
6. **Rondas al azar dentro de la franja** (plan §2.4) o **a cada hora en punto** (§2.4 bis, elegida): ids
   `ronda_<fecha>_<hora>` para que respuestas y familia casen aunque la ronda se retrase.

## NACHO · Decisión
- Cálculo de rondas en `safety_core` (`rondas.dart`): franja con las dos horas incluidas (9–21 son 13 rondas),
  límites 6–23, ritmo cada 1, 2 o 3 horas. Si hay una toma a menos de 15 minutos, antes o después, la ronda se
  retrasa 15 minutos, hasta 4 veces; si el retraso la saca de la franja, no se hace.
- Móvil de la persona: alarma de ronda en Android con `alarm` («¿Cómo estás?», tono suave, volumen 0,6, la
  voz grabada si la hay); iOS por el mismo canal, aún stub. Con la app abierta, un temporizador lanza las
  rondas futuras (no relanza una pasada, no interrumpe una toma: reintenta cada minuto durante 10 minutos).
  Si suena la alarma de una ronda ya contestada, solo se para.
- Cada respuesta se guarda en `PreguntasControl` y `Respuestas` y emite `pregunta_respondida` (ronda, tipo
  estado|dolor|plan, respuesta, tiempo de respuesta, origen `movil`). «Prefiero decirlo» se guarda como
  `decirlo` y la ronda cuenta como contestada. El modo prueba sigue sin guardar.
- Familia: en Hoy, «Última respuesta» y «Avisos de hoy»; en Resumen, rondas contestadas y sin respuesta del
  día y de la semana. Semáforo con motivo: rojo por toma sin confirmar, «mal» o dos rondas seguidas sin
  respuesta; naranja por retraso de toma, toma sin vídeo o una ronda sin respuesta. Avisos del plan: «mal»,
  dolor nuevo (mayor que el anterior del día), el mismo dolor tres veces, racha sin respuesta (un aviso por
  racha). El envío real a la familia llega en otra entrega.
- Las respuestas no van al calendario (serían hasta 39 entradas al día).
- Tras la revisión (misma fecha): la familia empieza a esperar rondas 10 minutos después de activar el control
  (margen por relojes descolocados y retraso del cartero); si al cambiar la franja se añaden horas que antes no
  tocaban, se espera respuesta solo desde ese momento (no se inventan «sin respuesta» de horas que nunca se
  preguntaron). La alarma de una ronda se mueve si cambia su retraso por una toma nueva, y una ronda nunca
  interrumpe una toma abierta: la alarma se para y la pregunta sale al acabar la toma.

## NACHO · Consecuencias
- Sin verificar: iOS (stub), y en Android real el tono suave, el bucle, el volumen y la apertura a pantalla
  completa; si `alarm` mantiene una ronda sonando hasta que se abre la pregunta.
- Pendiente: envío real de avisos y escalado por ronda (semana 4), «Ahora no», «estoy con ella» del cuidador,
  respuesta por voz, vistas Ayer y Semana con respuestas, dolores por hora, respuestas de ejemplo en la demo.
