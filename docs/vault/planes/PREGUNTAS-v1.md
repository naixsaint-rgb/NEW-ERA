# NACHO · Preguntas antes de la primera línea de código

Antes de escribir la primera línea de código necesitamos algunas respuestas vuestras. No hace falta contestar todo a la vez ni con detalle: las 15 primeras son las que más cambian el diseño.

Si no sabéis una respuesta, decidnos «no lo sé» y usaremos el supuesto que aparece debajo de cada pregunta.

Cada pregunta trae su «Por qué» (qué decide) y su «Si no contestáis» (lo que haremos mientras tanto), y los temas sensibles los tratamos con cuidado.

Podéis contestar en un solo mensaje o por bloques, como os resulte más cómodo.

## NACHO · Las 15 bloqueantes

**1. Por escrito, ¿para qué sirve la app? ¿Aceptáis que solo anote, recuerde, informe y os diga 'consultad al médico', sin avisar de que 'algo va peor', sin sugerir dosis y sin puntuar tests, aunque a veces os parezca poco?**

Por qué: Esa frase (la finalidad prevista) decide si la app es producto sanitario (MDR regla 11, certificación cara) o no. Cada función se diseña contra ella.

Si no contestáis: Finalidad limitada a registrar, recordar lo que pautó el médico, informar con nivel de evidencia y derivar. Ninguna función puntúa, detecta ni dosifica.

**2. Si pudierais arreglar una sola cosa de la vida diaria con el Alzheimer antes de dentro de dos meses, ¿cuál sería (dobles tomas, las noches, la agitación de la tarde, que se pierda, que coma poco, que los hermanos no se coordinen, que el cuidador principal se hunda)? Y en 8 semanas, al abrir la app, ¿qué tendría que poder hacer para pensar 'esto ya nos sirve', y qué os daría igual que faltara?**

Por qué: Decide qué módulo se construye primero y fija el alcance de la primera versión y la lista de lo que queda fuera a propósito. Las 13 dimensiones suman más de 150 ideas y en 8 semanas caben tres o cuatro bien hechas.

Si no contestáis: V1: lista de medicación con tomas compartidas, diario de un toque (ánimo, sueño, comida), informe PDF para el médico, tarjeta de emergencia y botón 'Se ha perdido'. Todo lo demás queda para después.

**3. ¿Empezamos solo con vuestra familia o abierta a otras familias desde el primer día? ¿Cuántas familias imagináis usando la app al cabo de un año y de tres?**

Por qué: Una familia permite funcionar sin cuenta y con datos en el móvil; varias familias exigen servidor, aislamiento de datos, soporte, presupuesto y un responsable legal del tratamiento (RGPD).

Si no contestáis: Primer año: solo vuestra familia y 3 a 5 familias amigas como piloto, con datos separados por 'hogar' desde el día 1 para poder abrir después sin reescribir. Tres años: se retoma cuando el piloto funcione.

**4. ¿Qué medicamentos toma hoy la persona (aunque sea de memoria), cuántas tomas hay al día y cuáles son a demanda? En concreto: ¿hay alguno para la memoria (donepezilo, rivastigmina, galantamina, memantina), para dormir, para la conducta, anticoagulantes, parches? ¿Ha oído hablar la familia de lecanemab o donanemab?**

Por qué: Define si la v1 es una lista simple o necesita parches, tomas a demanda, anti-amiloide, etiquetas de riesgo y tarjeta de emergencia. Es el eje de mayor riesgo de la app.

Si no contestáis: Lista con tomas fijas y a demanda, estados tomada, rechazada y escupida, ficha oficial de CIMA enlazada; sin módulo anti-amiloide ni parches en la v1.

**5. ¿Quién gestiona hoy la medicación (la propia persona, un cuidador principal, varios, una cuidadora contratada, la farmacia con SPD)? ¿Usáis pastillero semanal o diario, cómo lo preparáis, y cuántas veces os habéis equivocado o dudado de si ya se tomó?**

Por qué: Decide el flujo de registro, el aviso anti-doble dosis y a quién va el recordatorio (al cuidador, nunca solo a la persona con Alzheimer).

Si no contestáis: Un cuidador responsable y otros con solo registro; avisos solo al cuidador; confirmación explícita ante doble marca; exportación de horario para el pastillero.

**6. ¿Quién cuida hoy a la persona, y cuántas personas participan de verdad en una semana normal (familiares, vecinos, cuidadora, centro de día)? Para cada una: nombre o apodo, parentesco, horas a la semana y si vive con ella o a qué distancia.**

Por qué: Define cuántos perfiles hay, qué ve cada uno y si el diseño es para un cuidador principal con ayudas puntuales o para un equipo repartido. Cambia roles, permisos y sincronización.

Si no contestáis: Un cuidador principal, de 2 a 4 familiares de apoyo (algunos a distancia) y, como mucho, una cuidadora con rol propio.

**7. ¿Cómo son los turnos y los relevos? Contadnos un día típico: quién se levanta, quién da la medicación, quién hace las noches y qué pasa en el cambio de turno (qué se cuenta y cómo).**

Por qué: El mayor riesgo es la doble dosis o el 'creía que lo habías dado tú'. El diseño de avisos, relevos y registro de quién apuntó cada dato sale de aquí.

Si no contestáis: Dos o tres relevos al día con una ficha de traspaso breve y aviso anti-doble marca con confirmación explícita; las noches las cubre una sola persona.

**8. ¿Quién debería ver qué? Pensad en nombres reales: hijos que viven lejos, hermanos que no se hablan, nietos, vecinos, el médico, la farmacia, la trabajadora social. ¿Cuántas personas apuntarán datos de la misma persona, y a quién no queréis dar acceso a ciertos datos (economía, medicación, notas de ánimo, notas del cuidador)? ¿Cómo se retira el permiso a alguien si hace falta? Y los profesionales de fuera (médico, farmacia, trabajadora social, fisioterapeuta, centro de día): ¿tienen que tener cuenta, o basta un PDF para la consulta?**

Por qué: Los roles y permisos se diseñan sobre vuestros conflictos reales, y este es el diseño más difícil de cambiar después. Una pantalla de 'quién ve mis datos' y un registro de accesos evitan disputas familiares. El acceso temporal de profesionales exigiría otro tipo de permiso y registro; si todo se resuelve con un PDF para la consulta, no hace falta crear cuentas para ellos.

Si no contestáis: Roles: persona de apoyo principal (todo), familiar (agenda y resumen), familiar a distancia (resumen diario), cuidadora (solo registro). Los profesionales no tienen cuenta: reciben un PDF que genera el cuidador cuando lo decide. Notas privadas del cuidador no visibles para nadie; permisos retirables al instante.

**9. ¿Qué quiere y qué puede decidir ahora la propia persona sobre sus datos (ubicación, fotos, quién ve su información médica)? ¿Sabe de su diagnóstico y ha dicho algo sobre cómo quiere ser cuidada? ¿Quién decide hoy por ella si no puede (poder preventivo, curatela, guardador de hecho, voluntades anticipadas), y quién es hoy su persona de apoyo?**

Por qué: La Ley 8/2021 y el RGPD art. 9 obligan a respetar su voluntad con apoyos mientras pueda. La app no puede dar ni quitar representación: el consentimiento lo da la persona con apoyo, y según su situación real se muestra, se firma o se acompaña de otra manera.

Si no contestáis: Consentimiento por capas y revisable: la persona decide con apoyo, en lectura fácil con pictogramas; cada familiar ve lo mínimo; si no hay medidas formales, la app no presume representación y se registra quién la apoya. Datos solo en el dispositivo hasta aclarar.

