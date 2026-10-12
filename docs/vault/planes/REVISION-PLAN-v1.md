# NACHO · Revisión escéptica de PLAN.md

12/10/2026 · Revisor final. Copia previa intacta en `PLAN.pre-revision.md`. Se corrigió fondo, no estilo. Nada se ha programado ni se ha tocado el repositorio: sigue haciendo falta HIPOTENUSA.

## NACHO · 1. Correcciones hechas

### Fidelidad a la evidencia (contrastado con digest.md y verified/*.json)

| # | Dónde | Qué decía → qué dice | Por qué |
|---|---|---|---|
| 1 | §2 tabla, alimentación; §4 Nutrición | MIND «B» → **No ayuda · A** | verified/nutricion y natural_holistico: A (NEJM 2023) |
| 2 | §2 tabla; §4 Nutrición | ESPEN «(D)» → guía B según el verificador; recomendaciones de buena práctica = consenso (D) | El verificador da B a la guía; el crítico pide no subir a A el consenso |
| 3 | §2 ficha del cobre | Kessler 2008 «Confianza C» → **B** (un solo ensayo pequeño, no descarta efectos modestos) | verified/cobre_metales: B |
| 4 | §2 tabla, cuidador; §4 Cuidador | Depresión del cuidador «C» → **B** (meta-revisión de calidad baja) | verified/cuidador_familia: B (Cheng y Zhang 2020) |
| 5 | §2 tabla, cuidador | «un tercio… por agotamiento» → conductas abusivas significativas asociadas a ansiedad y depresión del cuidador (Cooper 2009, C) | La fuente asocia, no atribuye causa |
| 6 | §2 tabla, fase avanzada; §4 | Planificación anticipada «B» → **C** | El verificador la bajó de B a C (gap-final_de_vida) |
| 7 | §2 tabla, natural | «Reminiscencia (C)» → B en residencias (Cochrane 2018), poca o ninguna en domicilio; con tablet, C | verified/natural_holistico B; ux_paciente C para la digital |
| 8 | §2 tabla, medicina china | «setas: D» → melena de león C (un ensayo, n=30); resto sin verificar, D | natural_holistico C, mtc_oriental D |
| 9 | §2 tabla, sueño | Se mantiene «actividad y cuidador, C» (Cochrane 2023, certeza baja) y se añade McCurry 2011, B | Ambos en sueno_circadiano |
| 10 | §2 tabla, medicación | Se añaden IACE (B), lecanemab (IPT-445, A; sin homocigosis APOE e4) y financiación en SNS solo en prensa (D) | verified/medicacion |
| 11 | §2 tabla, incontinencia | arándano en institucionalizados No ayuda · A; D-manosa MERIT 2024, B | gap-incontinencia |
| 12 | §2 tabla, vacunas | Crítica 2026 concretada (Brain Behav Immun, efectos >100 %, sin descenso poblacional); ensayos de Dinamarca y Finlandia, fechas estimadas | gap-vacunas |
| 13 | §2 tabla, trabajo | Ley 4/2026 «en vigor el 23/10/2026» | Hoy (12/10/2026) aún no está en vigor |
| 14 | §2 tabla, seguridad | Niveles añadidos: Safe Return C, delirium superpuesto B | seguridad_delirium |
| 15 | §2 tabla, natural | CST «B» explicado: Cochrane 2023 con certeza moderada | El verificador puso A a la revisión; con tres ejes la confianza es la certeza (moderada = B) |
| 16 | §2 ficha de huperzina | Quitado «No consta como medicamento autorizado en España» → «se vende como suplemento, sin control de dosis ni de pureza» | Lo primero no está en el material; lo segundo sí (mtc_oriental) |
| 17 | §2 nota de producto en uso | Quitado «lo recomendó la vecina» | Evitar un testimonio, aunque sea de ejemplo |
| 18 | §4 Diario; §9 | Arons 2013 B + «resultado citado de memoria, pendiente del texto completo» | datos_investigacion: solo se verificó el DOI |
| 19 | §4 Medicación | «Avisar al cuidador evita dobles tomas (D)» → «un recordatorio a la persona puede provocar dobles tomas (D, consenso de diseño)»; «errores fatales» → errores de dosificación, algunos fatales, por no retirar el parche (ficha de Exelon) | Formulación fiel a ux_paciente y medicacion |
| 20 | §5 IA | «detección de emociones (art. 5 del Reglamento de IA)» → decisión propia, más estricta que la ley; el art. 5 prohíbe explotar vulnerabilidades y el reconocimiento de emociones solo en trabajo y educación | legal_etica: la cita atribuía al art. 5 más de lo que dice |
| 21 | §1; glosario | «Así queda fuera de la regla 11» → en principio no sería producto sanitario y la regla 11 (que solo clasifica lo que ya lo es) no se aplicaría; la MDCG cita «un módulo de medicación» como posible producto sanitario | legal_etica y medicacion |
| 22 | §7 «Hoy está distinto» | Marcado como texto del material, a firmar por un médico y validar con consultor o AEMPS | Es la función con más riesgo de reclasificar (crítico) |

