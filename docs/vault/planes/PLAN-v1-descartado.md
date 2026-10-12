# NACHO · Plan maestro: app de apoyo en Alzheimer (nombre de trabajo «Hilo»)

12/10/2026 · Estado: propuesta para analizar juntos; nada construido. **Nada de este plan se programa ni toca el repositorio hasta que el promotor diga HIPOTENUSA.**

## NACHO · 0. Cómo leer esto y reglas del juego

**Palabras clave.**

| Palabra | Qué significa | Qué hacemos al oírla |
|---|---|---|
| **HIPOTENUSA** | Autorización para escribir código o tocar el repositorio | Hasta oírla, ni una línea. Propuesta: vale para la tarea descrita justo antes (pregunta 9.3 de PREGUNTAS.md) |
| **ENOLA** | Parar y explicar con detalle | Se detiene todo y se explica qué se hacía, por qué y qué falta |
| **NACHO** | Canario de memoria | Cada respuesta del orquestador empieza por NACHO; si falta, se ha perdido el contexto. En los documentos, título y secciones `##` empiezan por «NACHO · » |

**Qué se hizo para llegar aquí.** Nadie ha programado nada.
1. **13 dimensiones** investigadas con búsqueda web (nutrición, medicación, sueño, cobre, medicina china, natural y holístico, cuidador, seguridad y delirium, UX de la persona, competencia, stack, legal y ética, datos e investigación), cada una **revisada por un verificador escéptico independiente** que bajó niveles y marcó lo no comprobado.
2. **4 enfoques de diseño independientes** (familia primero, persona primero, riesgo primero y plataforma de evidencia), **2 jueces** y **una síntesis** con el esqueleto de familia primero.
3. **Un crítico de completitud**: 11 contradicciones, afirmaciones flojas y 5 huecos, que se investigaron y verificaron igual (fase avanzada, incontinencia, vacunas, economía del cuidador y transiciones).
4. **70 preguntas** desde 6 lentes (persona, familia, clínico, legal, producto, técnico); 12 bloqueantes.
5. En total, **unos 50 agentes**: Sonnet investigó y redactó; Opus refutó, diseñó y juzgó; Haiku consolidó; Fable orquestó.

Cuando el crítico y la síntesis chocan, **manda la resolución del crítico**. Donde eso pasa, se dice. Hay una excepción declarada: en los ejes de evidencia el crítico pidió dos y el plan usa tres (los dos del crítico más el riesgo); se explica justo debajo.

**Cómo leer los niveles de evidencia.** Una sola letra engaña: una «A» junto a «ginkgo» se lee «recomendado» y significa lo contrario. Por eso el plan y la app usan **tres ejes** (dirección y confianza, que pidió el crítico, más el riesgo de la síntesis):

| Eje | Valores | Pregunta que responde |
|---|---|---|
| **Dirección** | Ayuda · No ayuda · Incierto · Perjudica | ¿Hacia dónde apunta lo que se ha medido? |
| **Confianza** | A alta · B moderada · C baja · D muy baja, descriptiva o anecdótica | ¿Cuánto nos fiamos de esa dirección? |
| **Riesgo para esta población** | Bajo · Medio · Alto | ¿Qué puede salir mal en una persona mayor, polimedicada y con demencia? |

Ejemplo: **ginkgo para prevenir la demencia: No ayuda · A · riesgo medio.** La A significa «alta confianza en que NO funciona» (ensayos GEM y GuidAge). No es un aval.

**Las normas** no llevan letra: son «dato normativo, verificado el día X». **Las tarifas** no llevan etiqueta. En este texto, «(B)» es la confianza; la dirección va en la frase. Lo marcado «cita a verificar» se mantiene así.

## NACHO · 1. Resumen ejecutivo

**La decisión.** Proponemos construir «Hilo», una herramienta de coordinación y preparación para **una casa** con una persona con Alzheimer. Tiene tres superficies sobre un mismo registro cifrado: **el Círculo** (móviles de quienes cuidan), **la Pizarra** (tablet o móvil viejo de la persona) y **el Kit** (papel y fondo de pantalla). Primero para vuestra familia, en una v0 de **semana 0 más 8 semanas**, con seis piezas: eventos y círculo; medicación y alarmas al cuidador; diario por excepción y relevo; «Esto soy yo», «Se ha perdido» y kit; Pizarra; e informe para la consulta.

**Qué es y qué no.** Registra, recuerda al cuidador lo pautado, comunica, prepara la consulta, informa con nivel de evidencia y deriva. **No** diagnostica, puntúa, dosifica, detecta deterioro ni avisa de que «algo va peor». Con esa finalidad, en principio no sería producto sanitario y la regla 11 del MDR (que solo clasifica lo que ya es producto sanitario) no llegaría a aplicarse. Dos salvedades: nadie pudo leer el texto oficial de la MDCG 2019-11 rev.1 (403), y la propia guía cita «un módulo de medicación» entre los que pueden ser producto sanitario; por eso se pide una consulta a la AEMPS antes de abrir a otras familias.

**En qué cambia respecto a vuestra idea inicial, y por qué.**
- **El núcleo no es el diario ni la persona: es la coordinación** («¿se la habrá dado ya?», relevo, consulta). El abandono es el modo de fallo del sector: solo el 43 % de 35 apps se actualizó en 12 meses y YoTeCuido está parada desde 2020. Nueve categorías diarias no se sostienen.
- **Sin semáforo.** Interpreta datos (zona gris de la regla 11), da falsa calma y presiona a la cuidadora. Lo sustituye un parte del día que escribe una persona.
- **Sin GPS propio.** No ha demostrado reducir daños (C) ni avisa en salidas permitidas. A cambio: «Se ha perdido» con el 112 en dos toques, ficha, QR y ubicación nativa con acuerdo.
- **Cobre, medicina china y lo natural entran desde el v0 como fichas honestas iguales para todos,** no como eje. Ninguna intervención sobre metales ha funcionado.
- **La biblioteca no «se actualiza sola».** Se propone sola y la publica una persona. Tope de 8 a 10 fichas en v0 y unas 20 en v1, firmadas.
- **Coste casi cero, no cero.** Unos 23 € en v0; a escala, de unos 280 a 1.060 €/año según la tabla de la sección 5, a cargo de una entidad. El cuello de botella no son los tokens: son las personas (médico, farmacéutico, jurista, AFA).
- **Se añade lo que faltaba:** una métrica de éxito con regla de parada, la persona como titular de sus datos, la continuidad si el promotor lo deja, y los cinco huecos del arco vital (fase avanzada, incontinencia, vacunas, trabajo y dinero, transiciones).

**Métrica de éxito y regla de parada.** La familia registra al menos **5 de 7 días en la semana 12** sin que nadie se lo pida. Hasta demostrarlo no entra una segunda familia. Si no se cumple, se para y se revisa el método antes de añadir nada.

**Qué necesitamos de vosotros para arrancar.**
1. Responder las **12 preguntas bloqueantes** (sección 13). Las más urgentes: la medicación actual y quién la gestiona, los turnos, los móviles reales y si aceptáis por escrito la finalidad «anota, recuerda, informa y deriva».
2. **Nombrar a las personas**: un médico de familia o farmacéutico que revise textos (unas 4 horas en el v0), y quién será el segundo administrador del círculo.
3. **La semana 0**: siete días de notas de voz «lo peor de hoy» y una conversación en lectura fácil con la persona sobre qué quiere y qué no.
4. **Unos 23 €** para la cuenta de Google Play.
5. Decir **HIPOTENUSA** cuando estéis de acuerdo con el plan, o **ENOLA** en cualquier punto que queráis desmontar. Sin HIPOTENUSA no se escribe ni una línea ni se crea el repositorio; la semana 0 (notas de voz, acta, dispositivos) es trabajo vuestro en papel y no lo necesita.

## NACHO · 2. Lo que dice la evidencia (verdades incómodas y lo que sí ayuda)

La verdad más incómoda va primero: **ningún alimento, suplemento, hierba ni metal ha demostrado frenar el Alzheimer ya establecido.** Lo mejor respaldado es psicosocial, de bajo riesgo y de efecto pequeño. No es desesperanza: es dónde poner la energía. Una app que ahorre una dosis doble, una noche de búsqueda o una consulta mal preparada vale más que diez promesas.

