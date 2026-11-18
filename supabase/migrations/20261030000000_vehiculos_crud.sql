-- CRUD de vehículos por usuario para SearchMyCar.
-- Ejecuta este archivo completo en Supabase → SQL Editor.
-- Es idempotente: puedes ejecutarlo más de una vez.

begin;

create table if not exists public.vehiculos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  categoria text not null default 'auto',
  marca text not null,
  modelo text not null,
  patente text not null,
  color text not null,
  anio integer,
  creado_en timestamptz not null default now(),
  unique (user_id, patente)
);

-- Compatibilidad con la tabla creada en versiones anteriores de la app.
alter table public.vehiculos
  add column if not exists id uuid,
  add column if not exists user_id uuid
    references auth.users(id) on delete cascade,
  add column if not exists categoria text,
  add column if not exists marca text,
  add column if not exists modelo text,
  add column if not exists patente text,
  add column if not exists color text,
  add column if not exists anio integer,
  add column if not exists creado_en timestamptz default now(),
  add column if not exists tipo text;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'vehiculos'
      and column_name = 'id'
      and data_type = 'uuid'
  ) then
    alter table public.vehiculos alter column id set default gen_random_uuid();
    update public.vehiculos set id = gen_random_uuid() where id is null;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'vehiculos'
      and column_name = 'user_id'
      and data_type = 'uuid'
  ) then
    alter table public.vehiculos alter column user_id set default auth.uid();
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'vehiculos'
      and column_name = 'creado_en'
  ) then
    alter table public.vehiculos alter column creado_en set default now();
    update public.vehiculos set creado_en = now() where creado_en is null;
  end if;
end;
$$;

alter table public.vehiculos alter column tipo drop not null;

-- Las filas antiguas sin dueño quedan invisibles para todos los usuarios.
-- Si la tabla está vacía, user_id pasa a ser obligatorio.
do $$
begin
  if not exists (
    select 1 from public.vehiculos where user_id is null
  ) then
    alter table public.vehiculos alter column user_id set not null;
  end if;
end;
$$;

update public.vehiculos
set categoria = 'auto'
where categoria is null
   or categoria not in ('bicicleta', 'moto', 'auto');

alter table public.vehiculos alter column categoria set default 'auto';
alter table public.vehiculos alter column categoria set not null;

alter table public.vehiculos
  drop constraint if exists vehiculos_categoria_check;

alter table public.vehiculos
  add constraint vehiculos_categoria_check
  check (categoria in ('bicicleta', 'moto', 'auto'));

-- Elimina un posible índice único global sobre la patente, porque ahora
-- la patente debe ser única por usuario, no en toda la tabla.
do $$
declare
  restriccion record;
  indice record;
begin
  for restriccion in
    select conname
    from pg_constraint
    where conrelid = 'public.vehiculos'::regclass
      and contype = 'u'
      and pg_get_constraintdef(oid) ilike '%(patente)%'
      and pg_get_constraintdef(oid) not ilike '%user_id%'
  loop
    execute format(
      'alter table public.vehiculos drop constraint %I',
      restriccion.conname
    );
  end loop;

  for indice in
    select indexname
    from pg_indexes
    where schemaname = 'public'
      and tablename = 'vehiculos'
      and indexdef ilike '%unique%'
      and indexdef ilike '%(patente)%'
      and indexdef not ilike '%user_id%'
  loop
    execute format('drop index if exists public.%I', indice.indexname);
  end loop;
end;
$$;

do $$
begin
  if not exists (
    select 1
    from public.vehiculos
    where user_id is not null
    group by user_id, patente
    having count(*) > 1
  ) then
    create unique index if not exists vehiculos_user_patente_idx
      on public.vehiculos (user_id, patente);
  end if;
end;
$$;

create index if not exists vehiculos_user_id_idx
  on public.vehiculos (user_id);

alter table public.vehiculos enable row level security;

-- Elimina políticas anteriores para garantizar el aislamiento por usuario.
do $$
declare
  politica record;
begin
  for politica in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'vehiculos'
  loop
    execute format('drop policy if exists %I on public.vehiculos', politica.policyname);
  end loop;
end;
$$;

create policy "Ver mis vehiculos"
on public.vehiculos for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Crear mis vehiculos"
on public.vehiculos for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Actualizar mis vehiculos"
on public.vehiculos for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Eliminar mis vehiculos"
on public.vehiculos for delete
to authenticated
using ((select auth.uid()) = user_id);

grant select, insert, update, delete
on public.vehiculos to authenticated;

commit;