### Coherencia interna

| # | Dónde | Corrección | Por qué |
|---|---|---|---|
| 23 | §1, §5 tabla, §8 veredicto 8 | Coste a escala «330 a 1.200 €/año» → **unos 280 a 1.060 €/año** (desde 430 € si hay que contratar seguro); v1 «variable» → unos 150 a 800 €/año más revisión jurídica; v0 con Apple «114 €» → 113 € | La cifra de la síntesis no salía de su propia tabla: v2 = backend 270-550 + Apple 0-90 + dominio 12-15 + seguro 0-400 |
| 24 | §5 y §6 v1 | Añadida la prueba cerrada de Play (12 testers, 14 días, cuenta personal); Codemagic «cuentas personales, sin equipos» | tecnologia_stack; afecta a la v1 con la AFA |
| 25 | §4, §6, §8 n.º 9 | Parches: **v0 si la persona los usa** (se sabe en S0), si no v1, en las tres secciones | Antes: v1 en el mapa, «propongo v0» en el roadmap |
| 26 | §2, §4, §5, §8 n.º 1 | Sin etiquetas por sustancia al registrar; duplicado y doble toma redactados como integridad del registro («constan dos registros… comprobad el pastillero»), sin «antes de dar otra» | Resolución 1 del crítico aplicada en todo el plan |
| 27 | §8 n.º 3 | La Pizarra no muestra medicación en v0 ni v1, coherente con §3; la opción del crítico (estado «ya tomada») queda como decisión vuestra | Había contradicción entre §3 y la tabla de contradicciones |
| 28 | §4, §8 n.º 5, §7.1 | Sin Zarit, NPI, PAINAD ni versiones simplificadas o derivadas; lista de conductas en palabras de la familia; del PHQ solo la pregunta de autolesión, sin total | Resolución 5 del crítico, ahora explícita |
| 29 | §8 n.º 8; §0 | Tres ejes = los dos del crítico más el riesgo; se declara como única excepción a «manda el crítico» | Antes no se explicaba el choque |
| 30 | §8 n.º 2 | «Sin GPS propio en v0 ni v1», acuerdo familiar firmado | Antes solo decía v1 |
| 31 | §4, §6 | «lo que funciona con ella» → «lo que hemos aprendido con ella» (texto libre de la familia) | La resolución 4 prohíbe la palabra «funciona» |
| 32 | §4 Fase avanzada | «recordatorio de revisar la medicación cuando cambian los objetivos» → pregunta fija para la consulta, igual para todos | Rozaba «proponer retiradas», que es su propia línea roja |
| 33 | §4 Incontinencia y Vacunas | Avisos para ofrecer el baño y recordatorios de vacunas van al Círculo, nunca a la persona | Coherencia con «sin recordatorios a la persona» |
| 34 | §6 v0 | Ficha de traspaso añadida a S6-S7, ficha del zóster a S7 y párrafo «Los cinco huecos en el v0» | El mapa los ponía en v0 y el roadmap no los tenía |
| 35 | §6 v1 y v2 | v1: tarjeta del cuidador, voz en la Pizarra, microcontenido START, turnos, nutrición completa. v2: directorio de paliativos, observaciones sobre el dinero, FHIR, programa de sueño con licencia, geovalla con condiciones | Funciones del mapa que faltaban en el roadmap |
| 36 | §2 tabla, cinco huecos | Cada fila de hueco lleva ahora **Línea roja** explícita; Transiciones no tenía ninguna | Punto 4 del encargo |
| 37 | Cabecera, §1, §6, §11 | HIPOTENUSA repetida: nada se programa ni se crea el repo sin ella; la semana 0 no la necesita | Punto 5 del encargo |
| 38 | §0 | «pregunta 9.3» → «pregunta 9.3 de PREGUNTAS.md» | En §13 la numeración es otra |
| 39 | §12 | Nuevas filas: Arons 2013, licencia y versión española del FAM-CAM, financiación de lecanemab en BIFIMED | Pendientes que no estaban listados |