| Tema | Qué se sabe (con nivel) | Qué NO funcionó | Qué hace la app |
|---|---|---|---|
| **Alimentación e hidratación** | ESPEN 2024 (guía: B según el verificador): 40 recomendaciones, la mayoría puntos de buena práctica por falta de ensayos, es decir, consenso (D): causas tratables, ayuda en la comida, suplementos orales para nutrir, no para la cognición. Sin sonda en demencia grave. Prevención multidominio útil para familiares en riesgo sin demencia (B) | Dieta MIND (NEJM 2023: No ayuda · A); vitamina E, omega-3, cetogénica, suplementos «para la demencia» | Losetas «Comió» y «Bebió»; causas tratables para la consulta. No diagnostica malnutrición ni asigna texturas |
| **Medicación** | IACE y memantina: beneficio sintomático modesto (B). Antipsicóticos: más mortalidad (A, OR aproximado 1,5). Lecanemab y donanemab: solo en fase temprana con amiloide confirmado y sin homocigosis APOE e4; efecto muy modesto (IPT-445, A). Financiación en el SNS sin verificar (solo prensa, D). Dolor no tratado como causa de agitación (B) | Brexpiprazol sin indicación en demencia en la UE; antidepresivos sin beneficio en la depresión con demencia; motores de interacciones (RxNav discontinuado) | Pauta literal, estados de toma con autor, aviso de duplicado redactado como integridad del registro («hay dos entradas con el mismo nombre»), enlace a la ficha técnica. Sin etiquetas por sustancia al registrar. Avisos solo al cuidador; nunca dosis |
| **Sueño y atardecer** | Alteraciones en hasta el 40 %. DREAMS START (un ECA, n=377, 2026): 6 sesiones para familiares redujeron la alteración del sueño (B). Actividad física y social e intervenciones con el cuidador: beneficio pequeño (Cochrane 2023, certeza baja: C); en un ensayo, caminar y más luz en casa redujeron el tiempo despierto medido, sin mejora en la escala del cuidador (McCurry 2011, B). Ningún ECA del atardecer | Melatonina: probablemente poco o ningún efecto (C). Luz: confianza muy baja (D). Sin ECA de hipnóticos ni antipsicóticos para dormir | Loseta «Noche»; agenda según las costumbres de la persona; programa conductual en v2 con licencia |
| **Cobre y metales** | Asociación observacional heterogénea (Li 2017; U en UK Biobank 2026), sin causa. Riesgo real: exceso de zinc (también por adhesivos de dentadura) y metales pesados en el 20,7 % de productos ayurvédicos online (JAMA 2008) | Cobre oral (Kessler 2008) neutro; zinc (ZINCAiD 2025), quelantes, deferiprona (perjudicial) y selenio, sin beneficio | Fichas de cobre y de zinc con adhesivos en v0. Sin guía del agua ni mg/día junto a alimentos |
| **Medicina china y oriental** | Tai chi y qigong: efecto pequeño (B). Acupuntura, huperzina, yokukansan, azafrán y melisa: C. Moxibustión: D. Setas: melena de león, un solo ensayo de 30 personas con deterioro leve (C); reishi y el resto, sin verificar (D). Informes RedETS (#coNprueba). MBSR para cuidadores, certeza baja (C) | Ginkgo no previene la demencia (A). Aromaterapia, certeza muy baja | Fichas de tres ejes sin dosis ni compra; «producto en uso» con foto para el médico |
| **Natural y holístico** | Estimulación cognitiva en grupo (+1,99 MMSE; Cochrane 2023, certeza moderada: B). Música frente a cuidado habitual en síntomas depresivos (DME −0,23, B), sin efecto en agitación. Reminiscencia: ligera mejora en residencias (Cochrane 2018, B), poca o ninguna en domicilio; con tablet, C | Ejercicio no frena el declive (DAPA, n=494); ACHIEVE negativo; curcumina, resveratrol. Homeopatía, reiki, Bredesen y CBD **no se investigaron** | Mi música; actividades que valen por sí mismas; lo no investigado queda «sin revisar» |
| **Cuidador** | Depresión del cuidador, lo más modificable, efecto pequeño (Cheng y Zhang 2020, B según el verificador, meta-revisión de calidad baja). START (B). Coordinación de cuidados, Care Ecosystem n=780 (B). Un tercio refiere conductas abusivas significativas, asociadas a ansiedad y depresión del cuidador (Cooper 2009, C) | Grupos y respiro «puros»; iSupport en España, abandono muy alto; apps sin efecto en carga | Pregunta 0-10 privada y rutas fijas (AFA, médico, 024, 112); microcontenido tipo START en v1 |
| **Seguridad y delirium** | Las desapariciones críticas empiezan en salidas permitidas y el tiempo manda (Rowe 2011, C). El 53 % de Safe Return no llevaba la pulsera (C). Delirium superpuesto en cerca del 30 % en la comunidad (B) | GPS sin reducción de daños demostrada (C); 4AT para cuidadores sin validez | «Se ha perdido», ficha y QR, ropa de hoy, simulacro; «Hoy está distinto» con mensaje fijo |
| **Fase avanzada y final de vida** | Pronóstico incierto: en CASCADE murió el 54,8 % en 18 meses (C). Planificación anticipada: aceptable y asociada a menos hospitalizaciones (revisión paraguas, C; el verificador la bajó de B a C). Ayudas a la decisión reducen el conflicto familiar (B) | Sonda: sin beneficio demostrado y más úlceras con PEG (Davies 2021). Antibióticos en neumonía avanzada: más supervivencia, peor confort (C) | Valores y preferencias de la persona, instrucciones previas, plan de crisis, modo duelo. **Línea roja:** sin pronóstico, estadificación ni propuestas de retirada |
| **Incontinencia e intimidad** | Micción incitada, a corto plazo (B). No tratar la bacteriuria asintomática (B, IDSA 2019). Aseo centrado en la persona (B, residencias). Absorbentes por prestación farmacéutica (RD 90/2026, dato normativo) | Aseo a horas fijas (C); tiras de orina en mayores de 65; arándano en mayores institucionalizados (No ayuda · A); D-manosa (MERIT 2024, B); restringir líquidos | Diario de 3 días, piel con foto local, fichas, guía de absorbentes. **Línea roja:** sin color ni olor de la orina; nunca antibióticos |
| **Infecciones y vacunas** | Vacuna recombinante: previene zóster y neuralgia (A). Relación con demencia: C (experimentos naturales y cohortes). Calendario 2026: zóster a los 65 con recaptación hasta 80 (dato normativo) | Crítica de 2026 (Brain Behav Immun): efectos implícitos imposibles (>100 %) y sin descenso poblacional; otras vacunas muestran asociaciones parecidas (sesgo del vacunado sano). Valaciclovir (VALAD, B): no eficaz. Ensayos aleatorizados en Dinamarca y Finlandia, con resultados estimados hacia 2029-2030 | Registro de vacunas, recordatorios que crea la familia, ficha del zóster en dos bloques. **Línea roja:** nunca «previene el Alzheimer» |
| **Trabajo, dinero y patrimonio** | Verificado en el BOE a 12/10/2026 (dato normativo): reducción de jornada, adaptación (15 días con presunción de concesión), excedencia hasta 2 años, despido nulo, Ley 4/2026 (en vigor el 23/10/2026). Abuso financiero en demencia: 28,3 % con intervalo enorme (C) | El módulo de estafas del borrador se apoyaba en divulgación: retirado | Guía de derechos fechada, plantillas, cuaderno de papeles, gastos. **Línea roja:** nunca calcula plazos ni importes ni «detecta» abuso |
| **Transiciones** | Planificación del alta (B). Prevención multicomponente del delirium en planta: 10,5 % frente a 18,4 % (B). Mínima sujeción en residencias (B). Instrucción 1/2022 de la Fiscalía | Conciliación de medicación, certeza muy baja; alarmas de cama; no hay derecho estatal general de acompañamiento en urgencias | Ficha de traspaso, maleta, modo hospital, checklist de alta, guía de sujeciones. **Línea roja:** sin cribado de delirium; el comparador de listas no interpreta; el centro no accede a la app |

### El cobre, con el tono exacto que usará la app

Sabemos que el cobre os importa, y por eso lo tratamos con el mismo cuidado que lo demás. Texto de la ficha, tal cual:

> «Tomar cobre no ha mostrado efecto (un ensayo, 68 pacientes, Kessler 2008). Confianza B: es un solo ensayo pequeño, que no descarta efectos modestos. Hay una asociación observacional muy heterogénea (más cobre libre y menos zinc en sangre; forma de U en UK Biobank 2026) que no demuestra causa. No funcionaron: zinc (ZINCAiD 2025), quelantes (Cochrane), deferiprona (JAMA Neurol 2025: aceleró el deterioro y causó neutropenia en el 7,5 %), selenio (PREADViSE). Riesgo alto con quelación o “detox de metales”; medio con exceso de zinc, también por algunas cremas adhesivas de dentadura, que puede causar déficit de cobre con daño neurológico y anemia. Referencias públicas, no pautas: EFSA, 5 mg/día de cobre y 25 mg/día de zinc; agua de grifo, 2,0 mg/L de cobre (RD 3/2023). Hable con su médico si toma zinc, usa adhesivo a diario o le ofrecen quelación.»

La app **nunca** dirá «el cobre causa el Alzheimer» ni «dieta sin cobre», ni pondrá un rango de mg/día junto a una lista de alimentos: es un único estudio observacional, y empujaría a restringir frutos secos, legumbres y marisco en alguien que ya puede comer poco. El litio en microdosis queda en una ficha con confianza D (el dato causal es de ratones) y riesgo alto.

### La medicina china y lo natural, con el tono exacto que usará la app

Queríais todos los ángulos, y los tendréis. La regla: **cada ficha se juzga por lo que se ha medido, no por su origen.** Ni «natural» como argumento a favor (lo prohíbe el RD 1907/1996) ni «oriental» como argumento en contra. Ejemplo, la huperzina A:

> «Dirección incierta: ensayos pequeños, sobre todo de un solo país, sugieren beneficio; el ensayo estadounidense (Rafii 2011, cita a verificar) fue negativo en su variable principal. Confianza C. Riesgo medio-alto: actúa como donepezilo, rivastigmina y galantamina y sumarlos puede aumentar efectos como pulso lento o náuseas (información general, no un cálculo para esta persona). Se vende como suplemento, sin control de dosis ni de pureza. Si toma uno de esos fármacos, consulte antes.»

Todas las fichas tienen las mismas secciones (qué es; qué se ha probado, a favor y en contra; lo que no sabemos; seguridad; de qué hablar con su médico; fuentes; revisor, fecha y caducidad) y cierran con «No suspenda ni cambie ningún medicamento; consúltelo antes». Son **iguales para todos** y nunca se cruzan con la medicación registrada. Lo que sí podéis hacer es anotar «toma esto desde el lunes», con foto de la etiqueta, para que el médico lo vea en el informe.

## NACHO · 3. El producto

**Qué es.** Una herramienta de coordinación para una casa. Finalidad prevista, congelada: «Organizar el cuidado, registrar lo ocurrido, recordar al cuidador lo pautado por el profesional, comunicar a la familia, preparar la consulta, informar con nivel de evidencia y derivar. No diagnostica, trata, previene ni cura ninguna enfermedad.»

**Qué no es.** No es producto sanitario ni localizador GPS, foro, chatbot o tienda. No sustituye al pastillero ni al sistema personalizado de dosificación (SPD) de la farmacia, que siguen siendo la referencia física. No recuerda la medicación a la persona.

**Para quién, por orden.** 1) La cuidadora o cuidador principal que comparte el cuidado. 2) La persona, como usuaria y titular de sus datos. 3) La familia a distancia, como contribuyente y no como supervisora.