**10. ¿Qué trámites están hechos o en marcha: grado de dependencia y PIA, discapacidad, ayuda a domicilio, centro de día, apoyos judiciales de la Ley 8/2021 (curatela, poderes), instrucciones previas? ¿En qué comunidad autónoma vivís? ¿Qué comunidad autónoma se lanza primero, y la app da información por comunidad desde el inicio o solo la norma estatal con aviso de variación?**

Por qué: La guía de trámites depende de la comunidad autónoma. Además, quién tiene poder sobre la salud o el dinero determina quién puede consentir el tratamiento de los datos y quién ve qué.

Si no contestáis: Comunidad por confirmar, dependencia solicitada sin resolver y sin curatela; el consentimiento lo da la persona con apoyo de un familiar de referencia.

**11. ¿Dónde os sentís cómodos con que vivan los datos: solo en el móvil de la cuidadora principal, en un móvil de cada familiar sincronizados, o en un servidor? Si es servidor, ¿aceptáis uno en la UE y que, a coste cero, a veces se pause o haya que pasar a pago cuando crezca?**

Por qué: Determina si hay servidor, quién es responsable del dato (art. 9 RGPD), la evaluación de impacto y el coste. La excepción doméstica protege a la familia, no a quien ofrece la app a otras.

Si no contestáis: Local cifrado por defecto, sin cuenta; sincronización opcional con cifrado de extremo a extremo en servidor UE solo para el piloto familiar; copia de seguridad exportable para que nada dependa de un servicio gratuito.

**12. ¿Cuánto dinero puede salir de vuestro bolsillo, y cuándo? ¿Aceptáis pagar 25 USD de Google una vez y 99 USD al año de Apple si no hay exención? ¿Y si la app crece, un tope de 25 a 50 USD al mes lo podéis sostener, o alguna entidad lo cubriría? Y, ¿tenéis un coste cero absoluto como condición, aunque haya menos funciones o menos fiabilidad?**

Por qué: El coste cero absoluto tiene riesgos reales para datos de salud (servicios gratuitos que se pausan o limitan). Saber vuestro techo decide si usamos un servidor gratuito con parches o uno de pago barato y fiable, y si todo va en local o en nube europea.

Si no contestáis: Tope de 0 USD hasta el lanzamiento a otras familias; 25 USD de Google aceptados; Apple solo con exención; hasta 25 USD al mes solo cuando haya más de unas 20 familias activas. Se revisa el presupuesto con más de 5 familias.

**13. Cuando varios cuidadores apuntan datos, ¿preferís que se sincronicen al instante entre todos (hace falta un servidor) o basta con que cada uno apunte en su móvil y se junten una vez al día o por exportación? ¿Necesitáis avisos remotos en el momento (por ejemplo, 'la medicación de las 9 no está confirmada')?**

Por qué: Los avisos en tiempo real son lo que más cuesta y más se rompe con servidores gratuitos. Si basta con sincronizar cuando hay red, ahorramos casi todo el coste y la fragilidad; si queréis avisos remotos, hay que presupuestarlos.

Si no contestáis: Sincronización cuando hay red, sin avisos remotos urgentes en la v1; el aviso de toma va solo al cuidador que tiene el móvil o la tablet de turno.

**14. ¿Quién va a tocar el móvil en el día a día: solo el cuidador, o también la persona con Alzheimer? Si es ella, ¿qué sabe hacer sola hoy (llamar, mirar fotos, leer texto grande, WhatsApp), le gusta o se inquieta con las pantallas, y se acuerda de dónde lo deja?**

Por qué: Decide si existe un modo para ella o la app es solo para quien cuida. Hacer dos apps en una duplica el trabajo, y un aparato que le inquieta o con el que llama a todo el mundo de madrugada es un riesgo, no una ayuda.

Si no contestáis: La v1 es sobre todo modo cuidador. El modo persona, desactivado hasta que la familia lo pida y lo pruebe, se reduce a una pantalla opcional de día, fecha y fotos de 'Mi gente', sin avisos ni alarmas hacia ella.

**15. ¿Qué móvil o tablet usa hoy cada persona que va a usar la app (la persona con Alzheimer y cada cuidador): marca, modelo y versión del sistema (Ajustes > Acerca del teléfono; una foto por dispositivo nos vale)? ¿Cuántos son iPhone y cuántos Android, y tiene iPhone alguien clave, como el cuidador principal o el familiar que vive lejos? ¿Cómo van de vista y oído, y qué destreza digital tiene cada uno (si usa WhatsApp sola, si tiene datos o solo wifi)?**

Por qué: Decide si empezamos por Android o por los dos sistemas, la versión mínima, cómo funcionan las alarmas y el ahorro de batería, si el modo bloqueado de la tablet es posible y el tamaño de letra. Si el cuidador principal usa iPhone, publicar solo en Android deja a la familia fuera desde el día uno y obliga a pagar la cuenta de Apple o a recurrir a una web instalable; si todos son Android, podemos ahorrar meses y 99 USD.

Si no contestáis: Asumimos Android 10 o superior e iPhone con iOS 16 o superior; empezamos por Android con una tablet para la persona y los móviles de los cuidadores, y los iPhone usan una web instalable hasta una segunda fase; letra grande y todo en un toque.

## NACHO · Persona y su vida diaria

**1. ¿Qué diagnóstico tiene y desde cuándo (Alzheimer, mixta u otra demencia)? ¿En qué fase la sitúa su neurólogo, y qué sabe la propia persona de su diagnóstico?**

Por qué: Decide qué módulos van primero (recordatorios y autonomía en fase leve; cuidado y confort en fase avanzada) y el tono; lo que ella sabe condiciona qué textos puede ver.

Si no contestáis: Fase leve-moderada; la persona sabe que tiene 'problemas de memoria'; el cuidador elige el nivel de interfaz a mano.

**2. Pregunta de cuidador experto: si mañana ingresara en urgencias o la cuidara un desconocido, ¿qué tres cosas necesitaría saber esa persona para no asustarla (cómo comunica sí y no, qué hace cuando tiene miedo, qué no tolera)? ¿Quién lo sabe hoy y está escrito en algún sitio? ¿Qué plan escrito hay si la situación empeora de golpe (caída, hospital, cuidador enfermo)?**

Por qué: Una ficha de traspaso ('esto soy yo' y tarjeta de emergencia) evita agitación y malas decisiones en urgencias; es una función que casi ninguna app hace bien y que en una crisis vale más que el resto.

Si no contestáis: Ficha de una página con plantilla propia, exportable a PDF y QR, con dos niveles de privacidad, y tarjeta de emergencia (medicación, alergias, contactos) accesible desde la pantalla de bloqueo.

**3. ¿Cómo se llama la persona y cómo le gusta que la llamen (nombre, apodo, usted o tú)? ¿Qué es lo que mejor la define: oficio, aficiones, lo que más le enorgullece?**

Por qué: El modo Paciente, el libro de vida y los textos deben hablarle como ella quiere; un trato impersonal o infantilizador provoca rechazo y agitación.

Si no contestáis: Nombre de pila y trato de tú o usted configurable por el cuidador, sin apodos.

**4. Pregunta de cuidador experto: ¿cuál es el momento del día más difícil, qué la calma en ese momento (canción, olor, objeto, persona, rutina) y qué no hay que decirle nunca? ¿Qué fue clave en su identidad antes de la enfermedad (oficio, fe, aficiones)?**

Por qué: Es la base de la rutina calmante, el banco de actividades y la ficha 'quién soy'; lo que calma suele valer más que cualquier suplemento, y lo que desorienta debe evitarse.

Si no contestáis: Ficha 'Esto me calma / esto me asusta' vacía, con registro rápido de un toque tras cada episodio, y libro de vida con música, olores, fotos y temas a evitar.

