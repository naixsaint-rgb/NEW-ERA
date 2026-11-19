# NACHO · ADR-0011 · Pantallas de familia terminadas: Círculo, Alarmas, Calendario, Alimentación y Consultas

Fecha: 2026-11-19. Estado: aceptada (HIPOTENUSA del promotor del 19/11/2026).

## NACHO · Contexto
Al probar la app en Android y iPhone el promotor encontró pantallas que solo decían «llega en la semana N».
Pidió saber cuáles quedaban así y terminarlas. Se han hecho cinco piezas seguidas, una por agente (Sonnet),
porque todas tocan el mismo archivo de textos y el mismo de fichas.

## NACHO · Alternativas y decisiones
1. **Quitar a un familiar: borrado o baja lógica.** Elegida la baja lógica (`baja_en`): la fila se conserva
   para el historial y la baja viaja por el cartero. No retira la clave del círculo todavía; la pantalla lo dice.
2. **Papel del familiar: columna nueva o reutilizar `relacion`.** Reutilizada, con siete valores estables
   (hija, hijo, marido, mujer, cuidadora, cuidador, otro).
3. **Turno semanal: una fila por semana o una regla.** Una sola fila con `repetir_semanal`. Si la hora de fin
   no es posterior a la de inicio, el turno acaba al día siguiente (guardia de noche).
4. **Fechas de citas y turnos: instante UTC o texto de pared.** Texto de pared (`yyyy-MM-dd`, `HH:mm`) en la
   zona de la persona, como las tomas, para que el cambio de hora no las mueva.
5. **Comidas y vasos: tablas de solo inserción o editables.** Hasta hoy `Comidas` e `Hidrataciones` tenían
   disparadores de solo inserción como los hechos críticos. Se han quitado (esquema 7) porque la familia
   tiene que poder corregir y borrar una anotación; el borrado es baja lógica. Tomas, eventos y
   consentimientos siguen siendo de solo inserción.
6. **Contador de agua: un número por día o una fila por vaso.** Una fila por vaso: dos móviles que suman a la
   vez suman los dos y no hay conflicto. El objetivo diario (6 por defecto) se guarda solo en cada móvil.
7. **Grabación de la consulta: por el cartero o solo local.** Solo en el móvil que graba: una hora pesa unos
   14 MB y el cartero admite 45 KB por sobre. A los demás les llega una marca («Hay una grabación en el móvil
   de X»), nunca el audio. Antes de grabar se pide marcar «Tengo su permiso»; esa casilla no se guarda en
   `Consentimientos`.
8. **Resumen de la consulta: con IA o texto compuesto.** Texto compuesto en el móvil con fecha, preguntas y
   notas, para copiar. Sin IA y sin enviar nada fuera (línea que no se cruza: datos de la familia fuera de la nube).
9. **«Qué ha pasado desde la última consulta».** Solo cifras tal cual (tomas, rondas, «mal», dolores,
   comidas) desde la cita anterior del mismo tipo, o 30 días. La app no las interpreta.

## NACHO · Consecuencias
- Esquema local 5 → 8 en un día (miembros con baja, citas y turnos, comidas editables, consultas).
- 489 tests. Las cinco piezas no han tenido revisión crítica de Opus: son pantallas, formularios y listas.
- Siguen con cartel de pendiente, porque de verdad no existen: ubicación (Hoy), pulso, pasos y sueño con el
  reloj (Resumen), voz clonada (Voces), y el resto de Ajustes.
- Pendiente: rotar la clave al quitar a un familiar; registrar comida cuando ella responde «comer»; objetivo
  de vasos compartido; rastro del permiso de grabación si el promotor lo quiere.
