-- NEW-ERA · Cartero cifrado (Supabase, plan gratuito)
--
-- Pegar entero en el SQL Editor de Supabase y ejecutar ("Run"). Se puede
-- ejecutar más de una vez: no borra datos.
--
-- El servidor solo hace de cartero (ADR-0003): guarda y reparte sobres que
-- cada móvil cifra con la clave del círculo (AES-256-GCM). No tiene la clave,
-- no puede leerlos y no sabe de qué tratan. Lo que ve: el ulid (hora del
-- evento), el token del círculo, el id aleatorio del dispositivo que envía, la
-- versión de la clave y el tamaño (relleno a bloques de 256 bytes).
--
-- Esta versión lleva solo eventos. Vídeos y fotos irán por Storage en otra
-- entrega (ver supabase/README.md).

-- ------------------------------------------------------------------ Tabla

create table if not exists public.sobres (
  -- Orden de llegada. Cada móvil recuerda el último que ha guardado y pide
  -- solo lo posterior (`id > último`).
  id bigint generated always as identity primary key,

  -- ULID del evento (26 caracteres, alfabeto Crockford). Único en todo el
  -- servidor: reenviar un sobre ya entregado no lo duplica (el móvil inserta
  -- con ON CONFLICT DO NOTHING). Lo genera el móvil con 80 bits de azar: nadie
  -- puede adivinarlo para ocupar su sitio antes.
  ulid text not null unique
    check (ulid ~ '^[0-9A-HJKMNP-TV-Z]{26}$'),

  -- Token del círculo: HKDF-SHA256 de la clave del círculo con la etiqueta
  -- "newera/v1/token-servidor", en hexadecimal (64 caracteres).
  -- Por qué HKDF y no SHA-256(clave): la clave de cifrado de los sobres sale
  -- de la misma clave con otra etiqueta ("newera/v1/sobres/aes-256-gcm"). Con
  -- HKDF las dos salidas son independientes (separación de dominios): conocer
  -- el token, que el servidor ve y guarda, no da ninguna pista sobre la clave
  -- de los sobres ni sobre la clave del círculo. Además deja sitio para
  -- derivar más cosas (vídeos, avisos) sin reutilizar nada.
  circulo_token text not null
    check (circulo_token ~ '^[0-9a-f]{64}$'),

  -- Id aleatorio (UUID v4) del dispositivo que envía. No es un dato personal.
  remitente text not null
    check (char_length(remitente) between 1 and 64),

  -- Versión de la clave del círculo con la que se cifró (rotaciones futuras).
  version_clave integer not null
    check (version_clave between 1 and 1000000),

  -- Nonce de AES-GCM: 12 bytes en base64 (16 caracteres, sin relleno).
  -- Base64 en texto y no bytea: PostgREST lo devuelve y lo recibe tal cual en
  -- JSON, igual en Android, iOS y web, sin el formato "\x..." de bytea.
  nonce text not null
    check (nonce ~ '^[A-Za-z0-9+/]{16}$'),

  -- Evento cifrado + etiqueta de autenticación (16 bytes), en base64. Tope de
  -- unos 64 KiB cifrados para que nadie llene la base gratuita (500 MB) con
  -- sobres enormes. Un evento ocupa 256-1024 bytes.
  contenido text not null
    check (char_length(contenido) between 24 and 90000
           and contenido ~ '^[A-Za-z0-9+/]+={0,2}$'),

  -- Hora del servidor. El móvil no puede fijarla (no tiene permiso sobre la
  -- columna, ver más abajo).
  creado_en timestamptz not null default now()
);

-- Cada móvil pide "lo de mi círculo después del id N, en orden".
create index if not exists sobres_por_circulo
  on public.sobres (circulo_token, id);

-- ------------------------------------------------- Permisos: solo leer y dejar
--
-- La clave anon va dentro de la app y es pública por diseño: cualquiera puede
-- usarla. Por eso no basta con esconderla; lo que manda son estos permisos y
-- las políticas RLS. Sin cuentas de usuario: el rol es siempre `anon`.
-- Nadie con la clave anon puede cambiar ni borrar un sobre (los hechos son de
-- solo inserción también aquí).