**5. ¿Tiene dolor o molestias que no sabe expresar (boca, prótesis, estreñimiento, pies, articulaciones, orina)? ¿Cómo lo muestra: gesto, rechazo, gritos, se frota la zona? Cuando se agita, ¿alguna vez fue dolor, infección o un medicamento nuevo?**

Por qué: El dolor y las causas tratables no tratadas suelen estar detrás de la agitación y acaban con psicofármacos; fija una lista de causas tratables y un registro antes y después de cada cambio.

Si no contestáis: Registro de conducta con pregunta fija de posible dolor y checklist de causas tratables para comentar con el médico, sin puntuaciones.

**6. ¿Cómo duerme y cómo son las tardes y las noches? ¿Se levanta, se confunde de día y noche, se inquieta al atardecer? ¿Toma algo para dormir (melatonina, trazodona, benzodiacepinas, valeriana, infusiones) y empeora al atardecer?**

Por qué: Marca si el primer módulo es el diario de noche y tarde o el de rutinas calmantes, y qué productos de farmacia o herbolario necesitan ficha y registro.

Si no contestáis: Diario de noche y tarde de 30 segundos con modo oscuro como primer módulo; ficha de evidencia de melatonina y somníferos, sin recomendar productos.

**7. ¿Qué música, canciones, programas, oficios y lugares marcaron su vida? ¿Y qué temas, canciones o personas la entristecen o asustan (por ejemplo, un fallecido, una guerra, un hospital)?**

Por qué: Alimenta las listas de música por momento del día, la reminiscencia y la lista de temas a evitar; una canción equivocada puede angustiar.

Si no contestáis: Libro de vida y listas de música vacíos, con campo de 'temas a evitar' visible y reacción registrada en un toque.

**8. ¿Cómo reacciona ante fotos antiguas, la voz grabada o la videollamada de familiares? ¿Hay alguien cuya voz la tranquilice, o que la desoriente (por ejemplo, alguien que ya no está)?**

Por qué: Las voces y vídeos grabados tienen evidencia muy baja y pueden confundir; decide si se activan y si quedan desactivados por defecto.

Si no contestáis: Función de voz y vídeo desactivada por defecto; solo fotos con nombre y parentesco, con parada inmediata.

**9. ¿Qué lengua habla en casa y con quién (castellano, catalán, gallego, euskera, otra lengua o variante latinoamericana)? ¿Entiende mejor leer, oír o ver imágenes?**

Por qué: Decide el idioma de la v1, los pictogramas y la lectura fácil, y si hay que traducir fichas para una cuidadora extranjera; también pesa en un eventual salto a Latinoamérica.

Si no contestáis: Castellano de España en lectura fácil, con pictogramas; otras lenguas y variantes después.

**10. ¿Cómo se llama la app que os gustaría (nombre provisional)? ¿Hay palabras que os resulten dolorosas (por ejemplo 'Alzheimer', 'demencia', 'paciente') y que prefiráis evitar en pantalla?**

Por qué: El nombre y el tono se ven cada día y también los verá ella. Además, la app no puede prometer curas (RD 1907/1996).

Si no contestáis: Nombre provisional neutro, sin 'cura', 'cerebro' ni 'memoria' como promesa; la palabra 'paciente' no aparece en el modo persona.

**11. Si el cuidador principal es la pareja, ¿hay cambios en la intimidad, en dormir juntos o conductas de desinhibición que os preocupen y sobre las que querríais orientación privada?**

Por qué: Son situaciones frecuentes y muy incómodas que suelen callarse. Si aparecen, la app debe ofrecer orientación privada sin registrar detalles íntimos, y decidir qué entra en el diario es una decisión de diseño con consecuencias de privacidad.

Si no contestáis: Sin registro de intimidad; orientación privada en un bloque de 'cosas que cuesta contar', con enlace a la asociación de familiares y a la consulta del médico.

## NACHO · Salud, medicación y nutrición

*Bloqueante n.º 4: Medicación que toma (ver arriba).*

*Bloqueante n.º 5: Quién gestiona la medicación (ver arriba).*

**12. ¿Hay a veces rechazo de la medicación, o alguien la administra escondida en la comida o la bebida? ¿Cómo lo vivís y lo habláis con el médico?**

Por qué: Es una realidad habitual y delicada. Cambia los estados de toma (rechazada, escupida), el tono de la app y la conversación sobre la Ley 8/2021 y el respeto a la voluntad.

Si no contestáis: Estado 'rechazada' sin juicio, nota libre y una pregunta sugerida para el médico; no se guía la administración encubierta.

**13. ¿Quién sigue a la persona (neurólogo, médico de familia, geriatra) y cada cuánto la ven? ¿Cómo es la relación con el médico y el farmacéutico: os escuchan cuando preguntáis por suplementos, y estarían dispuestos a revisar un informe?**

Por qué: Si no hay diálogo, el informe PDF y la plantilla de preguntas pasan a ser el centro del producto. Además condiciona quién revisa los contenidos clínicos.

Si no contestáis: Relación correcta pero con poco tiempo de consulta: informe de una página, preguntas sugeridas y sin acceso directo del profesional en la v1.

**14. ¿Qué os gustaría medir y apuntar sobre todo? Elegid las 5 primeras: tomas, peso, comida, agua, deposiciones, sueño, siestas, agitación, dolor, ánimo, caídas, actividad, analíticas, citas.**

Por qué: Evita construir diez diarios que nadie rellena. Fija el orden de la v1 y la pantalla de registro de un toque.

Si no contestáis: Tomas, sueño y siestas, comida e hidratación, agitación y ánimo, y peso, en ese orden.

**15. Pregunta de cuidador experto: ¿qué es lo que más os cuesta contar en una consulta de 10 minutos y luego se os olvida (episodios nocturnos, rechazos de comida, cambios tras un fármaco, caídas pequeñas)? ¿Qué os gustaría poder enseñar de golpe?**

Por qué: Muestra qué informe sirve de verdad al médico y cuál sobra; evita gráficas bonitas que nadie mira.

Si no contestáis: Informe de 1 a 2 páginas con medicación y tomas, sueño, comidas, peso, conducta y caídas, con las preguntas que escriba la familia.

**16. ¿Come y traga la persona con normalidad? ¿Hay tos o atragantamientos, comida que se queda en la boca, pérdida de peso o apetito, o informe de logopedia con nivel de textura? ¿Le cuesta tragar las pastillas y las parte, tritura o mezcla con comida? ¿Hay restricciones de líquidos por el corazón o los riñones que deban constar?**

Por qué: Dispara la ficha de disfagia (IDDSI copiado del informe), las recetas por textura y la pregunta al farmacéutico sobre formas farmacéuticas; vigila el riesgo de triturar pastillas sin saberlo.

Si no contestáis: Sin disfagia confirmada: campo opcional de dificultad para tragar, enlace a formas farmacéuticas en CIMA y primeros auxilios por atragantamiento; recetas por textura en la v2.

**17. ¿Qué le gusta y qué rechaza comer o beber? ¿Hay dietas que ya sigáis o queráis probar (mediterránea, cetogénica, aceite de coco, ayunos, suplementos nutricionales)? ¿Come mejor con ciertos platos, vajilla o compañía?**

Por qué: Determina recetas, los 'platos de su vida' y las fichas honestas de dietas (la cetogénica y el aceite de coco no se recomiendan de rutina según ESPEN) sin imponer un modelo.

Si no contestáis: Biblioteca mediterránea y de 'platos de su vida' filtrada por textura y alergias; fichas de evidencia para cetogénica y coco; sin planes dietéticos individualizados.

**18. ¿Ha tenido la persona o la familia analíticas con cobre, ceruloplasmina, zinc, hierro, litio o similares? ¿Alguien os ha recomendado medirlo, quelar metales o quitar el cobre? ¿Vivís en una casa con tuberías antiguas o bebéis agua de pozo?**

