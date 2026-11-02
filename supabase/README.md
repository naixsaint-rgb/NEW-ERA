# NACHO · Servidor cartero (Supabase)

El servidor solo guarda y reparte sobres cifrados entre los móviles del círculo (ADR-0003). No tiene la
clave y no puede leer nada. Lleva los eventos y las fichas (con sus fotos reducidas) y, en otra tabla,
los vídeos de comprobación cifrados por trozos.

## NACHO · Crear el proyecto (una vez, gratis)

1. En [supabase.com](https://supabase.com), **New project**. Plan **Free**. Región **Central EU (Frankfurt)**.
   La contraseña de la base: genérala y guárdala tú; nosotros no la necesitamos.
2. Cuando esté listo: **SQL Editor** → nueva consulta → pega entero [`schema.sql`](schema.sql) → **Run**.
   Debe terminar sin errores. Se puede repetir sin perder nada.
3. Realtime: no hay que activar nada para la tabla (los avisos van por *Broadcast* desde la base). Si en
   **Realtime → Settings** aparece una opción para permitir canales públicos, déjala activada (sin verificar
   el nombre exacto). Si estuviera desactivada, todo funciona igual pero lo nuevo tarda hasta 2 minutos.
4. Copia dos datos de **Project Settings → API** (en paneles nuevos, «Data API» y «API Keys»):
   - **Project URL**: `https://<algo>.supabase.co`
   - **Clave pública**: la `anon` `public` o, si solo aparece la nueva, la *publishable* (`sb_publishable_…`).

## NACHO · Qué no nos pases nunca

- La clave **`service_role`** (o *secret*, `sb_secret_…`): se salta todas las protecciones.
- La contraseña de la base de datos.
- Ninguna de las dos va al repositorio, a un chat ni a la app.

La URL y la clave anon son públicas por diseño (van dentro de la app): están en `supabase/proyecto.json`
y la CI las mete en el APK. Un secreto de GitHub con el mismo nombre tendría prioridad.

## NACHO · Dónde van la URL y la clave

- **Repositorio**: `supabase/proyecto.json` (`url`, `anon_key`). La CI los mete en el APK de Android. La
  demo web de Pages no los lleva (es pública y sin cifrar).
- **En local**:
  ```bash
  flutter run --dart-define=SUPABASE_URL=https://<algo>.supabase.co --dart-define=SUPABASE_ANON_KEY=<clave>
  ```
  Igual con `flutter build apk` o `flutter build ios`.
- **iOS (Codemagic)**: cuando haya build firmada, las dos variables en el entorno de Codemagic y los mismos
  `--dart-define` en el `flutter build`.
- Sin ellas, la app funciona igual que hasta ahora, solo en el móvil.

## NACHO · Cómo funciona

- Cada evento se cifra en el móvil con AES-256-GCM (nonce aleatorio; el ulid va como dato asociado) y una
  clave sacada con HKDF-SHA256 de la clave del círculo. Va relleno a bloques de 256 bytes para que el
  tamaño no delate el tipo de evento.
- Cada móvil se presenta con la cabecera `x-circulo-token`, otra derivación HKDF de la misma clave: no
  sirve para descifrar. Las políticas RLS solo dejan leer y dejar sobres de ese token. Nadie puede cambiar
  ni borrar un sobre con la clave anon.
- Al llegar sobres, la base avisa por Realtime en el canal `aviso_<sha256(token)>` (sin datos) y los
  móviles piden lo nuevo. Sin aviso, preguntan cada 2 minutos con la app abierta. Sin red, reintentan
  cada vez más espaciado (hasta 5 minutos) y al volver a abrir la app.
- Comprobado: `schema.sql` se ha probado en PostgreSQL 16 imitando los roles de Supabase (RLS, permisos,
  formatos, avisos, segunda ejecución). La app se ha probado contra un servidor falso.
- **Sin verificar** hasta tener el proyecto: el aviso por Realtime desde la base en el plan gratuito y la
  cabecera propia desde la versión web (CORS). Si fallan, la app sigue con la consulta periódica.
- Los proyectos gratuitos se pausan tras una semana sin actividad; se reactivan desde el panel.

## NACHO · Emparejamiento

- Cada móvil crea su círculo y su clave al instalarse. Para compartirlos: en el móvil que ya tiene los
  datos, **Círculo → Invitar otro móvil** enseña un QR y el mismo código para escribir
  (`NEWERA1-XXXX-…`: versión, ids del círculo y de la persona, clave y una suma de comprobación). Lleva la
  clave en claro: solo se enseña en persona.
- En el otro móvil, en «¿De quién es este móvil?», **Este móvil se une a una familia que ya usa la app**:
  se lee el QR o se escribe el código. Si ese móvil tenía datos propios, avisa de que se borran. La base
  local se crea de nuevo con la clave del círculo, se vuelve a elegir perfil y se recibe todo desde el
  principio.
- Las fichas (persona, familiares, medicamentos, versiones de pauta y fotos) viajan en eventos
  `ficha_creada`/`ficha_modificada` con la fila entera. Las fotos van reducidas (512 px, JPEG 80; menos
  si no caben): el `contenido` de un sobre no puede pasar de 90 000 caracteres en base64.
- El servidor no cambia: sigue sin ver nada más que sobres cifrados.

## NACHO · Vídeos de comprobación

Van por una tabla propia, `clips_trozos`, con las mismas reglas que `sobres` (no por Storage: sus
políticas con la cabecera del círculo no se han podido comprobar).

- El móvil de la persona graba 10 s a 15 fps, ~500 kbps y 480p, sin audio. Con ffmpeg y vídeo sintético,
  10 s ocupan unos 640 KB: 10 trozos (sin medir aún con la cámara de un móvil).
- Calcula el SHA-256 del clip, lo parte en trozos de 64 KiB y cifra cada uno con AES-256-GCM (clave HKDF
  con etiqueta propia, nonce aleatorio; el id del clip, el número y el total van como datos asociados:
  nadie puede reordenar ni mezclar trozos). Los sube de 5 en 5, sin duplicar si se repite.
- Cuando están todos, manda el evento `clip_grabado` en su sobre (id del clip, total, tamaño, tipo,
  duración y hash) y borra el clip del móvil. Si se corta a medias, sigue donde lo dejó. Más de 4 MB: no
  viaja y el evento lo anota (`omitido: 'tamaño'`).
- La familia no baja nada hasta que alguien toca «Ver vídeo» en Hoy; descifra, comprueba el hash y lo
  guarda en el móvil 7 días.
- El servidor borra los trozos de más de 7 días con un disparador al insertar y, si el proyecto tiene
  `pg_cron`, también cada noche (03:17 UTC). Si no hay `pg_cron`, el SQL sigue sin él.
- Comprobado en PostgreSQL 16 imitando los roles de Supabase: permisos, RLS por cabecera, formatos, tope
  de tamaño (un trozo de 64 KiB cifrado son 87 404 caracteres), reenvío sin duplicar, caducidad y
  segunda ejecución. **Sin verificar** en el proyecto real: `pg_cron` y el tamaño máximo de petición.
