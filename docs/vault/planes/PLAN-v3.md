# NACHO · Plan v3: la app de la persona y la app de la familia

Fecha 12/10/2026. Estado: propuesta para analizar juntos; nada construido; nada se programa sin HIPOTENUSA. Incorpora las ocho decisiones del promotor del 12/10/2026 (sección 0.1).

Este plan concreta la visión del promotor sin cambiarla. Cada límite real va con su fuente y su plan B. Cada dato lleva enlace a las seis piezas (`plan3/pieza-*.json`); lo no comprobado dice "sin verificar".

## NACHO · 0. La visión del promotor, tal cual

Esto es el contrato. Lo que aparece aquí se construye.

**Dos aplicaciones sobre un mismo sistema.**

**1. La app de la PERSONA con Alzheimer.** Va en su móvil y en un reloj de mano.
- Calendario.
- Qué está tomando y cuándo lo ha hecho.
- Cuando toca una pastilla, la app dice que hay que tomarla y muestra cuál es con una foto o imagen de la pastilla.
- Suena una alarma que no para hasta que se toma.
- Después, con la cámara del móvil, se hace una foto o un vídeo para poder comprobar que lo ha hecho.
- Un reloj de mano que monitorice de alguna forma si se la ha tomado.
- Alarmas a los familiares.
- Ayuda por si está perdida: mirar cómo se encuentra por medio del reloj, con preguntas de control en cualquier momento del día.
- Esas preguntas, con la voz de sus familiares, que hay que clonar.

**2. La app de los FAMILIARES.**
- Todo lo anterior como centro de mando: calendario, lo que dicen los médicos con grabaciones de las consultas, qué toma, cuándo lo tomó, alarmas, vídeos de comprobación.
- Además, la pestaña de alimentación.
- Las ideas que hemos leído y lo que dicen los estudios.
- Las tablas que dan opciones.
- Eso solo lo ven los familiares. La persona no lo necesita.

**Reglas del proyecto.**
- Coste cero o casi cero en servicios. El hardware, como el reloj, lo compra la familia. Hay que dar opciones y precios en España.
- Pensada para muchas familias.
- Nadie de la industria médica hace de juez.
- No se inventa nada. Cada dato técnico con enlace a documentación oficial o fuente real.
- Fable orquesta, Opus diseña, Sonnet investiga y construye, Haiku consolida.
- Nada se programa sin HIPOTENUSA.

### 0.1 Decisiones del promotor (12/10/2026)

Respuestas a las preguntas abiertas del plan. Mandan sobre cualquier otra cosa que diga este documento.

|Decisión|Respuesta|Qué cambia en el plan|
|---|---|---|
|1. Móvil de la persona|iPhone. La app de la familia, en Android y en iPhone ("son los dos")|La persona usa iPhone con iOS 26 y AlarmKit (2.2, 6.2). La app de la familia es Flutter para los dos sistemas (9.1). Android queda como ruta alternativa para otras familias|
|2. Reloj|Apple Watch|Reloj recomendado: Apple Watch, con el SE con datos móviles como opción económica (4.3). Galaxy Watch queda como plan B para familias Android (4.4). App del reloj en Swift (9.1)|
|3. Voces|Se graban los familiares. Hay en la familia un PC con tarjeta gráfica NVIDIA|Primero la voz grabada (5.1). La clonación con Chatterbox Multilingual (licencia MIT) es viable y entra en fase posterior (5.2, semana 9)|
|4. Alarmas a familiares|Lo decidirá más adelante|Se mantiene el valor por defecto: familiar 1 a los 5 minutos y familiar 2 a los 10 (2.2). El orden de familiares queda como pregunta abierta (11.2)|
|5. Qué apaga la alarma|Por ahora el botón, con vídeo de comprobación. La etiqueta NFC, opción futura|La NFC sale de la ruta inicial (2.2, 6.4, semana 4)|
|6. Pastillero|Lo llena la familia (pastillero semanal)|Pastillero semanal normal en lugar del SPD de la farmacia (6.4)|
|7. Control por horas|De 9 a 21|Franja por defecto de 2.4 bis|
|8. Ritmo|Las tres preguntas cada hora, ajustable desde la app de la familia|Ritmo por defecto de 2.4 bis; se ajusta en la pestaña Alarmas (3.5)|

## NACHO · 1. El sistema en una página

Dos apps Flutter (la de la persona, en iPhone, con capa nativa Swift), una app propia en el Apple Watch y un servidor gratuito que solo hace de cartero. Android queda como ruta alternativa para otras familias.

```
        MÓVIL DE LA PERSONA (iPhone, iOS 26)                     RELOJ DE LA PERSONA (Apple Watch)
   ┌──────────────────────────────────────────┐            ┌──────────────────────────────────┐
   │ App PERSONA (Flutter + capa Swift)       │  Bluetooth │ App RELOJ (Swift, watchOS)       │
   │ - alarma AlarmKit local (iOS 26)         │◄──────────►│ - alarma propia, foto de pastilla│
   │ - foto de la pastilla, voz de la familia │ emparejado │ - botón TOMADA, voz de la familia│
   │ - cámara: foto o vídeo de 10 s           │            │ - preguntas de control SÍ / NO   │
   │ - NFC del pastillero (opción futura)     │            │ - GPS, SOS, llamada, caídas      │
   │ - base local cifrada (funciona sin red)  │            │ - datos móviles (opcional)       │
   └───────────────┬──────────────────────────┘            └───────────────┬──────────────────┘
                   │ TLS, datos ya cifrados en el móvil                    │ datos móviles propios
                   ▼                                                       ▼
            ┌─────────────────────────────────────────────────────────────────────┐
            │ SERVIDOR GRATUITO (Supabase Free, Frankfurt): solo hace de cartero   │
            │ - cola de eventos (toma, aviso, respuesta, ubicación)                 │
            │ - buzón temporal de vídeos cifrados (se borran tras la entrega)       │
            │ - dispara los avisos push a los familiares                            │
            └───────────────┬─────────────────────────────────────────────────────┘
                            ▼
     MÓVILES DE LOS FAMILIARES (Android e iPhone): App FAMILIA (Flutter)
     Hoy · Medicación · Calendario · Consultas · Alarmas · Voces · Alimentación · Ideas y tablas · Círculo · Ajustes
     + PC de la familia (NVIDIA, fase posterior): genera una vez las frases con voz clonada y las sube como audio
     + Catálogo público (647 estudios) en GitHub Pages, sin servidor
```