**Las tres superficies.**
- **El Círculo** (móviles de quienes cuidan): quién dio qué y cuándo, qué pasó esta noche, el relevo en una pantalla y lo que hay que llevar a la consulta.
- **La Pizarra** (tablet o móvil viejo de la persona): «JUEVES» enorme, «por la tarde» con icono, quién viene hoy, Mi gente y Mi música. Tres botones como máximo. Funciona aunque nunca se toque. **No contiene diario, medicación ni informes, ni siquiera cifrados**: la persona no debe leer «hoy agresiva» sobre sí misma.
- **El Kit** (papel y fondo de pantalla): «Esto soy yo», «Se ha perdido» y la hoja de nevera. Sigue protegiendo aunque la app se abandone.

**Roles y permisos.** Los datos se cifran con una clave por categoría (`persona`, `cuidados`, `circulo`); cada rol recibe solo las suyas.

| Rol | Dispositivo | Puede | Claves |
|---|---|---|---|
| Persona (titular) | Pizarra | Ver el día, el mensaje, Mi gente y Mi música; pedir «Ahora no»; ver «Quién ve mis cosas» | `persona` |
| Apoyo principal | Círculo, densidad Completa | Todo; administrar e invitar. No es representación legal | las tres |
| Cuidador en casa | Círculo, Sencilla o Completa | Registrar tomas, diario, relevo e incidentes | las tres |
| Familiar a distancia | PWA o Círculo | Leer el parte, escribir en la Pizarra, enviar fotos; medicación solo si se concede | `persona`, `circulo` |
| Cuidadora contratada (v1) | Círculo | Tomas e incidentes de sus turnos; sin histórico ni gastos; con caducidad y aviso del art. 89 LOPDGDD | `cuidados` |
| Profesional | Ninguno | Leer el PDF que le da la familia | ninguna |

Siempre **dos administradores**, para que el círculo no quede huérfano. La **densidad Sencilla**, para un cónyuge mayor, tiene cuatro botones: «Dado», «No ha querido», «Luego» y «Necesito ayuda ya». Salir de la Pizarra exige PIN del cuidador.

**La persona como titular.** Con la Ley 8/2021 la persona decide con los apoyos que elija; ni la familia ni la app otorgan representación. Por eso:
- El consentimiento es un **proceso**, no una casilla: por finalidad (registro, medicación, fotos, voz, ubicación, investigación), con quién decidió, con qué apoyo, cómo, y cuándo se revisa.
- **«Ahora no»** en la Pizarra silencia música y mensajes una o dos horas. Se registra como asentimiento retirado y el Círculo ve «Carmen pidió tranquilidad a las 17:10» (nombre de ejemplo), sin etiqueta clínica.
- Si la persona retira el asentimiento a una finalidad, ese registro **se pausa** y la app no permite saltárselo. Si la familia cree imprescindible un registro, lo habla con ella y con su médico y lo anota en el acta; mientras, pastillero y papel. La app no decide.
- Texto fijo en el Círculo: «Un rol en esta app no da representación legal. La persona decide con los apoyos que elija (Ley 8/2021).»
- Se recoge su **legado digital** (art. 3 LOPDGDD): qué pasa con sus datos cuando fallezca.

Queda abierta una pregunta del crítico: si la persona ya no puede consentir y el apoyo no es representación, ¿quién consiente (art. 9.2.a RGPD) en el modo sincronizado? Se pide dictamen (sección 12).

## NACHO · 4. Mapa de funciones por módulo

Para leer la tabla: **la evidencia respalda la necesidad o el enfoque, no la app.** Ninguna función de Hilo tiene evidencia propia; eso solo lo diría una evaluación (v2).

