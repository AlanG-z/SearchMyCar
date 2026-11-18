-- Registro de ubicaciones por vehículo para SearchMyCar.
-- Ejecuta este archivo completo en Supabase → SQL Editor.
-- Es idempotente: puedes ejecutarlo más de una vez.

begin;

create table if not exists public.ubicaciones (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid()
    references auth.users(id) on delete cascade,
  vehiculo_id uuid not null
    references public.vehiculos(id) on delete cascade,
  latitud double precision not null,
  longitud double precision not null,
  precision_metros double precision,
  creado_en timestamptz not null default now(),
  constraint ubicaciones_latitud_check
    check (latitud between -90 and 90),
  constraint ubicaciones_longitud_check
    check (longitud between -180 and 180),
  constraint ubicaciones_precision_check
    check (precision_metros is null or precision_metros >= 0)
);

-- Compatibilidad si la tabla ya existía de forma parcial.
alter table public.ubicaciones
  add column if not exists id uuid,
  add column if not exists user_id uuid
    references auth.users(id) on delete cascade,
  add column if not exists vehiculo_id uuid
    references public.vehiculos(id) on delete cascade,
  add column if not exists latitud double precision,
  add column if not exists longitud double precision,
  add column if not exists precision_metros double precision,
  add column if not exists creado_en timestamptz default now();

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ubicaciones'
      and column_name = 'id'
      and data_type = 'uuid'
  ) then
    alter table public.ubicaciones alter column id set default gen_random_uuid();
    update public.ubicaciones set id = gen_random_uuid() where id is null;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ubicaciones'
      and column_name = 'user_id'
      and data_type = 'uuid'
  ) then
    alter table public.ubicaciones alter column user_id set default auth.uid();
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ubicaciones'
      and column_name = 'creado_en'
  ) then
    alter table public.ubicaciones alter column creado_en set default now();
    update public.ubicaciones set creado_en = now() where creado_en is null;
  end if;
end;
$$;

alter table public.ubicaciones
  drop constraint if exists ubicaciones_latitud_check;
alter table public.ubicaciones
  drop constraint if exists ubicaciones_longitud_check;
alter table public.ubicaciones
  drop constraint if exists ubicaciones_precision_check;

alter table public.ubicaciones
  add constraint ubicaciones_latitud_check
    check (latitud between -90 and 90),
  add constraint ubicaciones_longitud_check
    check (longitud between -180 and 180),
  add constraint ubicaciones_precision_check
    check (precision_metros is null or precision_metros >= 0);

create index if not exists ubicaciones_user_fecha_idx
  on public.ubicaciones (user_id, creado_en desc);

create index if not exists ubicaciones_vehiculo_idx
  on public.ubicaciones (vehiculo_id);

alter table public.ubicaciones enable row level security;

-- Elimina políticas anteriores para garantizar el aislamiento por usuario.
do $$
declare
  politica record;
begin
  for politica in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'ubicaciones'
  loop
    execute format('drop policy if exists %I on public.ubicaciones', politica.policyname);
  end loop;
end;
$$;

create policy "Ver mis ubicaciones"
on public.ubicaciones for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Crear mis ubicaciones"
on public.ubicaciones for insert
to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.vehiculos v
    where v.id = vehiculo_id
      and v.user_id = (select auth.uid())
  )
);

create policy "Actualizar mis ubicaciones"
on public.ubicaciones for update
to authenticated
using ((select auth.uid()) = user_id)
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1
    from public.vehiculos v
    where v.id = vehiculo_id
      and v.user_id = (select auth.uid())
  )
);

create policy "Eliminar mis ubicaciones"
on public.ubicaciones for delete
to authenticated
using ((select auth.uid()) = user_id);

grant select, insert, update, delete
on public.ubicaciones to authenticated;

commit;