Por qué: El cobre tiene evidencia observacional pero ninguna terapia probada. Saber si hay analíticas y qué agua beben determina si se ofrece registro de valores y la guía 'Mi agua', o solo ficha de seguridad.

Si no contestáis: Registro opcional de valores copiados del laboratorio sin interpretación, ficha de seguridad (zinc, plomo, productos importados) y guía 'Mi agua' con SINAC y valores del RD 3/2023.

**19. ¿Estáis dispuestos a hacer pequeños experimentos con la persona (por ejemplo, música a las 17:00 durante dos semanas y comparar con las dos anteriores), sabiendo que no prueban nada pero ayudan a ver qué le sienta bien? ¿Cuánto esfuerzo diario aguantáis: 10 segundos, 1 minuto, 5 minutos?**

Por qué: Define el diseño del módulo n=1: duración, medidas, avisos de sesgo y lo que se puede pedir a un cuidador agotado.

Si no contestáis: Experimento opcional de dos semanas con una sola actividad y una medida de un toque; resultado como medias descriptivas con aviso de sesgo.

**20. ¿Tiene puestas la vacuna de la gripe, la del neumococo, la de la COVID-19 y la del herpes zóster? ¿Y el cuidador principal? ¿Queréis que el registro de vacunas se comparta entre familiares, con consentimiento de cada uno? ¿Aceptáis que la app nunca sugiera vacunar ni diga si os toca, y que solo registre, recuerde lo programado e informe con nivel de evidencia?**

Por qué: Las vacunas son de las pocas acciones preventivas con evidencia clara en demencia, y el calendario depende de la comunidad autónoma y del riesgo. Una app que sugiere vacunas o dice la elegibilidad hace triaje clínico, y eso cambia su clasificación y su responsabilidad.

Si no contestáis: La app registra y recuerda lo programado, con enlace oficial de la comunidad; el registro es privado de cada persona y se comparte solo con consentimiento revocable; sin recomendación de vacunación ni elegibilidad.

**21. ¿A qué edad empezaron los síntomas y hay antecedentes de demencia en la familia? Si es de inicio precoz, ¿hay hijos preocupados por su propio riesgo o que quieren consejo genético?**

Por qué: El inicio precoz o los antecedentes familiares cambian la conversación con el médico y el apoyo a los hijos. La app no puede dar consejo genético ni interpretar pruebas, pero sí derivar a una consulta especializada.

Si no contestáis: Campo de antecedentes familiares sin interpretación y enlace a consejo genético en la unidad de referencia; sin contenido de riesgo individual.

## NACHO · Terapias, remedios y evidencia

**22. ¿Qué suplementos, vitaminas, hierbas, infusiones, cremas o adhesivo de dentadura toma ahora la persona o el cuidador, y cuáles ha probado antes (qué pasó, mejoría o molestias)? ¿Quién de la familia recibe remedios por WhatsApp, Instagram o consejos de conocidos (suplementos, hierbas, curas milagro, clínicas, aparatos, quelaciones)? ¿Probáis cosas sin contárselo al médico, cuánto habéis gastado y quién decide qué se prueba?**

Por qué: Dimensiona el registro de suplementos (foto de la etiqueta, procedencia y coste) y cubre el punto ciego de seguridad: zinc, hierbas o productos importados con metales. Si un familiar manda remedios, la app necesita una vía amable para registrarlos y comentarlos con el farmacéutico, sin ocultarlos y sin juicio. El gasto calibra el aviso sobre coste.

Si no contestáis: Registro libre con foto del envase, procedencia, coste y ficha de evidencia A-D; abierto a cualquier familiar, con el texto fijo de comentarlo con el farmacéutico; tono neutral y respetuoso, sin cálculo de interacciones ni juicio sobre creencias.

**23. Si la app muestra evidencia honesta (incluidos estudios negativos y el nivel D 'se probó y no funcionó', sin testimonios, promesas ni enlaces de compra), ¿cómo queréis que lo diga para que la familia no se sienta contradicha? ¿Qué frase os dolería leer y cuál os ayudaría? Y si algo que habéis probado y os ha ido bien sale con un nivel D, ¿qué hacemos?**

Por qué: El tono decide si la familia sigue confiando o abandona la app. Las fichas negativas son obligatorias por honestidad y por el RD 1907/1996, que prohíbe testimonios y promesas de cura.

Si no contestáis: Tono sereno y respetuoso ('esto es lo que se sabe, esto no se sabe, tú decides'), sin ironía ni alarma, con etiqueta de confianza A-D y sugerencia de consulta; sin testimonios, precios ni enlaces de compra.

**24. De la medicina china, ayurveda, homeopatía, acupuntura, reiki, aromaterapia, Tai Chi u otras tradiciones, ¿qué usáis ya y qué os gustaría probar? ¿Hay alguna que tenga para vosotros más valor cultural o espiritual que de tratamiento?**

Por qué: Decide qué fichas y programas (por ejemplo Tai Chi sentados) entran primero y cómo separar 'gusta y relaja' de 'trata'.

Si no contestáis: Biblioteca con dos ejes (efecto y confianza) para Tai Chi o Qigong, acupuntura, huperzina, ginkgo, aromaterapia y mindfulness; Tai Chi y masaje de manos como práctica de confort.

## NACHO · Seguridad, delirium y emergencias

**25. ¿Ha tenido confusión brusca, somnolencia nueva, infecciones de orina, caídas o ingresos? ¿Cómo está de equilibrio y movilidad (bastón, andador, silla)?**

Por qué: El delirium es la urgencia que más se pasa por alto, y la movilidad decide si ejercicios como el Tai Chi o la lista de seguridad del hogar tienen sentido.

Si no contestáis: Pantalla 'Hoy está distinto' con mensaje fijo de consultar o llamar al 112, y ejercicios solo en silla o con apoyo.

**26. ¿Cuándo fue la última vez que se desorientó fuera de casa o salió sola? ¿Sale a pasear, conduce o maneja dinero? ¿Hay agua, campo o vías cerca, y qué llevaría encima sin quitárselo (móvil, reloj, colgante, nada)? Si dice 'no quiero que me sigáis' o se enfada con el GPS, ¿quién decide sobre la ubicación y qué hacemos si hay un riesgo claro de perderse pero ella lo rechaza?**

Por qué: Decide si la v1 prioriza el protocolo 'se ha perdido', la ficha de identificación y la ubicación compartida, y qué objeto puede llevar en realidad. La ubicación debe ser proporcionada y por niveles: sin acuerdo escrito de la familia no se impone vigilancia, y el respeto a su voluntad importa tanto como la seguridad.

Si no contestáis: Botón 'Se ha perdido' con 112 y ficha para quien la encuentre; ubicación apagada por defecto, con niveles (solo si me pierdo, geovalla) activables solo con acuerdo familiar escrito, registro visible y revisión cada 3 meses. El protocolo de desaparición no depende del GPS.

**27. Cuando estáis en plena crisis (agitación a las 3 de la madrugada, un atragantamiento), ¿qué es lo que menos podéis hacer con las manos y con los ojos? ¿Qué os hace perder segundos hoy (desbloquear el móvil, buscar el teléfono del médico)? ¿Y estáis de acuerdo en que el 112 y el centro de salud estén siempre visibles y nunca se activen por síntomas registrados?**

Por qué: Si apuntar un dato exige más de 5 segundos o dos manos, no se hará. Decide si priorizar voz, botones grandes, acceso desde la pantalla de bloqueo o un botón físico.

Si no contestáis: Diseño para una sola mano, a oscuras, con registro en un toque o por voz, sin pedir desbloqueo para las acciones de emergencia.