| Módulo | Qué hace | Versión | Evidencia | Línea roja |
|---|---|---|---|---|
| **Pizarra** | Día y parte del día, línea de la familia con caducidad, Mi gente, Mi música, Llamar o «Ahora no». Mensajes de voz desactivados | v0; voz en v1 | Reloj D; música B (musicoterapia, no listas de reproducción); reminiscencia con tablet C | Sin medicación, rojo, alarmas ni aciertos. Niveles manuales, nunca estadios GDS. Un fallecido nunca llama |
| **Diario por excepción** | «Día normal» de un toque; losetas Noche, Comió, Bebió, Ánimo, Deposición, Dolor, Caída y Nota; observado frente a valorado | v0 | Coordinación B; sesgo del informante (Arons 2013, B; resultado citado de memoria, pendiente del texto completo) | Sin rachas, umbrales ni ordenar «lo que funciona»; «coincidir no es causar» |
| **Medicación** | Alta por CIMA, pauta literal con fuente, cinco estados sin valor por defecto; dos tomas registradas o dos entradas con el mismo nombre se muestran como integridad del registro, no como alerta clínica. Parches con «retiré el anterior»; problemas de suministro | v0; parches en v0 si la persona los usa (se sabe en S0), si no en v1; suministro en v1 | Un recordatorio a la persona puede provocar dobles tomas, por eso el aviso va al cuidador (D, consenso de diseño); errores de dosificación, algunos fatales, por no retirar el parche anterior (ficha técnica de Exelon) | Sin dosis, consejo ante olvidos ni interacciones. Sin etiquetas por sustancia al registrar: solo en la ficha general del fármaco, igual para todos, cuando se abre. Nunca recuerda la medicación a la persona |
| **Nutrición** | Losetas y causas tratables; peso neutro e IDDSI copiado del informe | v0 mínimo; resto en v1 | ESPEN: guía B, recomendaciones de consenso D; MIND: No ayuda · A | No diagnostica ni asigna texturas |
| **Sueño y rutina** | Loseta Noche; agenda según costumbres; programa para el cuidador | v0; programa en v2 con licencia | DREAMS START B; luz D | Sin pautas de siesta ni fármacos |
| **Conducta y SOS** | «Hoy está distinto» (sí o no; causas posibles sin ordenar; mismo mensaje con 1 que con 8 síes); «Necesito ayuda ya»; diario ABC con «dolor primero» y signos de malestar sin suma | v0; ABC en v1 | START B; dolor primero B | No atribuye causa ni puntúa; sin NPI, PAINAD ni versiones simplificadas. Texto firmado por un médico y validado con un consultor: es la función con más riesgo regulatorio |
| **Seguridad** | «Esto soy yo» (PDF, tarjeta, QR con texto), fondo «Si me encuentras», ropa de hoy, «Se ha perdido» con 112 en dos toques, kit de nevera, simulacro. Temporizador de vuelta y tarjeta del cuidador | v0; extras en v1 | Rowe 2011 C; GPS C | Sin GPS propio; ubicación nativa con acuerdo; nunca sustituye al 112 |
| **Cuidador** | Pregunta 0-10, «he perdido la paciencia», pregunta de autolesión con ruta fija a 024 y 112; microcontenido tipo START | v0; microcontenido en v1 | Depresión del cuidador B (meta-revisión de calidad baja); START B | Solo local; sin Zarit, PHQ ni versiones simplificadas; la pregunta de autolesión no suma ningún total |
| **Círculo y relevo** | «Últimas 24 h» con tomas dudosas primero, traspaso, «lo que hemos aprendido con ella» (texto libre de la familia, con preferencias de intimidad), parte del día. Turnos y gastos | v0; turnos en v1 si se piden | Coordinación B | Sin semáforo ni rankings |
| **Biblioteca** | 8 a 10 fichas en v0 (cobre, huperzina, música y zinc fijas; propuesta: melatonina, ginkgo, tai chi, zóster, tiras de orina, litio); unas 20 en v1; `/evidencia` en v2 | v0-v2 | Tres ejes; registro canónico | Iguales para todos; sin dosis, marcas ni testimonios |
| **Informe** | Bandeja «para la próxima consulta», PDF de una página, JSON; FHIR R4 | v0; FHIR en v2 | Coordinación B | Sin colores ni interpretación; discrepancias juntas, no promediadas |
| **Trámites** | Dependencia y BVD (documentar, no puntuar), Ley 8/2021, conducción, por comunidad y con fecha | v1 | Dato normativo | Sin importes ni baremo calculado |
| **Fase avanzada y final de vida** *(nuevo)* | «Mis valores y preferencias» que rellena la persona («lo que dijo ella» frente a «lo que cree la familia»), en papel desde la semana 0; instrucciones previas por comunidad; plan de crisis con lo hablado con el médico; una pregunta fija para la consulta, igual para todos («¿revisamos la medicación ahora que el objetivo ha cambiado?»); modo duelo. Guías de decisión (sonda, hospitalización, antibióticos) y directorio de paliativos. La LO 3/2021, solo si lo decidís tras revisión ético-jurídica | v1; guías y directorio en v2 | Planificación anticipada C; ayudas a la decisión B | Nunca estadifica (FAST y GDS tienen copyright), pronostica, puntúa dolor ni propone retiradas. Plan de crisis sin opciones precargadas |
| **Incontinencia y cuidado íntimo** *(nuevo)* | Diario miccional de 3 días; días desde la última deposición como dato; piel con foto solo local; fichas de aseo, piel, tiras de orina y «lo natural y la orina»; aviso al cuidador para ofrecer ir al baño, con el intervalo que fija una persona (nunca a la propia persona); absorbentes por comunidad | Deposición e intimidad en v0; resto en v1 | Micción incitada B; bacteriuria B; aseo B | Sin color, olor ni turbidez; nunca cultivos, antibióticos ni laxantes; señales de derivación sin umbral |
| **Infecciones y vacunas** *(nuevo)* | Registro de vacunas por miembro; recordatorios al Círculo con la fecha que da el centro de salud («confirma con tu centro de salud»), nunca a la persona; fichas del zóster (A para zóster, C para demencia) y de antivirales; enlace al calendario de la comunidad; «cuídate tú»; higiene oral | Ficha en v0 si cabe; resto en v1 | Zóster A; demencia C; VALAD B | Nunca «previene el Alzheimer»; no calcula elegibilidad ni intervalos |
| **Economía, trabajo y patrimonio** *(nuevo)* | Derechos laborales por tipo de trabajo con fecha; aviso de despido nulo y derivación; plantillas y registro de fechas; cuaderno de papeles; empleo de hogar; gastos; poderes, guarda de hecho y patrimonio protegido; pasos ante sospecha de abuso; bono social | v1; observaciones sobre el dinero en v2 | Dato normativo; abuso C | No calcula derechos, plazos ni importes; no detecta abuso |
| **Transiciones** *(nuevo)* | Ficha de traspaso; maleta; modo hospital (observaciones, delirium, objetos familiares, enlace al 4AT oficial); checklist de alta; comparador de listas de medicación como preguntas; tarjeta de acompañamiento; guía de sujeciones; hoja de ruta de residencia; modo transición (congelar, exportar, registro de accesos) | Traspaso en v0; casi todo en v1; modo transición en v2 | Alta B; delirium B; sujeciones B; antipsicóticos A | Sin cribado; el comparador no interpreta; sin «momento de ingreso»; el centro no accede a la app |
| **n=1** | Protocolos de 7 días de base y 14 de prueba, solo con actividades que valen por sí mismas | v2 | Viabilidad D | Bloqueado para fármacos y suplementos; sin conclusiones |

## NACHO · 5. Arquitectura y coste

**Stack.** Flutter, un solo binario con perfil elegido al emparejar (Pizarra o Círculo). **Android primero** en v0: alarmas fiables, fijado de pantalla y pista de prueba interna de Play. Familiares con iPhone: una PWA ligera que solo recibe las claves `persona` y `circulo` y guarda 7 días. iOS nativo en v1. Accesibilidad desde el sprint 1 (fuente al 200 %, lectores de pantalla, objetivos de 19 mm, contraste 7:1). Lo crítico vive en un paquete aparte, `safety_core`, con revisión obligatoria.

**Datos locales cifrados.** Drift con SQLCipher; la clave, en Keystore o Keychain. Registro de eventos **solo de adición**: nada se borra ni se edita, se corrige con un evento nuevo que apunta al anterior. **Nada derivado se guarda** (ni puntuaciones ni niveles de riesgo), y un test de esquema lo comprueba. El chequeo del cuidador, la foto de la ropa y los borradores no existen en el esquema de sincronización.

**Buzón E2E y planes B y C.** El servidor es un buzón tonto: guarda texto cifrado y no sabe leerlo. libsodium (XChaCha20-Poly1305, X25519, Ed25519), una clave por categoría. Los medios se borran del servidor cuando todos los dispositivos confirman o a los 14 días.
- **A:** Supabase Free en Frankfurt. Se pausa tras una semana sin actividad: la Pizarra envía un latido diario y, si se pausa, nada urgente se rompe.
- **B:** Appwrite Cloud en Frankfurt (pausa y contrato de encargo por confirmar), tras la misma interfaz `SyncTransport`.
- **C (escala):** Supabase Pro (25 USD/mes) o un nodo PocketBase de una AFA, con versión fijada (aún no es 1.0).
- **Si se come las semanas:** el v0 funciona con un solo dispositivo de la casa.

**Auth por QR.** Sin email ni contraseña. Se une un móvil escaneando un QR en persona, con un token de un solo uso de 10 minutos. Revocar a alguien rota las claves afectadas. **Recuperación:** hoja de rescate impresa en dos copias en manos de dos familiares, exportación cifrada mensual y un simulacro de restauración con la familia como criterio de salida del v0.

**Notificaciones.**
- **Android:** `flutter_local_notifications`; permiso `POST_NOTIFICATIONS`; `SCHEDULE_EXACT_ALARM` pedido con pantalla explicativa, **nunca `USE_EXACT_ALARM`** (la política de Play lo reserva a apps de alarma y calendario); reprogramación tras `BOOT_COMPLETED` y tras actualizar; comprobación en cada arranque con banner rojo si se revoca; guía de batería por fabricante.
- **iOS (v1):** tope de **64 notificaciones pendientes**; ventana deslizante de 48 a 72 h (6 tomas diarias nunca superan 60). Time Sensitive; Critical Alerts necesita autorización de Apple y solo se pediría para «Se ha perdido», sin depender de ella; AlarmKit (iOS 26) a evaluar.
- **Panel de salud** en «Ahora»: permiso, batería, «avisos programados hasta el jueves», última sincronización, «probar alarma ahora» y prueba semanal tipo detector de humo.
- **Toma no confirmada:** la evalúa cada móvil, no el servidor. Cada dispositivo con `cuidados` programa un aviso de respaldo a T+30 min y lo cancela si llega la confirmación.
- **Remotas:** FCM gratuito con texto genérico («Hay novedades en la familia»). La Pizarra nunca suena.

**Offline.** Todo funciona sin red salvo sincronizar y el push. El camino crítico no pasa por ningún servidor: 112 por `tel:`, hoja de compartir del sistema, QR con texto, papel. Dos tomas registradas para la misma hora se muestran como integridad del registro («constan dos registros: Luis a las 9:02 y Ana a las 9:10. Comprobad el pastillero»), sin consejo de dosis, y nunca se resuelven solas.

**IA: ninguna en v0 ni v1.** Tres razones: los datos de salud (art. 9 RGPD) no deben salir a una nube; una API de IA cuesta dinero; y un resumen «inteligente» se acerca a interpretar, la frontera de la regla 11. El dictado del teclado basta. Nunca clonación de voces, chat con la persona ni detección de emociones: es una decisión propia, más estricta que la ley (el art. 5 del Reglamento de IA prohíbe explotar vulnerabilidades por edad o discapacidad, y el reconocimiento de emociones solo en el trabajo y la educación). En v2, a evaluar, un borrador de resumen en el propio dispositivo junto al registro original.

**Integraciones gratuitas.** CIMA REST sin autenticación (condiciones de redistribución por verificar); `tel:`, SMS y hoja de compartir; guía para Medical ID. Más tarde, HealthKit y Health Connect solo como tendencia. Fuera del v0, por licencias: ARASAAC e iSupport.

**Seguridad y residencia.** Cifrado en reposo y de extremo a extremo; sin analítica ni SDK de terceros; errores sin datos personales (GlitchTip desde v1); servidores en Frankfurt. **El cifrado no saca los datos del RGPD**: el texto cifrado y los metadatos siguen siendo datos personales, el proveedor es encargado y la EIPD se hace igual. La excepción doméstica solo cubre a vuestra familia, y lo confirma un jurista antes de que entre otra.