**Comprobado y correcto (sin cambios), entre otros:** 43 % de 35 apps y 20 % sin actualizar; YoTeCuido 2020; antipsicóticos OR ~1,5 (A); brexpiprazol sin indicación en la UE; RxNav discontinuado; sueño alterado hasta el 40 %; DREAMS START n=377 (B); melatonina C; luz D; 20,7 % ayurvédicos (JAMA 2008); deferiprona y neutropenia 7,5 %; EFSA 5 y 25 mg/día; RD 3/2023 2,0 mg/L; ginkgo A; música −0,23 (B); DAPA n=494; Care Ecosystem n=780; CASCADE 54,8 %; micción incitada B; bacteriuria B; zóster A, demencia C; VALAD B; calendario 2026; art. 34.8 con 15 días y presunción; abuso financiero 28,3 % (C); delirium 10,5 % frente a 18,4 % (B); mínima sujeción B; Supabase y pausa; 64 notificaciones en iOS; USE_EXACT_ALARM; las 12 bloqueantes coinciden literalmente con final.md; las 14 URL de los anexos están en el material; título y todas las `##` empiezan por «NACHO · ».

## NACHO · 2. Lo que queda marcado «sin verificar»

- Rafii 2011 (huperzina): «cita a verificar» (verificada en medicacion, no en mtc_oriental).
- Arons 2013: resultado citado de memoria.
- memory-toolkit como plugin de memoria: el nombre no aparece en el material.
- Financiación de lecanemab y donanemab en el SNS: solo prensa (D).
- Seguro de responsabilidad civil (150 a 400 €/año), tasa de la asociación, cuenta de organización de Play, D-U-N-S y fondos de NLnet o NGI: estimaciones o por verificar.
- Texto oficial de la MDCG 2019-11 rev.1: nadie lo leyó (403).
- Setas distintas de la melena de león, homeopatía, reiki, Bredesen y CBD: sin investigar.
- Licencias de FAM-CAM y DREAMS START, y condiciones de redistribución de CIMA.

Nota: el plan pasa de 9.947 a unas 11.000 palabras por las correcciones.

## NACHO · 3. Dudas que solo puede resolver el promotor

1. **Pizarra y medicación.** El plan deja la Pizarra sin ningún dato de medicación. El crítico permitía un estado («ya tomada a las 9:02 por María», nunca un recordatorio). ¿Lo queréis cerrado del todo o abierto como opción en v1?
2. **Parche en el v0.** Si la persona usa parche de rivastigmina, su registro entra en el v0 y sale Mi música. ¿Aceptáis ese cambio?
3. **Dinero a escala.** La tabla suma de unos 280 a 1.060 €/año y depende sobre todo del seguro y del backend. ¿Hay una AFA que ya tenga seguro de responsabilidad civil y lo cubra, o hay que presupuestarlo?
4. **Cifras de referencia en la ficha del cobre.** La ficha muestra los límites de EFSA y del agua (5 mg/día y 2,0 mg/L) como referencias, no como pautas. ¿Las queréis, o preferís quitarlas para no alimentar el relato del cobre del grifo, que el material califica de D?
5. **Memoria.** ¿Basta con una bóveda Obsidian en `docs/vault`, o queréis además un plugin de memoria (hoy sin verificar)?
6. **Extensión.** ¿Os vale un plan de unas 11.000 palabras, o preferís un resumen de 2 páginas encima y el resto como anexo?