**28. Si el registro muestra que alguien (familiar, cuidadora, la propia persona) olvida, duplica o esconde tomas, o un posible maltrato por agotamiento, ¿qué queréis que haga la app: que lo muestre a todos, solo a la persona de apoyo, o que sugiera ayuda externa?**

Por qué: El registro de quién dio qué puede usarse para culpar, y un tercio de cuidadores admite conductas abusivas por agotamiento. Hay que decidir si el registro de auditoría es transparente o confidencial, y cómo se ofrece ayuda sin acusar.

Si no contestáis: Avisos de doble toma o toma no confirmada solo a la persona de apoyo, en tono neutro y sin culpar; el registro es visible para quienes participan; nada sobre maltrato se infiere, y se ofrece siempre el botón 'Necesito hablar con alguien' (024, AFA, médico).

**29. ¿Hay algo de vuestra casa que nunca debería aparecer en un móvil: la dirección exacta, el dinero, los nombres de menores, fotos íntimas, el diagnóstico en la pantalla de bloqueo, o un secreto que la persona cuenta en confusión?**

Por qué: Lo que más duele no es el dato médico, sino lo íntimo. Con esto definimos notificaciones sin contenido, campos 'solo en papel', borrado de notas concretas y lo que NO se pide.

Si no contestáis: Notificaciones con texto genérico, sin diagnóstico ni nombre en la pantalla de bloqueo; cada nota puede marcarse 'privada' o borrarse al instante; no se piden dirección exacta, datos bancarios ni fotos íntimas.

**30. ¿Vivís en un pueblo o zona rural? ¿A qué distancia está el centro de salud? ¿Cómo lleváis el calor del verano: hay aire acondicionado y quién vigila que beba en una ola de calor?**

Por qué: En zona rural la urgencia tarda más y la cobertura falla. La ola de calor y la deshidratación son un riesgo real en demencia: decide si la v1 incluye alertas de calor, la lista de contactos locales y la guía sin conexión.

Si no contestáis: Ficha de contactos locales y número del centro de salud en la pantalla principal; guía de calor y deshidratación sin alertas automáticas; todo funciona sin conexión.

## NACHO · Red de cuidado y familia

*Bloqueante n.º 6: Quién cuida hoy (ver arriba).*

*Bloqueante n.º 7: Turnos y relevos (ver arriba).*

*Bloqueante n.º 8: Quién ve qué (ver arriba).*

**31. Pregunta de cuidador experto: ¿cómo está la cuidadora principal (sueño, dolor, ánimo, citas médicas aplazadas, medicación propia)? ¿Os gustaría que la app se ocupara también un poco de ella, y aceptaría registrar su estado sabiendo que son datos de salud suyos, con permiso separado, que nadie más verá salvo que ella lo comparta?**

Por qué: La sobrecarga es el primer motivo de abandono de los cuidados. Si el cuidador principal no tiene sitio en la app, esta fallará cuando él o ella se rompa; y sus datos necesitan consentimiento y perfil propios.

Si no contestáis: Espacio breve y privado para el cuidador (autocuidado, citas, respiro, 'necesito hablar con alguien') con consentimiento separado, privado por defecto, con autocuestionario propio (no escalas con licencia) y enlaces a 024 y a la AFA.

**32. ¿Hay o habrá cuidadora contratada (interna, por horas, de agencia) o centro de día? ¿Qué horario hace, tiene contrato y está dada de alta en la Seguridad Social, qué idioma habla con más soltura, y qué le dejaríais apuntar y qué no (medicación, comidas, incidencias, datos económicos o de salud)? ¿Aceptaría que su registro quede guardado con su nombre? Si hay empleo de hogar, ¿quién figuraría como titular del hogar y empleador?**

Por qué: Una persona externa necesita un rol de solo registro, una hoja de traspaso y quizá otro idioma. Sus datos de actividad son laborales: no se puede vigilarla sin informarla (art. 89 LOPDGDD), y el RGPD exige que no vea más de lo necesario.

Si no contestáis: Rol 'cuidadora profesional' que apunta tomas, comidas e incidencias y ve la ficha de traspaso, sin datos económicos, legales ni informes completos; recibe aviso claro de lo que se registra, sin ubicación ni cámara, y puede pedir su borrado.

**33. ¿Hay tensiones o desacuerdos en la familia (reparto de tiempo, dinero, medicación, residencia sí o no, probar terapias alternativas o seguir solo la medicina convencional)? ¿Quién manda la última palabra, y cómo participa la propia persona mientras pueda?**

Por qué: Un registro transparente puede aliviar o empeorar el conflicto ('mira cuánto hago yo'). Condiciona permisos, quién añade suplementos, el registro de quién decidió qué y el respeto a la voluntad de la persona (Ley 8/2021).

Si no contestáis: Calendario compartido de turnos y gastos con registro neutro, sin ranking de 'quién hace más'; cualquier terapia nueva se registra con 'quién la propuso' y 'comentada con el médico sí o no', sin bloqueo; la voluntad de la persona se anota como preferencia.

**34. ¿Cómo os coordináis hoy (grupo de WhatsApp, llamadas, libreta en la nevera, Excel, calendario, alguna app como Medisafe)? ¿Qué funciona bien, qué se pierde o genera discusiones, y qué apps habéis probado y por qué las dejasteis o mantenéis?**

Por qué: El competidor real suele ser el grupo de WhatsApp, que ya usan todos. Si algo funciona, lo respetamos (por ejemplo, enviar un resumen por ahí); si se pierde, es el dolor que hay que resolver primero; y saber por qué se abandonó cada app evita repetir sus errores.

Si no contestáis: WhatsApp para avisar y hablar, llamadas para urgencias; la app se centra en lo que WhatsApp hace mal: registro estructurado, histórico y quién hizo qué, y apuntar un dato debe costar menos que escribirlo.

**35. ¿Alguien que no sea el cuidador principal usaría la app solo para ver cómo está la persona desde lejos (un hijo en otra ciudad, un nieto)? ¿Y qué debería ver y qué no?**

Por qué: Es el tercer modo de uso: ni persona ni cuidador. Ahorra llamadas, pero puede generar culpa o intromisión.

Si no contestáis: Rol 'familiar a distancia' con resumen diario de solo lectura, sin notas privadas del cuidador ni autochequeos.

## NACHO · Datos, consentimiento y legal

*Bloqueante n.º 9: Decisiones de la persona (ver arriba).*

*Bloqueante n.º 10: Trámites y comunidad autónoma (ver arriba).*

*Bloqueante n.º 1: Finalidad de la app (ver arriba).*

*Bloqueante n.º 11: Dónde viven los datos (ver arriba).*

**36. ¿Existe ya una asociación o fundación de la familia (o una AFA cercana) que pueda figurar como editora de la app y pedir la exención de cuota de Apple para ONG? Si no, ¿estáis dispuestos a constituir una asociación sin ánimo de lucro (al menos 3 socios fundadores y unos meses de trámites)? ¿Habrá algún ingreso, donación o patrocinio? ¿Quién sería la entidad responsable del tratamiento de datos y de los contenidos ante familias en duelo?**

Por qué: Apple exige entidad jurídica en apps de salud y solo exime la cuota de 99 USD a ONG reconocidas; Google pide cuenta verificada y declaración de salud. Quien figura como editora responde si algo falla; los patrocinios de herbolarios o laboratorios rompen la neutralidad de las fichas.

Si no contestáis: Se construye y prueba solo en privado (APK y pruebas internas) sin publicar en tiendas; se empieza en Android y se ofrece una web instalable para iPhone; sin patrocinadores ni venta de productos.