revoke all on table public.sobres from public, anon, authenticated;
grant select on table public.sobres to anon;
-- Solo estas columnas: `id` y `creado_en` los pone el servidor.
grant insert (ulid, circulo_token, remitente, version_clave, nonce, contenido)
  on table public.sobres to anon;
-- Sin UPDATE, DELETE ni TRUNCATE para anon ni authenticated.

-- ------------------------------------------------------------------ RLS
--
-- Cada móvil manda la cabecera HTTP `x-circulo-token` con su token. PostgREST
-- (la API REST de Supabase) pone las cabeceras de cada petición, en
-- minúsculas, en la variable `request.headers` (JSON) de la transacción, y
-- las políticas la leen. Así un móvil solo ve y solo deja sobres de su
-- círculo.
--
-- `nullif(..., '')`: si la variable no existe (una conexión que no viene de
-- PostgREST) sale nulo y la política deniega, en vez de fallar al convertir
-- '' a JSON.
--
-- Realtime "postgres_changes" no sirve aquí: comprueba RLS con el JWT del
-- suscriptor, no con cabeceras, así que con estas políticas no entregaría
-- nada, y abrir una política para él dejaría a cualquiera con la clave anon
-- leer los sobres (cifrados) de todos los círculos. Por eso la tabla NO se
-- añade a la publicación `supabase_realtime`; los avisos van por Broadcast
-- (siguiente sección).

alter table public.sobres enable row level security;

drop policy if exists sobres_leer_de_mi_circulo on public.sobres;
create policy sobres_leer_de_mi_circulo
  on public.sobres
  for select
  to anon
  using (
    circulo_token =
      nullif(current_setting('request.headers', true), '')::json
        ->> 'x-circulo-token'
  );

drop policy if exists sobres_dejar_en_mi_circulo on public.sobres;
create policy sobres_dejar_en_mi_circulo
  on public.sobres
  for insert
  to anon
  with check (
    circulo_token =
      nullif(current_setting('request.headers', true), '')::json
        ->> 'x-circulo-token'
  );

-- Sin políticas de UPDATE ni DELETE: con RLS activada, quedan denegados.

-- ---------------------------------------------- Avisos por Realtime Broadcast
--
-- Al insertar sobres, un disparador manda un aviso vacío al canal público
-- `aviso_<sha256(token) en hex>` del círculo. El aviso no lleva datos: solo
-- dice "hay algo nuevo" y el móvil lo pide por la API REST, con su cabecera y
-- sus políticas. El canal es un hash del token, no el token: escuchar el canal
-- no permite leer sobres.
--
-- `realtime.send` es la función de Supabase "Broadcast from Database". Si
-- fallara o no existiera, el aviso se pierde pero el sobre se guarda igual
-- (bloque EXCEPTION) y los móviles lo recogen en su consulta periódica (cada
-- 2 minutos con la app abierta).
--
-- Una vez por sentencia (no por fila): un lote de 50 sobres da un solo aviso
-- por círculo.

create or replace function public.sobres_avisar_nuevos()
returns trigger
language plpgsql
security definer          -- anon no puede escribir en realtime.messages
set search_path = ''      -- todo va con su esquema: nada que suplantar
as $$
declare
  token text;
begin
  for token in select distinct n.circulo_token from nuevos n loop
    begin
      perform realtime.send(
        '{}'::jsonb,
        'nuevos',
        'aviso_' || encode(sha256(convert_to(token, 'UTF8')), 'hex'),
        false              -- canal público: los móviles no tienen cuenta
      );
    exception when others then
      null;                -- sin aviso; el sobre queda guardado
    end;
  end loop;
  return null;
end;
$$;

drop trigger if exists sobres_avisar_nuevos on public.sobres;
create trigger sobres_avisar_nuevos
  after insert on public.sobres
  referencing new table as nuevos
  for each statement
  execute function public.sobres_avisar_nuevos();

-- Límites conocidos (anotados para la EIPD):
-- * Con la clave anon cualquiera puede dejar sobres basura bajo un token
--   inventado. No molestan a nadie (nadie los pide) y ocupan como mucho
--   90 KB cada uno. Si pasa, se borran desde el panel con el rol de servicio.
-- * Los sobres de eventos no caducan: un móvil nuevo del círculo necesita el
--   historial. Los vídeos sí (7 días, ADR-0003), en la entrega de Storage.
