-- ============================================================
-- GRAFIK 360 PRO · INDUSTRIA GRÁFICA & PUBLICIDAD
-- BASE DE DATOS SUPABASE / POSTGRESQL
-- Ejecutar en el SQL Editor de tu proyecto en Supabase.
-- Incluye: profiles, quotations (cotizaciones), orders (pedidos),
-- triggers automáticos, RLS (Row Level Security) y Storage Bucket.
-- ============================================================

create extension if not exists pgcrypto;

-- 1. TABLA DE PERFILES DE USUARIO / TALLER
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default 'Usuario Taller',
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now()
);

-- 2. TABLA DE COTIZACIONES (QUOTATIONS)
create table if not exists public.quotations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  client_name text not null check (char_length(trim(client_name)) >= 2),
  client_phone text not null check (char_length(trim(client_phone)) >= 4),
  client_email text,
  project_title text not null check (char_length(trim(project_title)) >= 3),
  service_type text not null,
  description text not null,
  width_meters double precision not null default 1.0 check (width_meters > 0),
  height_meters double precision not null default 1.0 check (height_meters > 0),
  quantity integer not null default 1 check (quantity >= 1),
  unit_price double precision not null default 0.0 check (unit_price >= 0),
  total_amount double precision not null default 0.0 check (total_amount >= 0),
  status text not null default 'pendiente' check (status in ('borrador', 'pendiente', 'aprobada', 'rechazada')),
  image_url text,
  notes text,
  latitude double precision check (latitude between -90 and 90 or latitude is null),
  longitude double precision check (longitude between -180 and 180 or longitude is null),
  delivery_address text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 3. TABLA DE PEDIDOS / ÓRDENES DE PRODUCCIÓN (ORDERS)
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  quotation_id uuid references public.quotations(id) on delete set null,
  order_number text not null,
  client_name text not null check (char_length(trim(client_name)) >= 2),
  client_phone text not null,
  project_title text not null check (char_length(trim(project_title)) >= 3),
  service_type text not null,
  specifications text not null,
  total_amount double precision not null default 0.0 check (total_amount >= 0),
  advance_payment double precision not null default 0.0 check (advance_payment >= 0),
  status text not null default 'en_produccion' check (status in ('en_diseno', 'en_produccion', 'listo_para_entrega', 'instalado_entregado', 'cancelado')),
  delivery_date timestamptz,
  image_url text,
  delivery_address text,
  latitude double precision check (latitude between -90 and 90 or latitude is null),
  longitude double precision check (longitude between -180 and 180 or longitude is null),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ÍNDICES DE RENDIMIENTO
create index if not exists quotations_created_at_idx on public.quotations(created_at desc);
create index if not exists quotations_status_idx on public.quotations(status);
create index if not exists quotations_owner_idx on public.quotations(owner_id);

create index if not exists orders_created_at_idx on public.orders(created_at desc);
create index if not exists orders_status_idx on public.orders(status);
create index if not exists orders_owner_idx on public.orders(owner_id);
create index if not exists orders_quotation_idx on public.orders(quotation_id);

-- TRIGGER AUTOMÁTICO PARA UPDATED_AT
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_quotations_updated_at on public.quotations;
create trigger trg_quotations_updated_at
before update on public.quotations
for each row execute function public.set_updated_at();

drop trigger if exists trg_orders_updated_at on public.orders;
create trigger trg_orders_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

-- TRIGGER DE REGISTRO DE USUARIOS
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles(id, full_name)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'full_name', ''), split_part(coalesce(new.email, 'Usuario Taller'), '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- FUNCIÓN HELPER DE ADMIN
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

grant execute on function public.is_admin() to authenticated;

-- ============================================================
-- POLÍTICAS DE SEGURIDAD RLS (ROW LEVEL SECURITY)
-- ============================================================
alter table public.profiles enable row level security;
alter table public.quotations enable row level security;
alter table public.orders enable row level security;

-- PROFILES
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select
to authenticated
using (id = auth.uid());

-- COTIZACIONES (QUOTATIONS)
drop policy if exists "quotations_select_authenticated" on public.quotations;
create policy "quotations_select_authenticated"
on public.quotations for select
to authenticated
using (true);

drop policy if exists "quotations_insert_own" on public.quotations;
create policy "quotations_insert_own"
on public.quotations for insert
to authenticated
with check (owner_id = auth.uid());

drop policy if exists "quotations_update_owner_or_admin" on public.quotations;
create policy "quotations_update_owner_or_admin"
on public.quotations for update
to authenticated
using (owner_id = auth.uid() or public.is_admin())
with check (owner_id = auth.uid() or public.is_admin());

drop policy if exists "quotations_delete_owner_or_admin" on public.quotations;
create policy "quotations_delete_owner_or_admin"
on public.quotations for delete
to authenticated
using (owner_id = auth.uid() or public.is_admin());

-- PEDIDOS (ORDERS)
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated"
on public.orders for select
to authenticated
using (true);

drop policy if exists "orders_insert_own" on public.orders;
create policy "orders_insert_own"
on public.orders for insert
to authenticated
with check (owner_id = auth.uid());

drop policy if exists "orders_update_owner_or_admin" on public.orders;
create policy "orders_update_owner_or_admin"
on public.orders for update
to authenticated
using (owner_id = auth.uid() or public.is_admin())
with check (owner_id = auth.uid() or public.is_admin());

drop policy if exists "orders_delete_owner_or_admin" on public.orders;
create policy "orders_delete_owner_or_admin"
on public.orders for delete
to authenticated
using (owner_id = auth.uid() or public.is_admin());

-- ============================================================
-- STORAGE BUCKET PARA ARTES, BOCETOS Y EVIDENCIAS DE PRODUCCIÓN
-- ============================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'graphic-assets',
  'graphic-assets',
  true,
  10485760, -- 10 MB
  array['image/jpeg','image/png','image/webp','image/svg+xml','application/pdf']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Políticas de Storage
drop policy if exists "graphic_assets_insert_own" on storage.objects;
create policy "graphic_assets_insert_own"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'graphic-assets'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "graphic_assets_update_own" on storage.objects;
create policy "graphic_assets_update_own"
on storage.objects for update
to authenticated
using (
  bucket_id = 'graphic-assets'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'graphic-assets'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "graphic_assets_delete_own" on storage.objects;
create policy "graphic_assets_delete_own"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'graphic-assets'
  and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin())
);