| Concepto | v0 (vuestra familia) | v1 (5 a 12 familias de una AFA) | v2 (plataforma) |
|---|---|---|---|
| Google Play | 25 USD una vez (unos 23 €) | ya pagado (o cuenta de organización, por verificar) | — |
| Apple | 0 € (sin iOS nativo) | 99 USD/año (unos 90 €) o 0 € con exención de ONG, que es discrecional | igual |
| Backend | 0 € (Supabase Free) | 0 € o Supabase Pro 25 USD/mes | 25 a 50 USD/mes (unos 270 a 550 €/año) |
| Dominio y web | 0 € (GitHub Pages) | 0 a 15 €/año | 12 a 15 €/año |
| CI y compilación iOS | 0 € (GitHub Actions) | 0 € (Codemagic, 500 min/mes en cuentas personales, sin equipos) o un Mac prestado | igual |
| Entidad jurídica | — | 0 € si publica una AFA existente; si se crea una asociación, tasa por verificar y certificado de representante de unos 15 a 20 € | igual |
| Seguro de responsabilidad civil | — | 150 a 400 €/año (estimación sin verificar) | igual |
| Revisión jurídica (EIPD, finalidad) | — | clínica jurídica o CEAFA; coste por determinar | — |
| **Total** | **unos 23 €** (unos 113 € si se quisiera iOS nativo) | unos 150 a 800 €/año (con el seguro estimado) más revisión jurídica por determinar | **unos 280 a 1.060 €/año más tiempo de revisores** (desde unos 430 € si hay que contratar seguro) |

**Lo que NO es gratis:** los 25 USD de Google, y con cuenta personal una prueba cerrada de 12 testers durante 14 días antes de producción; los 99 USD/año de Apple salvo exención; el backend de pago cuando haya varias familias; la entidad jurídica (Apple exige que las apps de salud las publique una organización, guideline 5.1.1(ix), con número D-U-N-S por verificar); la revisión jurídica; y, sobre todo, **el mantenimiento**: el 20 % de las apps del sector nunca se actualiza.

## NACHO · 6. Roadmap

### v0: vuestra familia, semana 0 más 8 semanas

**Nada de esta tabla empieza sin HIPOTENUSA.** La semana 0 la hacéis vosotros sin código; la S1 empieza solo después de oír la palabra.

Tiempo humano estimado, a ajustar en la semana 0: 6 a 10 h/semana del promotor, 1 h/semana por cuidador y unas 4 h en total del médico o farmacéutico.

| Semana | Entrega | Criterio de salida |
|---|---|---|
| S0 | 7 días de notas de voz «lo peor de hoy»; acta en lectura fácil con la persona (incluye cómo quiere ser cuidada); dispositivos reales; hoja de tratamiento; revisor nombrado | Ranking de 3 dolores y acta en la bóveda privada. Si los dolores son otros, se cambian las funciones, no el método |
| S1-S2 | Eventos cifrados, unión por QR, claves por categoría | 3 dispositivos unidos en menos de 2 min; un evento offline llega a los demás en menos de 60 s; el servidor solo ve blobs; restauración simulada con la familia |
| S2-S3 | Medicación como registro | Una doble marca offline muestra el duplicado en ambos móviles; ningún texto ante olvidos; el farmacéutico da por fiel la hoja |
| S3 | Alarmas y panel de salud | 14 días sin perder una alarma en los móviles reales; banner si se revoca el permiso |
| S3-S4 | Diario por excepción | Mediana de 10 s o menos por registro |
| S4 | Relevo y «lo que hemos aprendido con ella» (con preferencias de intimidad) | Lo esencial en menos de 60 s (2 cuidadores cronometrados) |
| S4-S5 | Pizarra, Mi gente, Mi música | Correcta en el cambio de hora; mensaje visible en menos de 2 min; 7 días sin cuelgues; la persona lee el día sin ayuda en 3 observaciones |
| S5-S6 | Parte del día y PWA | Leído al menos 4 días por semana |
| S6 | Informe | Usado en una consulta real; lo que sobra o falta, como ADR |
| S6-S7 | Seguridad y kit; ficha de traspaso (sale de «Esto soy yo»); «Hoy está distinto» | Tarjeta en la cartera, simulacro de 10 min, textos revisados por el médico |
| S7 | Productos en uso y fichas (la del zóster, si cabe) | Cada ficha con linter, revisor, fecha y caducidad |
| S8 | Chequeo del cuidador, exportación, borrado, retro | Reimportación sin pérdidas; servidor sin filas tras borrar; decisiones de la retro en la bóveda |

**Orden de sacrificio** si el tiempo no llega: PWA → Mi música → parte del día → fichas por encima de cuatro → sincronización (pasa a un dispositivo de la casa). **Las alarmas y sus pruebas nunca se recortan.** **Parches:** si en la semana 0 resulta que la persona usa parche de rivastigmina, su registro con «retiré el anterior» entra en el v0 (S2-S3) a costa de Mi música; si no, va a v1.

**Los cinco huecos en el v0**, sin semanas propias: «Mis valores y preferencias» en papel (S0); loseta Deposición (S3-S4) y preferencias de intimidad en el relevo (S4); ficha de traspaso (S6-S7); ficha del zóster (S7, sacrificable). Trabajo y dinero no entra en el v0.

### v1: varias familias (semanas 9 a 40)
- **S9-S12, congelación.** No entra nada nuevo. **Puerta:** 5 de 7 días en la semana 12 sin recordatorio. Si no se cumple, se para.
- **Antes de abrir:** AFA titular, EIPD, dictamen sobre el consentimiento, consulta a la AEMPS, políticas de Play (prueba cerrada de 12 testers durante 14 días si la cuenta es personal) y TestFlight, y panel de co-diseño de 5 a 8 familias.
- **Funciones:** iOS nativo, cuidadora contratada, parches (si no entraron en el v0), temporizador y tarjeta del cuidador, mensajes de voz en la Pizarra (desactivados por defecto), diario ABC, microcontenido tipo START, turnos si se piden, nutrición completa, trámites, unas 20 fichas y los módulos nuevos marcados v1 en la sección 4.
- **Alertas solo de proceso:** toma no registrada, días sin registros, batería baja. Nada sobre sueño, peso o ingesta.
- **Salida:** permanencia acordada con la AFA (propuesta: 60 % de familias en la semana 12); cero alarmas perdidas sin explicar; EIPD aprobada; dos mantenedores con acceso a las cuentas.

### v2: plataforma (desde el mes 10)
Tiendas públicas a nombre de la entidad; `/evidencia` con revisores; vigía de evidencia sin LLM (un script sobre E-utilities, Europe PMC y ClinicalTrials.gov que abre incidencias); protocolos n=1; programa de sueño para el cuidador tipo DREAMS START solo con licencia; nodos por AFA; lenguas cooficiales; guías de decisión de final de vida y directorio de paliativos; modo transición; observaciones sobre el dinero; FHIR; geovalla y sensores solo con las condiciones de la sección 9; **evaluación preregistrada** con universidad o AFA, con la depresión del cuidador como resultado principal medida fuera de la app y con comité de ética. **Salida:** retención a 90 días publicada, menos del 10 % de fichas caducadas, protocolo de evaluación aprobado.

**Medición sin analítica.** v0: contador local «días con algún registro» que la familia enseña en la retro, registro de disparos de alarmas y cronometrajes. v1 y v2: encuesta voluntaria de la AFA a 30, 90 y 180 días, consolas de las tiendas y un botón «la app me falló» sin datos de salud.

## NACHO · 7. Líneas rojas

**Regulatorias (MDR regla 11 y MDCG 2019-11).**
1. No diagnosticar, estadificar ni puntuar: sin MMSE, MoCA, NPI, Zarit, MNA, PAINAD ni FAST, ni versiones simplificadas o derivadas. Un resultado profesional se guarda como texto aportado.
2. No dosificar ni aconsejar ante olvidos.
3. No calcular interacciones por paciente ni disparar avisos por la combinación registrada.
4. Sin alertas clínicas ni semáforos. Solo alertas de proceso hasta la consulta a la AEMPS.
5. No recordar la medicación a la persona.