Principios que sostienen el dibujo:
- **La alarma vive en el móvil y en el reloj, no en internet.** Si se cae la red, suena igual.
- **El servidor no ve nada.** Recibe datos cifrados en el móvil de origen y los reparte. Plan v2 ya fijó Supabase Free en Frankfurt ([precios](https://supabase.com/pricing)).
- **La persona no maneja nada.** Todo lo configura la familia.
- **La comprobación la hace una persona de la familia.** Ninguna IA decide si se tomó la pastilla.
- **La persona usa iPhone con iOS 26.** Es lo que da AlarmKit, la alarma que según Apple anula el silencio y el modo Concentración ([Apple](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit)). Si su iPhone no admite iOS 26, se activa el plan B de 6.2. Android queda como ruta alternativa para otras familias (6.1, 4.4).
- **El reloj recomendado es un Apple Watch con datos móviles propios.** Así avisa aunque el iPhone se quede en casa. Sin datos móviles, depende de que el iPhone esté cerca (4.3).

## NACHO · 2. La app de la PERSONA

Regla de diseño: una sola pantalla viva, letras enormes, como mucho tres botones a la vez, sin menús, sin ajustes visibles. Todo lo configurable está en la app de la familia. Se apoya en la guía de diseño para demencia que ya usaba Plan v2 ([Alzheimer's Society](https://www.alzheimers.org.uk/blog/how-design-website-someone-affected-dementia)) y en pictogramas de [ARASAAC](https://arasaac.org/).

### 2.1 Pantalla de inicio (siempre la misma)

- Arriba, en letras de 3 a 4 cm: **día de la semana, fecha y parte del día** ("Martes 13 de octubre · Por la mañana").
- Hora grande.
- Debajo, **"Lo siguiente"**: la próxima toma o cita, con su foto ("A las 14:00, pastilla blanca pequeña").
- Fila "**Mi gente**": fotos de los familiares. Un toque en una foto llama a esa persona.
- Botón rojo grande: **"Necesito ayuda"**.
- Abajo, una tarjeta con el último mensaje o foto que ha mandado la familia.

En iPhone (ruta principal) el modo de bloqueo es **Acceso Asistido**, disponible desde iOS 17. La clave `UISupportsFullScreenInAssistiveAccess` con valor `YES` en el `Info.plist` hace que la interfaz de la app ocupe todo el espacio por encima del botón Atrás. Además, Ajustes la lista como "Optimizada para Acceso Asistido", para que el familiar de confianza que lo configura en nombre de la persona sepa que la app está pensada para ese modo ([Apple](https://developer.apple.com/documentation/bundleresources/information-property-list/uisupportsfullscreeninassistiveaccess)). Qué apps deja visibles, cómo se sale del modo y si las llamadas de "Mi gente" funcionan dentro de él: sin verificar. La guía de Apple que enlaza esa página ([Optimizar tu app para Acceso Asistido](https://developer.apple.com/documentation/accessibility/optimizing-your-app-for-assistive-access)) no se ha leído. Se prueba en la semana 1.

En Android (ruta alternativa para otras familias) la app hace de pantalla de inicio (launcher). El bloqueo total en una sola app exige un móvil gestionado como dispositivo dedicado ([lock task mode](https://developer.android.com/work/dpc/dedicated-devices/lock-task-mode)): opción para un móvil comprado solo para la persona.

### 2.2 La toma de medicación, paso a paso

Es el corazón de la app y lo primero que se construye.

**Paso 0. La familia prepara la pauta** (en su app): qué pastilla, a qué hora, foto de la caja y de la pastilla (de CIMA o hecha por ellos), en qué compartimento del pastillero está, y qué voz la anuncia. El móvil de la persona recibe la pauta y **programa las alarmas en local**. No depende de internet ([pieza alarmas_camara](https://developer.android.com/develop/background-work/services/alarms/schedule)).

**Paso 1. Aviso.** A la hora exacta:
- **En iPhone** se usa AlarmKit, que exige iOS 26 o posterior. Según Apple, la alarma anula tanto el modo Concentración como el silencio del iPhone, si hace falta, y trae un botón de parar y un botón secundario que abre la app ([Apple](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit)). Pide autorización al usuario una vez. La pantalla de alerta es la del sistema: la foto a pantalla completa y la voz de la familia salen al abrir la app. Si AlarmKit admite la voz grabada como sonido de la alarma: sin verificar. El sistema reenvía además la alerta al Apple Watch emparejado, si lo hay (misma fuente). Si el iPhone no admite iOS 26, se activa el plan B de la sección 6.2.
- En Android (ruta alternativa) la pantalla se enciende aunque el móvil esté bloqueado. Se usa una alarma exacta (`setAlarmClock`) más una notificación de pantalla completa que abre la pantalla de toma sobre el bloqueo ([alarmas](https://developer.android.com/develop/background-work/services/alarms/schedule), [cambios de Android 14](https://developer.android.com/about/versions/14/behavior-changes-14)).
- Suena **la voz de un familiar** (en iPhone, al abrir la app): "Mamá, soy Lucía. Es la hora de la pastilla blanca pequeña".
- Se ve **la foto de la pastilla** a pantalla completa (en iPhone, al abrir la app), con su nombre en letras grandes y el compartimento ("Martes · Mañana").

**Paso 2. Alarma que no para.** Tras la voz, suena un tono en bucle con vibración.
- **En iPhone** lo mantiene AlarmKit hasta que se pulsa parar. Que suene en bucle sin límite de tiempo: sin verificar. Parar en la pantalla del sistema silencia la alarma, pero no confirma la toma: solo cuenta como tomada el botón de nuestra app. La página de Apple permite ligar acciones propias a los botones con App Intents y ofrece un botón "Repetir" que vuelve a lanzar la alarma pasado un tiempo ([Apple](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit)). Cómo combinarlos para que la alarma siga hasta la confirmación: sin verificar; se prueba en la semana 1. El Apple Watch emparejado recibe la alerta (paso 1); la app propia del reloj se describe en 2.3.
- **En Android** lo mantiene un servicio en primer plano que solo se apaga con la confirmación; el paquete Flutter `alarm` (MIT) ya hace bucle, volumen forzado y vibración ([pub.dev/alarm](https://pub.dev/packages/alarm)).
- Cada 2 minutos se repite la frase con voz de la familia entre los tonos.

**Paso 3. Confirmación.** Un solo botón gigante verde: **"YA ME LA HE TOMADO"**. Por ahora se confirma de dos formas; la tercera es una opción futura (decisión del promotor, 12/10/2026):
- Tocar el botón del móvil.
- Tocar el botón del reloj.
- Opción futura, no se construye por ahora: acercar el móvil a la etiqueta NFC del compartimento del pastillero (sección 6.4).

**Paso 4. Cámara.** Al confirmar, se abre la cámara frontal **sin que la persona toque nada**. Por defecto graba un **vídeo de 10 segundos**; la familia puede elegir foto. La voz de la familia dice: "Enséñame la pastilla y tómatela delante del móvil". Se usa el plugin oficial `camera` de Flutter, que admite foto y vídeo en Android 7+ e iOS 13+ ([pub.dev/camera](https://pub.dev/packages/camera)). La duración máxima y la cámara frontal no aparecen en la documentación leída: sin verificar, se prueba en la semana 2.

**Paso 5. Envío a la familia.** El clip se cifra en el móvil y sube al buzón del servidor. Los familiares reciben "Toma de las 9:00: vídeo listo". Si no hay red, se queda en cola y sube después. La toma queda registrada en local en el momento.

**Paso 6. La alarma se calla.** Solo ahora. La pantalla vuelve al inicio con un "Muy bien" y la foto del familiar que habló.

**Qué pasa si no confirma (escalado por defecto, ajustable):**

|Minuto|Qué pasa|
|---|---|
|0|Voz de la familia + foto + tono en bucle en móvil y reloj|
|2|Repite la voz, sube el volumen|
|5|Aviso al **familiar 1**: "Mamá no ha confirmado la pastilla de las 9:00". Botón "Llamar"|
|10|Aviso al **familiar 2**. El reloj vibra fuerte y repite la voz|
|15|Llamada automática desde el reloj (LTE) al familiar 1|
|30|La toma queda como "no confirmada" en el historial. La alarma sigue hasta que un familiar la cierre a distancia|

Un familiar puede **cerrar la alarma a distancia** desde su app ("ya hablé con ella, se la ha tomado") y queda escrito quién lo hizo.

**Si toca la pantalla pero no hay vídeo** (sale de la cámara, se tapa): la toma queda como "confirmada sin vídeo" y la familia lo ve en naranja.

### 2.3 El reloj, visto por la persona

El reloj lleva nuestra propia app (Apple Watch, watchOS, sección 4). La persona ve:
- **En reposo**: hora enorme y parte del día.
- **Hora de pastilla**: vibra y suena sin parar, muestra la foto de la pastilla y reproduce la voz de la familia. Botón redondo que ocupa media esfera: **TOMADA**. Cómo suena y vibra sin parar una alarma propia en watchOS: sin verificar; se prueba en la semana 5.
- **Pregunta de control**: la voz pregunta; dos botones, **SÍ** verde y **NO** rojo. También vale responder hablando (fase posterior).
- **SOS**: el botón rojo de la esfera. Que una app propia lea el botón lateral del Apple Watch: sin verificar.
- **Llamar**: una sola ficha con las fotos de dos familiares.

Monitorización de la toma con el reloj: el toque de TOMADA confirma. Además, el acelerómetro busca el gesto de llevar la mano a la boca como **indicio**. Los estudios de este gesto son pequeños y de laboratorio (28 participantes, [PMC10196892](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10196892/); 22, [Politécnico de Milán](https://re.public.polimi.it/handle/11311/1207131)): marca el vídeo como "hubo gesto", no prueba nada.

### 2.4 Preguntas de control a lo largo del día

La familia elige franjas ("entre 10 y 13", "entre 17 y 20") y cuántas preguntas por franja. La app las lanza en un momento al azar dentro de la franja, en el reloj y, si no hay reloj, en el móvil.

Ejemplos con la voz de un familiar:
- "Hola papá, soy Javier. ¿Estás bien?" → SÍ / NO.
- "¿Estás en casa?" → SÍ / NO.
- "¿Sabes dónde estás?" → SÍ / NO.
- "¿Has comido?" → SÍ / NO.

Qué pasa con cada respuesta (por defecto):

|Respuesta|Acción|
|---|---|
|SÍ a todo y dentro de zona segura|Se registra. No se avisa a nadie|
|SÍ pero fuera de zona segura|Se registra y llega aviso suave al familiar 1 con la ubicación|
|NO a "¿estás bien?" o "¿sabes dónde estás?"|Aviso inmediato al familiar 1 con ubicación y ruta reciente. El reloj ofrece "Llamar a Javier"|
|Sin respuesta a los 2 minutos|Repite más fuerte|
|Sin respuesta a los 5 minutos|Aviso al familiar 1 con ubicación|
|Sin respuesta a los 10 minutos|Aviso al familiar 2 y llamada automática del reloj al familiar 1|

El flujo es el de la pieza de localización ([pieza localizacion_perdida](https://developer.android.com/develop/sensors-and-location/location/background)). Es lógica propia: no cuesta servicio.

### 2.4 bis Control por horas: cómo estás, qué te duele, qué vas a hacer luego

Petición del promotor (12/10/2026): preguntarle cada hora y que su respuesta aparezca al momento en los móviles de cuidadores y familia, para tenerla acompañada todo el día. Decisión del promotor (12/10/2026): franja de 9 a 21 y las tres preguntas cada hora, ajustables desde la app de la familia.

**Cómo funciona para ella.**
- Cada hora, dentro de la franja despierta (**por defecto de 9 a 21**), el móvil o el reloj le hablan con la voz de un familiar: "Hola mamá, soy Lucía. ¿Cómo estás?". Nunca de noche. Si acaba de pasar una toma de medicación, la pregunta espera. La familia cambia la franja y el ritmo desde su app (pestaña Alarmas, 3.5). En iPhone, cómo se lanza la pregunta cada hora sin que la persona toque nada (notificación local con sonido o alarma de AlarmKit): sin verificar; se prueba en la semana 5.
- Las tres preguntas, en cada ronda, en este orden y con respuesta de un toque o de voz:
  1. **¿Cómo estás?** Cuatro caras grandes: bien, regular, mal, muy mal. O hablar.
  2. **¿Qué te duele?** Pictogramas grandes de ARASAAC: nada, cabeza, tripa, piernas, espalda, otro. Se pueden tocar varios. O hablar.
  3. **¿Qué vas a hacer luego?** Pictogramas: comer, pasear, dormir, tele, visita, nada. O hablar.
- Si habla, el móvil graba su respuesta y la transcribe en el propio dispositivo (Vosk o whisper.cpp, sección 8). La familia recibe el audio con su voz y el texto.
- En el reloj, por su pantalla pequeña, van las caras y hasta cuatro pictogramas; las respuestas por voz se hacen en el móvil. Si la familia prefiere, las tres preguntas van siempre al móvil y el reloj solo vibra para avisar.
- Botón "Ahora no" siempre visible. Si no responde, se repite a los 2 minutos; a los 5 avisa al familiar 1; a los 10 al familiar 2 (mismo escalado que 2.4).
- Si el cuidador de turno marca en su app "estoy con ella", las preguntas se pausan y es él quien anota cómo está, con las mismas tres preguntas.

**Cómo lo ven cuidadores y familia.**
- En Hoy, una **línea del día**: una tarjeta por hora con la cara, los pictogramas, el texto o el audio, la hora, cuánto tardó en responder y dónde estaba. Verde si respondió, naranja si tardó, rojo si no respondió o dijo "mal" o "muy mal".
- Avisos inmediatos a quien la familia decida: "mal" o "muy mal", un dolor nuevo, dos preguntas sin respuesta seguidas, o un dolor repetido tres veces en el día.
- Vista de semana: cuántas veces le dolió cada cosa y a qué horas; cómo estuvo por franjas. Son sus respuestas tal cual, sin interpretación.
- Lo que dice que va a hacer luego se usa: si responde "pasear", la app espera su vuelta y a la hora pregunta "¿has vuelto del paseo?"; si responde "comer", la app registra la comida en Alimentación.
- Todas las respuestas entran como medidas del motor de pruebas en casa (3.8): ánimo y dolor por horas frente a cada intervención que se esté probando, sin teclear nada.

**Datos.** Entidad PreguntaControl ampliada: tipo (estado, dolor, plan), respuesta (icono, texto, audio), tiempo de respuesta, origen (móvil, reloj, cuidador), ubicación, quién fue avisado. Audio cifrado como los vídeos (9.5). Consentimiento de la persona en lo que entienda y del representante.

**Roadmap.** Entra en la semana 5 en el iPhone, antes del reloj, porque no depende de él; en el reloj, en la semana 6 con el resto de la app de reloj.

### 2.5 "Me he perdido" y "No responde"

**"Me he perdido" (lo pulsa la persona).** El botón rojo del móvil o del reloj:
1. Habla la voz de un familiar: "Tranquila, mamá. Ya viene alguien. Quédate donde estás".
2. Activa el **modo perdido**: ubicación cada pocos segundos con servicio en primer plano de tipo ubicación.
3. Avisa a todos los familiares del círculo con mapa y ruta reciente.
4. Llama al familiar 1 por el reloj.
5. Muestra en el reloj, en grande: nombre, "Tengo Alzheimer" y el teléfono del familiar, para quien la encuentre.

**"No responde" (lo detecta el sistema).** Preguntas sin respuesta, salida de zona segura o caída detectada activan el mismo modo perdido, pero sin hablar a la persona primero. La familia ve un botón "Llamar al 112" con la ficha de la persona (foto, datos médicos, medicación, ruta). El detalle está en la sección 7.

### 2.6 Llamar a la familia con un toque

Fotos grandes en "Mi gente". Un toque llama. No hay teclado ni agenda. Por defecto, como mucho cuatro fotos en el móvil y dos en el reloj.

### 2.7 Mensajes y fotos de la familia

La familia manda una foto con una frase grabada ("Mira a tu nieta en el colegio"). Sale como tarjeta grande en el inicio y suena una vez. Solo hay un botón: "Llamar".

### 2.8 Música

Botón "Mi música" con la lista que carga la familia. Un toque reproduce, otro para. Se calla durante una alarma.

### 2.9 Qué NO tiene la app de la persona

- Ni menús, ni ajustes, ni teclado, ni navegador, ni tienda de apps.
- Ni catálogo, ni alimentación, ni ideas, ni tablas.
- Ni grabaciones de consultas, ni historial de vídeos, ni alertas a familiares.
- No permite borrar una toma, cambiar una pauta ni desactivar una alarma.
- No usa IA en la nube con sus datos.

## NACHO · 3. La app de la FAMILIA

Es el centro de mando. Cada familiar la instala en su móvil. Diez pestañas. Las tres últimas antes de Ajustes (Alimentación, Ideas y tablas, Círculo) son solo para la familia y no tienen nada que ver con la pantalla de la persona.

### 3.1 Hoy

Lo primero que ve un familiar al abrir:
- **Estado** en un semáforo: verde (todo confirmado y en zona), naranja (algo sin vídeo o pregunta sin responder), rojo (toma no confirmada, fuera de zona, SOS o caída).
- **Última toma**: hora, pastilla, quién confirmó y cómo (móvil, reloj; NFC, si se activa más adelante).
- **Último vídeo** de comprobación, para verlo con un toque. Botones: "Toma verificada" o "Dudosa".
- **Dónde está**: mapa con la última ubicación, la hora de esa ubicación y la batería del reloj y del móvil.
- **Última respuesta de control**: pregunta, respuesta y hora.
- **Lo siguiente**: próxima toma y próxima cita.

### 3.2 Medicación

- **Alta de un medicamento**. Se busca por nombre en CIMA, la API pública de la AEMPS. Cada registro trae número de registro, nombre, laboratorio, dosis, forma, principio activo, prospecto y un listado de fotos ([CIMA REST](https://cima.aemps.es/cima/rest/medicamentos)). No todos los registros tienen foto (cobertura sin verificar): la familia **siempre** puede hacer su propia foto de la caja y de la pastilla.
- **Hoja de tratamiento con foto**. El familiar fotografía la hoja del médico; el texto se reconoce en el móvil con ML Kit Text Recognition v2 ([ML Kit](https://developers.google.com/ml-kit/vision/text-recognition/v2/android)) y se confirma línea a línea. La letra manuscrita no está garantizada: nunca se da de alta nada sin confirmar.
- **Pauta**: hora, dosis, días, compartimento del pastillero, voz que la anuncia, y si se pide foto o vídeo.
- **Calendario de tomas**: vista por día y semana con cada toma en verde (verificada), azul (confirmada), naranja (confirmada sin vídeo o dudosa) o rojo (no confirmada).
- **Historial con vídeos**: cada toma con su clip; filtrable por medicamento.
- **Cambios con fecha y quién los hizo**: cada alta, baja o cambio de dosis queda escrito con fecha, familiar que lo hizo y, si viene de una consulta, el enlace a la grabación. El registro es de solo inserción, como en Plan v2: no se borra, se corrige con otra entrada.

### 3.3 Calendario

- **Citas** médicas y de otro tipo, con lugar, motivo y quién acompaña.
- **Turnos de cuidado**: quién está con la persona cada día o franja.
- **Recordatorios compartidos** ("comprar pastillas el viernes", "renovar receta").
- Exportar a `.ics` (formato iCalendar, [RFC 5545](https://www.rfc-editor.org/rfc/rfc5545)) y botón "Añadir a mi calendario" que abre el calendario del sistema sin pedir permisos ([Calendar Provider](https://developer.android.com/identity/providers/calendar-provider)).
- La persona solo ve en su inicio la próxima cita, en grande y con foto del médico o del lugar si la familia la pone.

### 3.4 Consultas

- **Grabar** desde la ficha de la cita, tras pedir permiso al médico con un texto breve que la app anota.
- **Transcribir en el móvil**, sin nube (whisper.cpp o Vosk, sección 8).
- **Buscar** por palabras en transcripciones y notas ("¿cuándo dijo que bajáramos la dosis?").
- **Resumen** guiado que escribe el familiar: qué dijo el médico, qué cambia, próxima cita.
- **Vincular** a la cita y a cada cambio de medicación: desde un cambio de dosis se salta al minuto de la grabación.

### 3.5 Alarmas

- **Quién recibe qué**: tabla de familiares por tipo de aviso (toma no confirmada, pregunta sin respuesta, fuera de zona, SOS, caída, batería baja).
- **Escalado**: orden de familiares y minutos de cada paso (por defecto los de 2.2 y 2.4; el orden de familiares lo fijará el promotor más adelante).
- **Control por horas**: franja (por defecto de 9 a 21) y ritmo (por defecto, las tres preguntas cada hora).
- **Horarios de silencio** por familiar: de noche solo recibe SOS y caídas. Siempre hay al menos un familiar de guardia; la app no deja guardar un horario que deje una franja sin nadie.
- **Prueba de alarma**: lanza una toma falsa.

### 3.6 Voces

- **Grabar frases** del guion (sección 5); escuchar y repetir cada toma.
- **Clonar**: 10-30 s de referencia; el lote se genera en un PC de la familia y se aprueba frase a frase.
- **Probar** cualquier frase en el móvil y el reloj de la persona.
- **Ver la reacción**: por voz y por frase, respuestas, silencios y marcas de "se calmó" o "se inquietó". Retirar una voz con un toque.

### 3.7 Alimentación (solo familia)

- **Menús de la semana**: el familiar planifica comidas y cenas. Puede marcar el patrón que quiere seguir (MIND, mediterránea, cetogénica, vegana tipo Ornish o el suyo propio); la app no recomienda ninguno.
- **Hidratación**: vasos al día con un toque y aviso a la persona con voz de la familia ("¿Bebemos un vaso de agua?"). El catálogo no tiene filas sobre hidratación (comprobado: 0 coincidencias); la meta diaria la pone la familia.
- **Registro de comidas**: foto del plato, qué comió (todo, la mitad, poco, nada) y hora. Opcional: puntuación MIND semanal, idea que propone el dosier de alimentación.
- **Lo que dicen las fuentes**: las 44 filas del tema `nutricion_alimentos` del catálogo, con la cifra tal cual, quién pagó y el enlace. Ejemplos que la familia verá así:
  - Dieta MIND, ensayo de 3 años y 604 personas: "diferencia 0.035 (IC95% -0.022 a 0.092; P=0.23)" ([Barnes 2023](https://pubmed.ncbi.nlm.nih.gov/37466280/)). Financiado por el NIA según el dosier.
  - Dieta MIND, observacional, 923 personas: "3er tercil HR 0.47 (0.26-0.76)" ([Morris 2015](https://pubmed.ncbi.nlm.nih.gov/25681666/)).
  - Vajilla roja en Alzheimer avanzado: "+25% de comida y +84% de líquido; 8 de 9 aumentaron" ([Dunne 2004](https://pubmed.ncbi.nlm.nih.gov/15297089/)).
  - Aceite MCT 42 g/día: "80% estables o mejor" ([Juby 2022](https://pubmed.ncbi.nlm.nih.gov/35310527/)).
  - Leche con probióticos: "MMSE +27.90% (±8.07) vs -5.03% (±3.00), P<0.001" ([Akbari 2016](https://pubmed.ncbi.nlm.nih.gov/27891089/)).
- **Lo enterrado** (p. ej. NCT03998423, NCT04396015) y **Probar en casa** con el motor de pruebas (3.8).

### 3.8 Ideas y tablas (solo familia)

Es el trabajo ya hecho, puesto dentro de la app.
- **Catálogo**: 647 estudios, 15 temas, 353 intervenciones, con cifra tal cual, dirección según la fuente, tipo de fuente, n, dosis, efectos adversos, **quién paga** y enlace (`catalogo/out/CATALOGO.xlsx`, hoja "Filas", 21 columnas).
- **Filtros** que pone la familia: tema, tipo de fuente, dirección (mejora, sin cambio, empeora, mixto), financiación, coste, "cómo probarlo en casa". Sin pesos ni niveles de evidencia. Nadie de la industria hace de juez.
- **Tablas que dan opciones**: la hoja "Resumen" (355 filas): por intervención, cuántos estudios y cuántos dicen mejora, sin cambio, empeora o mixto.
- **Dosieres**: los 15 dosieres (`DOSIERES.md`): tesis, defensores, mecanismos, consenso y quién lo paga, lo enterrado, protocolos, riesgos que reconocen los defensores, fuentes heterodoxas e ideas para la app.
- **Enterrados**: la hoja "Enterrado" (214 filas): ensayos que se registraron y no publicaron.
- **Quién paga**: vista que agrupa por financiador y marca si vende el producto.
- **Motor de pruebas en casa**: el de Plan v2, sección 4. Protocolo tomado de las fuentes, aviso de lo que reportan (informa, no bloquea), 14 días de base, diseños AB, ABA o ABAB, medidas diarias de un toque y semanales guiadas, antes y después con datos tal cual. **Ventaja nueva de este plan**: la adherencia ya no se teclea; sale sola de las tomas confirmadas con vídeo. Y los cambios de medicación de las consultas aparecen solos en la gráfica como "cambio simultáneo".

### 3.9 Círculo

- **Familiares** con foto, teléfono y relación.
- **Roles**: *responsable* (cambia pautas, consentimientos y el círculo; puede haber dos), *cuidador* (ve todo, confirma tomas, recibe alarmas), *apoyo* (ve el estado y recibe avisos que se le asignen), *lectura* (solo ve).
- **Relevo**: quién está de guardia hoy; cambio de turno en un toque, enlazado al calendario.
- Invitar con código de un solo uso; expulsar revoca acceso y claves.

### 3.10 Ajustes

- **Datos**: qué se guarda, dónde y cuánto tiempo. Por defecto los vídeos se borran del servidor al entregarse a todos o a los 7 días, y de los móviles a los 90 días salvo los marcados.
- **Exportar**: PDF para el médico, CSV y JSON.
- **Borrar**: borrar una grabación, una voz, un periodo o todo. Borrado también en el servidor.
- **Consentimientos**: quién autoriza en nombre de la persona y con qué documento; consentimiento de cada familiar para su voz; aviso al médico en cada grabación. Revocables.
- **Asistente de instalación** del móvil de la persona, paso a paso: en iPhone, Acceso Asistido, autorización de AlarmKit y avisos (secciones 2.1 y 6.2); en Android, por marca (sección 6.1).

## NACHO · 4. El reloj

### 4.1 Qué pidió el promotor y qué tiene que hacer el reloj

Mostrar la foto de la pastilla, sonar hasta confirmar, botón para confirmar, monitorizar de alguna forma la toma, voz de la familia, preguntas de control, GPS, SOS, caída, y avisar a la familia sin depender del móvil. Decisión del promotor (12/10/2026): el reloj es un Apple Watch.

### 4.2 Comparativa con precios en España

|Opción|Precio visto|Foto de pastilla y alarma propia|Voz familiar|Preguntas de control|GPS / LTE|SOS / caída|Fuente|
|---|---|---|---|---|---|---|---|
|Samsung Galaxy Watch8 40 mm LTE (plan B, Android)|487,40 € (PcComponentes, versión internacional)|Sí, app propia Wear OS|Sí, altavoz|Sí|Sí / Sí|SOS por app propia; caída del sistema a terceros sin verificar|[PcComponentes](https://www.pccomponentes.com/samsung-galaxy-watch8-4g-lte-gps-40mm-super-amoled-grafito-s-m-version-internacional), [Wear OS](https://developer.android.com/training/wearables/get-started)|
|Samsung Galaxy Watch8 Classic 46 mm LTE (plan B, Android)|PVP 579 €; ofertas desde 249,95 € (liquidación, nov. 2025)|Sí|Sí|Sí|Sí / Sí|Igual que arriba|[Powerplanet](https://www.powerplanetonline.com/es/samsung-galaxy-watch8-classic-46mm-lte-blanco)|
|Google Pixel Watch 4 LTE|Filtración 499 € (41 mm) y 549 € (45 mm), precios de Francia; oferta vista 368,78 € (45 mm, fecha desconocida). Sin verificar en España|Sí|Sí|Sí|Sí / Sí|Sin verificar|[Android Authority](https://www.androidauthority.com/google-pixel-watch-4-pricing-leak-3578995)|
|**Apple Watch SE GPS + Cellular** (recomendado)|Lanzamiento 2023: 329 € (40 mm) y 359 € (44 mm); ofertas 275-340 €. Actual sin verificar|Sí, app watchOS|Sí|Sí|Sí / Sí|Detección de caídas oficial, llama a emergencias tras ~1 min inmóvil|[Xataka](https://www.xatakamovil.com/apple/apple-watch-se-2023-caracteristicas-precio-ficha-tecnica/amp), [Apple caídas](https://support.apple.com/en-us/108896)|
|SaveFamily Senior (cerrado)|99 € sin SIM + 6 €/mes (5 €/mes con plan anual de 60 €)|**No**: no es programable|No|No|Sí / Sí (SIM propia)|Sí, SOS y caída del fabricante|[PcComponentes](https://www.pccomponentes.com/savefamily-senior-smartwatch-pantalla-ips-1-4-gps-aviso-de-cai-da-boton-sos-negro-no-incluye-sim), [SaveFamily](https://savefamilygps.com/products/reloj-con-gps-para-adultos-altas-calidades-mide-el-ritmo-cardiaco)|
|Nock Senior (Neki)|79 € + desde 12 €/mes según prensa (sin verificar en tienda)|No|No|No|Sí|SOS|[wwwhatsnew](https://wwwhatsnew.com/?p=262838)|
|Bangle.js 2 (abierto)|£99,60 IVA incluido; unos 90 € en Berrybase|Aviso, vibración y botón; foto pequeña sin verificar|No consta altavoz|Sí, por toque|GPS sí / LTE no|Sin LTE: depende del móvil cerca|[banglejs.com](https://banglejs.com/), [Berrybase](https://www.berrybase.de/es/espruino-bangle.js-v2-smartwatch-schwarz)|
|PineTime (abierto)|Sin verificar|Aviso y botón|No consta|Por toque|No consta|Depende del móvil|[InfiniTime](https://github.com/InfiniTimeOrg/InfiniTime)|

Garmin, Amazfit, Xiaomi y Huawei: sin verificar en precio y sensores; no se recomiendan todavía.

### 4.3 Recomendación principal

**Apple Watch, con app propia en watchOS. La opción económica es el Apple Watch SE con datos móviles (GPS + Cellular).**

Por qué:
- Encaja con el iPhone de la persona (decisión del promotor, 12/10/2026). La alerta de AlarmKit del iPhone se reenvía al Apple Watch emparejado, si lo hay ([Apple](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit)).
- Tiene **detección de caídas oficial** (se activa sola a partir de 55 años) con cuenta atrás y llamada a emergencias ([Apple caídas](https://support.apple.com/en-us/108896), [Apple Family Setup](https://support.apple.com/en-us/109036)).
- Según la tabla de 4.2, hace lo pedido con una app watchOS: foto de la pastilla, voz de la familia, preguntas de control, GPS y SOS. Se programa en Swift. Requisitos del Mac y de Xcode: sin verificar.

Tres formas de montarlo, según cómo viva ella:
- **Apple Watch SE GPS + Cellular** (opción económica): línea propia, así que avisa aunque el iPhone se quede en casa. Precio visto: lanzamiento de 2023, 329 € (40 mm) y 359 € (44 mm); ofertas 275-340 €. Precio actual sin verificar ([Xataka](https://www.xatakamovil.com/apple/apple-watch-se-2023-caracteristicas-precio-ficha-tecnica/amp)).
- **Apple Watch sin datos móviles, emparejado a su iPhone**: también vale si ella lleva siempre su iPhone. No hay cuota, pero depende de que el iPhone esté cerca. Modelo y precio: sin verificar en esta investigación.
- **Family Setup**: solo si la persona no tiene iPhone propio. El reloj se gestiona desde el iPhone de otro familiar y no incluye algunas funciones de salud ([Apple Family Setup](https://support.apple.com/en-us/109036)).

Límites que hay que saber antes de comprar:
- **Autonomía**: sin verificar. Se asume carga diaria (sección 7.6). La app de la familia avisa con batería baja.
- **Línea de datos**: solo en el modelo Cellular. Necesita una tarifa del operador, con cuota mensual sin verificar.
- **Caídas**: la detección es oficial, pero que nuestra app lea el evento está sin verificar. Plan: usar la función de caídas del propio reloj, configurada por la familia, y en paralelo un detector propio con el acelerómetro que se mide en pruebas (7.4).
- **Cuenta de Apple Developer**: hace falta para instalar nuestra app en el iPhone y el Apple Watch reales (sección 9.6).
- **No sabe si se tragó la pastilla.** Ningún reloj lo sabe.

### 4.4 Plan B y plan C

- **Plan B, para familias Android: Samsung Galaxy Watch8 o Watch8 Classic con LTE**, el que esté más barato en oferta, con app propia en Wear OS.
  - Hace **todo lo pedido** con licencias gratuitas: pantalla para la foto, altavoz para la voz, botón de confirmar, GPS, LTE propio y app independiente que funciona sin el móvil ([Wear OS](https://developer.android.com/training/wearables/get-started)).
  - Wear OS se programa en Kotlin con Compose. Android Studio es gratis. Encaja con el envío de audios por Data Layer ([Data Layer](https://developer.android.com/training/wearables/data/messages)).
  - El Classic en liquidación (desde 249,95 €) es la entrada más barata vista con LTE. Precio de noviembre de 2025: hay que confirmarlo en tienda.
  - Límites: autonomía en torno a un día, sin verificar. Línea o eSIM del operador, con cuota sin verificar. El acceso de apps de terceros a la detección de caídas de Samsung está sin verificar, y Health Services de Wear OS no documenta una API de caídas ([Health Services](https://developer.android.com/training/wearables/health-services/passive)).
- **Plan C, si la familia no quiere smartwatch o no puede cargarlo cada día**: SaveFamily Senior (99 € + 5-6 €/mes) para SOS, caída y ubicación con su propia app. Nuestra app no puede hablarle, así que las preguntas de control y la voz pasan al móvil, y la confirmación de la toma al móvil (y a la NFC, si se activa más adelante).

### 4.5 Qué comprar para empezar

1. **Un** Apple Watch SE GPS + Cellular. No comprar varios hasta probar 2 semanas. Si ella lleva siempre su iPhone, sirve un Apple Watch sin datos móviles (precio sin verificar).
2. Una tarifa de datos para el reloj, solo con el modelo Cellular (precio según operador, sin verificar).
3. Si el iPhone de ella no es un iPhone 11 o posterior, Apple no lo da como compatible con iOS 26 ([Apple](https://www.apple.com/newsroom/2025/06/apple-elevates-the-iphone-experience-with-ios-26/)); el iPhone SE (2.ª generación) no se ha comprobado. Entonces se activa el plan B de 6.2 o se compra un iPhone compatible (modelo y precio sin verificar en esta investigación). La versión mínima de iOS que pide cada Apple Watch: sin verificar.
4. La cuenta de Apple Developer (99 USD/año, o exención para entidades sin ánimo de lucro) desde la semana 1 (sección 9.6).
5. Un pastillero semanal que llena la familia. Las etiquetas NFC, solo si más adelante se activa esa opción (sección 6.4).
6. Familias Android: un Galaxy Watch8 Classic LTE (o Watch8 LTE) en oferta y un móvil Android reciente y con NFC (requisito que fijamos nosotros; modelo y precio sin verificar en esta investigación).

## NACHO · 5. Las voces de la familia

El promotor pide las voces de los familiares, clonadas. Se hace en dos capas que se suman: primero la voz real grabada, que no falla nunca; después la voz clonada, para las frases que nadie ha grabado.

### 5.1 Capa 1: biblioteca grabada

- Cada familiar graba con su móvil un guion cerrado de 30 a 60 frases. Se guarda como audio (AAC u Opus) con su texto y su uso ([MediaRecorder](https://developer.android.com/reference/android/media/MediaRecorder)). El equivalente en iPhone: sin verificar.
- Se sincroniza al móvil de la persona por el servidor y al reloj Wear OS (plan B) por Data Layer: `DataClient` con Asset para frases y `ChannelClient` para archivos grandes. `MessageClient` no sirve para audio porque no reintenta ([Data Layer](https://developer.android.com/training/wearables/data/messages)). Al Apple Watch, la vía de envío de archivos desde el iPhone (WatchConnectivity) queda sin verificar: no se ha leído su documentación.
- Se reproduce sin red. Coste cero. Sin riesgo legal de clonación.
- Las frases con nombres u horas variables se graban por piezas ("es la hora de" + "la pastilla blanca" + "de la mañana").

### 5.2 Capa 2: clonación con modelo abierto

**Qué modelo.** Primera opción: **Chatterbox Multilingual** de Resemble AI. Licencia MIT, más de 23 idiomas con español y afinados para español de España, clonación con un clip de referencia de unos 10 segundos ([GitHub](https://github.com/resemble-ai/chatterbox), [Hugging Face](https://huggingface.co/ResembleAI/chatterbox)). Todo audio generado lleva la marca de agua Perth, lo cual ayuda a etiquetarlo como voz generada.

Alternativas con licencia libre: **OpenVoice v2** (MIT, español nativo, [GitHub](https://github.com/myshell-ai/OpenVoice)) y **CosyVoice 3** (Apache-2.0, español entre 9 idiomas, [GitHub](https://github.com/FunAudioLLM/CosyVoice)).

**Descartados para una app abierta a muchas familias**, por licencia no comercial: XTTS v2 (pesos CPML, [Hugging Face](https://huggingface.co/coqui/XTTS-v2)), F5-TTS (pesos CC-BY-NC, [GitHub](https://github.com/SWivid/F5-TTS)) y Fish Speech (licencia de investigación, [licencia](https://github.com/fishaudio/fish-speech/blob/main/LICENSE)).

**En qué máquina se genera.** En un **PC de la familia**, no en el móvil. Ninguno de estos modelos tiene versión oficial para Android. Chatterbox Multilingual (500M) pide GPU NVIDIA; VRAM exacta sin verificar. **En esta familia sí hay un PC con tarjeta NVIDIA** (decisión del promotor, 12/10/2026), así que la clonación es viable y Chatterbox Multilingual sigue siendo la primera opción. Entra en fase posterior, después de grabar las voces (5.1). Modelo de la tarjeta y su VRAM: sin verificar. Para familias sin GPU, OpenVoice v2 puede ir en CPU, más lento (sin verificar). El proceso: el familiar graba 10-30 s limpios; un programa del proyecto (Python) genera en el PC el lote de frases de una vez; el familiar aprueba o descarta cada frase en su app; las aprobadas se suben como grabaciones marcadas "voz generada".

La voz de referencia y el modelo no salen de los equipos de la familia. Nada pasa por una IA en la nube.

**Calidad en español: sin verificar.** Nadie la ha medido con una voz real de la familia. La semana 9 del roadmap compara Chatterbox, OpenVoice y CosyVoice con la misma voz y la familia elige de oído.

**Respaldo si falta una frase**: voz genérica española en el móvil con el TTS del sistema Android ([TextToSpeech](https://developer.android.com/reference/android/speech/tts/TextToSpeech)) o con sherpa-onnx (Apache-2.0, funciona en Android y Wear OS, [GitHub](https://github.com/k2-fsa/sherpa-onnx)). En iPhone y Apple Watch, el TTS del sistema o sherpa-onnx: sin verificar. El registro indica cuándo se usó voz genérica.

### 5.3 Lista de frases iniciales

- **Medicación**: "[Nombre], soy [familiar]. Es la hora de tu pastilla." · "Es la [color y tamaño], la que ves en la pantalla." · "Está en el pastillero, en el día de hoy." · "Cuando te la tomes, toca el botón verde." · "Enséñame la pastilla y tómatela delante del móvil." · "Todavía no me has dicho que te la has tomado." · "Acerca el móvil a la pegatina del pastillero." · "Muy bien. Gracias."
- **Control**: "Hola, soy [familiar]. ¿Estás bien?" · "¿Estás en casa?" · "¿Sabes dónde estás?" · "¿Has comido?" · "¿Has bebido agua?" · "Toca sí o no."
- **Calma y ayuda**: "Tranquilo. Ya viene alguien." · "Quédate donde estás. Te estamos buscando." · "Si alguien te ayuda, enséñale el reloj." · "Te llamo ahora mismo." · "Te quiero mucho."
- **Día a día**: "Buenos días. Hoy es [día]." · "Hoy tienes médico a las [hora]." · "Vamos a cargar el reloj." · "Buenas noches."

### 5.4 Consentimiento

- **Del familiar** cuya voz se graba o se clona: escrito, informado y revocable. Qué se graba, para qué, dónde se guarda, quién lo oye y cómo se borra. Si lo retira, se borran su voz, su referencia y su lote.
- **Etiqueta**: toda frase clonada se marca como "voz generada" en la app de la familia. El Reglamento europeo de IA obliga a indicar contenido sintético según la pieza; esto es orientación sin fuente oficial abierta en esta investigación (sin verificar).
- Se informa al representante de la persona. No se clonan voces de terceros ni de fallecidos sin autorización.
- Esto es orientación técnica, no asesoría jurídica. Consultar a la AEPD antes de abrir a muchas familias.

### 5.5 Cómo se mide la reacción de la persona

No hay estudio verificado sobre el efecto de una voz familiar clonada en una persona con Alzheimer. Una voz parecida pero no idéntica podría confundirla. Por eso se mide desde el primer día:
- Por cada frase reproducida se guarda: voz, frase, si era grabada o generada, si la persona respondió y en cuántos segundos, si silenció o si la repetición fue necesaria.
- Un familiar presente puede marcar en su app "se calmó", "igual" o "se inquietó".
- La pestaña Voces muestra, por voz, el tiempo medio de respuesta y las marcas.
- Botón para retirar una voz o una frase y pasar a la grabada o a otra voz.
- Límite de repeticiones por hora para no saturar.
- Opcional: convertirlo en una prueba del motor (grabada frente a clonada, diseño ABAB) para que la familia decida con sus propios datos.

## NACHO · 6. Alarmas, cámara y comprobación física

### 6.1 Qué se puede garantizar en Android (ruta alternativa)

|Pieza|Qué hace|Límite real|Fuente|
|---|---|---|---|
|Alarma exacta (`setAlarmClock`, `setExactAndAllowWhileIdle`)|Suena a la hora aunque el móvil esté en reposo (Doze)|`SCHEDULE_EXACT_ALARM` no viene concedido en instalaciones nuevas y se puede revocar; `USE_EXACT_ALARM` lo limita la política de Play (detalle sin verificar)|[Alarmas](https://developer.android.com/develop/background-work/services/alarms/schedule), [Play](https://support.google.com/googleplay/android-developer/answer/13392821)|
|Notificación de pantalla completa|Abre la pantalla de toma sobre el bloqueo con la foto|Desde Android 14 solo se concede por defecto a apps de llamadas o alarmas; el resto pide permiso al usuario|[Android 14](https://developer.android.com/about/versions/14/behavior-changes-14)|
|Servicio en primer plano|Mantiene el sonido en bucle hasta confirmar|Desde Android 14 hay que declarar un tipo; `specialUse` exige justificación en Play Console|[Tipos de servicio](https://developer.android.com/develop/background-work/services/fgs/service-types)|
|Reprogramar tras reinicio|Vuelve a poner las alarmas al encender|Permiso `RECEIVE_BOOT_COMPLETED`|[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)|
|Fabricantes|—|Xiaomi, Huawei y otros matan procesos en segundo plano; hay que poner batería sin restricciones e inicio automático|[dontkillmyapp](https://dontkillmyapp.com/xiaomi)|

**Conclusión Android**: sí hay alarma a su hora, sobre la pantalla bloqueada, con foto, que no para hasta confirmar. Depende de tres cosas que deja hechas el asistente: app declarada de alarmas en Play Console, alarma exacta y pantalla completa concedidas, y batería sin restricciones. La app lo comprueba a diario y avisa a la familia si se pierde un permiso.

### 6.2 Qué se puede garantizar en iOS (ruta principal)

|Pieza|Qué hace|Límite real|Fuente|
|---|---|---|---|
|**AlarmKit (iOS 26 o superior)**|Alarma que, según Apple, suena aunque el iPhone esté en silencio o en modo Concentración; botón de parar y botón para abrir la app; el sistema reenvía la alerta al Apple Watch emparejado, si lo hay|Solo iOS 26.0 o posterior; pide autorización del usuario y la clave `NSAlarmKitUsageDescription` en el `Info.plist`, sin la cual no se pueden programar alarmas; la pantalla de alerta es la del sistema, así que la foto a pantalla completa se ve al abrir la app; si suena indefinidamente, sin verificar; parar o repetir desde el reloj, sin verificar|[AlarmKit](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit.md), [AlarmKit (marco)](https://developer.apple.com/documentation/alarmkit)|
|Notificaciones locales (antes de iOS 26)|Aviso a su hora|Máximo 64 pendientes; suenan una vez, no en bucle|[pieza alarmas](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter) (sin verificar en página)|
|Critical Alerts|Atraviesan No Molestar y silencio|Apple concede el permiso caso a caso|[Apple](https://developer.apple.com/documentation/usernotifications/unnotificationinterruptionlevel/critical) (sin verificar en página)|

**Conclusión iOS**: con iOS 26 y AlarmKit se cumple "suena hasta que se toma", con la foto al abrir. Según Apple, iOS 26 llega a los iPhone 11 y posteriores ([Apple](https://www.apple.com/newsroom/2025/06/apple-elevates-the-iphone-experience-with-ios-26/)). La lista completa de modelos, con el iPhone SE (2.ª generación), no se ha leído: sin verificar.

**Plan B si el iPhone no admite iOS 26**: con versiones anteriores no hay alarma en bucle fiable. Se repiten avisos time-sensitive, se pide a Apple Critical Alerts y el escalado a la familia de 2.2 sigue funcionando. Se valora además un iPhone compatible o la ruta Android para esa familia. El modelo de iPhone y la versión de iOS de la persona se comprueban en la semana 1 (pregunta abierta (a) de 11.2).

Desde Flutter hará falta un puente nativo en Swift a AlarmKit; si existe ya un plugin, sin verificar.

### 6.3 El flujo técnico de una toma

1. La pauta llega cifrada al móvil, que programa una alarma por toma (alarma exacta en Android, AlarmKit en iPhone) en una ventana deslizante de días. Cuántas alarmas admite AlarmKit a la vez: sin verificar.
2. A la hora: en iPhone, la alerta de AlarmKit y, al abrir la app, foto y voz grabada; en Android, notificación de pantalla completa + servicio de sonido, con foto, voz grabada y tono en bucle.
3. Confirmación (botón del móvil o del reloj; NFC, opción futura) → evento `toma_confirmada` con hora y origen.
4. Cámara frontal 10 s, que se libera en cada cambio de ciclo de vida ([camera](https://pub.dev/packages/camera)); clip cifrado y en cola; se para el sonido.
5. Sin confirmación en 5 minutos → `toma_no_confirmada` al servidor, que avisa al familiar 1; sin red en el móvil, avisa el reloj por LTE.

### 6.4 Las tres capas de comprobación

Ninguna capa prueba por sí sola que la pastilla se tragó. Juntas dan a la familia lo más cercano posible, y la última palabra es de un familiar.

**Capa 1: confirmación en pantalla o en el reloj.** El toque de "YA ME LA HE TOMADO" o de TOMADA. Prueba que la persona atendió el aviso. Es lo que apaga la alarma.

**Capa 2: foto o vídeo.** Vídeo de 10 segundos con la cámara frontal: se ve la pastilla en la mano y el gesto de tomarla. Lo revisa un familiar y marca "verificada" o "dudosa". Opción de ayuda, nunca de prueba: MediaPipe Hand Landmarker detecta 21 puntos de la mano en el móvil (17 ms en CPU en un Pixel 6, [MediaPipe](https://developers.google.com/edge/mediapipe/solutions/vision/hand_landmarker)) y puede marcar el clip como "posible gesto mano-boca". No hay cifras de fiabilidad publicadas para este uso. ML Kit no reconoce pastillas concretas ([ML Kit](https://developers.google.com/ml-kit/vision/object-detection)). Una persona con demencia puede enseñar la pastilla sin tragarla: por eso la familia mira el vídeo.

**Capa 3: pastillero (y NFC, opción futura).** Por ahora se construyen las capas 1 y 2; la NFC no (decisión del promotor, 12/10/2026). La alarma la apaga el botón y la comprobación es el vídeo.
- **Pastillero**: por ahora, un **pastillero semanal normal que llena la familia** (decisión del promotor, 12/10/2026). Alternativa para otras familias: el **SPD de la farmacia** (blísteres semanales preparados por el farmacéutico, con consentimiento informado firmado; coste según farmacia y comunidad, sin verificar; [guía de buenas prácticas](https://sefac.org/sites/default/files/2018-05/BBPP-14-SPD.pdf)). Un pastillero electrónico básico con alarma cuesta unos 20 € (InnovaGoods en MediaMarkt, [ficha](https://www.mediamarkt.es/es/product/_innovagoods-v0103066-83375118.html)), pero no se conecta a nada.
- **Etiqueta NFC (opción futura, no se construye por ahora)** pegada en cada día o compartimento. El móvil Android la lee al acercarlo y registra hora y compartimento ([NFC Android](https://developer.android.com/develop/connectivity/nfc/nfc)). Podría apagar la alarma en lugar del botón: así la persona tendría que ir al pastillero. Precio de etiquetas: sin verificar. En Android 16 el usuario puede revocar la lectura de etiquetas y en Android 17 hay requisitos nuevos de permisos ([NfcAdapter](https://developer.android.com/reference/android/nfc/NfcAdapter)). En iPhone, Core NFC lee etiquetas NDEF, con detalles sin verificar ([Core NFC](https://developer.apple.com/documentation/corenfc)). **Desde el reloj no**: no hay documentación oficial de lectura NFC para apps de terceros en Wear OS ni Apple Watch ([foro Samsung](https://forum.developer.samsung.com/t/nfc-is-supported-for-watch/21731)).
- **Plan B para familias con perfil técnico**: pastillero propio con sensor de peso y WiFi, partiendo de DoseBuddy (Arduino Uno R4 WiFi, unos 85 USD según su página; licencia por leer, [GitHub](https://github.com/BJGh/DoseBuddy)). Mendo (ESP32-S3) solo como referencia: no tiene licencia abierta OSI ([GitHub](https://github.com/Elegiac-Quantum/mendo-pill-dispenser)).
- **No se recomiendan**: suscripciones tipo Hero (29,99-44,99 USD al mes en EE. UU., sin API ni venta verificada en España, [fuente](https://aiht.substack.com/p/hero-pill-dispenser)).

En la app de la familia cada toma muestra sus capas: ✔ toque, ✔ vídeo, y el gesto del reloj como indicio (✔ NFC, cuando se active).

## NACHO · 7. Localización y seguridad

Los enlaces de esta sección son de Android. Su equivalente en iPhone y Apple Watch (ubicación en segundo plano, permisos, geocercas) queda sin verificar, salvo lo que citan 7.2 y 7.4. Se revisa antes de la semana 10.

### 7.1 Ubicación

- **Normal**: FusedLocation de bajo consumo; en segundo plano, unas pocas posiciones por hora ([ubicación en segundo plano](https://developer.android.com/develop/sensors-and-location/location/background), [batería](https://developer.android.com/develop/sensors-and-location/location/battery)).
- **Modo perdido**: servicio en primer plano de tipo ubicación, posición cada pocos segundos, hasta que un familiar lo cierre.
- En el reloj con LTE, el reloj manda su propia ubicación aunque el móvil se quede en casa.
- Se guarda la **ruta de las últimas horas** para enseñarla a quien busca.
- Google Play restringe el permiso de ubicación en segundo plano y exige justificarlo. Una app de seguridad para personas con demencia encaja, pero la aprobación no está garantizada.

### 7.2 Geocercas

- Zonas seguras con radio mínimo de 100 a 150 m (casa, barrio, centro de día). Android admite hasta 100 geocercas por app ([geofencing](https://developer.android.com/develop/sensors-and-location/location/geofencing)).
- **Límite real**: el aviso tarda de media 2-3 minutos y hasta unos 6 si el móvil está quieto. No es tiempo real.
- Google no recomienda geocercas en Wear OS por consumo. Por eso la geocerca va en el móvil y, si el móvil se queda en casa, el reloj compara su ubicación con la zona en el momento de cada pregunta de control y cada pocos minutos en franjas de riesgo.
- iOS: 20 regiones por app y permiso "Siempre", sin verificar en página oficial ([Core Location](https://developer.apple.com/documentation/corelocation/monitoring-the-user-s-proximity-to-geographic-regions)).
- Zonas por horario ("de noche, solo casa").

### 7.3 Protocolo si se pierde

1. **Salida de zona, SOS, caída o pregunta sin respuesta** → modo perdido.
2. Voz de un familiar en el reloj: "Quédate donde estás. Te estamos buscando". Pantalla con nombre, "Tengo Alzheimer" y teléfono.
3. Aviso a **todos** los familiares de guardia con mapa en vivo y ruta.
4. Llamada automática del reloj al familiar 1; si no contesta, al 2.
5. "Voy yo" en la app de la familia para saber quién va.
6. A los 15 minutos sin localizarla, la app propone llamar al 112 y muestra la **ficha para el 112**: foto reciente, descripción, ropa de hoy (si la familia la ha fotografiado por la mañana), medicación, enfermedades y última ubicación. El protocolo concreto del 112 en España (SMS, app 112 SOS) queda sin investigar.
7. Al encontrarla, un familiar cierra el modo perdido y escribe una nota.

**Refuerzo sin integración**: Find Hub de Google (localiza el reloj o el móvil incluso apagados, con bloqueo de pantalla, [Google](https://support.google.com/android/answer/3265955)) o Buscar (Find My) de Apple, que localiza iPhone y Apple Watch desde el móvil de un familiar ([Apple](https://support.apple.com/en-us/104978), página sin verificar en esta sesión). La familia los configura aparte. No tienen API para nuestra app (sin verificar).

### 7.4 Caídas

- **Apple Watch**: detección oficial; tras una caída e inmovilidad de un minuto, cuenta atrás de 30 s y llamada a emergencias con ubicación, y aviso a contactos ([Apple](https://support.apple.com/en-us/108896)).
- **Samsung y Pixel**: tienen detección del fabricante, pero su acceso desde nuestra app está sin verificar. Se configura la del reloj para que llame a un familiar. En paralelo, un detector propio con el acelerómetro marca "posible caída" y lanza la pregunta "¿Estás bien?"; si no responde, modo perdido. Su fiabilidad se mide en pruebas antes de usarlo para avisar.
- **SaveFamily Senior**: caída y llamada automática del fabricante ([SaveFamily](https://savefamilygps.com/products/reloj-con-gps-para-adultos-altas-calidades-mide-el-ritmo-cardiaco)).

### 7.5 Preguntas de control y escalado

El escalado es el de 2.4. Por defecto: 2 minutos repite, 5 avisa al familiar 1, 10 avisa al 2 y llama. La familia cambia los tiempos y el orden en Alarmas. Las preguntas de control también vigilan el reloj: si el reloj no manda señal en 30 minutos dentro de una franja activa, la familia recibe "el reloj no responde".

### 7.6 Batería

- Autonomía de los relojes LTE con ubicación frecuente: sin datos verificados. Se asume carga diaria.
- Rutina de carga: frase con voz de la familia a la hora de dormir ("Vamos a cargar el reloj"), base de carga junto a la cama, y aviso a la familia si a las 23:00 el reloj no está cargando.
- Aviso a la familia con batería por debajo del 30 % y del 15 %, en reloj y móvil.
- Los registros pasivos de Health Services no sobreviven a un reinicio: la app los vuelve a registrar al arrancar ([Health Services](https://developer.android.com/training/wearables/health-services/passive)).

## NACHO · 8. Grabación de consultas

### 8.1 Flujo

1. El familiar abre la cita en el calendario de la app.
2. Pulsa "Avisar al médico": la app muestra un texto breve para pedir permiso y anota que se pidió.
3. Pulsa **Grabar**. Indicador visible. Audio cifrado en el móvil, unido a la cita ([MediaRecorder](https://developer.android.com/reference/android/media/MediaRecorder.AudioSource)). Con la pantalla apagada hace falta servicio en primer plano; el detalle por versión de Android está sin verificar.
4. Al terminar, la transcripción se hace en el móvil, mejor cargando y con wifi.
5. Se indexa para búsqueda local (SQLite FTS5, [sqlite.org](https://www.sqlite.org/fts5.html)).
6. El familiar escribe el resumen guiado y marca decisiones.
7. Foto de la hoja de tratamiento → ML Kit → confirmación → alta o cambio contra CIMA, con fecha y enlace a la grabación.
8. Se programan la próxima cita y los cambios de pauta, que llegan solos al móvil de la persona.

### 8.2 Transcripción sin nube

|Motor|Tamaño|Precisión publicada (WER, español)|Licencia|Fuente|
|---|---|---|---|---|
|Vosk small-es 0.42|39 MB|16,02 (cv), 16,72 (mtedx), 11,21 (mls)|Apache-2.0|[Vosk](https://alphacephei.com/vosk/models)|
|Vosk es 0.42 grande|1,4 GB|7,50 (cv), 10,05 (mtedx), 5,84 (mls)|Apache-2.0|[Vosk](https://alphacephei.com/vosk/models)|
|whisper.cpp base / small|142 MiB (~388 MB RAM) / 466 MiB (~852 MB RAM)|Sin verificar en español de consulta|MIT (código)|[whisper.cpp](https://github.com/ggml-org/whisper.cpp)|

Elección por defecto: **whisper.cpp base cuantizado** después de la consulta, y **Vosk small-es** como alternativa ligera. Esas cifras son de audio leído y limpio, no de una consulta con ruido, varias voces y nombres de fármacos. La precisión real se mide en la semana 12 con grabaciones de prueba consentidas. La transcripción es para buscar y repasar. **El audio original se guarda siempre.** El reconocimiento de voz del sistema puede mandar audio a la nube, así que no se usa.

### 8.3 Situación legal en España, en tres líneas

- Grabar una conversación en la que uno participa no vulnera el secreto de las comunicaciones (STC 114/1984, [Tribunal Constitucional](https://hj.tribunalconstitucional.es/en/Resolucion/GetDocumentResolucion/367)); difundirla sí puede afectar al honor y la intimidad.
- La información clínica es del paciente; se informa a familiares en la medida en que el paciente lo permita y, si no puede entenderla, a las personas vinculadas o a su representante (Ley 41/2002, art. 5, [BOE](https://www.boe.es/buscar/act.php?id=BOE-A-2002-22188)).
- Lo prudente: avisar al médico y pedir conformidad. No es asesoría jurídica; validar con un abogado antes de abrir a muchas familias.

### 8.4 Buenas prácticas

- Pedir permiso siempre. Si el médico se niega, respetarlo y pedir informe escrito.
- Grabar solo para la familia. No publicar ni compartir fuera del círculo.
- Guardar cifrado; solo lo oyen responsables y cuidadores. Informar a la persona en lo que entienda.
- No grabar llamadas telefónicas: no es fiable en el móvil.
- La transcripción no sustituye al informe del médico.

## NACHO · 9. Arquitectura y datos

### 9.1 Piezas

- **Móvil de la persona (iPhone, iOS 26)**: Flutter, con una capa nativa fina en Swift para AlarmKit, Acceso Asistido y avisos. Base local Drift con SQLCipher.
- **App de la familia**: Flutter, un solo código para Android e iPhone ("son los dos", decisión del promotor), como en Plan v2. Las secciones 3 y 8 citan APIs de Android (ML Kit, MediaRecorder, Calendar Provider): en iPhone hace falta su equivalente, sin verificar caso por caso. Se revisa antes de la semana 3.
- **Ruta Android para otras familias**: la misma app de la persona con capa nativa Kotlin para alarma exacta, pantalla completa, servicio en primer plano y NFC (sección 6.1).
- **Reloj (Apple Watch)**: app nativa en Swift para watchOS. Que funcione sin el iPhone cerca, con datos móviles: sin verificar en la documentación de Apple.
- **Reloj plan B (Wear OS)**: app nativa Kotlin con Compose for Wear OS, independiente del móvil ([Wear OS](https://developer.android.com/training/wearables/get-started)). Hay plugins Flutter para Wear OS, pero sin soporte oficial y con sensores y servicios en nativo ([flutter_wear_os_connectivity](https://pub.dev/documentation/flutter_wear_os_connectivity/latest/)).
- **Servidor**: **Supabase Free en Frankfurt**, el mismo de Plan v2 ([precios](https://supabase.com/pricing)). Por qué: base de datos, autenticación, almacenamiento y tiempo real en un solo servicio gratuito, en la UE, con código abierto que se puede alojar en otro sitio si cambian las condiciones. Va detrás de una capa abstracta para poder cambiarlo. Límite conocido: el plan gratuito se pausa tras una semana sin actividad; con tomas diarias no ocurre. Cupo de almacenamiento del plan gratuito: sin verificar en el material.
- **Avisos push** a los familiares: Firebase Cloud Messaging en Android y APNs en iOS. Coste y condiciones: sin verificar en las piezas. El aviso lleva solo "hay novedades"; el contenido se descarga cifrado.
- **Compilación**: GitHub Actions y Codemagic para iOS, como en Plan v2. Instalar en el iPhone y el Apple Watch reales exige cuenta de Apple (9.6). Si hace falta un Mac con Xcode para la capa Swift y watchOS: sin verificar.

### 9.2 Cifrado

- Cada círculo familiar tiene una clave propia, creada en el móvil del responsable y repartida a cada miembro al aceptar la invitación. El servidor nunca la tiene.
- Todo lo que sube (eventos, vídeos, audios, transcripciones) va cifrado en el móvil de origen y, además, por TLS.
- En el móvil, base SQLCipher y archivos cifrados.
- Expulsar a un miembro rota la clave.
- EIPD (evaluación de impacto) antes de abrir a familias reales, con la guía de la AEPD ([AEPD](https://www.aepd.es/guias/gestion-riesgo-y-evaluacion-impacto-en-tratamientos-datos-personales.pdf)).

### 9.3 Modelo de datos (entidades)

- **Personas**: Persona (alias, foto, datos para el 112, apoyos según la Ley 8/2021), Miembro (rol, horario de silencio, orden de escalado), Dispositivo (permisos, batería, última señal), Consentimiento (quién, sobre qué, documento, fecha, revocado).
- **Medicación**: Medicamento (registro CIMA, fotos), Pauta (dosis, horas, compartimento, voz, foto o vídeo), Toma (prevista, confirmada, origen, estado, gesto), Comprobación (clip, revisor, veredicto), CambioMedicación (qué, quién, cuándo, consulta de origen).
- **Agenda y consultas**: Cita, Turno, Recordatorio, Consulta (audio, transcripción, resumen, decisiones).
- **Voces**: Voz (grabada o generada, modelo), Frase (texto, uso, aprobada), Reproducción (respuesta, tiempo, reacción).
- **Seguridad**: PreguntaControl, Ubicación, ZonaSegura, Incidente, Aviso (destinatario, leído, escalado).
- **Alimentación**: Comida, Hidratación.
- **De Plan v2**: catálogo (Estudio, Intervención, Protocolo, Financiador, EnsayoRegistrado, Tema) y pruebas en casa (Prueba, Fase, Medida, Evento, EventoAdverso, CambioSimultáneo).
- Todo evento es de solo inserción.

### 9.4 Sin conexión

- Las alarmas, la voz, las fotos de pastillas y las preguntas de control funcionan sin red: están en el móvil y en el reloj.
- Los eventos se guardan y se suben cuando vuelve la red.
- Si el móvil de la persona no tiene red, el reloj con LTE manda los avisos urgentes.
- La familia ve cuándo fue la última señal de cada dispositivo.

### 9.5 Cómo viaja un vídeo de comprobación

1. Grabación de 10 s en el móvil de la persona, a resolución baja (tamaño por clip sin medir).
2. Cifrado en el móvil con la clave del círculo.
3. Subida al buzón privado del servidor; si no hay red, queda en cola.
4. El servidor anota "vídeo nuevo" y manda push a cuidadores y responsables.
5. Cada móvil familiar descarga, descifra y guarda.
6. Cuando todos lo han descargado, o a los 7 días, se borra del servidor.
7. En los móviles se borra a los 90 días, salvo los marcados.

### 9.6 Costes (solo lo inevitable)

|Concepto|Coste|Fuente|
|---|---|---|
|Google Play, cuenta de desarrollador (app de la familia en Android)|25 USD, pago único|[Google](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)|
|**Apple Developer, inevitable desde la semana 1**: hay que instalar la app en su iPhone y su Apple Watch|99 USD/año o 0 € con exención para entidades sin ánimo de lucro|[Apple](https://developer.apple.com/support/membership-fee-waiver/), [Apple](https://developer.apple.com/programs/whats-included/)|
|Alternativa: Apple ID gratuito ("Personal Team" en Xcode)|0 €. Instalación desde Xcode, con límites: hasta 3 dispositivos y 3 apps por dispositivo, 10 App IDs, y todo caduca a los 7 días (hay que recompilar y reinstalar). Las betas y la distribución se gestionan en App Store Connect, que se abre con la membresía. TestFlight y Apple Watch con cuenta gratuita: sin verificar. Solo vale para pruebas de pocos días, no para el uso diario de la persona|[Apple](https://developer.apple.com/support/compare-memberships/)|
|Supabase Free, GitHub, Codemagic Free|0 €|Plan v2, sección 5.3|
|Flutter, Kotlin, Android Studio, Vosk, whisper.cpp, Chatterbox, sherpa-onnx|0 € (código abierto)|Piezas|
|**Lo que compra la familia**: Apple Watch SE con datos móviles|329 € (40 mm) y 359 € (44 mm) en el lanzamiento de 2023; ofertas 275-340 €; hoy sin verificar. Plan B Galaxy Watch: desde 249,95 € (oferta) a 487,40 €|Sección 4|
|iPhone compatible con iOS 26 (solo si el de ella no lo admite)|Sin verificar|Sección 4.5|
|Línea de datos del reloj|Sin verificar|—|
|Pastillero semanal (lo llena la familia) y, más adelante, etiquetas NFC|Pastillero semanal normal y etiquetas: sin verificar. Un electrónico básico, unos 20 €|Sección 6|
|PC con GPU NVIDIA para clonar|Ya lo tiene la familia (decisión del promotor); no se compra. Familias sin GPU: plan B en CPU|Sección 5|

## NACHO · 10. Roadmap

16 semanas desde HIPOTENUSA. Cada entrega la prueba la familia. Fable orquesta, Opus diseña (datos, cifrado, consentimientos, alarmas), Sonnet construye, Haiku consolida (textos, traducciones, catálogo).

|Semanas|Entrega|Criterio de hecho|
|---|---|---|
|1|Esqueleto en el iPhone de ella: comprobar modelo de iPhone y versión de iOS; si no admite iOS 26, activar plan B (6.2). Cuenta de Apple Developer abierta. Base cifrada, círculo, pauta con foto; alarma con AlarmKit (iOS 26) y Acceso Asistido|En el iPhone de ella, la alarma suena a su hora con la pantalla bloqueada y el iPhone en silencio; la foto a pantalla completa sale al abrir la app|
|2|En el iPhone: pantalla de toma + alarma que no para + voz grabada + botón de confirmar + cámara de 10 s|La alarma sigue hasta confirmar (parar en el sistema no cuenta como toma), con la app cerrada y tras reiniciar el iPhone; el vídeo se graba sin tocar nada|
|3|Servidor, envío cifrado del vídeo, app de familia (Android e iPhone) con Hoy y Medicación, alta con CIMA|El vídeo llega a 2 familiares en menos de 2 minutos con red; el servidor solo ve datos cifrados|
|4|Escalado, cierre a distancia, asistente de instalación del iPhone (Acceso Asistido, AlarmKit, avisos). La NFC del pastillero queda como opción futura|Una toma no confirmada avisa al familiar 1 a los 5 min y al 2 a los 10; una semana real sin fallos|
|5|Control por horas en el iPhone, de 9 a 21: tres preguntas cada hora (ajustable) con voz de la familia, respuesta por toque o voz, línea del día en la app de familia, avisos|Una semana real de respuestas cada hora visibles en dos móviles de familiares en menos de un minuto|
|5-6|App watchOS en el Apple Watch: alarma, foto, voz, TOMADA, llamada, SOS, preguntas por horas en la esfera y caídas oficiales|Con el iPhone apagado (Apple Watch con datos móviles), el reloj suena, confirma y avisa. Cómo suena una alarma propia en watchOS y si la llamada automática está permitida: sin verificar, se prueba aquí|
|7|Gesto mano-boca en el reloj como indicio; batería y carga|Se mide el gesto con la familia y se publica la cifra tal cual; aviso de carga funcionando|
|8|Voces: biblioteca grabada de 24 frases y sincronización al reloj|Cada aviso suena con la voz elegida en móvil y reloj sin red|
|9|Clonación en el PC con NVIDIA de la familia: Chatterbox Multilingual primero, comparado con OpenVoice y CosyVoice; aprobación frase a frase; registro de reacción|La familia elige modelo de oído; las frases generadas llegan etiquetadas|
|10|Localización: ubicación, geocercas, ruta|Salida de zona avisada en el tiempo real medido (se anota)|
|11|Preguntas de control, "me he perdido", modo perdido, ficha 112, caídas|Simulacro completo con un familiar haciendo de persona perdida|
|12|Consultas: grabar, transcribir, buscar|Precisión medida con 3 grabaciones consentidas; cifra anotada|
|13|Calendario, turnos, resumen guiado, vínculo con cambios de medicación|De un cambio de dosis se salta al minuto de la grabación|
|14|Alimentación: menús, hidratación, registro de comidas, filas del catálogo|Las 44 filas con cifra y enlace visibles y filtrables|
|15|Ideas y tablas: catálogo completo, dosieres, enterrados, quién paga, motor de pruebas|Una prueba AB completa con familia sintética, adherencia tomada de las tomas|
|16|Círculo, Ajustes, exportar, borrar, consentimientos; EIPD; pruebas cerradas de la app de familia en Android e iPhone|Borrado probado en servidor; EIPD redactada; app de familia en prueba cerrada de Play y en TestFlight (cuenta de pago)|
|Sin semana fija|Ruta Android para otras familias: alarma exacta con pantalla completa, servicio en primer plano, asistente de batería por marca y Galaxy Watch con Wear OS|En 3 móviles Android de marcas distintas, la alarma suena a su hora con la pantalla bloqueada y la foto a pantalla completa; con el móvil apagado, el reloj suena, confirma y avisa por LTE|

**Desde la semana 4 se puede usar de verdad**: alarma de pastilla con foto y voz grabada, que no para, vídeo de comprobación que llega a la familia y escalado a dos familiares. En iPhone (iOS 26) y sin reloj. La NFC del pastillero queda como opción futura.

## NACHO · 11. Qué decido por defecto y qué te pregunto

### 11.1 Decisiones por defecto

|Tema|Por defecto|
|---|---|
|Móvil de la persona|iPhone con iOS 26 y AlarmKit. Android, ruta alternativa para otras familias|
|Reloj|Apple Watch SE con datos móviles; si ella lleva siempre su iPhone, un Apple Watch sin datos. Galaxy Watch8 en oferta, plan B para familias Android|
|Comprobación|Vídeo de 10 s, cámara frontal, revisado por un familiar|
|Qué apaga la alarma|Botón del móvil o del reloj, más vídeo de comprobación; NFC, opción futura|
|Pastillero|Semanal, lo llena la familia|
|Escalado|2 min repite, 5 familiar 1, 10 familiar 2, 15 llamada. El orden de familiares lo fijará el promotor más adelante|
|Voces|Grabadas por los familiares primero; clonación viable con Chatterbox Multilingual en el PC NVIDIA de la familia, en fase posterior|
|Preguntas de control|2 franjas al día, 1 pregunta por franja|
|Control por horas|De 9 a 21, las tres preguntas cada hora; ajustable desde la app de la familia|
|Servidor|Supabase Free Frankfurt, solo datos cifrados|
|Vídeos|Servidor 7 días como máximo; móviles 90 días|
|Transcripción|whisper.cpp base en el móvil; Vosk como alternativa|
|IA|Solo en el dispositivo; nada en la nube con datos de la familia|
|Licencias|App Apache-2.0, servidor AGPL-3.0, contenidos CC BY-SA 4.0 (Plan v2)|

### 11.2 Preguntas respondidas y dos abiertas

**Preguntas respondidas (12/10/2026).** El efecto de cada una está en 0.1.

1. **Móvil de la persona.** iPhone. La app de la familia, en Android y en iPhone.
2. **Reloj.** Apple Watch.
3. **Voces.** Se graban los familiares. Hay en la familia un PC con tarjeta NVIDIA, así que la clonación es viable más adelante.
4. **Alarmas a familiares.** Lo decidirá más adelante. Vale el valor por defecto: dos familiares, a los 5 y a los 10 minutos.
5. **Qué apaga la alarma.** Por ahora el botón, con vídeo de comprobación. La etiqueta NFC, opción futura.
6. **Pastillero.** Semanal, lo llena la familia.
7. **Control por horas.** De 9 a 21.
8. **Ritmo.** Las tres preguntas cada hora, ajustable desde la app de la familia.

**Preguntas abiertas (solo dos).**

- **(a) ¿Qué modelo exacto de iPhone y qué versión de iOS tiene la persona?** Se ve en Ajustes > General > Información. Decide si hay AlarmKit: iOS 26 llega a los iPhone 11 y posteriores ([Apple](https://www.apple.com/newsroom/2025/06/apple-elevates-the-iphone-experience-with-ios-26/)). Si no, se activa el plan B de 6.2.
- **(b) ¿En qué orden se avisa a los familiares en las alarmas?** El promotor lo fijará más adelante, junto con quién está de guardia de noche. Hasta entonces: familiar 1 a los 5 minutos y familiar 2 a los 10.

## NACHO · 12. Riesgos y límites reales

|Riesgo|Fuente|Plan B|
|---|---|---|
|**Riesgo principal**: el iPhone de la persona no admite iOS 26 (no es un iPhone 11 o posterior) y no hay AlarmKit: ni alarma en bucle ni alarma que atraviese el silencio|[AlarmKit](https://developer.apple.com/documentation/alarmkit/scheduling-an-alarm-with-alarmkit.md), [iOS 26](https://www.apple.com/newsroom/2025/06/apple-elevates-the-iphone-experience-with-ios-26/)|Plan B de 6.2: avisos time-sensitive repetidos, Critical Alerts pedidas a Apple y escalado a la familia; o un iPhone compatible; o la ruta Android para esa familia. Se comprueba en la semana 1|
|Sin cuenta de Apple Developer de pago no hay instalación estable en el iPhone y el Apple Watch: con Apple ID gratuito los perfiles caducan a los 7 días y caben 3 apps por dispositivo|[Apple](https://developer.apple.com/support/compare-memberships/), [Apple](https://developer.apple.com/support/membership-fee-waiver/)|Abrir la cuenta en la semana 1 (99 USD/año, o exención para entidades sin ánimo de lucro, 9.6). El Apple ID gratuito solo para pruebas de pocos días. Compilar y firmar exige Xcode, es decir, un Mac o compilación en la nube (Codemagic): que haya un Mac en la familia, sin verificar|
|(Ruta Android) El fabricante del móvil mata la alarma|[dontkillmyapp](https://dontkillmyapp.com/xiaomi)|Asistente de batería por marca; comprobación diaria; móvil Android dedicado como launcher; el reloj suena en paralelo|
|(Ruta Android) Play no concede pantalla completa o alarma exacta|[Android 14](https://developer.android.com/about/versions/14/behavior-changes-14), [Play](https://support.google.com/googleplay/android-developer/answer/13392821)|Declarar app de alarmas; pedir el permiso al usuario en el asistente|
|Nada prueba que se tragó la pastilla|Piezas alarmas y pastilleros|Tres capas y revisión humana del vídeo|
|Gesto del reloj poco fiable|[PMC10196892](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10196892/)|Solo indicio; se mide y se publica la cifra|
|Caídas: acceso de nuestra app a la detección del Apple Watch, sin verificar; en Wear OS no está documentado|[Health Services](https://developer.android.com/training/wearables/health-services/passive), [Apple caídas](https://support.apple.com/en-us/108896)|Función de caídas del propio reloj configurada por la familia (Apple Watch: detección oficial); en la ruta Android, función del reloj configurada o SaveFamily|
|Llamada automática al familiar desde nuestra app en el Apple Watch|Sin verificar en la documentación de Apple|Aviso al familiar con botón "Llamar"; la llamada automática se prueba en las semanas 5-6|
|Reloj sin batería|Autonomía sin verificar|Rutina de carga con voz; aviso a la familia; Find My (Apple) o Find Hub (Android)|
|Geocerca lenta (2-6 min)|[Geofencing](https://developer.android.com/develop/sensors-and-location/location/geofencing)|Preguntas de control y modo perdido con ubicación continua|
|Play rechaza ubicación en segundo plano|[Ubicación](https://developer.android.com/develop/sensors-and-location/location/background)|Ubicación solo en el reloj; distribución por F-Droid (Plan v2)|
|Voz clonada que confunde o suena rara|Pieza voz_clonada|Registro de reacción; voz grabada; retirar con un toque|
|Licencia de un modelo de voz cambia|[Chatterbox](https://github.com/resemble-ai/chatterbox)|OpenVoice v2 (MIT) o CosyVoice 3 (Apache-2.0)|
|Transcripción imprecisa|[Vosk](https://alphacephei.com/vosk/models)|Audio original siempre; resumen del familiar|
|CIMA sin foto de una pastilla|[CIMA](https://cima.aemps.es/cima/rest/medicamentos)|Foto hecha por la familia|
|Supabase cambia condiciones o se pausa|[Supabase](https://supabase.com/pricing)|Capa abstracta; Supabase autoalojado|
|La persona no puede consentir|Ley 41/2002, [BOE](https://www.boe.es/buscar/act.php?id=BOE-A-2002-22188)|Representante documentado; EIPD; consulta a la AEPD|
|Precios de relojes desactualizados|Fuentes de 2025|Confirmar en tienda antes de comprar|

## NACHO · 13. Anexos

### 13.1 Lista de compra

|Qué|Precio|Enlace|
|---|---|---|
|**Apple Watch SE GPS + Cellular** (principal)|329 € (40 mm) y 359 € (44 mm) en el lanzamiento de 2023; ofertas 275-340 €; sin verificar hoy|[Xataka](https://www.xatakamovil.com/apple/apple-watch-se-2023-caracteristicas-precio-ficha-tecnica/amp), [Applesfera](https://www.applesfera.com/seleccion/apple-watch-se-baja-precio-marca-su-minimo-smartwatch-equilibrado-apple-se-vuelve-todavia-barato)|
|Apple Watch sin datos móviles (si ella lleva siempre su iPhone)|Sin verificar|—|
|Cuenta de Apple Developer|99 USD/año, o 0 € con exención para entidades sin ánimo de lucro|[Apple](https://developer.apple.com/support/membership-fee-waiver/)|
|iPhone compatible con iOS 26 (solo si el de ella no lo admite)|Sin verificar|—|
|Galaxy Watch8 Classic 46 mm LTE (oferta, plan B Android)|Desde 249,95 € (nov. 2025)|[Powerplanet](https://www.powerplanetonline.com/es/samsung-galaxy-watch8-classic-46mm-lte-blanco)|
|Galaxy Watch8 40 mm LTE (plan B Android)|487,40 €|[PcComponentes](https://www.pccomponentes.com/samsung-galaxy-watch8-4g-lte-gps-40mm-super-amoled-grafito-s-m-version-internacional)|
|SaveFamily Senior (plan C)|99 € + 5-6 €/mes|[PcComponentes](https://www.pccomponentes.com/savefamily-senior-smartwatch-pantalla-ips-1-4-gps-aviso-de-cai-da-boton-sos-negro-no-incluye-sim)|
|Pastillero electrónico básico|Unos 20 €|[MediaMarkt](https://www.mediamarkt.es/es/product/_innovagoods-v0103066-83375118.html)|
|Etiquetas NFC NTAG (opción futura)|Sin verificar|—|
|Línea de datos del reloj|Sin verificar|—|

### 13.2 Fuentes técnicas

Cada dato de este plan lleva su enlace en el texto. La lista completa, con lo verificado y lo no verificado, está en los campos `fuentes` y `notas` de cada `plan3/pieza-*.json`. Las de más peso: [alarmas Android](https://developer.android.com/develop/background-work/services/alarms/schedule), [AlarmKit](https://developer.apple.com/documentation/alarmkit), [Acceso Asistido](https://developer.apple.com/documentation/bundleresources/information-property-list/uisupportsfullscreeninassistiveaccess), [membresías de Apple](https://developer.apple.com/support/compare-memberships/), [iOS 26](https://www.apple.com/newsroom/2025/06/apple-elevates-the-iphone-experience-with-ios-26/), [Wear OS](https://developer.android.com/training/wearables/get-started), [Chatterbox](https://github.com/resemble-ai/chatterbox), [geofencing](https://developer.android.com/develop/sensors-and-location/location/geofencing), [NFC](https://developer.android.com/develop/connectivity/nfc/nfc), [whisper.cpp](https://github.com/ggml-org/whisper.cpp), [CIMA](https://cima.aemps.es/cima/rest/medicamentos).

### 13.3 Inventario de archivos

|Archivo|Qué es|
|---|---|
|`plan3/pieza-alarmas_camara.json`|Alarma que no para y cámara|
|`plan3/pieza-relojes.json`|Relojes y precios|
|`plan3/pieza-voz_clonada.json`|Voces grabadas y clonadas|
|`plan3/pieza-localizacion_perdida.json`|Localización y preguntas de control|
|`plan3/pieza-consultas_calendario.json`|Consultas, calendario y CIMA|
|`plan3/pieza-pastilleros_sensores.json`|Pastilleros, NFC y sensores|
|`plan3/PLAN-v3.md`|Este documento|
|`catalogo/out/CATALOGO.xlsx` y `CATALOGO.md`|647 estudios, 15 temas, 353 intervenciones|
|`catalogo/out/DOSIERES.md`|Los 15 dosieres|
|`plan2/PLAN-v2.md`|Plan anterior: núcleo común, motor de pruebas, arquitectura|