**37. ¿Conocéis a personas reales que puedan revisar lo que escribimos? Hace falta revisión jurídica (abogado o gestor de una AFA, graduado social, asesor fiscal, delegado de protección de datos) y revisión clínica por ficha (farmacéutico, geriatra o enfermería de la SEGG o de semFYC, unidad de paliativos o SECPAL para el final de la vida, médico hospitalario para antipsicóticos, delirium y sujeciones). ¿Aceptaríais retrasar el lanzamiento público hasta que revisen la finalidad, la privacidad y las fichas?**

Por qué: Nosotros programamos, pero no sustituimos una revisión jurídica ni clínica. Sin revisores con nombre, fecha y firma, las fichas no pueden publicarse y no hay quien responda ante una duda.

Si no contestáis: Uso familiar privado durante el piloto. Publicación solo tras revisión jurídica y firma de un profesional clínico por cada ficha; el contenido sin firmar queda marcado 'pendiente de revisión'.

**38. Voz, fotos y vídeo: ¿grabaríais a la persona (para el libro de vida, síntomas o registros) o solo mensajes de la familia hacia ella? ¿Hay alguien en casa (nietos, otras personas) que aparezca en fotos y deba consentir? ¿Preferís nada de fotos de la comida o medicación? ¿Y las fotos de la piel para seguir una úlcera o una irritación (solo en el móvil y cifradas), o se descartan?**

Por qué: La voz y la imagen son datos personales (y de salud en este contexto). Cada nivel exige su propio consentimiento; las fotos de terceros, y de menores, suman otro. Decide qué se graba, dónde y quién lo ve.

Si no contestáis: Solo voz e imagen aportadas por la familia, guardadas en el dispositivo y desactivadas por defecto; no se graba a la persona sin pulsar un botón, ni se suben a la nube fotos de terceros o de menores.

**39. Al fallecer la persona (o si la familia deja de usar la app), ¿qué queréis que pase con sus datos, fotos y recuerdos? Y si ella pide algún día 'borra todo lo que habéis anotado sobre mí', o cuando el estado avance no pueda decidirlo, ¿qué respetaríais? ¿Quién lo decide y quién puede pulsar el borrado? ¿Qué plazo de conservación queréis tras el fallecimiento o la baja, y quién puede activar el modo duelo?**

Por qué: La LOPDGDD (art. 3) permite que herederos o personas designadas accedan o supriman los datos de fallecidos, y exportar y borrar es un derecho del RGPD. Pero la tensión entre su voluntad pasada, la actual y la protección de la familia no la resuelve la ley sola.

Si no contestáis: Perfil de 'legado digital' con una persona designada; sin designación, los datos se conservan 12 meses en el dispositivo y luego se avisa para exportar o borrar. Exportación completa y borrado total con doble confirmación y copia descargable previa; las voluntades de la persona se muestran antes de cualquier borrado.

**40. ¿Estaríais dispuestos a que, más adelante, datos agregados y anónimos (por ejemplo, 'a muchas familias les ayuda la música por la tarde') sirvan para ciencia ciudadana, solo si cada familia lo acepta de forma voluntaria y aparte? ¿O preferís que nada salga nunca de vuestros dispositivos? ¿Queréis compartir con otras familias o con estudios científicos pequeños, y con qué anonimato?**

Por qué: Los datos de salud agregados solo pueden salir con consentimiento propio, grupos mínimos para que nadie sea identificable y probablemente comité de ética. Si la respuesta es no, no se construye esa parte y se simplifica la arquitectura.

Si no contestáis: En la fase 1 ningún dato sale del dispositivo ni se usa para investigar; la ciencia ciudadana queda como fase posterior, voluntaria, con consentimiento aparte, comité de ética y delegado de protección de datos.

**41. ¿Con qué licencia queréis compartir el código y los contenidos? ¿Queréis que el código sea público (por ejemplo AGPL, que obliga a compartir mejoras, o MIT o Apache, más libres)? ¿Os importa que una empresa lo copie, lo mejore e incluso lo cobre? ¿Y los textos de evidencia, los queréis reutilizables citando la fuente? ¿Y podemos citar o enlazar materiales de Alzheimer's Society o CEOMA, o preferís plantillas propias?**

Por qué: Una licencia permisiva encaja con las tiendas y facilita ayuda gratuita; una más restrictiva protege el fin social pero limita la adopción. Los contenidos suelen ir aparte (CC BY-SA). Cambiarla después es difícil.

Si no contestáis: Código con Apache-2.0 (o MPL-2.0 si las mejoras deben volver al común) y contenidos propios con CC BY-SA; sin reproducir escalas con licencia (MMSE, MoCA, NPI, Zarit, MNA).

**42. ¿Quién va a mantener la app dentro de dos años, cuando el entusiasmo baje y el sistema operativo cambie? ¿Hay alguien en la familia o en una asociación con conocimientos técnicos? ¿Quién revisa cada año los contenidos y con qué fecha de caducidad (vacunas, úlceras, absorbentes, normativa)?**

Por qué: Una app de salud sin mantenimiento se rompe con cada actualización de Android o iOS y se vuelve un riesgo. Esto decide la tecnología (algo muy extendido y fácil de relevar) y si el código abierto es la salida.

Si no contestáis: Mantenimiento con herramientas muy comunes y todo documentado para que pueda continuarlo otra persona; revisión anual de contenidos, con fecha de caducidad en cada ficha.

**43. ¿Qué entidad firmará como fabricante y responsable, y tiene seguro de responsabilidad civil y número D-U-N-S? ¿Aceptáis pedir una consulta formal de cualificación a la AEMPS antes de abrir la app a otras familias?**

Por qué: Si la app se considera producto sanitario, hace falta un fabricante identificado, un seguro y una certificación. La consulta a la AEMPS aclara antes de invertir si la finalidad encaja. Quien figura como responsable responde si algo falla.

Si no contestáis: Uso solo familiar y privado durante el piloto, sin fabricante registrado; consulta a la AEMPS antes de cualquier apertura a otras familias.

## NACHO · Alcance y prioridades

*Bloqueante n.º 2: Alcance de la v1 (ver arriba).*

*Bloqueante n.º 3: Familia única o abierta (ver arriba).*

*Bloqueante n.º 14: Quién usa el móvil (ver arriba).*

**44. ¿Cómo sabréis que la app funciona? Elegid hasta tres señales que podáis ver vosotros (por ejemplo: cero dobles tomas, menos llamadas entre hermanos para preguntar 'qué ha comido', el cuidador principal duerme una hora más, la consulta médica sale preparada).**

Por qué: Sin criterio de éxito acordado se miden cosas fáciles (descargas) y no las que importan. Define qué datos se guardan y se resumen.

Si no contestáis: Éxito = uso diario durante 4 semanas por al menos 2 cuidadores, cero dobles tomas registradas y que el informe se lleve a una consulta.

**45. ¿Qué cosas NO queréis nunca en la app, aunque fueran útiles (cámaras, GPS permanente, mensajes de la persona fallecida, un foro abierto, inteligencia artificial que responda preguntas)?**

Por qué: Las líneas rojas de la familia ahorran semanas de trabajo y de debate, y permiten descartar ideas atractivas desde el principio.

Si no contestáis: Sin cámaras ni audio ambiente, sin foro abierto, sin IA que responda en la nube, y GPS solo con consentimiento y botón manual en la v1.

**46. Cuando algo sale mal (una toma olvidada, un mensaje que asusta), ¿preferís que la app avise mucho o poco? ¿A partir de qué hora no queréis que suene nada en casa?**

Por qué: Un cuidador agotado desinstala la app que le grita. Los avisos van solo al cuidador y se agrupan.

Si no contestáis: Avisos solo al cuidador, agrupados, con horario silencioso de 22:00 a 8:00 y un máximo diario. Nada sonoro en el dormitorio.

