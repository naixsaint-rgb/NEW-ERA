# NACHO · Interfaz iOS para todos (TRIÁNGULO, 26/10/2026)

Especificación de la capa visual aprobada por el promotor. Las maquetas están en
`docs/vault/specs/maquetas-ios/*.html` (ábrelas en un navegador; cada una es una pantalla de 390×844).
No cambia nada de datos, cifrado, catálogo ni alarmas: solo tema, tipografía, componentes y pantallas.

## NACHO · 1. Decisión del promotor
- 26/10/2026: vio tres opciones (A "Ajustes", B "Salud", C "Noche") y la propuesta "Todas juntas"; dijo que le
  gustan todas y que se usen todas. Dio TRIÁNGULO (palabra que autoriza el rediseño).
- Lo que más le gustó: la **foto de la pastilla** en todas partes ("así cualquiera sabe qué pastilla es sin mirar
  el blíster"), la pantalla **Hoy** con **Ayer · Hoy · Mañana · Semana**, la pantalla **Resumen** para ver cómo
  está casi sin preguntarle, las pantallas de **ella** y el **modo noche**.

## NACHO · 2. Cómo encaja todo
App de familia (cinco pestañas abajo + botón "Más" arriba a la derecha):
1. **Hoy** (maqueta A-Familia y D-Semana): selector Ayer · Hoy · Mañana · Semana.
2. **Resumen** (maqueta B-Familia): estado de un vistazo con cifras reales.
3. **Medicación** (maqueta D-Medicacion): pastillero de la semana y pastillas con su foto.
4. **Alimentación** (como estaba, con el tema nuevo).
5. **Ideas y tablas** (como estaba, con el tema nuevo).
"Más" (botón arriba a la derecha, en todas las pestañas): Calendario, Consultas, Alarmas, Voces, Círculo, Ajustes.
En pantalla ancha (≥ 840 dp) sigue el carril lateral con todas las secciones.
Modo noche (maqueta C-Familia): tema oscuro de la familia. Ajuste "Aspecto": Automático (sigue al sistema, por
defecto) · Claro · Oscuro · Noche de 22:00 a 08:00.

App de la persona (sin pestañas, una pantalla cada vez, siempre en claro):
- **Inicio** (maqueta A-Persona): hora enorme, fecha, tarjeta "ahora", botón "Mis pastillas", "Mi gente" con caras,
  "Necesito ayuda", último mensaje de la familia.
- **Mis pastillas** (maqueta D-Persona-Pastillas): las tomas de hoy con la foto de cada una; la de ahora resaltada.
- **Toma** (maqueta B-Persona): foto grande, "Ahora · 14:00 · compartimento", botón verde "Ya me la he tomado",
  luego cámara y "Muy bien" (como ya existe).
- **Pregunta** (maqueta C-Persona): "¿Cómo estás?" con la voz de un familiar y tres respuestas grandes. En esta
  entrega solo existe en modo prueba (botón "Probar pregunta" en Medicación o Ajustes de la familia); la
  programación por horas, la grabación y las respuestas guardadas llegan en la semana 5 del plan v3.

## NACHO · 3. Tokens de color
Todos los textos cumplen 4,5:1 con su fondo (los tests `textContrastGuideline` lo comprueban). Los naranjas y
amarillos de relleno llevan texto oscuro encima; el resto, texto blanco.

Claro (familia y persona):

| Token | Valor | Uso |
|---|---|---|
| fondoAgrupado | `#F2F2F7` | fondo de las pantallas de familia; relleno suave dentro de tarjetas blancas |
| tarjeta | `#FFFFFF` | tarjetas y listas agrupadas; fondo de las pantallas de la persona |
| separador | `#E5E5EA` | líneas entre filas (sangradas 58 px desde la izquierda) |
| texto | `#1C1C1E` | texto principal |
| textoSecundario | `#6E6E73` | fechas, subtítulos, cabeceras de sección (nunca `#8E8E93`: no llega a 4,5:1) |
| chevron | `#C7C7CC` | flechas de "ver más" (decorativas) |
| barra | `#F9F9F9` + borde `#D1D1D6` | barra de pestañas |
| azul | `#0066CC` | tinte de la familia, pestaña activa, botón "Mis pastillas" |
| verde | `#1B7F3B` | confirmada, "Ya me la he tomado", "Bien" |
| naranjaTexto | `#B45309` | avisos en texto ("Sin respuesta", "aviso a las 14:05") |
| naranjaRelleno | `#FF9500` | botones "Regular" y celdas parciales, con texto `#1C1C1E` |
| rojo | `#D70015` | no confirmada, "Mal", ayuda |
| morado | `#4A148C` | cerrada por un familiar |
| indigo | `#4B44C9` | sueño (cuando exista el reloj) |
| azulClaro / verdeClaro / naranjaClaro / rojoClaro / moradoClaro | `#E5F0FF` / `#E3F3EA` / `#FFF1E0` / `#FDECEA` / `#EFE7F7` | fondos de iconos redondos y tarjetas tintadas |
| mesa | `#EDE7DC` (borde `#B9B4A8`) | fondo de la foto o el pictograma de la pastilla |

Oscuro (solo familia):

| Token | Valor |
|---|---|
| fondo | `#000000` |
| tarjeta | `#1C1C1E` |
| rellenoSuave y separador | `#2C2C2E` |
| texto | `#FFFFFF` |
| textoSecundario | `#AEAEB2` |
| chevron | `#5A5A5E` |
| barra | `#161618` + borde `#2C2C2E` |
| azul | `#0A84FF` |
| verde | `#30D158` (texto oscuro encima si es relleno) |
| naranja | `#FF9F0A` (texto oscuro encima) |
| rojo | `#FF453A` |
| indigo | `#8E8AFF` |
| tintes | verde `#163D27`, naranja `#3D2A10`, azul `#0F2A4A`, rojo `#3D1418`, morado `#2B2A4A` |

Los nombres antiguos de `Colores` (`verde`, `azul`, `naranja`, `rojo`, `morado`, `gris`, `texto`, `blanco`,
`fondoPersona`, `fondoFamilia`) se conservan con los valores nuevos para que el resto del código siga compilando:
`verde=#1B7F3B`, `azul=#0066CC`, `naranja=#B45309`, `rojo=#D70015`, `gris=#6E6E73`, `texto=#1C1C1E`,
`fondoPersona=#FFFFFF`, `fondoFamilia=#F2F2F7`.

## NACHO · 4. Tipografía
Letra del sistema (SF en iPhone, Roboto en Android, la del navegador en web). Sin fuentes propias.

Familia: víspera (fecha pequeña) 13/600 mayúsculas con espaciado 0,4; título grande 34/800 con espaciado −0,5;
título de tarjeta 17/700; cuerpo 15; secundario 13; cifra grande 28–34/800; cabecera de sección 13/600 mayúsculas;
etiqueta de pestaña 10/600 (11 en Android). Mínimo 13 pt (antes 16; el sistema puede escalar hasta 2,0).

Persona: hora 76/700 (espaciado −2); fecha 24/600 gris; títulos 26–34/700; cuerpo 19–22; botones 24–28/700;
mínimo 19 pt; escala del sistema entre 1,0 y 1,3. Nunca más de tres acciones a la vez.

## NACHO · 5. Formas y medidas
- Radios: lista agrupada y tarjeta normal 14; tarjeta destacada (Resumen, persona) 20–28; botón de la persona 24;
  botón pequeño 10; chip 999; icono cuadrado 8; foto de pastilla 12–20.
- Márgenes: 20 a los lados; 14 entre bloques; 14–16 dentro de una tarjeta; cabecera a 60 del borde superior
  (SafeArea + 12).
- Listas agrupadas: filas de 56 (76 con foto), separador sangrado 58 px; icono cuadrado 30×30 con fondo de color
  y símbolo blanco (o redondo 30 con fondo claro y símbolo de color para estados).
- Barra de pestañas: 84 de alto (incluida la zona segura), iconos 26, etiqueta 10/600; activa en azul, el resto
  en textoSecundario. Iconos de `CupertinoIcons`: casa (Hoy), corazón (Resumen), cápsula (Medicación),
  cubiertos o similar (Alimentación), libro (Ideas y tablas).
- Objetivos táctiles ≥ 44 dp en familia, ≥ 64 en la persona (botones principales 80–112).
- Sombras: ninguna en listas; sombra muy suave (0 1 2, 4 %) en tarjetas de Resumen.
- Animaciones: las de Cupertino (transición de página `CupertinoPageTransitionsBuilder` en iOS y Android).

## NACHO · 6. Componentes (`app/lib/shared/ios/`)
- `CabeceraGrande(vispera, titulo, {accion})`: víspera 13 mayúsculas + título 34/800; deja 48 px libres a la
  derecha para el botón "Más" que pinta el `FamiliaShell`.
- `TituloSeccion(texto)`: 13/600 mayúsculas, margen izquierdo 16.
- `GrupoLista(children)`: contenedor blanco (oscuro en noche) con radio 14 y separadores sangrados.
- `FilaLista({leading, titulo, subtitulo, detalle, trailing, onTap, conChevron})`: 56 de alto mínimo.
- `IconoCuadrado(icono, {color, fondo, redondo})`: 30×30.
- `TarjetaGrande` (ya existe; se restyla: sin borde, radio 14, blanco; parámetro `radio`).
- `BotonGrande` (ya existe; se restyla: radio 24, icono a la izquierda, texto 28/700; parámetro `alinear`).
- `SelectorSegmentos<T>(valores, etiqueta(T), seleccionado, alCambiar)`: `CupertinoSlidingSegmentedControl`.
- `FotoPastilla(medicamento, {tamano, insigniaCamara})`: foto sobre fondo mesa o `PastillaPictograma`; insignia
  de cámara pequeña abajo a la derecha cuando hay foto.
- `IndicadorAnillo(fraccion, {color, tamano, grosor})`: anillo de progreso (CustomPaint).
- `CeldaDia(texto, estado)`: celda 34–38 de alto para las rejillas de semana y pastillero; estados: completa
  (verde, texto blanco), parcial (naranjaRelleno, texto oscuro), hoy (azulClaro con borde azul), futura (relleno
  suave), vacía.
- `BarraPestanas(seleccionada, alElegir)`: la barra inferior; sustituye a `NavigationBar` en pantalla estrecha.
- `BotonMas()`: botón redondo de 40 con las iniciales del círculo (o icono persona), `ClavesUi.pestana('mas')`, va a
  `Rutas.mas`; lo pinta el shell arriba a la derecha una sola vez.
- `EtiquetaEstadoToma` (ya existe): se mantiene; usa los colores nuevos.

## NACHO · 7. Pantallas y datos reales
Regla de oro: **no inventar**. Lo que no existe en la base se muestra como "llega en la semana N" (texto
gris, sin cifra) o no se muestra. Pulso, pasos y sueño no existen hasta que haya reloj (semana 6): un solo aviso,
nunca tres tarjetas vacías. El control por horas llega en la semana 5: en familia se muestra la franja 9–21 en gris
con el aviso; no se pintan respuestas.

### Hoy (familia)
- Cabecera: víspera con la fecha larga ("Lunes, 26 de octubre"), título "Hoy".
- `SelectorSegmentos`: Ayer · Hoy · Mañana · Semana (`ClavesUi.segmento('ayer')`…).
- **Hoy**: tarjeta de estado (punto de color del semáforo + "Todo en orden por ahora" / aviso + subtítulo con la
  última toma: "Confirmada por Carmen desde el reloj, 09:00"); dentro, tres casillas: Tomas (hechas de previstas
  hoy), Vídeos (clips grabados hoy), Avisos (ayuda pedida + llamadas hoy). Sección "Próxima toma": `FotoPastilla`,
  "14:00 · Mediodía" (compartimento si lo hay), nombre para la persona, "Si no la toma: aviso a las 14:05"
  (hora prevista + los minutos del paso `avisarFamiliar1` de `ConfigEscalado.pasos`, 5 por defecto). Sección "Tomas de hoy": `GrupoLista` con hora, nombre y
  `EtiquetaEstadoToma`. Sección "Comprobaciones": vídeos y fotos grabados hoy ("Vídeo de la toma de las 09:00 ·
  10 s"), vacío → "Sin comprobaciones hoy". Sección "Llega pronto": las reservadas (vídeo a la familia, ubicación,
  control por horas) como filas grises.
- **Ayer**: tomas de ayer con su estado y quién las confirmó; comprobaciones de ayer; aviso de control por horas.
- **Mañana**: tomas previstas de mañana (hora, foto, nombre, compartimento) y aviso "Quién recibe los avisos:
  Familiar 1 a los 5 min, Familiar 2 a los 10" con los nombres reales por `ordenEscalado`.
- **Semana**: últimos 7 días (hoy el último, a la derecha, en azul). Tarjeta de totales: "N de M tomas hechas ·
  hoy quedan K" y "Respuestas: llega en la semana 5". Rejilla: fila Tomas con `CeldaDia` "h/p" por día; fila
  Respondió en gris con el aviso. Sección "Lo que dijo esta semana" solo cuando existan respuestas (semana 5); hasta
  entonces una fila gris con el aviso.
- Datos: `calcularTomas` con `desde`/`hasta` por día; la ventana de eventos de toma pasa de 4 a 8 días atrás.

### Resumen (familia)
- Cabecera "Resumen". Tarjeta héroe: icono redondo verde/naranja/rojo según semáforo, "Lucía está bien" /
  "Lucía necesita un vistazo" (alias de la persona) y subtítulo con el último hecho (última toma confirmada o
  "Sin tomas aún"); chip "Última señal: 09:03" (hora del último evento de la persona).
- Rejilla 2×2: Tomas (anillo hechas/previstas de hoy, "siguiente 14:00"), Vídeos (n hoy, "ver" → Hoy),
  Avisos (ayuda y llamadas hoy), Mensaje (último mensaje a ella, truncado, "enviar" → semana 4 si no existe
  pantalla). Después una fila gris: "Pulso, pasos y sueño llegan con el reloj (semana 6)".
- Tarjeta "Próxima toma" como en Hoy. Franja "Control por horas · 9 a 21 h" en gris con el aviso.

### Medicación (familia)
- Cabecera: víspera "Pastillero y pastillas", título "Medicación", botón azul "Añadir medicamento" (mantiene el
  texto que buscan los tests) arriba a la derecha o justo debajo de la cabecera.
- Tarjeta "Pastillero de la semana": columnas L M X J V S D (hoy en azul), una fila por hora distinta de las pautas
  activas; cada celda `CeldaDia` según el estado de esa toma (confirmada → completa; no confirmada → rojo; ahora →
  hoy; futura → relleno suave con mini pictograma; sin pauta ese día → vacía). Subtítulo "Lo llenó … el domingo"
  solo si existe el dato (no existe: se omite).
- Botón "Probar pantalla de toma" (texto que buscan los tests) y "Probar pregunta" (modo prueba de la pantalla C).
- Sección "Pastillas · con su foto": `GrupoLista` con `FotoPastilla` 56, nombre, "09:00 y 14:00 · 1 comprimido",
  "Foto de <quien> · <fecha>" solo si se conoce (el evento `medicamento_creado` lleva autor y fecha), chevron a
  detalle. Pie: "La foto la hace la familia una vez. Se ve en la alarma de ella, en el pastillero y en el vídeo
  de comprobación."

### Persona · Inicio
- Hora 76/700 centrada (pulsación de 5 s para salir del perfil, como ahora), fecha larga 24 gris.
- Tarjeta "ahora" (`ClavesUi.loSiguiente`): "Ahora no toca nada · Las pastillas son a las 14:00" o, a su hora,
  `FotoPastilla` + "Es la hora: cápsula roja" con botón verde (`ClavesUi.esLaHora`).
- Botón azul "Mis pastillas" (`ClavesUi.misPastillas`) → `/persona/pastillas`.
- "Mi gente": caras de 96 con nombre; tocar llama (como ahora).
- Botón rojo "Necesito ayuda" (`ClavesUi.necesitoAyuda`) fijo abajo. Mensaje de la familia si lo hay.
- Los textos que esperan los tests se mantienen: fecha larga, "Por la mañana", "12:00", "A las 14:00, cápsula
  roja", "Mi gente", "Es la hora: cápsula roja", "Estoy llamando a Lucía.".

### Persona · Mis pastillas
- Título "Mis pastillas", "Hoy, lunes". Una tarjeta por toma de hoy: foto 72, hora y nombre, estado en palabras
  grandes ("Ya tomadas" con visto verde / "Después de cenar"); la toma de ahora con borde azul, foto 104 y botón
  verde "Ya me la he tomado" que abre la pantalla de toma. Botón gris "Volver al inicio".

### Persona · Toma
- Misma lógica (confirmar → cámara → "Muy bien"). Aspecto B-Persona: tarjeta blanca radio 28 con etiqueta
  "Ahora toca" en verde, foto grande sobre fondo mesa, nombre 26/700, "Compartimento: Mediodía", botón verde de 88
  "YA ME LA HE TOMADO" (texto actual). Abajo: "Te lo recuerda la voz de <familiar>" solo si hay voz (no hay aún:
  se omite).

### Persona · Pregunta (modo prueba)
- "13:00 · pregunta 1 de 3" con tres puntos; tarjeta gris "Te lo pregunta <Familiar 1>" con icono de altavoz;
  "¿Cómo estás?" 48/800; botones Bien (verde) · Regular (naranjaRelleno, texto oscuro) · Mal (rojo) de 108;
  "Prefiero decirlo" con micrófono (borde gris). Las tres preguntas en orden: ¿Cómo estás? · ¿Te duele algo? ·
  ¿Qué vas a hacer luego? (respuestas de la segunda: Nada · Un poco · Mucho; de la tercera: Pasear · Descansar ·
  Ver la tele · Otra cosa). En modo prueba no se guarda nada y al final vuelve a Medicación con un aviso.

### Más y Ajustes
- "Más": `GrupoLista` con Calendario, Consultas, Alarmas, Voces, Círculo, Ajustes (icono cuadrado de color +
  chevron), claves `ClavesUi.pestana(slug)`.
- Ajustes: fila "Aspecto" con `SelectorSegmentos` Automático · Claro · Oscuro · Noche (22–08); se guarda en el
  almacén seguro con la clave `aspecto`. Resto como ahora.

## NACHO · 8. Reglas de construcción
- Todo texto sale de `app_es.arb` (el test de literales lo exige). Palabras prohibidas (test): cura*, revierte,
  trata*, funciona*, milagro*, "sustituye a", "sin necesidad de médico", natural*.
- Ningún estado solo por color: color + icono + texto.
- Ningún dato inventado; los nombres de ejemplo son los de `semilla_demo.dart`.
- Claves de test en `ClavesUi`. Tests: los existentes deben seguir en verde (adaptando lo que cambia de sitio) y
  cada pantalla nueva trae su test de widget y pasa `textContrastGuideline` y `androidTapTargetGuideline`.
- `flutter analyze` sin avisos; `dart format`.
- Commits en castellano, Conventional Commits con ámbito (`feat(ui): …`, `feat(hoy): …`).
