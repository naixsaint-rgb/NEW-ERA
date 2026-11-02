# NACHO · Método base: una base de datos de estudios sin juez

Documento reutilizable. Describe cómo se construyó el catálogo de NEW-ERA (15 temas, 647 filas, 353
intervenciones, 134 ensayos enterrados) para poder repetirlo en otro proyecto con otro tema. Es corto a
propósito: lo que no está aquí no hizo falta.

## NACHO · 1. Postura (la fija quien investiga, no se discute)
- Quien investiga es el promotor. Nadie de la industria médica o farmacéutica hace de juez, ni ningún agente
  con ese papel. No hay "niveles de evidencia", ni "no funciona", ni se descarta nada por pequeño, antiguo,
  animal, heterodoxo o anecdótico.
- Si una fuente reporta una mejora, va a la tabla con su cifra tal cual, la dirección que dice la propia
  fuente, quién lo pagó y el enlace. Seguir el dinero. Buscar donde el consenso no mira. Rescatar lo
  enterrado (ensayos terminados sin resultados publicados, tratamientos abandonados por baratos).
- Única regla propia: **no inventar**. Lo que no exista no aparece. Cada fila lleva enlace. La comprobación
  es documental (la cita existe, la cifra aparece), nunca un juicio sobre si es verdad.
- El producto final muestra, filtra y suma; no recomienda ni descarta. Nunca promete curas.

## NACHO · 2. La unidad: una fila por estudio
Un JSON por tema (`data/<tema>.json`) con `key`, `title`, `notas` (qué se consultó y cuánto), `dosier` y
`rows`. Cada fila tiene estos campos, todos texto, vacíos permitidos, ninguno inventado:

| Campo | Qué va |
|---|---|
| intervencion | tal como la nombra la fuente |
| tradicion_o_angulo | de dónde viene la idea (tradición, autor, teoría) |
| estudio | autores, año, revista o registro |
| tipo_fuente | vocabulario cerrado (abajo) |
| diseno | diseño en palabras de la fuente |
| n | tamaño de muestra |
| poblacion | quiénes, edad, lugar |
| duracion | cuánto duró |
| dosis_o_protocolo | dosis, pauta o protocolo exacto |
| que_midio | la variable medida |
| resultado_reportado | **la cifra tal cual** (porcentaje, puntos, OR, IC) |
| direccion_segun_la_fuente | mejora · sin cambio · empeora · mixto · no aplica |
| efectos_adversos_reportados | lo que la fuente dice |
| financiacion_y_conflictos | quién pagó, conflictos declarados |
| como_probarlo_en_casa | solo si la propia fuente lo describe |
| coste_aprox | si se conoce; si no, vacío |
| verificacion | resultado de la comprobación documental |
| identificador | PMID, PMCID, DOI, NCT… |
| enlace | URL que cualquiera puede abrir |

Vocabularios cerrados: `tipo_fuente` = ensayo aleatorizado · ensayo no aleatorizado · observacional ·
serie de casos · caso · animal · celula · revision · registro de ensayo · foro o testimonio · libro o web ·
otro. `direccion_segun_la_fuente` = mejora · sin cambio · empeora · mixto · no aplica. `verificacion` empieza
por "cita encontrada; cifra coincide", "cita encontrada; cifra no coincide (…)", "página existe", "página no
accesible" o "sin verificar".

Aparte, `grupos/<tema>.json`: una lista, del mismo largo que `rows`, con el **nombre canónico** de cada
intervención (para que "Cu supplementation" y "cobre oral" sumen juntas). Los nombres canónicos los pone una
pasada aparte, nunca el investigador que escribe la fila.

## NACHO · 3. Fuentes gratuitas y cómo se consultan sin cuota
- **Europe PMC** (REST: `ebi.ac.uk/europepmc/webservices/rest/search?query=…&format=json`), texto completo
  en PMC cuando lo hay. Es la fuente principal: rápida, sin clave, cubre PubMed y preprints.
- **PubMed E-utilities** (`esearch`, `efetch`) para resúmenes y PMID.
- **ClinicalTrials.gov API v2** (`clinicaltrials.gov/api/v2/studies?query.term=…`) para registros; filtro
  por estado COMPLETED/TERMINATED y campo `hasResults` para lo enterrado.
- **Registros de resultados negativos y enterrados**: Open Negative Results Registry ("Dark Data Medicine",
  github.com/Ciprian-LocalPulse/open-negative-results-registry, datos CC0/CC-BY).
- **Examine.com** y **GreenMedInfo** como índices para encontrar estudios por intervención (la fila siempre
  apunta al estudio original, no al índice).
- Foros, testimonios, libros y webs: entran con `tipo_fuente` = "foro o testimonio" o "libro o web", con su
  enlace, y se leen como lo que son. No se excluyen.
- Todo se consulta con `curl` o scripts de Python, que no tienen cuota ni cuestan tokens. Los buscadores
  web de los agentes se reservan para lo que las APIs no encuentran.

## NACHO · 4. Flujo de trabajo en seis pasos
1. **Temas**: el promotor da las ideas; se agrupan en 10–20 temas con nombre y alcance de una línea.
2. **Investigación por tema** (un agente Sonnet por tema, en paralelo, con el mismo encargo): buscar en las
   APIs con 20–40 consultas, leer resúmenes o texto completo, y devolver `rows` con la cifra tal cual. Se le
   pide expresamente pensar "como quien no comulga con el consenso": buscar también en registros de ensayos
   sin resultados, en tratamientos baratos abandonados, en tradiciones y en quién financia.