**47. ¿Aceptáis lanzar la v1 con un tope de unas 20 fichas de evidencia revisadas y firmadas, en lugar de una biblioteca completa, hasta tener revisores estables?**

Por qué: Una biblioteca sin revisores firmados es el mayor riesgo de confianza y de cumplimiento. Limitar el número de fichas permite publicar con garantías y crecer después.

Si no contestáis: Hasta 20 fichas con revisión firmada; el resto aparece como 'pendiente de revisión' o no se muestra en público.

**48. ¿Qué criterio usaremos para retirar una función que nadie usa a los tres meses, y quién toma esa decisión?**

Por qué: Sin criterio, la app se llena de módulos que nadie usa, y cada uno es un mantenimiento más. Con un criterio claro se simplifica y se libera tiempo para lo que sí se usa.

Si no contestáis: Se revisa el uso cada tres meses; una función sin uso tras dos revisiones se oculta, y la decisión la toman la familia y la persona de apoyo principal.

## NACHO · Técnico, dispositivos y costes

*Bloqueante n.º 15: Dispositivos y sistema operativo (ver arriba).*

*Bloqueante n.º 12: Presupuesto (ver arriba).*

*Bloqueante n.º 13: Sincronización y avisos (ver arriba).*

**49. ¿Hay buena cobertura y wifi en casa, en el centro de día y por donde pasea? ¿Cuántas horas o días podríais pasar sin conexión sin que la app deje de ser útil, y qué pasa si dos cuidadores apuntan lo mismo sin red? Y si la app dejara de funcionar un día (servidor pausado, tienda que la retira, fallo del móvil), ¿qué no podéis perder: la lista de medicación, el contacto del médico, el historial de peso, las fotos y recuerdos?**

Por qué: Si falla la conexión, la app debe seguir registrando y sincronizar después, y los choques entre dos cuidadores sin red son críticos en medicación. Los servicios gratuitos se pausan, y en una app de medicación ese fallo no puede dejar a nadie sin su pauta. Estas respuestas cambian la arquitectura (todo en el aparato primero) y definen qué se guarda también en papel o en el propio móvil.

Si no contestáis: Diseño sin conexión primero (datos en el aparato, sincronización cuando haya red); medicación, alergias, contactos y tarjeta de emergencia siempre exportables a PDF imprimible; copia semanal y hoja de medicación imprimible siempre disponible.

**50. ¿Cómo queréis probar las versiones? Por ejemplo, instalar un archivo APK que os mando por enlace (Android), entrar por TestFlight (iPhone, necesita cuenta de Apple), o abrir una web en el navegador. ¿Quién de la familia puede instalar cosas en su móvil sin ayuda?**

Por qué: Instalar un APK exige permitir 'orígenes desconocidos' y Google ha anunciado verificación de desarrolladores que puede complicarlo. TestFlight necesita la cuenta de Apple; la web es lo más sencillo pero con menos funciones.

Si no contestáis: Pruebas por APK en los Android de la familia y por web instalable en los iPhone, con una sesión de instalación guiada de 20 minutos.

**51. ¿Queréis inteligencia artificial en la app? Si sí, ¿para qué (pasar la voz a texto, resumir el informe para el médico, hacer los textos más fáciles de leer, responder preguntas), y aceptáis que funcione solo dentro del móvil, sin enviar datos de salud a ninguna empresa, aunque sea más limitada?**

Por qué: Enviar datos de salud a una IA en la nube exige contrato de protección de datos y consentimiento específico (RGPD art. 9), y acerca la app a dar consejos clínicos. En el aparato es gratis y privada, pero pesa y no funciona en móviles viejos.

Si no contestáis: Sin IA generativa en la v1. Solo voz a texto en el aparato para apuntar por voz. La IA se reevalúa después con revisión jurídica.

**52. ¿La persona o algún cuidador ya lleva reloj inteligente, pulsera, báscula conectada, tensiómetro, pastillero electrónico, localizador GPS o sensores en casa? ¿Los lleva puestos de verdad o los rechaza?**

Por qué: Si ya existen, podemos leer sus datos (Health Connect o HealthKit) sin comprar nada. Si no, no vamos a depender de hardware: los relojes son poco fiables en demencia y a menudo se rechazan o se pierden.

Si no contestáis: No dependemos de ningún wearable. La v1 funciona solo con registro manual; la lectura de datos del reloj queda como opción posterior.

## NACHO · Forma de trabajo con el equipo

**53. ¿Cómo queréis que trabajemos con vuestra memoria del proyecto? Proponemos un repositorio privado de código, una bóveda de Obsidian con vuestras notas y decisiones, y un archivo CLAUDE.md que resume reglas y decisiones para no repetir preguntas. ¿Os parece bien, quién tendría acceso de lectura y escritura, y hay algo que nunca debe escribirse ahí (nombres, diagnósticos, fotos)?**

Por qué: Sin memoria compartida cada sesión empieza de cero y se pierden decisiones. Pero esas notas pueden contener datos de salud: si el repositorio o la bóveda se sincronizan en la nube, hay que decidir qué se puede escribir y cómo anonimizarlo.

Si no contestáis: Repositorio privado, bóveda de Obsidian local y CLAUDE.md con reglas y decisiones, sin ningún dato personal ni de salud real: solo nombres en clave y ejemplos inventados.

**54. Sobre las palabras clave: HIPOTENUSA autoriza a escribir código y ENOLA detiene y pide explicación. ¿HIPOTENUSA vale para toda una fase (por ejemplo 'el registro de medicación') o para cada paso pequeño? Cuando digáis ENOLA, ¿preferís que pare ya y explique en una frase, o que acabe lo que está haciendo y luego explique?**

Por qué: Evita que escribamos código sin permiso o que os frenemos a cada paso. Con una app de salud queremos que el control lo tengáis vosotros, y conviene que ENOLA funcione como freno inmediato.

Si no contestáis: HIPOTENUSA autoriza solo la tarea concreta que se acaba de describir. ENOLA detiene de inmediato y se explica en tres frases antes de continuar.

## NACHO · Fase avanzada, final de vida y transiciones

**55. Si la persona entra en el próximo año en una residencia, un centro de día o un hospital, ¿la app debe seguir sirviendo allí (acceso del personal, ficha de traspaso, sujeciones) o se queda en casa? ¿Quién de ese centro debería tener cuenta propia, o basta con que la familia exporte e imprima?**

Por qué: Cambia el rol del personal en el RGPD, puede exigir evaluación de impacto y acuerdos con cada centro, y decide si la ficha de traspaso se diseña para el hogar o también para la transición.

Si no contestáis: La v1 se queda en casa; la familia exporta e imprime la ficha de traspaso y la hoja de medicación para residencia u hospital; el personal no tiene cuenta.

**56. ¿En qué fase está hoy la persona, y ha expresado algo sobre el final de su vida o sobre cómo quiere ser cuidada en fases avanzadas? ¿Existe documento de instrucciones previas, y está inscrito en su comunidad autónoma?**

Por qué: La fase avanzada puede durar años y concentra las decisiones más duras (hospitalizar o no, antibióticos, alimentación de confort). Deben prepararse mientras ella aún puede expresarlas; el diseño actual se detiene en la fase leve-moderada y la familia se quedaría sola justo cuando más la necesita.

Si no contestáis: Fase leve-moderada y sin instrucciones previas; la app muestra la planificación anticipada como tema para hablar con el médico y enlaza el registro de cada comunidad, sin guardar deseos sin acuerdo.