**De contenido (RD 1907/1996 y tono #coNprueba).**
6. Sin promesas de cura, testimonios, «natural» como argumento, marcas, compra ni insinuar que el médico sobra.
7. Ficha sin revisor, fecha y caducidad no se publica. Fichas iguales para todos.

**De datos.**
8. Sin datos de salud a terceros: ni analítica, ni IA en la nube, ni contenido en el push.
9. Sin GPS propio ni grabación pasiva.
10. La persona es titular: si retira el asentimiento, el registro se pausa.
11. Datos reales nunca en el repositorio.

Cada PR pasa la casilla «¿interpreta, puntúa o decide?». Un linter de lenguaje con excepciones por contexto («tome» en una pauta literal, «natural» en «luz natural») ayuda, pero no sustituye la revisión humana. Si se cruza una línea: función apagada en menos de 72 h, aviso a la familia, ADR y regla nueva en el linter.

**Redacciones de ejemplo.**
- *Aviso general:* «Esta app no es un producto sanitario. No diagnostica, trata, cura ni previene ninguna enfermedad. No sustituye a su médico, a su farmacéutico ni al 112.»
- *Alta de medicamento:* «Copie la pauta tal como figura en la hoja del médico. El pastillero o el sistema de la farmacia siguen siendo la referencia. Ante una duda o un olvido, consulte el prospecto o a su farmacéutico.»
- *Hoy está distinto:* «Contacte hoy con su médico o enfermera. Si está muy dormida, tiene fiebre, le cuesta respirar o se ha caído, llame al 112.» (Igual con uno que con ocho síes. Texto tomado del material; lo firma un médico y se valida con un consultor o la AEMPS antes de usarlo.)
- *Ficha de cobre* y *ficha de huperzina:* el texto literal está en la sección 2.

## NACHO · 8. Por qué esta línea y no otra

### Alternativas rechazadas

| Alternativa | Por qué no |
|---|---|
| React Native, nativo doble o solo PWA | Nativo doble duplica el trabajo; una PWA no tiene alarmas fiables ni almacén cifrado |
| Sin sincronización | Sin ella no se resuelve «¿se la habrá dado ya?» |
| Backend con datos en claro | El proveedor vería datos de salud; con E2E, cambiar de proveedor es migrar una tabla |
| La persona como núcleo | Retención apostada a evidencia D o C; su uso cae con la fase |
| Plataforma de evidencia en el MVP | Fichas, vigía, FHIR y n=1 sin revisores ni entidad |
| Solo seguridad | Lo raro no crea hábito |
| IA en la nube | Art. 9 RGPD, coste y riesgo regulatorio |
| Código cerrado | El sector muere por abandono; abierto, otra AFA puede continuar |
| Varias familias desde el día 1 | Sin permanencia en una casa, escalar repite el abandono |
| Crear una asociación primero | Una AFA existente ya aporta exención, testers y revisores |
| GPS y geovallas | Confianza C, latencia, EIPD, restricciones de Play; no avisa en salidas permitidas |
| Semáforo o escalas validadas | Interpretar y puntuar es la frontera de la regla 11; las escalas tienen titular |

### Veredicto sobre la hipótesis inicial del orquestador

1. **Dos interfaces y semáforo: corregido.** Perfiles de un binario; Pizarra pasiva. **Semáforo rechazado**: lo sustituye un parte escrito por una persona.
2. **Diario como núcleo: corregido.** El núcleo es la coordinación; el diario va por excepción. Datos para investigación: v2, con comité de ética.
3. **Biblioteca viva: corregida.** 8 a 10 fichas en v0, cobre incluido. «Se actualiza sola», rechazado: se propone sola y la publica una persona.
4. **n=1: aplazado a v2**, estandarizado y bloqueado para fármacos y suplementos.
5. **Cuidador como «paciente dos»: aceptado y acotado.** Pregunta 0-10 privada, sin escalas.
6. **Seguridad: aceptada y reforzada**, salvo la ubicación dentro de la app, que se rechaza.
7. **Rutina: corregida.** «Siesta limitada» y agenda de luz son prescriptivas con certeza baja; la agenda sale de las costumbres.
8. **Coste cero y stack: aceptado con correcciones.** La sincronización pasa a núcleo; cifrar no exime del RGPD; coste real de 23 € en v0 a unos 1.060 €/año a escala.
9. **Memoria: aceptada con corrección.** Sin datos reales ni contenido clínico publicado en la bóveda. **Faltaba:** regla de parada, continuidad, la persona como titular, los revisores como cuello de botella y los 5 huecos del arco vital.

### Las 11 contradicciones que encontró el crítico y cómo se resolvieron

| # | Contradicción | Resolución adoptada |
|---|---|---|
| 1 | Etiquetas por sustancia al registrar un fármaco frente a «no cruzar medicación con listas de riesgo» | Sin etiquetas por sustancia al registrar: solo en la ficha general del fármaco, igual para todos, cuando se abre; sin tarjetas ni avisos por la combinación registrada; el duplicado se redacta como integridad del registro («hay dos entradas con el mismo nombre»), no como alerta clínica. Lo demás espera a la consulta a la AEMPS |
| 2 | Geovallas en el núcleo frente a GPS fuera de la v1 | Sin GPS propio en v0 ni v1; ubicación nativa del sistema con acuerdo familiar firmado; geovalla y sensores, a v2 con condiciones |
| 3 | Recordatorios al paciente frente a dobles tomas | Avisos y reintentos solo al cuidador. El crítico admitía que, si el cuidador lo activa, la Pizarra mostrara un estado («ya tomada a las 9:02 por María»), nunca un recordatorio. Este plan va más allá: la Pizarra no contiene medicación en v0 ni v1 (sección 3). Reabrirlo lo decidiríais vosotros |
| 4 | Destacar «lo que funciona» frente a no inferir | Registros y medias en paralelo, sin ordenar ni la palabra «funciona». Las conclusiones las escribe el cuidador |
| 5 | Zarit, PHQ, NPI y PAINAD con puntos de corte | Termómetro propio 0-10 y lista de conductas en palabras de la familia; sin Zarit, NPI ni PAINAD, ni versiones simplificadas (son obras derivadas); del PHQ solo una pregunta de autolesión con ruta fija a 024 y 112, sin total; permisos escritos y validación española antes de v2 |
| 6 | Licencias NC (iSupport, ARASAAC) frente a contenidos CC BY-SA | Matriz de licencias por activo y módulos separados; contenido propio en CC BY-SA; confirmación escrita a la OMS y a ARASAAC |
| 7 | Versiones distintas de la misma fuente (MDCG, Cochrane de música, Rafii 2011) | Registro canónico de evidencia con versión, fecha y verificador; leer el PDF oficial de la MDCG antes de fijar la finalidad |
| 8 | Una letra A para hallazgos negativos, normas y tarifas | Tres ejes (dirección y confianza, que pidió el crítico, más riesgo para esta población); normas como dato normativo; tarifas sin etiqueta |
| 9 | Parches aplazados frente a errores fatales con doble parche | Si la persona usa parche, su registro con «retiré el anterior» entra ya en el v0 (el crítico decía v1; se adelanta porque es el error más grave descrito en la ficha técnica). Si no lo usa, va a v1 |
| 10 | Umbrales del cuidador («avisar si duerme menos de X») frente a «sin avisar de que va peor» | Solo alertas de proceso en v1; fisiológicas aplazadas hasta la consulta regulatoria |
| 11 | Consentimiento explícito frente a un cuidador que registra datos de otra persona | Dictamen jurídico: excepción doméstica, consentimiento de la persona mientras pueda, guarda de hecho o curatela; interés vital solo en la desaparición |

## NACHO · 9. Ideas fuera de la caja

**Retenidas.**
- Pizarra remota: la familia escribe «Hoy viene Marta a las 6» y la tablet responde a la pregunta repetida (D; coste mínimo).
- Ropa de hoy, «dónde buscar primero» y simulacro trimestral (Rowe 2011, C); QR con texto y fondo «Si me encuentras», sin servidor.
- Kit de nevera y panel de avisos con prueba semanal tipo detector de humo.
- «Ahora no» como asentimiento revocable.
- Discrepancias entre informantes visibles (Arons 2013, B; resultado pendiente del texto completo).
- Ficha honesta del zóster, con su C.
- «Mis valores y preferencias» en papel desde la semana 0.

**Aplazadas.**
- Mensajes de voz de familiares: v1, desactivados (certeza muy baja, riesgo de angustia).
- Pregunta biográfica semanal a la familia dispersa: v1 (reminiscencia C).
- Geovalla, sensores tipo Home Assistant y avisos nocturnos: v2, con responsable de respuesta, política de Play verificada y dictamen.
- Desmontabulos offline: pegar una promesa («el EDTA limpia los metales») y ver la ficha: v2.
- Resumen con IA en el dispositivo, FHIR, n=1 y ciencia ciudadana: v2.

**Descartadas.**
- Recordatorios de medicación a la persona: dobles tomas.
- Litio en microdosis como función: confianza D y margen estrecho; solo ficha.
- Guía «Mi agua»: refuerza un relato de confianza D y le da autoridad de «A» a una norma.
- Cifras de supervivencia en el botón de pánico: aterrorizan sin cambiar la acción.
- 4AT adaptado para cuidadores: sin validez y con riesgo de ser cribado.
- Vigía con LLM en la CI: es de pago.

## NACHO · 10. Riesgos

| # | Riesgo | Mitigación |
|---|---|---|
| 1 | Agotamiento del promotor-cuidador | Seis piezas, orden de sacrificio, sprints semanales, congelación S9-S12 |
| 2 | Alarma perdida que causa omisión o doble toma | 14 días en móviles reales, panel de salud, respaldo a T+30, pastillero como referencia; el riesgo residual se dice |
| 3 | Reclasificación regulatoria por presión («¿no puede avisarme si está peor?») | Líneas rojas, linter, revisión de Opus; consulta a la AEMPS |
| 4 | Pérdida de claves y datos | Dos hojas de rescate, exportación mensual, simulacro de restauración, dos administradores |
| 5 | Abandono de la familia o sobreajuste a una casa | Semana 0, registro de 10 s, puerta en la semana 12, panel de co-diseño |
| 6 | Falta de revisores clínicos y jurídicos | Nombrarlos antes de fechar; sin revisor, borrador privado |
| 7 | Base jurídica del consentimiento sin resolver | Dictamen antes de la segunda familia; modo local mientras tanto |
| 8 | Dependencia del plan gratuito y coste real | Buzón intercambiable, modo local completo, 25 a 50 USD/mes asumidos por la entidad |
| 9 | Conflicto familiar (el registro como reproche) | Lenguaje sin culpa, sin rankings, chequeo privado |
| 10 | Fin del proyecto, o una app que abandona a la familia en la fase avanzada o el ingreso | AFA titular, ADR-0004, modo local, exportación, módulos de final de vida y transiciones; fondos públicos y de software libre (por verificar) |

## NACHO · 11. Cómo trabajaremos

**Regla:** Fable piensa y orquesta; cada modelo hace lo que mejor se le da gastando menos tokens; nadie lee lo que no necesita. **Nada de lo que sigue arranca sin HIPOTENUSA**, y cada HIPOTENUSA cubre la tarea descrita justo antes (propuesta, pregunta 9.3).

| Modelo | Hace | No hace |
|---|---|---|
| **Fable** | Especificación de una página por función (objetivo, criterio de salida, archivos, líneas rojas); contratos antes de repartir; orden y recortes; casilla de frontera de cada PR; ADR | Código |
| **Opus** | `safety_core` (eventos, duplicados, recordatorios, cambio de hora, criptografía, recuperación); modelo de amenazas y EIPD; registro de peligros; textos de alerta; fichas de riesgo alto; revisión obligatoria | Código repetitivo |
| **Sonnet** | Pantallas, base de datos, SQL y RLS con tests, CIMA, PDF y QR, tests; borradores de fichas desde los JSON verificados | `safety_core` sin revisión |
| **Haiku** | Cadenas de texto, linter, enlaces caducados, datos sintéticos, commits y changelog, `00-estado.md` y nota de sesión | Medicación, recordatorios, criptografía |

**Doble llave:** Sonnet implementa, Opus revisa y un familiar lo prueba en su móvil real.

**Repo y memoria.**
```
/CLAUDE.md      menos de 150 líneas: HIPOTENUSA, ENOLA, NACHO, coste cero,
                tono #coNprueba, líneas rojas, enrutado, ritual de sesión
/app            Flutter (Apache-2.0): lib/safety_core, lib/core, lib/features/...
/server         migraciones y tests RLS; pocketbase/ (plan C); AGPL-3.0
/evidencia      CC BY-SA 4.0: fichas/*.md con dirección, confianza, riesgo,
                fuentes, revisor, fecha y caducidad; matriz de licencias
/regulatorio    finalidad prevista, líneas rojas, checklist MDCG, EIPD, consentimientos
/tools          linter de lenguaje, validador de fichas, comprobador de enlaces
/.github        CI, plantilla de PR con casillas regulatorias, CODEOWNERS
/docs/vault     bóveda Obsidian de trabajo
```
- **Bóveda** (`docs/vault`): `00-estado.md` (dónde estamos, qué sigue, bloqueos), `01-promotor/` (vuestras decisiones y preguntas abiertas, con fecha), `decisiones/ADR-NNNN.md`, `specs/`, `seguridad/registro-de-peligros.md`, `investigacion/` (los JSON verificados, solo lectura), `sesiones/`, `retro/` y `glosario.md`. El contenido clínico publicado vive en `/evidencia`, nunca en la bóveda.
- **Datos reales fuera del repo.** Nombres, diagnóstico, tratamiento y el acta de la semana 0 van a una bóveda privada fuera del repositorio, protegida con `.gitignore`, un hook de pre-commit y escaneo de secretos. En el repo: «Familia piloto» y «P».
- **ADR** inmutables. Iniciales: 0001 local primero, 0002 buzón E2E, 0003 camino crítico sin servidor, 0004 gobernanza y continuidad (quién firma, cuentas a nombre de la entidad, dos mantenedores, qué pasa si el promotor lo deja o la persona fallece o ingresa).
- **Plugin de memoria opcional:** uno basado en markdown y sin servicios externos, por ejemplo memory-toolkit del directorio de Anthropic (nombre sin verificar: no aparece en el material), a confirmar antes de instalarlo.

**Ritual de sesión.** Al empezar se leen `CLAUDE.md`, `00-estado.md` y la especificación en curso. Al terminar, Haiku actualiza el estado y la nota de sesión, y Fable convierte cada decisión con alternativas en un ADR.

**Commits.** Conventional Commits en castellano con ámbito (`feat(medicacion): estados de toma sin valor por defecto`). Los cambios en `safety_core` o en textos de alerta llevan `Revisado-por:`.

**Retirar funciones que nadie usa (propuesta).** Si una función no la usa nadie de la casa durante 4 semanas seguidas, según el contador local que se enseña en la retro, pasa a «candidata a retirar». Decidís vosotros en la retro y queda un ADR. Quedan exentas las de seguridad («Se ha perdido», «Esto soy yo», alarmas, kit), que son raras por naturaleza.

## NACHO · 12. Lo que queda por verificar antes de construir

| Qué falta | Responsable propuesto | Cuándo |
|---|---|---|
| Texto oficial de la MDCG 2019-11 rev.1 (nadie pudo leerlo: 403) | Fable, con descarga manual del promotor | Antes de cerrar la finalidad (S0) |
| Jurista para la EIPD, la finalidad y la base del consentimiento | Promotor busca clínica jurídica o CEAFA; Opus prepara el borrador | Antes de la segunda familia |
| Consulta de cualificación a la AEMPS («Hoy está distinto», duplicado, alertas de proceso) | Entidad titular, con borrador de Opus | Antes de abrir a otras familias |
| Condiciones de uso de CIMA para redistribuir un índice | Sonnet lee; promotor escribe a la AEMPS si hace falta | S2 |
| Licencias: iSupport y ARASAAC (NC), IDDSI (SA sin modificaciones), DREAMS START | Haiku monta la matriz; promotor pide confirmación escrita | Antes de v1 |
| Políticas vigentes de Play (salud, cuenta de organización) y TestFlight; D-U-N-S | Sonnet | S0 y antes de v1 |
| Cita de Rafii 2011 (huperzina) | Sonnet verifica; Opus firma la ficha | S7 |
| Texto completo de Arons 2013 (sesgo del informante, citado de memoria) | Sonnet | Antes del informe (S6) |
| Licencia y versión española validada del FAM-CAM, base de «Hoy está distinto» | Sonnet; promotor escribe al titular si hace falta | Antes de S6 |
| Financiación de lecanemab y donanemab en BIFIMED (hoy solo consta en prensa) | Sonnet | Antes de publicar su ficha |
| Permisos de Zarit, NPI y PAINAD, y su validación española | Promotor escribe a los titulares | Antes de v2 |
| Entidad titular (AFA existente), seguro y cuentas | Promotor | Durante v0 |

## NACHO · 13. Las preguntas

La lista completa (84 preguntas tras fusionar las del crítico y las de los cinco huecos, con por qué importa y qué haremos por defecto si no hay respuesta, y con 15 bloqueantes recalculadas) está en **PREGUNTAS.md**. Aquí van las 12 bloqueantes originales y las 12 que añadió el crítico.

### Las 12 bloqueantes, tal cual

1. ¿Qué medicamentos toma hoy la persona (aunque sea de memoria), cuántas tomas hay al día y cuáles son a demanda? En concreto: ¿hay alguno para la memoria (donepezilo, rivastigmina, galantamina, memantina), para dormir, para la conducta, anticoagulantes, parches? ¿Ha oído hablar la familia de lecanemab o donanemab?
2. ¿Quién gestiona hoy la medicación (la propia persona, un cuidador principal, varios, una cuidadora contratada, la farmacia con SPD)? ¿Usáis pastillero semanal o diario, cómo lo preparáis, y cuántas veces os habéis equivocado o dudado de si ya se tomó?
3. ¿Cómo son los turnos y los relevos? Contadnos un día típico: quién se levanta, quién da la medicación, quién hace las noches y qué pasa en el cambio de turno (qué se cuenta y cómo).
4. Por escrito, ¿para qué sirve la app? ¿Aceptáis que solo anote, recuerde, informe y os diga 'consultad al médico', sin avisar de que 'algo va peor', sin sugerir dosis y sin puntuar tests, aunque a veces os parezca poco?
5. ¿Dónde os sentís cómodos con que vivan los datos: solo en el móvil de la cuidadora principal, en un móvil de cada familiar sincronizados, o en un servidor? Si es servidor, ¿aceptáis uno en la UE y que, a coste cero, a veces se pause o haya que pasar a pago cuando crezca?
6. ¿Cuánto dinero puede salir de vuestro bolsillo, y cuándo? ¿Aceptáis pagar 25 USD de Google una vez y 99 USD al año de Apple si no hay exención? ¿Y si la app crece, un tope de 25 a 50 USD al mes lo podéis sostener, o alguna entidad lo cubriría? Y, ¿tenéis un coste cero absoluto como condición, aunque haya menos funciones o menos fiabilidad?
7. ¿Empezamos solo con vuestra familia o abierta a otras familias desde el primer día? ¿Cuántas familias imagináis usando la app al cabo de un año y de tres?
8. Si pudierais arreglar una sola cosa de la vida diaria con el Alzheimer antes de dentro de dos meses, ¿cuál sería (dobles tomas, las noches, la agitación de la tarde, que se pierda, que coma poco, que los hermanos no se coordinen, que el cuidador principal se hunda)? Y en 8 semanas, al abrir la app, ¿qué tendría que poder hacer para pensar 'esto ya nos sirve', y qué os daría igual que faltara?
9. ¿Quién debería ver qué? Pensad en nombres reales: hijos que viven lejos, hermanos que no se hablan, nietos, vecinos, el médico, la farmacia, la trabajadora social. ¿Cuántas personas apuntarán datos de la misma persona, y a quién no queréis dar acceso a ciertos datos (economía, medicación, notas de ánimo, notas del cuidador)? ¿Cómo se retira el permiso a alguien si hace falta?
10. ¿Qué quiere y qué puede decidir ahora la propia persona sobre sus datos (ubicación, fotos, quién ve su información médica)? ¿Sabe de su diagnóstico y ha dicho algo sobre cómo quiere ser cuidada? ¿Quién decide hoy por ella si no puede (poder preventivo, curatela, guardador de hecho, voluntades anticipadas), y quién es hoy su persona de apoyo?
11. Cuando varios cuidadores apuntan datos, ¿preferís que se sincronicen al instante entre todos (hace falta un servidor) o basta con que cada uno apunte en su móvil y se junten una vez al día o por exportación? ¿Necesitáis avisos remotos en el momento (por ejemplo, 'la medicación de las 9 no está confirmada')?
12. ¿Qué móvil o tablet usa hoy cada persona que va a usar la app (la persona con Alzheimer y cada cuidador)? Decidme marca, modelo y versión del sistema (Ajustes > Acerca del teléfono; una foto de esa pantalla por dispositivo nos vale). ¿Cómo van de vista y oído (gafas, audífonos), y qué destreza digital tiene cada uno (edad, si usa WhatsApp sola, si tiene datos o solo wifi)?

### Las 12 que añadió el crítico (resumidas)

13. Si entra en residencia, centro de día u hospital este año, ¿la app debe seguir sirviendo allí o se queda en casa?
14. ¿Queréis que acompañe la fase final y el duelo? ¿Ha expresado ella deseos sobre el final de su vida?
15. ¿Hay incontinencia o rechazo al aseo? ¿Quién hace la higiene íntima y cómo lo vive? ¿Recibís absorbentes públicos?
16. ¿Tiene puestas las vacunas de gripe, neumococo, COVID-19 y zóster? ¿Y el cuidador principal?
17. ¿El cuidador principal trabaja? ¿Ha pedido reducción, adaptación o excedencia, o ha dejado el empleo?
18. ¿Quién gestiona las cuentas y el patrimonio? ¿Hay poderes notariales? ¿Ha habido estafas o presiones?
19. ¿A qué edad empezaron los síntomas y hay antecedentes? Si es de inicio precoz, ¿preocupa el consejo genético?
20. ¿Vivís en zona rural? ¿A qué distancia está el centro de salud? ¿Cómo lleváis el calor y quién vigila que beba?
21. Si cuida la pareja, ¿hay cambios en la intimidad o desinhibición sobre los que querríais orientación privada?
22. ¿Qué entidad firmará como responsable, con seguro y D-U-N-S? ¿Aceptáis consultar a la AEMPS antes de abrir?
23. ¿Aceptáis una v1 con un tope de unas 20 fichas revisadas, en lugar de una biblioteca completa?
24. ¿Qué criterio usaremos para retirar una función que nadie usa a los tres meses, y quién lo decide?

## NACHO · 14. Anexos

### A) Recursos gratuitos clave

| Nombre | Qué aporta | Coste | URL |
|---|---|---|---|
| CIMA (AEMPS), API REST | Medicamentos autorizados, fichas técnicas y prospectos | Gratis, sin autenticación | https://cima.aemps.es/cima/resources/docs/CIMA_REST_API.pdf |
| #coNprueba, informes RedETS | Evaluaciones oficiales en castellano de acupuntura, tai chi, aromaterapia y otras | Gratis | https://www.conprueba.es/index.php/informes |
| Revisión de 35 apps (JMIR Aging 2024) | 11 indicadores de calidad como lista de control editorial | Acceso libre | https://pmc.ncbi.nlm.nih.gov/articles/PMC11617330/ |
| iSupport (OMS) | Programa para cuidadores en español; licencia NC | Gratis | https://www.who.int/publications/i/item/9789241515863 |
| Línea 024 | Atención a la conducta suicida 24 h, también para familiares | Gratis | https://www.sanidad.gob.es/linea024/home.htm |
| Ley 8/2021 (BOE) | Medidas de apoyo a la capacidad jurídica | Gratis | https://www.boe.es/buscar/act.php?id=BOE-A-2021-9233 |
| Guía AEPD de riesgo y EIPD | Cómo hacer la evaluación de impacto | Gratis | https://www.aepd.es/guias/gestion-riesgo-y-evaluacion-impacto-en-tratamientos-datos-personales.pdf |
| Registro Nacional de Instrucciones Previas | Normativa y enlaces a registros autonómicos | Gratis | https://www.sanidad.gob.es/areas/profesionesSanitarias/rnip/home.htm |
| Calendario de vacunación 2026 (Ministerio) | Zóster, gripe, neumococo y COVID-19 en mayores | Gratis | https://www.sanidad.gob.es/areas/promocionPrevencion/vacunaciones/calendario/docs/CalendarioVacunacion_Todalavida.pdf |
| RD 90/2026 (BOE) | Absorbentes en la prestación farmacéutica | Gratis | https://www.boe.es/eli/es/rd/2026/02/11/90/con |
| flutter_local_notifications | Notificaciones locales; límite de 64 en iOS | Gratis | https://pub.dev/packages/flutter_local_notifications |
| Política de Play sobre alarmas exactas | Quién puede usar `USE_EXACT_ALARM` | Gratis | https://support.google.com/googleplay/android-developer/answer/13161072?hl=en |
| Exención de cuota de Apple | Requisitos para ONG | Gratis | https://developer.apple.com/support/membership-fee-waiver/ |
| ClinicalTrials.gov Data API v2 y E-utilities | Vigía de evidencia sin LLM | Gratis | https://clinicaltrials.gov/data-api/api |

### B) Glosario breve

- **ADR:** registro de una decisión de arquitectura, con alternativas y consecuencias.
- **AFA:** asociación de familiares de personas con Alzheimer.
- **CIMA:** base oficial de medicamentos de la AEMPS.
- **E2E:** cifrado de extremo a extremo; el servidor no puede leer los datos.
- **EIPD:** evaluación de impacto en protección de datos.
- **IACE:** inhibidores de la acetilcolinesterasa (donepezilo, rivastigmina, galantamina).
- **MDR y regla 11:** reglamento europeo de productos sanitarios; la regla 11 fija la clase del software que ya es producto sanitario, por ejemplo el que informa decisiones diagnósticas o terapéuticas.
- **MDCG 2019-11:** guía europea para saber si un software es producto sanitario.
- **PWA:** web que se instala como app.
- **RLS:** seguridad por filas en la base de datos.
- **SPD:** sistema personalizado de dosificación de la farmacia.

### C) Archivos producidos en esta sesión

| Archivo | Qué contiene |
|---|---|
| `verified/*.json` (18) | Las 13 dimensiones y los 5 huecos tras la revisión escéptica: resumen, hallazgos con nivel y fuentes, funciones candidatas, preguntas, recursos y notas de verificación |
| `digest.md` y `digest_short.md` | Todo lo verificado en un solo texto, y su versión corta con resúmenes, funciones y recursos |
| `design/approach-*.json` (4) | Los cuatro enfoques independientes |
| `design/judge-1.json` y `judge-2.json` | Las evaluaciones de los dos jueces |
| `design/synthesis.md` | El diseño final, columna vertebral de este plan |
| `critic.json` | Contradicciones, afirmaciones flojas, supuestos de riesgo, huecos y preguntas que faltaban |
| `questions/*.json` y `questions/final.md` | Las preguntas por lente y las 70 consolidadas de la primera ronda |
| `REVISION-PLAN.md` | Las 39 correcciones del revisor final, lo que sigue sin verificar y 6 dudas para vosotros |
| `PLAN.pre-revision.md` | El plan antes de la revisión, por si queréis comparar |
| `PLAN.md` | Este documento |
| `PREGUNTAS.md` | La lista completa de preguntas para el promotor |
| `INVESTIGACION.md` | La investigación completa en un documento legible |
