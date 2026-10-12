# NACHO · Plan v2: app de investigación y cuidado en Alzheimer, sobre la base del promotor

12/10/2026 · Estado: propuesta para elegir. Nada construido. Nada se programa sin HIPOTENUSA.

## NACHO · 0. En qué se basa este plan

### 0.1 La base del promotor, resumida

- Una app móvil para iOS y Android. Para personas con Alzheimer, quienes las cuidan y sus familias. Pensada desde el principio para muchas personas, no para una casa.
- El promotor investiga y saca sus propias conclusiones. No se fía del consenso médico ni de la industria farmacéutica: todos tienen conflictos de interés. Nadie de la industria médica o farmacéutica hace de juez. Ningún agente tiene ese papel.
- No se descarta nada por pequeño, antiguo, animal, heterodoxo o anecdótico.
- Si un estudio reporta una mejora, del 5 % o de lo que sea, va a una tabla y se suma a todo lo que hace cosas positivas.
- La app ayuda a las familias a cuatro cosas: conocer las opciones, probarlas con seguridad, medir qué le hace bien a su persona y sumar lo de muchas familias para descubrir qué ayuda de verdad.
- Postura de investigación: contraria al consenso. Seguir el dinero. Buscar donde el consenso no mira. Rescatar lo enterrado: ensayos sin resultados, tratamientos abandonados por baratos o no patentables. Ideas fuera de la caja: cobre llevado en el cuerpo, psilocibina, nicotina y todo lo que haya.
- Coste cero o casi cero. Recursos gratuitos. Fable piensa y orquesta; Opus, Sonnet y Haiku hacen cada uno lo que mejor se les da, gastando menos. Memoria en Obsidian. HIPOTENUSA autoriza código. ENOLA detiene y pide explicación. NACHO abre cada respuesta.
- Única regla propia del equipo: no inventar. Lo que no existe no aparece. Cada afirmación lleva enlace. La app no promete curas: presenta lo que reporta cada fuente y deja probar y medir.

### 0.2 Qué se hizo

- 15 temas investigados con postura contraria al consenso. Lista y archivos en el anexo 13.3.
- Un dosier por tema: tesis, defensores, mecanismos, consenso y quién lo paga, lo enterrado, protocolos reportados, riesgos que reconocen los propios defensores, fuentes heterodoxas e ideas para la app.
- 644 filas, una por estudio o fuente. Cada fila lleva la cifra tal cual, la dirección que da la fuente, quién lo pagó y el enlace. Ninguna fila sin enlace. 607 enlaces distintos.
- Comprobación documental de citas, sin juicio. En la versión verificada del catálogo (647 filas), 617 tienen "cita encontrada": en 419 la cifra coincide con el texto leído y en 193 la cita existe pero la cifra no se pudo comprobar en lo leído. 24 tienen "página existe". Verificar solo significa que la cita existe y la cifra aparece. No es una nota de calidad.
- Tres líneas de producto, escritas por separado: `plan2/linea-observatorio.json`, `plan2/linea-laboratorio.json` y `plan2/linea-red.json`.
- Recuentos de este documento: `python3 -I plan2/v2work/conteo_v2.py <raíz>`, sobre `catalogo/research/*.json`. Salida en `plan2/v2work/conteo_v2.json`.

### 0.3 Qué NO se hace esta vez

- La ciencia ortodoxa no hace de juez. La dirección de cada fila es la que da la fuente.
- No se elige la línea por el promotor. Las tres van lado a lado. La recomendación va aparte, en la sección 11, marcada como recomendación.
- No hay preguntas sobre su familiar. Solo decisiones de producto.
- Las pruebas en casa no se aplazan. Están en el MVP de las tres líneas, también para hierbas y suplementos.
- Ninguna idea fuera de la caja se descarta (sección 7).
- La regulación no organiza el plan. Tiene una sección breve y práctica (sección 6).

## NACHO · 1. Lo que el catálogo ya tiene

Totales sobre las 644 filas de `catalogo/research/*.json`: 322 "mejora", 120 "mixto", 61 "sin cambio", 38 "empeora" y 103 "no aplica", siempre según la fuente. Por tipo: 241 ensayos aleatorizados, 83 registros de ensayo, 79 observacionales, 68 en animales, 56 revisiones, 34 ensayos no aleatorizados, 32 series de casos, 20 foros o testimonios, 11 casos, 7 libros o webs, 6 en células, 6 otros y 1 patente. Lo enterrado: 127 entradas con 116 NCT distintos. Protocolos reportados: 125. Ideas para la app: 89. 344 filas mencionan "no consta" en el campo de financiación.

Formato de cada tema: filas · mejora · mixto · sin cambio · empeora · no aplica. Las cifras de los ejemplos van tal cual las transcribió la fuente.