**57. ¿Hay incontinencia o rechazo al aseo? ¿Quién hace la higiene íntima, es hombre o mujer la persona, y cómo lo vive cada uno (ella, quien la asea, la familia)? ¿Recibís absorbentes del sistema público, en farmacia con visado o por suministro directo, y en qué comunidad? ¿Aceptáis que la app no muestre nunca valoraciones de orina ni cuente episodios anómalos, y que la temperatura sea solo un dato?**

Por qué: La incontinencia es una de las causas de ingreso y de agitación, y el aseo íntimo es donde más se rompe la dignidad. Define la ficha de higiene, qué se registra (sin valorar), las rutinas y el coste de absorbentes. Las fotos de piel quedan en la pregunta de imágenes.

Si no contestáis: Registro de episodios sin valoración de orina; rutina de aseo con quién asea a quién; ficha de absorbentes con enlace al procedimiento oficial de su comunidad; temperatura solo como dato; derivación fija a atención primaria.

**58. ¿La app informará sobre la ayuda para morir (LO 3/2021) o solo sobre cuidados paliativos, rechazo de tratamiento e instrucciones previas? ¿Quién hará la revisión ético-jurídica de ese contenido?**

Por qué: Es un tema muy sensible y con marco legal propio; incluirlo cambia el contenido, el tono y la revisión necesaria. Sin decidirlo, el equipo no puede redactar nada sobre el final de la vida.

Si no contestáis: Solo cuidados paliativos, rechazo de tratamiento e instrucciones previas, con enlace oficial; la ayuda para morir no se trata en la v1.

**59. ¿Pedimos permiso para usar escalas como PAINAD, MOBID-2 o FAST/GDS, o preferís listas descriptivas sin puntuación?**

Por qué: Algunas escalas tienen licencia o condiciones de uso, y una puntuación puede sonar a diagnóstico. Decide qué se registra y cómo se describe el dolor en quien no puede comunicarlo.

Si no contestáis: Listas descriptivas sin puntuación (dolor, agitación, comodidad) con un toque; ninguna escala con licencia en la v1.

## NACHO · Economía, trabajo y patrimonio

**60. ¿El cuidador principal trabaja? ¿Ha pedido reducción de jornada, adaptación o excedencia, o ha dejado el empleo? ¿Cuál es su situación (cuenta ajena, autónoma, funcionaria, sin empleo, jubilada)? ¿Queréis que la app oriente sobre derechos laborales y deducciones fiscales?**

Por qué: Decide qué fichas de derechos se priorizan, y la carga laboral es un motivo habitual de abandono del cuidado. Las normas cambian, así que cualquier guía laboral o fiscal necesita revisión jurídica y fecha de actualización.

Si no contestáis: Guía laboral y fiscal general, con fecha de revisión y enlaces oficiales; sin asesoramiento individual; se prioriza la información sobre excedencia y reducción de jornada.

**61. ¿La persona tiene grado de dependencia reconocido, PIA y prestación? ¿Tiene certificado de discapacidad? ¿Se solicitó el convenio especial de cuidador dentro de los 90 días?**

Por qué: Sin certificado de discapacidad no se aplican el mínimo por discapacidad ni el patrimonio protegido, y muchos beneficios dependen de pedirlos a tiempo. La app debe avisar de esos plazos a tiempo, así que necesita saber en qué punto está cada trámite.

Si no contestáis: Checklist de trámites con plazos generales y enlace oficial; sin cálculo de cuantías; avisos de plazo activables por la familia.

**62. ¿Quién gestiona hoy las cuentas y el patrimonio? ¿Hay poderes notariales, guarda de hecho o curatela, y hay desacuerdo entre hermanos sobre dinero? ¿Ha habido estafas, compras raras o presiones de terceros?**

Por qué: El patrimonio es el terreno más expuesto a abusos y a conflictos familiares. Saber quién puede hacer qué decide si la app toca datos económicos y a quién se le muestran.

Si no contestáis: La app no guarda datos bancarios ni patrimoniales; solo orienta sobre formas legales de apoyo y muestra una lista de avisos de posible estafa con enlace oficial.

**63. ¿La app ofrecerá plantillas de cartas (a la mutua, al banco, a la empresa) con redacción genérica, o solo enlaces a fuentes oficiales?**

Por qué: Las plantillas ayudan mucho, pero una carta mal ajustada puede causar problemas jurídicos, y sin una persona revisora nadie responde por el texto. Decide cuánto trabajo de revisión hay que sostener.

Si no contestáis: Solo enlaces a fuentes oficiales y guías de redacción; plantillas genéricas solo cuando una persona revisora las firme.

**64. ¿Cómo se reparten y se apuntan hoy los gastos del cuidado (cuidadora, medicación, pañales, suplementos, taxis)? ¿Quién paga, y queréis un registro compartido o preferís que eso quede fuera de la app? ¿Quién ve el registro de gastos y quién lo custodia?**

Por qué: Los gastos compartidos son una causa clásica de conflicto, pero llevar dinero en la app añade datos sensibles y trabajo. Decide si entra en la primera versión.

Si no contestáis: Registro sencillo de gasto por persona y concepto (sin pagos ni cuentas bancarias) y exportación mensual; no entra en la primera versión.

## NACHO · Preguntas sobre cómo trabajar juntos

**65. ¿Queréis que cada frase empiece por NACHO, o solo cada mensaje y cada sección?**

Por qué: Con cada frase el texto se alarga y se hace pesado para leer en el móvil. Al inicio de cada mensaje y de cada sección es más cómodo, pero conviene confirmarlo para no confundirnos con las palabras clave.

Si no contestáis: Cada mensaje y cada sección empiezan por NACHO; las frases no.

**66. ¿Qué longitud preferís en las respuestas (máximo 5 líneas, media página o detalle completo con tablas)? ¿Los términos técnicos los explicamos siempre o los dejamos en un glosario?**

Por qué: Si el formato es incómodo no se lee y las decisiones se retrasan. La longitud decide si una respuesta se puede leer entre dos cosas, y el glosario evita dar por sabidas palabras como IDDSI o CIMA.

Si no contestáis: De 5 a 10 líneas, con detalle opcional al pedirlo; la jerga se explica en una frase la primera vez y hay glosario al final de cada documento.

**67. ¿En qué idioma queréis el código, los comentarios, los nombres de variables y los mensajes de commit: español o inglés? ¿Y la documentación y las notas de decisiones?**

Por qué: Si el código está en inglés y la familia lo lee en español, cuesta revisarlo. El idioma de los commits decide quién puede seguir el historial si otra persona toma el relevo (pregunta de mantenimiento).

Si no contestáis: Código, nombres y commits en inglés; textos de la app, notas y decisiones en español.

**68. ¿Cada cuánto queréis revisar el avance: cada semana, cada quince días o tras cada hito? ¿Qué necesitáis ver para decidir: una demo en el móvil, una lista de pendientes o el coste del mes? ¿Hay fechas que no se pueden mover (una cita médica, el cambio de cuidadora, una operación)?**

Por qué: Marca el tamaño de cada entrega. Con poco tiempo conviene entregas pequeñas, usables en casa en seguida; con más margen se puede construir más antes de enseñar.

Si no contestáis: Revisión cada 2 semanas con una demo corta usable en el móvil, una lista de decisiones pendientes y el coste acumulado del mes.

**69. ¿Queréis que el repositorio de código sea público desde el principio, o privado hasta tener una primera versión revisada? Y las notas con datos de la familia, ¿nunca salen de vuestros dispositivos?**

Por qué: Un repositorio público da transparencia y ayuda externa, pero cualquier dato real que se cuele queda expuesto para siempre. La visibilidad condiciona cuándo se publica el código y qué licencia se aplica (pregunta de licencia).

Si no contestáis: Privado hasta la primera versión revisada y después público, sin datos reales de salud ni de la familia, ni en el código ni en el historial de commits.