3. **Verificación documental** (Haiku, o Sonnet si Haiku devuelve esqueletos): para cada fila, abrir el
   enlace o la API y anotar en `verificacion` si la cita existe y si la cifra aparece. Nunca opina. Si una
   fila no tiene enlace verificable, se marca "sin verificar" y se mantiene visible como tal.
4. **Nombres canónicos** (`grupos/`): una pasada que agrupa intervenciones equivalentes bajo un nombre único
   sin tocar las filas.
5. **Crítico de cobertura** (un agente aparte): "¿qué ángulo falta? ¿qué tradición no se ha mirado? ¿qué hay
   enterrado?". Lo que encuentra vuelve al paso 2 como ronda nueva.
6. **Agregados con Python** (`build_catalogo.py`): recuentos por tema, grupo, dirección y tipo de fuente;
   Excel con hojas Leyenda · Filas · Resumen (fórmulas COUNTIFS) · Dosieres · Enterrado; Markdown; y JSON
   compacto para la app. Ningún recuento lo hace un modelo.

## NACHO · 5. Lo enterrado: cómo se busca
- ClinicalTrials.gov: ensayos COMPLETED o TERMINATED sin resultados publicados pasados 2–3 años, por
  intervención y por condición. Cada uno es una fila con `tipo_fuente` = "registro de ensayo" y
  `resultado_reportado` = "sin resultados publicados" (eso es un dato, no un juicio).
- Patrón de "abandonado por barato": sustancias sin patente con ensayos pequeños positivos y ningún ensayo
  grande después. Se anota en `financiacion_y_conflictos` quién pagó el pequeño y que no hubo grande.
- Cruce con registros de resultados negativos para no duplicar y para citar lo que otros ya rescataron.

## NACHO · 6. Dosier por tema (nueve apartados, escritos por el mismo agente que investigó, con enlaces)
tesis · defensores · mecanismos · consenso (qué dice y quién lo paga) · enterrado · protocolos (dosis y pautas
tal como los describen las fuentes) · riesgos reportados · fuentes · ideas para probar y medir en casa.
El tono es descriptivo: "la fuente sostiene", "el ensayo reporta". Sin adjetivos de valor.

## NACHO · 7. Reglas de redacción y comprobaciones automáticas
- Cifras tal cual, con su unidad e intervalo si lo hay. Nada de "significativo" si la fuente no lo dice.
- "Según la fuente" o "reporta" delante de cualquier resultado.
- Palabras prohibidas en el producto final (test automático): cura*, revierte*, trata*, funciona*, milagro*,
  "sustituye a", "sin necesidad de médico", natural*. Evitan promesas y problemas legales.
- Test automático de que cada fila tiene enlace y de que los vocabularios cerrados se respetan.
- Los nombres de personas reales (familias, testimonios) no entran en la base: se cita el foro, no el usuario.

## NACHO · 8. Encargos tipo (resumidos)
**Investigador de tema**: "Tema: X. Devuelve un JSON con 30–60 filas con este esquema. Busca en Europe PMC,
PubMed, ClinicalTrials.gov (incluidos ensayos sin resultados), registros de negativos, tradiciones y foros.
Cifra tal cual; dirección según la fuente; quién paga; enlace. No juzgues. No inventes: si no hay dato, vacío."
**Verificador**: "Para cada fila, abre el enlace o consulta la API. Escribe en `verificacion`: 'cita
encontrada; cifra coincide', 'cita encontrada; cifra no coincide (lo que dice la fuente)', 'página existe',
'página no accesible' o 'sin verificar'. No cambies ninguna otra celda."
**Crítico de cobertura**: "Lista ángulos, tradiciones, sustancias baratas y ensayos enterrados que faltan,
con una consulta concreta para cada uno."
**Nombres canónicos**: "Para cada fila, un nombre único de intervención; equivalentes juntas; el nombre más
corto y reconocible; misma longitud que `rows`."

## NACHO · 9. Reparto de modelos y coste
Fable planifica, reparte y revisa. Sonnet investiga por tema. Haiku verifica citas y formatea. Opus solo si un
tema exige leer textos largos o sintetizar mecanismos complejos. Python cuenta. Las APIs se consultan con
`curl`, no con buscadores de pago. Un tema completo (investigar, verificar, dosier) costó en NEW-ERA del orden
de una sesión de agente por tema; la verificación, mucho menos.

## NACHO · 10. Lista de arranque para otro proyecto
1. Escribir la postura (§1) en el `CLAUDE.md` del proyecto nuevo, con las palabras clave del promotor.
2. Copiar este documento, el esquema (§2), los vocabularios y `tools/build_catalogo.py`.
3. Definir los temas con el promotor y lanzar un investigador por tema.
4. Verificar, canonizar, criticar, repetir una ronda.
5. Generar Excel, Markdown y JSON para la app; publicar con la leyenda delante.
6. Guardar en la bóveda qué se consultó y cuánto, para no investigar dos veces lo mismo.

## NACHO · 11. Cifras de NEW-ERA como referencia
15 temas · 647 filas, todas con enlace · 353 intervenciones canónicas · 134 ensayos enterrados · dirección
según la fuente: 322 mejora, 120 mixto, 106 no aplica, 61 sin cambio, 38 empeora · tipos: 241 ensayos
aleatorizados, 86 registros, 79 observacionales, 68 animales, 56 revisiones, 34 no aleatorizados, 32 series de
casos, 20 foros o testimonios · verificación: 419 con cifra coincidente, 193 con cita encontrada y cifra no
coincidente (anotada tal cual), el resto página existe o no accesible.