### 1.1 Ambiente y tóxicos (`ambiente_toxicos`): 44 · 13 · 10 · 3 · 15 · 3
Tesis: el Alzheimer es la suma de agresiones ambientales (moho, metales, pesticidas, aire, apnea, fármacos) que se pueden retirar.
- Bredesen 2016, caso 1: "C4a de 22.799 a 2.750 ng/ml". [enlace](https://pmc.ncbi.nlm.nih.gov/articles/PMC4789584/)
- Rea 2018, n=100: "Aproximadamente 85% se 'aclararon' por completo; 14% mejoria parcial". [enlace](https://pubmed.ncbi.nlm.nih.gov/29861191/)
- Kaufmann 2026, apnea: "sin tratar 69% mas rapido" el declive frente a CPAP. [enlace](https://pubmed.ncbi.nlm.nih.gov/42445979/)
- Lo enterrado: NCT00477828, CPAP en Alzheimer (UCSD), completado en 2006, sin resultados. No se halló ningún ensayo registrado sobre moho y Alzheimer.

### 1.2 Cobre, zinc y metales (`cobre_metales`): 44 · 15 · 11 · 6 · 8 · 4
Tesis: el desequilibrio de metales impulsa el Alzheimer; Brewer culpa al cobre inorgánico ingerido; Yankner sitúa el déficit de litio como evento temprano.
- Desferrioxamina, McLachlan 1991, n=48: "la tasa de declive sin tratar fue el doble". [enlace](https://europepmc.org/article/MED/1674295)
- Litio, Forlenza 2011, n=45: "Descenso significativo de fosfo-tau en LCR (P=0.03)". [enlace](https://europepmc.org/article/MED/21525519)
- Agua rica en silicio, Davenward 2013: la cognición mejoró "en al menos 3 de 15 pacientes". [enlace](https://europepmc.org/article/MED/22976072)
- Lo enterrado: NCT05423522 (NanoLithium de Medesis), completado en 2024, sin resultados. Hueco: ningún ensayo humano de cobre en cama, ropa o pulsera en Alzheimer; la única pulsera es en artritis (Richmond 2013, n=70, NIHR). [enlace](https://europepmc.org/article/MED/24066023)

### 1.3 Cuerpo y mente (`cuerpo_mente`): 45 · 22 · 13 · 3 · 0 · 7
Tesis: meditación corta, yoga, tai chi, música, tacto, aromas y ejercicio como terapia barata.
- Kirtan Kriya en cuidadores, Lavretsky 2013: "65.2% del grupo KK con mejora del 50% en Hamilton vs 31.2%". [enlace](https://pubmed.ncbi.nlm.nih.gov/22407663/)
- Kirtan Kriya, Innes 2017, n=60: "a 6 meses las ganancias se mantuvieron o mejoraron (p<=0.006)". [enlace](https://pubmed.ncbi.nlm.nih.gov/28106552/)
- Yoga kundalini, Ibrahim 2022: hipocampo derecho "P=0.034". [enlace](https://pubmed.ncbi.nlm.nih.gov/36329774/)
- Lo enterrado: NCT05178992, robots asistentes (Vanderbilt, n=142), completado, sin resultados.

### 1.4 Fármacos baratos reposicionados (`farmacos_reposicionados`): 44 · 21 · 9 · 3 · 1 · 10
Tesis: genéricos como litio, metformina o sildenafilo tienen señales que no se financian por no ser patentables.
- Sildenafilo, Fang 2021: "Riesgo de Alzheimer -69% (HR 0,31...)". [enlace](https://pubmed.ncbi.nlm.nih.gov/35572351/)
- Masitinib, Dubois 2023: "ADAS-cog -1,46 vs +0,69; diferencia -2,15". [enlace](https://pubmed.ncbi.nlm.nih.gov/36849969/)
- Metformina, Yu 2026: "OR 0,79 (CrI 0,77-0,81)" frente a placebo. [enlace](https://europepmc.org/article/MED/42064764)
- Lo enterrado: NCT00231946 ALADDIN, leuprolida en fase III, 555 pacientes, sin resultados.

### 1.5 Hormonas, péptidos y longevidad (`hormonas_peptidos`): 45 · 22 · 9 · 10 · 1 · 3
Tesis: corregir a la vez déficits hormonales, NAD+, mitocondria y senescencia; péptidos rusos como cerebrolisina y semax.
- Melatonina 3 mg, Asayama 2003: ADAS-cog "placebo 0,3±3,7; melatonina -4,3±3,6 (p=0,017)". [enlace](https://doi.org/10.1272/jnms.70.334)
- Cerebrolisina, Gauthier 2015: cambio global a 4 semanas "OR 3,32". [enlace](https://doi.org/10.1159/000377672)
- Activadores metabólicos, Yulug 2023: "29% de mejora en el grupo CMA". [enlace](https://doi.org/10.1186/s40035-023-00336-2)
- Lo enterrado: NCT04430517 (NR, McLean, n=21), completado, sin resultados. NCT00743743 (resveratrol), retirado porque "PI has left institution".

### 1.6 Teoría infecciosa (`infecciones`): 42 · 19 · 8 · 3 · 4 · 8
Tesis: el Alzheimer es en parte respuesta a infecciones crónicas; el amiloide sería un péptido de defensa.
- Antiherpéticos, Tzeng 2018: "con antiherpéticos HR 0,092". [enlace](https://pubmed.ncbi.nlm.nih.gov/29488144/)
- Vacuna del zóster, Eyting 2025: "20,0% relativo". [enlace](https://pubmed.ncbi.nlm.nih.gov/40175543/)
- Doxiciclina más rifampicina, Loeb 2004, n=101: "-2,75 puntos ... P=.034" a 6 meses. [enlace](https://pubmed.ncbi.nlm.nih.gov/14962152/)
- Lo enterrado: piloto de Helsinki 2013, 30 seropositivos para HSV, 12 semanas, sin resultados publicados según AlzForum; NCT02997982 (VALZ-Pilot), sin resultados.

### 1.7 Luz, sonido, campos y oxígeno (`luz_energia`): 45 · 28 · 7 · 2 · 1 · 7
Tesis: problema de energía y oxígeno cerebral corregible sin fármacos; menos investigado por menos patentable.
- tACS gamma en casa, Cantoni 2025, n=50: "CDR-SB 0,35 (IC95% 0,10-0,61; P = ,007)". [enlace](https://pubmed.ncbi.nlm.nih.gov/41359335/)
- 40 Hz, extensión de 2 años, Chan 2025: "pTau217 bajó 47% y 19%" en 2 participantes. [enlace](https://pubmed.ncbi.nlm.nih.gov/41137616/)
- 40 Hz binaural, Fanid 2026: memoria de trabajo "p = 0,001, d = 1,42". [enlace](https://pubmed.ncbi.nlm.nih.gov/42222549/)
- Lo enterrado: NCT05637801 HOPE de Spectris, 673 participantes, completado el 17-08-2026, sin resultados publicados.

### 1.8 Metabólico: cetonas, ayuno, insulina (`metabolico_cetonas`): 45 · 28 · 8 · 4 · 0 · 5
Tesis: hipometabolismo de glucosa ("diabetes tipo 3"); las cetonas alimentan a las neuronas.
- AC-1202, Henderson 2009: en APOE4 negativos "4,77 puntos día 45 (p=0,0005)". [enlace](https://pubmed.ncbi.nlm.nih.gov/19664276/)
- Dieta cetogénica con MCT, Taylor 2018: "ADAS-Cog mejoró 4,1 puntos ... (P=0,02) y volvió a la línea base tras el lavado". [enlace](https://pubmed.ncbi.nlm.nih.gov/29955649/)
- kMCT, Fortier 2019: "Metabolismo cerebral de cetonas +230%". [enlace](https://pubmed.ncbi.nlm.nih.gov/31027873/)
- Lo enterrado: NCT01702480, MCT en polvo de GSK, 116 participantes, completado en 2015, sin publicación localizada.

### 1.9 Nicotina, cafeína y colinérgicos (`nicotina_colinergicos`): 45 · 24 · 8 · 3 · 3 · 7
Tesis: el sistema colinérgico cae pronto; sustancias baratas actúan sobre él y no se ensayan por no ser patentables.
- Huperzina A, Zhang 2002, n=202: mejora ≥4 puntos ADAS-Cog "56,1% vs 12,5%". [enlace](https://pubmed.ncbi.nlm.nih.gov/12181083/)
- Alfa-GPC 600 mg, Jeon 2024: "ADAS-cog descendió 2,34 puntos". [enlace](https://pubmed.ncbi.nlm.nih.gov/39300341/)
- Sigue el dinero, Cataldo 2010: separa los estudios por afiliación a la industria tabacalera. Caso-control con afiliación: "OR 0,86 (0,75-0,98)". Cohortes sin afiliación: "RR 1,45 (1,16-1,80)". [enlace](https://pubmed.ncbi.nlm.nih.gov/20110594/)
- Lo enterrado: NCT00091468, nicotina en MCI del NIA, estado UNKNOWN, sin resultados.

### 1.10 Alimentos, dietas y ayunos (`nutricion_alimentos`): 44 · 29 · 6 · 2 · 1 · 6
Tesis: dieta, polifenoles, probióticos y estilo de vida intensivo modifican el componente metabólico.
- Dieta MIND, Morris 2015, n=923: "3er tercil HR 0.47". [enlace](https://pubmed.ncbi.nlm.nih.gov/25681666/)
- Cetogénica vegetal con ayuno, Tağraf 2026: "MMSE +0.9 en intervención y -1.5 en control". [enlace](https://pubmed.ncbi.nlm.nih.gov/42497811/)
- Vajilla roja, Dunne 2004: "+25% de comida y +84% de líquido; 8 de 9 aumentaron". [enlace](https://pubmed.ncbi.nlm.nih.gov/15297089/)
- Lo enterrado: NCT03998423, trasplante fecal oral (Wisconsin), terminado con 5 inscritos, sin resultados.

### 1.11 Plantas, setas y fórmulas tradicionales (`plantas_tradiciones`): 45 · 28 · 4 · 8 · 0 · 5
Tesis: actúan sobre varias dianas a la vez; baratas y no patentables, reciben poca inversión.
- Melisa tópica, Ballard 2002: reducción del 30% del CMAI en "60% (21/35) con melisa vs 14% (5/36)". [enlace](https://pubmed.ncbi.nlm.nih.gov/12143909/)
- Azafrán, Akhondzadeh 2010: "ADAS-cog F=4,12, gl=1, P=0,04". [enlace](https://pubmed.ncbi.nlm.nih.gov/20831681/)
- Yokukansan, Mizukami 2009, n=106: NPI "p=0,040". [enlace](https://pubmed.ncbi.nlm.nih.gov/19079814/)
- Lo enterrado: NCT04492241, ginkgo más Armillariella (Beijing Tiantan, 800 personas), estado desconocido, sin resultados.

### 1.12 Protocolos integrales heterodoxos (`protocolos_heterodoxos`): 35 · 19 · 4 · 2 · 2 · 8
Tesis: el Alzheimer es un desequilibrio de red; se miden decenas de marcadores y se trata todo a la vez.
- MEND, Bredesen 2014: "9 de 10 mostraron mejora subjetiva u objetiva". [enlace](https://europepmc.org/article/MED/25324467)
- Estilo de vida intensivo, Ornish 2024, n=51: "CGIC p=0,001". [enlace](https://europepmc.org/article/MED/38849944)
- ReCODE y PHQ-9, Rao 2025, n=170: "mejora media de 3,96 puntos". [enlace](https://europepmc.org/article/MED/41594723)
- Lo enterrado: NCT05894954 EVANTHEA, aleatorizado de medicina de precisión, n=73, completado el 09-02-2026, sin resultados en el registro.

### 1.13 Psicodélicos, cannabinoides y nootrópicos (`psicodelicos`): 40 · 14 · 8 · 5 · 0 · 13
Tesis: neuroplasticidad y capacidad funcional residual que puede volver a ser accesible.
- Psilocibina, caso Lago 2026: "continencia urinaria restablecida (llevaba 5 años sin ella)". [enlace](https://pubmed.ncbi.nlm.nih.gov/42292331/)
- Aceite de cannabis, Shelef 2016: "NPI 44,4 a 12,8 (p<0,01)". [enlace](https://pubmed.ncbi.nlm.nih.gov/26757043/)
- Cannabinoides en agitación, metaanálisis da Silva 2026: "NPI total SMD -0,31". [enlace](https://pubmed.ncbi.nlm.nih.gov/42315374/)
- Lo enterrado: NCT00567060, piracetam de UCB, 676 personas, completado en 2004, sin resultados; Cochrane señala ensayos no liberados por la empresa.

### 1.14 Relatos de familias y foros (`relatos_familias`): 39 · 20 · 9 · 4 · 1 · 5
Tesis: las familias descubren antes que la medicina qué ayuda; los testimonios con detalle merecen ensayo propio.
- Newport 2024, 288 informes de cuidadores: "Mejora en 89,2%; 7,3% sin mejora". [enlace](https://esmed.org/MRA/index.php/mra/article/view/5316)
- MCT, Juby 2022, n=20: "80% estable o mejor". [enlace](https://pubmed.ncbi.nlm.nih.gov/35310527/)
- Insulina intranasal, Craft 2012, n=104: "20 UI mejoró memoria diferida (P<.05)". [enlace](https://pubmed.ncbi.nlm.nih.gov/21911655/)
- Lo enterrado: NCT01883648, aceite de coco de USF, terminado por "Funding limitations and enrollment was too low", sin resultados.

### 1.15 Sangre, plasma y quelación (`sangre_plasma_quelacion`): 42 · 20 · 6 · 3 · 1 · 12
Tesis: diluir factores de la sangre envejecida con recambio plasmático; quelación, ozono y vías intravenosas.
- AMBAR, Boada 2020, n=347: "ADCS-ADL P=0,03 (52% menos deterioro)". Lo paga Grifols, que vende albúmina. [enlace](https://europepmc.org/article/MED/32715623)
- Recambio en Argentina, Taragano 2025: "Declive del MMSE 45% menor que controles". [enlace](https://europepmc.org/article/MED/40928812)
- Piloto AMBAR, Boada 2017: "Aβ1-42 en LCR: +75,3 vs -45,5 pg/mL". [enlace](https://europepmc.org/article/MED/27911295)
- Lo enterrado: desferrioxamina (Crapper McLachlan 1991, 48 pacientes, [enlace](https://europepmc.org/article/MED/1674295)) sin ensayos posteriores hallados; NCT02054208 (NEUROSTEM), completado en 2019, sin resultados.

### 1.16 Las 25 intervenciones con más resultados reportados como mejora

Método: grupos por expresión regular sobre el campo `intervencion`; dentro de cada grupo se cuenta una vez cada enlace. Los grupos se solapan (una fila de "cetogénica con MCT" cuenta en dos). "Mejora" incluye animales y células; "en personas" los excluye. Script: `plan2/v2work/conteo_v2.py`.

|#|Intervención|Filas|Mejora|Mejora en personas|Mixto|Sin cambio|Empeora|No aplica|Aleatorizados|Ejemplo|
|---|---|---|---|---|---|---|---|---|---|---|
|1|Dieta cetogénica, cetosis y cetonas exógenas|27|20|18|2|1|0|4|12|[Taylor 2018](https://pubmed.ncbi.nlm.nih.gov/29955649/)|
|2|Aceite de coco, MCT y AC-1202|27|14|14|9|1|0|3|8|[Henderson 2009](https://pubmed.ncbi.nlm.nih.gov/19664276/)|
|3|Protocolos multifactoriales (MEND/ReCODE)|19|14|14|0|1|1|3|1|[Bredesen 2014](https://pubmed.ncbi.nlm.nih.gov/25324467/)|
|4|Litio en dosis baja o microdosis|25|12|6|7|3|1|2|6|[Forlenza 2011](https://europepmc.org/article/MED/21525519)|
|5|Estimulación 40 Hz (luz, sonido, tACS)|16|11|10|3|0|0|2|6|[Cantoni 2025](https://pubmed.ncbi.nlm.nih.gov/41359335/)|
|6|Recambio de plasma y plasma joven|22|10|9|2|2|0|8|11|[AMBAR 2020](https://europepmc.org/article/MED/32715623)|
|7|Colina, citicolina, alfa-GPC, fosfatidilserina|14|10|10|2|0|0|2|5|[Jeon 2024](https://pubmed.ncbi.nlm.nih.gov/39300341/)|
|8|Cannabinoides (THC, CBD, nabilona, dronabinol)|20|9|9|1|3|0|7|9|[Pessoa 2026](https://pubmed.ncbi.nlm.nih.gov/41277041/)|
|9|Antiherpéticos y vacuna del zóster|12|8|7|2|1|1|0|2|[Eyting 2025](https://pubmed.ncbi.nlm.nih.gov/40175543/)|
|10|Dieta MIND, mediterránea y aceite de oliva|12|8|8|0|2|0|2|7|[Morris 2015](https://pubmed.ncbi.nlm.nih.gov/25681666/)|
|11|Cafeína y café|9|7|5|1|0|0|1|0|[Cao 2012](https://pubmed.ncbi.nlm.nih.gov/22430531/)|
|12|Aromaterapia, melisa y masaje|9|7|7|0|0|0|2|6|[Ballard 2002](https://pubmed.ncbi.nlm.nih.gov/12143909/)|
|13|Ayuno y ventana de comida|8|7|5|1|0|0|0|3|[Tağraf 2026](https://pubmed.ncbi.nlm.nih.gov/42497811/)|
|14|Nicotina, tabaco y agonistas nicotínicos|17|6|6|4|3|3|1|5|[Newhouse 2012](https://pubmed.ncbi.nlm.nih.gov/22232050/)|
|15|Cerebrolisina y neuropéptidos|9|6|3|1|0|1|1|2|[Gauthier 2015](https://doi.org/10.1159/000377672)|
|16|Kirtan Kriya, yoga y meditación|7|6|6|0|0|0|1|7|[Lavretsky 2013](https://pubmed.ncbi.nlm.nih.gov/22407663/)|
|17|NAD+: nicotinamida y NR|13|5|5|3|2|1|2|9|[Yulug 2023](https://doi.org/10.1186/s40035-023-00336-2)|
|18|Ejercicio, tai chi, qigong, baile|10|5|4|4|1|0|0|5|[Huang 2025](https://pubmed.ncbi.nlm.nih.gov/41567790/)|
|19|Fotobiomodulación (luz roja e infrarroja)|9|5|5|3|0|0|1|4|[Chun 2026](https://pubmed.ncbi.nlm.nih.gov/42024020/)|
|20|Yokukansan y fórmulas Kampo o chinas|9|5|4|1|1|0|2|4|[Mizukami 2009](https://pubmed.ncbi.nlm.nih.gov/19079814/)|
|21|Melena de león (Hericium erinaceus)|8|5|4|0|0|0|3|3|[Mori 2009](https://pubmed.ncbi.nlm.nih.gov/18844328/)|
|22|Psilocibina, LSD, DMT|13|4|2|3|2|0|4|2|[Lago 2026](https://pubmed.ncbi.nlm.nih.gov/42292331/)|
|23|Oxígeno hiperbárico|7|4|2|0|0|1|2|2|[Hadanny 2020](https://pubmed.ncbi.nlm.nih.gov/32589613/)|
|24|Probióticos, kéfir y microbiota|7|4|3|2|0|0|1|2|[Akbari 2016](https://pubmed.ncbi.nlm.nih.gov/27891089/)|
|25|Azafrán|5|4|3|0|1|0|0|4|[Akhondzadeh 2010](https://pubmed.ncbi.nlm.nih.gov/20831681/)|

Empata en el puesto 25 "Arándano y uva" (5 filas, 4 mejora). Siguen ginkgo, insulina intranasal, huperzina, antibióticos, agua rica en silicio y sauna, con 3 cada uno. Cobre suma 9 filas y 1 mejora; la pulsera, 1 fila "sin cambio" y fuera de Alzheimer.

## NACHO · 2. Las tres líneas, lado a lado

Las tres cumplen la base del promotor. Las tres tienen catálogo sin juez, pruebas en casa en el MVP, suma anónima y coste casi cero. Cambia qué es el producto principal.

||A · Observatorio|B · Laboratorio en casa|C · Red de familias|
|---|---|---|---|
|Producto principal|Catálogo público y abierto de estudios; la app es la puerta para probar y aportar|La app: cada familia prueba, mide y suma|La comunidad: familias y practicantes que prueban protocolos juntos|
|A quién sirve primero|Familias que ya investigan por su cuenta; curadores voluntarios|Cuidador hispanohablante, fase leve o moderada, que ya prueba algo o quiere probar|Cuidadora que ya prueba y lo cuenta en grupos de WhatsApp, Facebook o foros|
|MVP (8-12 semanas)|Bóveda y web Quartz con 644 filas, vigías semanales, rastreador de enterrados, app con catálogo sin conexión, motor de pruebas y aporte anónimo|App sin cuenta, diario de un toque, línea base, motor de pruebas, minipruebas, cuaderno, módulos de cuidado, envío anónimo y tablero público|Bot de Telegram, app local, catálogo, motor de pruebas ABA, grupos de prueba, perfil de transparencia, reputación por datos, votación, moderación con registro público|
|Cómo vive el catálogo|Bóveda Obsidian en GitHub, web Quartz, edición por pull request o formulario, historial público|Bóveda en git, SQLite de solo lectura dentro de la app y web estática|Bóveda en git y Quartz; cualquier cuenta propone correcciones desde la app|
|Cómo se prueba en casa|"Probar esto" desde la ficha: AB por defecto, ABA, ABAB, ventana corta, ciclos, ciego casero|"Probar en casa": A-B-A' con retirada opcional, lote y etiqueta, minipruebas y muestra de voz|"Probar": ABA por defecto, ABAB, ventana de horas, observador ciego; o unirse a un grupo con fecha común|
|Cómo se suma|Columna "familias que lo probaron" en cada ficha; publica con 5 o más familias, una vez al mes|Tablero "Lo que reportan las familias", regenerado cada noche; celdas con menos de 5 como "<5"|Tablero por intervención y versión de protocolo; resúmenes semanales de cada grupo|
|Coste año 1|22-115 €|23-115 €|21-115 € (WhatsApp, si se elige, aparte)|
|Riesgo principal|Wiki que depende de voluntarios; poca ayuda diaria a la familia|Carga de registro para el cuidador; abandono|Arranque en frío, captura por vendedores y moderación sin fin|

Las cifras de coste son la suma de Google Play (25 USD, pago único) y Apple (99 USD al año, o 0 € con exención). Ver sección 5.

### 2.1 Línea A · El Observatorio

Qué es. Un catálogo público sin guardianes, como web gratuita en semanas. La app es la puerta para probar, medir y aportar.

MVP (14 entregas). Bóveda generada desde los JSON (644 notas, idempotente). Web Quartz en español e inglés (Lighthouse móvil 90 o más). Ficha con marcador por dirección, tipo de fuente y financiación. Columna de quién paga con filtro "ocultar lo que paga quien vende". Rastreador de enterrados en ClinicalTrials.gov v2 cruzado con Europe PMC. Vigía semanal de literatura que abre pull requests. Curación abierta: la integración continua rechaza filas sin enlace o sin cifra literal. App con catálogo sin conexión, "Probar esto" (5 cuidadores crean una prueba en menos de 3 minutos), registro de un toque y voz (menos de 30 s), 6 módulos de cuidado, antes y después sin veredicto, aporte anónimo. Android en prueba cerrada, TestFlight y PWA.

Fases. 2: pruebas colectivas prerregistradas en OSF, ciego casero, analíticas, wearables, grafo del dinero, enlaces a AlzForum, Examine y GreenMedInfo, sincronización familiar cifrada, cartas a promotores de ensayos enterrados. 3: volcados con DOI en Zenodo, API estática, federación por fork, otras demencias, protocolos compuestos.

Arquitectura. Monorepo público. Bóveda, scripts Python y Quartz; `catalogo.json` firmado. App Flutter sin conexión. Supabase Free en Frankfurt con aportes de solo inserción; un job publica `familias/*.json` con k≥5.

Por qué sí. El activo ya existe y se vuelve valor público sin esperar a las tiendas. Pone en el centro la cifra tal cual, quién paga y lo enterrado. Abierto y con historial, es difícil de cerrar.

Por qué no. Menos ayuda inmediata a una familia en crisis. Depende de voluntarios. La columna de familias es lo más lento. El riesgo de tienda se concentra en el contenido. Son dos productos.

### 2.2 Línea B · El Laboratorio en casa

Qué es. Cada familia es un laboratorio. Elige una intervención, la prueba con el protocolo de las fuentes y ve qué cambia en su persona. El cuidado diario alimenta la prueba. Con consentimiento, el resumen se suma de forma anónima.

MVP (14 entregas). Instalación sin cuenta (perfil en menos de 3 minutos, en modo avión). Catálogo de 644 filas en la app y la web, con humanos y animales por separado. Diario de un toque (menos de 30 s, botones de 48 dp o más, contraste WCAG AA). Línea base de 14 días. Motor de pruebas con lote y foto de etiqueta (A-B-A sintética de 60 días sin errores). Minipruebas propias y abiertas con 4 formas paralelas. Muestra de voz semanal solo en el dispositivo. Antes y después neutro, con un test que veta "funciona", "eficaz" o "cura". Cuaderno con PDF, CSV y JSON. Módulos de cuidado con CIMA. Adversos de las fuentes precargados y botón de pausa. Envío anónimo a Frankfurt. Tablero público nocturno con "<5".

Fases. 2: ABAB aleatorio y evaluador ciego, ventana corta, sincronización cifrada, Health Connect y HealthKit, analíticas, modo persona, edición comunitaria del catálogo, protocolos en paquete, inglés y portugués. 3: ensayos coordinados de familias con comité independiente, datos con DOI, subgrupos declarados (APOE4, fase, edad), lista de "dónde mirar", API y FHIR, federación.

Arquitectura. Flutter para iOS, Android y PWA. Módulos core, catalog, trial_engine (Dart puro con tests), measures, care, export y consent. Supabase opcional detrás de una capa de repositorio. Catálogo y tablero estáticos.

Por qué sí. Hace los cuatro verbos del promotor dentro de la app. Lo piden los dosieres: los 15 proponen un diario, 9 piden línea base o un cambio cada vez y 13 piden exportar para el médico (recuento de la línea B). La revisión de 35 apps no halló ninguna que combine registro personal de intervenciones, evidencia etiquetada y coordinación entre cuidadores en español, gratis y abierta ([enlace](https://pmc.ncbi.nlm.nih.gov/articles/PMC11617330/)). Todo vive en el teléfono.

Por qué no. Pide mucho al cuidador, y el abandono es el fallo principal del sector ([revisión 2026](https://pmc.ncbi.nlm.nih.gov/articles/PMC13052052/)). Una prueba n-de-1 no separa bien la intervención de la progresión, la expectativa o el azar. La suma pública tarda meses. Plasma, oxígeno hiperbárico o cerebrolisina intravenosa solo se registran. Es la línea con más ingeniería.

### 2.3 Línea C · La Red de familias

Qué es. El producto es la red de familias, cuidadores y practicantes que prueban, miden y comparten. La reputación se gana con transparencia y datos, nunca con títulos ni "me gusta". La red vota qué investigar y abre grupos donde decenas de familias corren el mismo protocolo a la vez.

MVP (13 entregas). Bot de Telegram con /hoy, voz y foto (50 familias piloto, 14 días, sin pérdidas). App local sin cuenta. Catálogo con los 127 enterrados. Motor N-de-1 ABA con 20 o más plantillas. Grupos de prueba con resumen semanal seudónimo. Perfil de transparencia obligatorio para publicar o votar. Reputación solo por pruebas completadas (también las que acaban en "peor"), filas verificadas y correcciones. Votación de 10 votos al mes; las 3 propuestas más votadas generan un dosier en 3 semanas. Tablero con "<5". Moderación con 5 reglas, ninguna sobre si algo funciona, registro público y jurado de 3. Módulos de cuidado. Consentimiento por niveles. Rastreador semanal de enterrados.

Fases. 2: WhatsApp si el coste cabe, foro propio, cruzado ciego con cápsulas, páginas de practicante con todos sus casos, rescate de enterrados, mapa del agua, analíticas por foto, sprints con literatura rusa, china y persa. 3: federación de nodos, ensayos de la red prerregistrados, comité de ética aliado, API, nodos en asociaciones, legado de datos.

Arquitectura. Flutter y bot de Telegram (webhook en una Edge Function). Supabase en Frankfurt guarda comunidad, resúmenes y bloques cifrados. Supergrupo de Telegram con un tema por intervención.

Por qué sí. Es la que hace literalmente "sumar lo de muchas familias". Va donde ya están: foros como el de Richard ([enlace](https://www.alzheimersblog.org/2012/02/05/coconut-oil-treat-alzheimers/comment-page-2/)) o el diario de 110 días de Margaret938 ([enlace](https://forum.alzheimers.org.uk/goto/post?id=764868)). Lleva "seguir el dinero" a las personas. Federable y abierta.

Por qué no. El primer día, una familia sola recibe poco. Necesita masa crítica y animación diaria. La moderación no se acaba: laxa, la capturan vendedores; estricta, se vuelve censura. Depende de Telegram y de las tiendas. Concentra el riesgo legal en la asociación titular.

## NACHO · 3. El núcleo común

Esto se construye igual elija la línea que elija. Es la mitad del trabajo y no depende de la decisión.

- Catálogo vivo. Fuente de verdad: una bóveda Obsidian en un repositorio público (una nota por estudio, intervención, protocolo, financiador, ensayo enterrado, tema y hueco). Web con Quartz en GitHub Pages. La misma compilación genera `catalogo.json` para la app. Cada fila: cifra literal, dirección según la fuente, tipo de fuente, n, dosis, quién paga (literal y categoría), verificación documental, enlace y quién la añadió. Cada ficha abre con su marcador: filas por dirección, por tipo de fuente y por financiación. Sin pesos ni niveles de evidencia. Los filtros los pone el lector. Admisión mecánica: enlace que responde, cifra literal presente, campos completos, no duplicado. Nada se rechaza por su dirección.
- Vigías gratuitos. GitHub Actions semanal: Europe PMC (resumen, `grantsList`, afiliaciones), PubMed E-utilities, ClinicalTrials.gov v2 (estado, `hasResults`, fechas, promotor). Haiku propone filas; un script comprueba que la cifra aparece literal en el texto fuente; una persona fusiona.
- Motor de pruebas en casa. Sección 4.
- Suma anónima. Ficha de resultado sin texto libre, nombres, fechas exactas, fotos ni audio. Consentimiento aparte y revocable. Publicación solo con 5 o más familias por celda y como mucho 2 variables cruzadas. Rótulo junto a cada agregado: "datos aportados por familias, sin grupo de control".
- Módulos de cuidado. Medicación como registro (CIMA de la AEMPS), sueño, comida, conducta, seguridad y cuidador. Todos escriben en el mismo registro de eventos que lee la prueba. Un cambio de medicación aparece solo como "cambio simultáneo" en la gráfica. Modo persona de una pantalla: día y parte del día en letras grandes, "Mi gente" con fotos, botón de llamar.
- Stack gratuito. Flutter (iOS, Android, PWA), Drift con SQLCipher, flutter_local_notifications, Vosk sin conexión, GitHub (Pages, Actions, Issue Forms), Supabase Free en Frankfurt detrás de una capa abstracta, Codemagic para iOS, pictogramas ARASAAC.
- Cifrado y datos en la UE. SQLCipher en el móvil, TLS en el envío, servidor en Frankfurt con contrato de encargado, EIPD antes de abrir al público. Ningún dato de familias pasa por una IA en la nube.
- Licencia abierta. App Apache-2.0, servidor AGPL-3.0, contenidos CC BY-SA 4.0. Si se cierra una vía, cualquiera puede volver a publicarlo.

## NACHO · 4. Motor de pruebas en casa

Principio: la familia decide. La app copia lo que reporta cada fuente, ayuda a medir y muestra los datos tal cual. No bloquea ninguna intervención: hierbas, suplementos, dispositivos, dieta, fármacos reposicionados con receta, psicodélicos o cannabinoides. No calcula dosis. No dice si algo funciona.

### 4.1 Protocolo desde las fuentes
En cada ficha, "Probar en casa" lista los protocolos reportados, cada uno con su enlace. Ejemplos del catálogo: MCT hasta 42 g/día ([Juby 2022](https://pubmed.ncbi.nlm.nih.gov/35310527/)); melena de león 3 g/día 16 semanas ([Mori 2009](https://pubmed.ncbi.nlm.nih.gov/18844328/)); azafrán 30 mg/día en dos tomas ([Akhondzadeh 2010](https://pubmed.ncbi.nlm.nih.gov/20831681/)); Kirtan Kriya 12 min/día 8-12 semanas ([Innes 2017](https://pubmed.ncbi.nlm.nih.gov/28106552/)); parche de nicotina 15 mg/día 6 meses ([Newhouse 2012](https://pubmed.ncbi.nlm.nih.gov/22232050/)); 40 Hz 1 h diaria ([Chan 2022](https://pubmed.ncbi.nlm.nih.gov/36454969/)). La familia elige uno, lo ajusta o escribe uno propio, que queda marcado "propio". Registra producto, marca, lote, precio y foto de la etiqueta.

### 4.2 Antes de empezar (informa, no bloquea)
Pantalla "Lo que reportan las fuentes": dosis y duración de cada estudio, efectos adversos reportados, riesgos que reconocen los propios defensores y la monitorización que usaba el estudio. Ejemplos: litio, creatinina, diarrea y temblor en LATTICE ([enlace](https://pubmed.ncbi.nlm.nih.gov/41770546/)); cannabinoides, somnolencia "RR 2,25 (IC95 1,43-3,54)" ([da Silva 2026](https://pubmed.ncbi.nlm.nih.gov/42315374/)); acúfenos con 40 Hz, "RD = 0,16" ([Ang 2025](https://pubmed.ncbi.nlm.nih.gov/41381439/)); valaciclovir, creatinina elevada en VALAD ([enlace](https://pubmed.ncbi.nlm.nih.gov/41405855/)); psilocibina, sudoración y sospecha de hipertermia en el caso Lago ([enlace](https://pubmed.ncbi.nlm.nih.gov/42292331/)). Al lado: medicación actual y aviso "dos cambios a la vez no se podrán separar". PDF opcional de una página para el médico o el farmacéutico. La familia fija sus propias señales de parada ("diarrea 3 días", "una caída"); la app se las recuerda cuando registra algo que coincide. El umbral lo pone la persona, nunca la app.

### 4.3 Línea base
14 días por defecto (de 7 a 28), mismas medidas, misma hora. Lo que ya se tomaba queda como "fondo". Si faltan más del 30 % de los días, la gráfica lo indica. Si la familia ya usa los módulos de cuidado, la base ya existe.

### 4.4 Diseños
- AB por defecto; duración, la de la fuente, u 8 semanas si no consta.
- ABA con retirada (2 semanas o la que cite la fuente; Mori 2009 reporta descenso 4 semanas después de parar).
- ABAB para efectos rápidos (música, 40 Hz, MCT).
- Ventana corta: miniprueba antes de la toma y a 1, 2 y 4 h, como describe Richard con MCT y coco ([relato](https://www.alzheimersblog.org/2012/02/05/coconut-oil-treat-alzheimers/comment-page-2/)).
- Ciclos para pautas intermitentes (D+Q 2 días cada 15; LSD cada 4 días).
- Ciego casero opcional: otro familiar prepara tomas iguales y la app sella la asignación hasta el final. Observador ciego: un familiar puntúa sin saber la fase.

### 4.5 Medidas
- Diarias, un toque cada una (0-10 o caras): sueño (horas y despertares), ánimo, agitación, apatía o iniciativa, lenguaje, orientación, reconoce a las personas, apetito, energía, digestivo, momentos buenos, carga del cuidador. Más adherencia (sí, no, parcial y dosis real), efectos adversos de una lista cerrada y conteos (caídas, salidas, alucinaciones).
- Semanales, unos 4-5 minutos guiados: fluidez verbal en 1 minuto (animales), recuerdo de 5 palabras inmediato y diferido, 5 preguntas de orientación, reloj dibujado (foto), tiempo de reacción con 10 toques, nombrar 5 fotos de "Mi gente", muestra de voz de 1 minuto sobre una lámina abierta. Formas paralelas para no repetir.
- Mensuales: 10 actividades de la vida diaria (sola, con ayuda, no), peso, tensión, coste en euros y minutos al día del protocolo.
- Opcionales: sueño y pasos del reloj, cetonas y glucosa, analíticas, y MMSE, MoCA o NPI tecleados como número si los pasa un profesional (tienen licencia; la app no los reproduce).
Ninguna puntuación se convierte en diagnóstico, estadio ni alerta clínica.

### 4.6 Captura
Aviso diario a la hora elegida. Una pantalla con botones grandes y "igual que ayer". Voz: "durmió mal, se levantó tres veces, comió poco" se transcribe sin conexión con Vosk; unas reglas locales proponen los valores y el cuidador confirma. Fotos del reloj, el plato y la etiqueta. Registro tardío permitido y marcado. Deshacer. Nada sale del móvil.

### 4.7 Antes y después
Por medida: gráfica con fases sombreadas, media y mediana por fase, días con dato, adherencia y diferencia tal cual. Marcas de cambios simultáneos (fármaco nuevo, infección, ingreso, otra prueba). Texto neutro: "Agitación: media 4,2 en la base y 3,1 en la prueba; 12 y 41 días con dato". Al cerrar, la familia escribe su conclusión por medida: mejor, igual, peor o no sé.

### 4.8 Secuencias
Cola de pruebas. "Un cambio cada vez" por defecto (lo proponen los dosieres de plantas, relatos y protocolos). Lavado configurable. La retirada de una prueba sirve de base de la siguiente. Si la familia solapa pruebas, se permite y queda rotulado. Los protocolos combinados (KetoFLEX 12/3, Ornish) van como paquete con sus componentes trazados.

### 4.9 Exportación
PDF de 1-2 páginas para el médico, CSV y JSON completos con esquema publicado, y la ficha de resultado anónima si la familia quiere aportarla.

## NACHO · 5. Arquitectura, modelo de datos y coste

### 5.1 Arquitectura (común; cada línea añade su pieza)
1. Catálogo estático: `boveda/` en Markdown y YAML, `scripts/` en Python (importar, vigías, verificar, construir, agregar), Quartz en GitHub Pages. No hay servidor para leer el catálogo.
2. Automatización: GitHub Actions (cron semanal, integración continua en cada pull request, compilación Android y web) y Codemagic para iOS.
3. App Flutter sin conexión: Drift con SQLCipher; registro de eventos de solo inserción (id, autor, hora, tipo, valor); caché del catálogo; notificaciones locales con ventana deslizante (iOS conserva 64 programadas, [fuente](https://pub.dev/packages/flutter_local_notifications)) y `SCHEDULE_EXACT_ALARM` pedido al usuario en Android ([fuente](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms)); Vosk para voz; PDF, CSV y JSON; capa de repositorio abstracta. La misma base compila como PWA.
4. Agregación mínima: Supabase Free en Frankfurt (eu-central-1), tabla de aportes de solo inserción detrás de una Edge Function que descarta IP y cabeceras. Un job publica agregados como JSON estático.
5. Pieza propia de cada línea: A, curación abierta y rastreador de enterrados; B, minipruebas, voz y cuaderno; C, bot de Telegram, grupos, reputación, votación y moderación.

### 5.2 Modelo de datos (entidades)
- Catálogo: Estudio (fila), Intervención (con marcador calculado), Protocolo (texto literal y origen: estudio, defensor, foro o propio), Financiador (tipo y si vende el producto), EnsayoRegistrado (NCT, estado, `hasResults`, días sin resultados), Tema (dosier), Hueco (qué se buscó y no se encontró), Medida.
- Solo en el móvil: Persona (alias, tramo de edad, fase declarada, apoyos según la Ley 8/2021), Miembro y rol, Prueba (diseño, fases, medidas, señales de parada), Evento (solo inserción), Pauta y toma, EventoAdverso, CambioSimultáneo, Consentimiento.
- En el servidor de la UE: FichaResultado (identificador aleatorio, intervención, banda de dosis, semanas por fase, por medida media base, media prueba y días, conclusión de la familia, adversos, tramo de edad, país, mes).
- Público: AgregadoPúblico (familias que empezaron, terminaron y aportaron; mejor, igual, peor, no sé; mediana; adversos; celdas suprimidas).
- Solo línea C: Cuenta con declaración de intereses, Reputación, Grupo, Propuesta, Voto, Publicación, AcciónModeración.

### 5.3 Coste

|Concepto|Coste|Cuándo|Fuente|
|---|---|---|---|
|Google Play|25 USD, pago único (unos 23 €)|Inevitable|[Google](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)|
|Apple Developer|99 USD/año (unos 85-92 €) o 0 € con exención para entidades sin ánimo de lucro|Inevitable salvo exención|[Apple](https://developer.apple.com/support/membership-fee-waiver/)|
|GitHub (repositorio público, Pages, Actions)|0 €|Siempre|[GitHub Actions](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions)|
|Supabase Free (500 MB, 50.000 MAU, pausa tras 1 semana sin actividad)|0 €|Piloto y MVP|[Supabase](https://supabase.com/pricing)|
|Supabase Pro|25 USD/mes|Solo si se crece|[Supabase](https://supabase.com/pricing)|
|Codemagic (500 min/mes en macOS)|0 €|Compilar iOS|[Codemagic](https://docs.codemagic.io/billing/pricing/)|
|Europe PMC, PubMed, ClinicalTrials.gov, CIMA|0 €|Siempre|Anexo 13.1|
|Vosk, Flutter, Drift, SQLCipher, Quartz|0 € (código abierto)|Siempre|Anexo 13.1|
|GlitchTip autoalojado|0 €|Siempre|[GlitchTip](https://glitchtip.com/)|
|Dominio propio|Opcional; precio no verificado en el material|Nunca necesario|—|
|Constituir la asociación titular|No consta en el material; no se inventa|Antes de la App Store|—|

Total del año 1: entre unos 23 € (Play más exención de Apple) y unos 115 € (Play más Apple). Servidores a 0 € mientras quepan en los planes gratuitos. Los tokens de Fable, Opus, Sonnet y Haiku salen de la suscripción del promotor.

Lo inevitable: la cuota de Google, la de Apple si no hay exención y una entidad jurídica, porque Apple exige que las apps de salud las publique una entidad (guideline 5.1.1(ix), [fuente](https://developer.apple.com/app-store/review/guidelines/)).

## NACHO · 6. Cómo publicarla sin que la cierren

- Titular: una asociación o fundación sin ánimo de lucro. Lo exige Apple para salud y abre la exención de cuota.
- Descripción: "cuaderno de cuidado e investigación personal para familias, con una biblioteca abierta de estudios enlazados". Frase que pide Google: "no es un producto sanitario y no diagnostica, trata, cura ni previene ninguna enfermedad; consulta a un profesional" ([Google Play](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en)). Declaración de apps de salud rellena.
- Textos que se evitan en tienda, avisos y pantallas (lo vigila la integración continua): cura, revierte, trata, funciona, milagro, "sustituye a", "sin necesidad de médico", "natural" como argumento, testimonios en la ficha de la tienda (los prohíbe el [RD 1907/1996](https://www.boe.es/eli/es/rd/1996/08/02/1907)), enlaces de compra y afiliados.
- Dentro de la app, cada cifra va como "según [fuente], [cifra tal cual]", con enlace. Sin calculadora de dosis: el protocolo es texto citado.
- Fuera del producto sanitario: el antes y después es descriptivo y el orden del catálogo es igual para todos. Si la app interpretara datos de una persona o lanzara alertas clínicas, entraría en la regla 11 del MDR ([MDCG 2019-11](https://health.ec.europa.eu/system/files/2020-09/md_mdcg_2019_11_guidance_en_0.pdf)).
- Investigación con personas: Apple (5.1.3) y Google piden consentimiento y aprobación de un comité de ética para enviar datos de investigación desde la app. El comité revisa consentimiento y privacidad, no qué intervenciones valen. Se pide en paralelo. Mientras llega, la app de tienda guarda y exporta; el envío funciona en la PWA.
- Si una tienda rechaza: se lee la norma citada, se corrige y se recurre. Mientras, PWA desde la web, APK en GitHub Releases y F-Droid. Si objeta una ficha concreta (psilocibina, cannabinoides), el promotor decide si en esa tienda la ficha enlaza a la web. El catálogo completo sigue siempre en la web.

## NACHO · 7. Ideas fuera de la caja

Ninguna descartada. Fuente del catálogo al lado. Si los propios defensores reportan un riesgo, va en la misma línea.

|#|Idea|Inspira|Riesgo que reportan sus defensores|
|---|---|---|---|
|1|Cobre llevado en el cuerpo: ficha de hueco declarado y plantilla de prueba (pulsera, ropa o cama de cobre; horas de uso; mismas medidas; cobre, ceruloplasmina y zinc si la familia los aporta). Variante de grupo con pulsera idéntica de otro metal|`cobre_metales`: sin ensayos humanos en Alzheimer; única pulsera, [Richmond 2013](https://europepmc.org/article/MED/24066023), artritis, n=70|Para cobre ingerido, Brewer: cobre-2 "muy tóxico para la cognición" ([enlace](https://pmc.ncbi.nlm.nih.gov/articles/PMC6405820))|
|2|Sesión acompañada de psilocibina: quién acompaña, dosis, temperatura y sudoración, sueño de 48 h, medidas de 30 días|`psicodelicos`: [Lago 2026](https://pubmed.ncbi.nlm.nih.gov/42292331/); pilotos de 25 mg x2|Lago: caso único, sudoración, sospecha de hipertermia, sin recomendación de uso sin supervisión|
|3|Nicotina en parche con registro de horas de vigilia y sueño|`nicotina_colinergicos`: [Newhouse 2012](https://pubmed.ncbi.nlm.nih.gov/22232050/), 15 mg/día 6 meses|Adicción, alteración del sueño, molestias digestivas (ADDF, en el dosier)|
|4|Contador público de "días enterrado" por ensayo y carta automática al promotor|`lo_enterrado` de los 15 temas: 127 entradas, 116 NCT; p. ej. NCT00567060, piracetam, 676 personas|—|
|5|Replicar en casa un ensayo enterrado: coco 1,25 oz dos veces al día, cruzado 3+3 meses|`relatos_familias`: [NCT01883648](https://clinicaltrials.gov/study/NCT01883648)|Diarrea con coco; interacción con warfarina citada en foro|
|6|Ventana corta: miniprueba antes y 1, 2 y 4 h después de la toma|`relatos_familias`: Richard, efecto "~1 h y ~4 h" ([enlace](https://www.alzheimersblog.org/2012/02/05/coconut-oil-treat-alzheimers/comment-page-2/))|El propio Richard: no sabe si es "just the progression"|
|7|Ciego casero con cápsulas iguales preparadas por otro familiar|`nicotina_colinergicos` (diseño cruzado de White y Snaedal) y `hormonas_peptidos` (n-de-1 con registro ciego)|—|
|8|Grupos sincronizados: muchas familias empiezan el mismo lunes el mismo protocolo, con prerregistro en OSF|`cuerpo_mente` (n-de-1 en casa) y `plantas_tradiciones`; p. ej. melena de león como [Mori 2009](https://pubmed.ncbi.nlm.nih.gov/18844328/)|Melena de león: molestias abdominales, náuseas, erupción (Li 2020, en el dosier)|
|9|La retirada como dato: fase sin la intervención para ver si lo cambiado vuelve|[Mori 2009](https://pubmed.ncbi.nlm.nih.gov/18844328/) (bajó a las 4 semanas de parar); [Taylor 2018](https://pubmed.ncbi.nlm.nih.gov/29955649/) (volvió a la base tras el lavado)|—|
|10|Generador de 40 Hz de luz y sonido en la app, 1 h, con registro de acúfenos|`luz_energia` ([Chan 2022](https://pubmed.ncbi.nlm.nih.gov/36454969/)); Kogan 2026 usó una app gratuita de 40 Hz|Acúfenos, "RD = 0,16" ([Ang 2025](https://pubmed.ncbi.nlm.nih.gov/41381439/))|
|11|Temporizador de Kirtan Kriya de 12 min, también para quien cuida|`cuerpo_mente`: [Lavretsky 2013](https://pubmed.ncbi.nlm.nih.gov/22407663/)|Menor adherencia en yoga (65 % frente a 95 %, Grzenda 2024, en el dosier)|
|12|Diario de música con reacción antes y después|`cuerpo_mente`: [Hillebrand 2025](https://pubmed.ncbi.nlm.nih.gov/39580646/), "d=.57"|Muchos estudios pequeños y cortos|
|13|Mapa del agua: litio, silicio, aluminio y cobre del agua de cada casa, publicado solo agregado|`cobre_metales`: [Kessing 2017](https://pubmed.ncbi.nlm.nih.gov/28832877/), "IRR 0,83" con más de 15 µg/L; agua de Exley|Efecto no lineal del litio en el agua (Kessing)|
|14|La casa como intervención: moho, humedad, HEPA, CPAP, lista de anticolinérgicos|`ambiente_toxicos`: [Bredesen 2016](https://pmc.ncbi.nlm.nih.gov/articles/PMC4789584/)|Bredesen: muestra pequeña y sin control|
|15|Panel de analíticas con "objetivo según la fuente" (PCR, insulina en ayunas, HbA1c, Cu/Zn, ceruloplasmina, litemia)|`protocolos_heterodoxos`: tabla de [Bredesen 2014](https://europepmc.org/article/MED/25324467)|Litio: vigilar litemia y riñón (dosier `cobre_metales`)|
|16|Coste y carga de cada protocolo como dato público|`protocolos_heterodoxos`: [Kogan 2026](https://europepmc.org/article/MED/42221535), 29 de 51 abandonos por coste, complejidad y falta de apoyo|El propio Kogan: hace falta un cuidador adherente|
|17|Grafo "sigue el dinero": financiador, filas que pagó, dirección reportada y si vende el producto|`consenso_y_quien_lo_paga` de los 15; [Cataldo 2010](https://pubmed.ncbi.nlm.nih.gov/20110594/); Grifols en AMBAR; Accera en AC-1202|—|
|18|Lectores de lo que el consenso no lee: la red vota idiomas y escuelas olvidadas (neuropéptidos rusos, fórmulas chinas, Kampo)|`hormonas_peptidos` y `plantas_tradiciones`: NCT02982603 (350) y NCT04492241 (800), sin resultados|Semax y selank: calidad de producto incierta (Hailu 2026, en el dosier)|
|19|Vajilla roja de alto contraste como microprueba de una semana|`nutricion_alimentos`: [Dunne 2004](https://pubmed.ncbi.nlm.nih.gov/15297089/)|—|
|20|Diario de boca y herpes: cepillado, dentista, herpes labial, zóster y vacunas|`infecciones`: [Paganini-Hill 2012](https://pubmed.ncbi.nlm.nih.gov/22860988/)|VALAD: más deterioro con valaciclovir y creatinina elevada ([enlace](https://pubmed.ncbi.nlm.nih.gov/41405855/))|
|21|Plantilla de cannabinoides con registro de somnolencia y caídas|`psicodelicos`: [Pessoa 2026](https://pubmed.ncbi.nlm.nih.gov/41277041/), CBD 300 mg/día|Somnolencia "RR 2,25" ([da Silva 2026](https://pubmed.ncbi.nlm.nih.gov/42315374/))|
|22|Plantilla de insulina intranasal registrada como la usan las familias|`relatos_familias`: Longecity ([enlace](https://www.longecity.org/forum/topic/98889-nasal-insulin-for-alzheimers/)); [Craft 2012](https://pubmed.ncbi.nlm.nih.gov/21911655/)|Quemazón nasal, rechazo del paciente, conservantes del producto (dosier)|

## NACHO · 8. Cómo trabajaremos

### 8.1 Enrutado de modelos

|Quién|Hace|No hace|
|---|---|---|
|Fable|Piensa y orquesta. Parte el trabajo, elige modelo, mantiene CLAUDE.md y las decisiones, vigila las reglas del promotor, decide qué se escala. Abre con NACHO.|Código sin HIPOTENUSA. Trabajo en masa.|
|Opus|Esquema de datos y migraciones, cifrado y privacidad, supresión k≥5, lógica del motor de pruebas, textos de consentimiento y de tienda, revisión de seguridad.|Volumen.|
|Sonnet|Flutter, Python, vigías, integración continua, Quartz, fichas, tests; segunda lectura de filas candidatas.|Decisiones de privacidad.|
|Haiku|Extraer campos de resúmenes de Europe PMC, clasificar financiación, normalizar nombres, traducir cadenas, resumir cambios de ClinicalTrials.gov.|Nada sin una comprobación de script detrás.|

Para gastar menos: recuentos, marcadores y agregados los hace Python, nunca un modelo. Lotes de 20 resúmenes por llamada. Prefijo de instrucciones fijo. Cada tarea recibe solo sus ficheros. Ningún modelo hace de juez de la evidencia. Ningún dato real de familias pasa por un modelo; se desarrolla con familias sintéticas.

### 8.2 Repositorio y memoria
- Repositorio público: `boveda/` (catálogo), `scripts/`, `web/`, `app/`, `servidor/`, `.github/`, `docs/` (regla de admisión, guía de textos, privacidad), `synthetic/`, `CLAUDE.md` y licencias.
- Bóveda privada `memoria/` en Obsidian: decisiones como ADR fechados (qué, por qué, quién decidió), bitácora de sesiones, estado del MVP, preguntas al promotor, registro de consultas a APIs para reproducir los huecos, ideas (también las aparcadas).
- `CLAUDE.md` copia la base del promotor de la sección 0.1: NACHO, HIPOTENUSA, ENOLA, no inventar, nadie de la industria como juez, nada descartado, toda mejora sumada, la familia decide, sin promesas de cura, seguir el dinero, rescatar lo enterrado, reparto de modelos. Añade: ningún dato real en el repositorio ni en prompts.
- Datos reales fuera de git: `.gitignore` y un hook de pre-commit bloquean `*.db`, `*.sqlite`, audio, fotos y exportaciones.

### 8.3 Ritual de sesión
1. Fable lee `memoria/` (última sesión, pendientes, decisiones abiertas).
2. Propone el plan de la sesión. Sin HIPOTENUSA solo se planifica e investiga.
3. Reparte tareas por modelo.
4. Cierra escribiendo `memoria/sesiones/AAAA-MM-DD.md`: hecho, decidido, enlaces, pendiente.
5. ENOLA en cualquier momento: se para todo y se explica.

### 8.4 Cómo entra cada idea nueva del promotor
1. Se abre `memoria/ideas/<idea>.md` con la frase del promotor tal cual.
2. Fable lanza un sprint de investigación con la postura del promotor: tesis, defensores, mecanismos, consenso y quién lo paga, lo enterrado, protocolos, riesgos que reconocen los defensores, fuentes heterodoxas, ideas para la app.
3. Haiku y Sonnet buscan en Europe PMC, PubMed, ClinicalTrials.gov v2, foros y fuentes heterodoxas, y escriben filas con cifra tal cual y enlace.
4. Un script verifica enlace y cifra. Lo no encontrado queda como hueco, con sus consultas.
5. Pull request con el dosier y las filas. Entra por la regla mecánica, sin juicio.

## NACHO · 9. Decisiones que tomo por defecto

|Decisión|Valor por defecto|Cómo cambiarla|
|---|---|---|
|Idiomas|Español de España y neutro; catálogo web también en inglés; literales en el idioma de la fuente|Decirlo; portugués y lenguas cooficiales en fase 2|
|Plataformas|Android, iOS y PWA desde un solo código Flutter|Decirlo; Telegram entra si se elige la línea C|
|Cuentas|Ninguna para usar la app ni para aportar|Pedir cuentas si se quiere red o sincronización|
|Backend|Ninguno para leer; Supabase Free en Frankfurt solo para aportes|Cambiar a PocketBase o Postgres propio sin tocar la app|
|Orden del catálogo|Por filas que reportan mejora; vista inicial con todo, animales y foros incluidos y rotulados|El lector reordena y filtra|
|Admisión de filas|Enlace vivo, cifra literal, campos completos; sin veto de contenido|Pasar a wiki pura (pregunta 2)|
|Medidas|8 diarias, adherencia, adversos y 3-5 semanales|La familia añade o quita|
|Tiempos|Base 14 días; duración de la fuente u 8 semanas; lavado 7-14 días|Ajustable en cada prueba|
|Bloqueos|Ninguno|No se cambia: es la base del promotor|
|Agregados|k≥5 por celda, como mucho 2 variables cruzadas, sin texto libre|Subir o bajar el umbral|
|Familias en el contador|Columna aparte, junto a los estudios|Pregunta 7|
|IA|Voz en el dispositivo; modelos solo sobre literatura pública|No se cambia sin EIPD nueva|
|Licencias|Apache-2.0, AGPL-3.0, CC BY-SA 4.0|Decirlo antes del primer commit|
|Titular|Asociación sin ánimo de lucro|Pregunta 1|

## NACHO · 10. Preguntas de producto

|#|Pregunta|Si no hay respuesta, asumo|
|---|---|---|
|1|¿Publica una asociación de familiares que ya existe o una nueva creada para esto?|Asociación nueva. Mientras se constituye, web y PWA|
|2|Edición del catálogo: ¿pull request con regla mecánica o wiki abierta que se revierte si hace falta?|Pull request más formulario sin git|
|3|¿Suma abierta a cualquiera desde el primer día o piloto cerrado de 30 a 50 familias los primeros 3 meses?|Abierta, con k≥5|
|4|¿Se pide ya un comité de ética independiente para que las aportaciones funcionen dentro de las tiendas?|Sí, en paralelo; mientras, aportes desde la PWA|
|5|Ámbito: ¿España, España y Latinoamérica, o internacional? ¿Solo Alzheimer u otras demencias de las filas?|España y Latinoamérica en español; Alzheimer y deterioro cognitivo leve|
|6|¿Canal de chat (Telegram o WhatsApp) en el MVP?|No en el MVP; Telegram en fase 2|
|7|¿Las pruebas de familias suman en el mismo contador que los estudios o en columna aparte?|Columna aparte|
|8|¿Se publican relatos de familias con detalle (dosis, semanas, cambios) o solo agregados?|Solo agregados; relato público si la familia lo redacta y lo pide|

## NACHO · 11. Mi recomendación

> RECOMENDACIÓN. Es mi opinión, no una decisión. La decisión es del promotor.

Recomiendo la línea B, el Laboratorio en casa, con dos injertos.

Por qué:
1. Encaja con la base al pie de la letra. El promotor pidió una app móvil que ayude a conocer las opciones, probarlas con seguridad, medir qué le hace bien a su persona y sumar lo de muchas familias. B hace los cuatro verbos dentro de la app. A pone el centro en la web. C pone el centro en la comunidad.
2. Da valor a una sola familia desde el primer día. A sirve sobre todo a quien lee. C necesita masa crítica antes de servir.
3. Los propios dosieres lo piden: diario, línea base, un cambio cada vez, exportar para el médico.
4. El hueco existe: la revisión de 35 apps no encontró ninguna que combine registro personal de intervenciones, evidencia etiquetada y coordinación entre cuidadores, gratis y en español ([enlace](https://pmc.ncbi.nlm.nih.gov/articles/PMC11617330/)).
5. Su riesgo principal, la carga de registro, se ataca con diseño (un toque, voz, "igual que ayer", cuidado que alimenta la prueba). El de A (voluntarios) y el de C (moderación y captura) dependen de personas que aún no existen.

Qué injertaría:
- De A, desde la semana 2: la web pública Quartz del catálogo, la columna de quién paga con el filtro "ocultar lo que paga quien vende", el rastreador de los 116 NCT enterrados y la curación abierta por pull request. Es barato, sale antes que la app y sobrevive a cualquier rechazo de tienda.
- De C, en la fase 2 (mes 4): los grupos de prueba sincronizados con prerregistro y la declaración de intereses obligatoria para quien proponga un protocolo. Más tarde, la votación de qué investigar.

Qué pasaría si elige otra:
- Si elige A: el catálogo público sale igual o antes; la app llega más tarde y más ligera; la columna de familias crece despacio. Injertaría de B el diario de un toque y las minipruebas.
- Si elige C: hay que asegurar alianzas con asociaciones y foros antes de abrir; el MVP suma bot, reputación, votación y moderación. Injertaría de B el motor completo y de A la web abierta.
- En los tres casos el núcleo común (sección 3) y el motor (sección 4) se construyen igual. Nada de lo hecho se pierde.

## NACHO · 12. Roadmap de la línea recomendada

Todo empieza con HIPOTENUSA. Sin ella, solo se planifica.

|Semana|Entrega|Hecho cuando|
|---|---|---|
|1|Repositorio, `CLAUDE.md`, bóveda `memoria/`; `importar.py` crea la bóveda del catálogo|644 notas de estudio, 15 de tema, 0 filas sin enlace; segunda ejecución sin cambios|
|2|Web Quartz pública con 25 fichas y marcador; columna de quién paga|Recuentos idénticos a `conteo_v2.py`; 100 % de filas con categoría de financiación y texto literal|
|3|Vigías de Europe PMC y ClinicalTrials.gov; página "Enterrados"|116 NCT cargados; el job abre un pull request; ninguna candidata sin enlace ni cifra literal|
|4|App sin cuenta: SQLCipher, catálogo sin conexión, perfil y roles|Funciona en modo avión; perfil en menos de 3 minutos|
|5|Diario de un toque, voz con Vosk, medicación (CIMA) y sueño|Registro diario en menos de 30 s con datos de prueba; botones de 48 dp o más|
|6|Línea base, motor de pruebas (AB, ABA, ventana corta), pantalla de riesgos de las fuentes, señales de parada|Prueba A-B-A sintética de 60 días sin errores; tests de fases en verde|
|7|Minipruebas semanales y módulos de comida, conducta, seguridad y cuidador|Batería en menos de 5 minutos; un cambio de medicación aparece como cambio simultáneo|
|8|Antes y después, cuaderno y exportación PDF, CSV y JSON|CSV reimportado reproduce la gráfica; test de textos sin "funciona", "eficaz" ni "cura"|
|9|Ficha de resultado, consentimiento en lectura fácil con ARASAAC, Edge Function en Frankfurt, borrado|Flujo completo con datos sintéticos; borrado remoto probado; borrador de EIPD|
|10|Tablero público con k≥5; prueba con 5 cuidadores reales|Crear prueba en menos de 3 minutos y registrar en menos de 30 s, cronometrado; ninguna celda menor de 5 con cifra|
|11|PWA publicada; Android en prueba cerrada (12 testers, 14 días); TestFlight; solicitud a un comité de ética|Builds en las tres vías; ficha de tienda pasa la lista de textos prohibidos|
|12|Revisión de seguridad de Opus, correcciones, documentación, retrospectiva; plan de los grupos de la fase 2|Sin hallazgos críticos abiertos; `memoria/` al día; decisión sobre fase 2 registrada|

Si elige otra línea:
- A: semanas 1-3 iguales. Semanas 4-6, curación abierta (formularios, integración continua de cifra literal, historial visible). La app (catálogo, diario, motor, aporte) pasa a las semanas 7-11 con menos módulos de cuidado.
- C: semanas 1-3 se reducen a catálogo y web. Semanas 4-5, bot de Telegram y app local. Semanas 6-7, motor y plantillas. Semanas 8-9, perfil de transparencia, grupos y reputación. Semana 10, votación y moderación con registro público. Semanas 11-12, piloto con 50 familias y publicación. Las alianzas con asociaciones y foros empiezan en la semana 1.

## NACHO · 13. Anexos

### 13.1 Recursos gratuitos

|Recurso|Para qué|URL|
|---|---|---|
|Europe PMC REST|Vigía de literatura, financiación (`grantsList`)|https://europepmc.org/RestfulWebService|
|PubMed E-utilities|PMID y DOI|https://www.ncbi.nlm.nih.gov/books/NBK25501/|
|ClinicalTrials.gov API v2|Ensayos sin resultados|https://clinicaltrials.gov/data-api/api|
|AlzForum Therapeutics|Ficha de cada tratamiento probado|https://www.alzforum.org/therapeutics|
|Examine.com|Efectos por sustancia (parte gratis); solo enlace|https://examine.com/|
|GreenMedInfo|Índice de estudios de medicina natural; solo enlace|https://greenmedinfo.com/|
|CIMA (AEMPS)|Medicamentos autorizados en España|https://cima.aemps.es/cima/resources/docs/CIMA_REST_API.pdf|
|Obsidian|Editar bóvedas|https://obsidian.md/|
|Quartz|Web desde la bóveda|https://quartz.jzhao.xyz/|
|GitHub Pages|Alojar la web|https://pages.github.com/|
|Supabase|Aportes en Frankfurt|https://supabase.com/pricing|
|Vosk|Voz sin conexión|https://github.com/alphacep/vosk-api|
|ARASAAC|Pictogramas|https://arasaac.org/|
|OSF|Prerregistros|https://osf.io/|
|Zenodo|DOI de datos|https://zenodo.org/|
|F-Droid|Plan B Android|https://f-droid.org/|
|Telegram Bot API|Línea C|https://core.telegram.org/bots/api|
|Guía AEPD de EIPD|Evaluación de impacto|https://www.aepd.es/guias/gestion-riesgo-y-evaluacion-impacto-en-tratamientos-datos-personales.pdf|
|Dementia Digital Design Guidelines|Diseño para demencia|https://www.alzheimers.org.uk/blog/how-design-website-someone-affected-dementia|

### 13.2 Inventario de archivos

|Archivo|Qué es|
|---|---|
|`catalogo/out/CATALOGO.xlsx`|Catálogo verificado en hoja de cálculo (647 filas)|
|`catalogo/out/CATALOGO.md`|Mismo catálogo en Markdown, por tema|
|`catalogo/out/DOSIERES.md`|Los 15 dosieres|
|`catalogo/research/*.json`|Fuente de los recuentos: dosier y filas por tema (644 filas)|
|`catalogo/verified/*.json`|Filas con estado de verificación documental|
|`plan2/linea-observatorio.json`|Línea A|
|`plan2/linea-laboratorio.json`|Línea B|
|`plan2/linea-red.json`|Línea C|
|`plan2/v2work/conteo_v2.py` y `conteo_v2.json`|Script y salida de los recuentos de este plan|
|`plan2/PLAN-v2.md`|Este documento|

### 13.3 Los 15 temas

|Tema|Archivo|
|---|---|
|Ambiente, tóxicos y entorno|`catalogo/research/ambiente_toxicos.json`|
|Cobre, zinc y metales|`catalogo/research/cobre_metales.json`|
|Cuerpo y mente|`catalogo/research/cuerpo_mente.json`|
|Fármacos baratos reposicionados|`catalogo/research/farmacos_reposicionados.json`|
|Hormonas, péptidos y longevidad|`catalogo/research/hormonas_peptidos.json`|
|Teoría infecciosa y antimicrobianos|`catalogo/research/infecciones.json`|
|Luz, sonido, campos y oxígeno|`catalogo/research/luz_energia.json`|
|Metabólico: cetonas, ayuno, insulina|`catalogo/research/metabolico_cetonas.json`|
|Nicotina, cafeína y colinérgicos|`catalogo/research/nicotina_colinergicos.json`|
|Alimentos, dietas y ayunos|`catalogo/research/nutricion_alimentos.json`|
|Plantas, setas y fórmulas tradicionales|`catalogo/research/plantas_tradiciones.json`|
|Protocolos integrales heterodoxos|`catalogo/research/protocolos_heterodoxos.json`|
|Psicodélicos, cannabinoides y nootrópicos|`catalogo/research/psicodelicos.json`|
|Relatos de familias y foros|`catalogo/research/relatos_familias.json`|
|Sangre, plasma y quelación|`catalogo/research/sangre_plasma_quelacion.json`|

