-- V Tower Social Club - SEGURIDAD (RLS estricto) + registro de consentimientos
-- Supabase > SQL Editor > New query > pega TODO > Run
-- Es seguro ejecutarlo varias veces.

-- 1) RLS activado en TODAS las tablas del esquema public
do $$
declare t record;
begin
  for t in select tablename from pg_tables where schemaname = 'public' loop
    execute format('alter table public.%I enable row level security', t.tablename);
  end loop;
end $$;

-- 2) PROFILES: borra politicas antiguas (por si alguna permitia leer filas ajenas) y deja solo las estrictas
do $$
declare p record;
begin
  for p in select policyname from pg_policies where schemaname = 'public' and tablename = 'profiles' loop
    execute format('drop policy %I on public.profiles', p.policyname);
  end loop;
end $$;

revoke all on public.profiles from anon, authenticated;
grant usage on schema public to anon, authenticated;
grant select, insert on public.profiles to authenticated;
-- el usuario solo puede editar su nombre y campus (NUNCA referral_count ni referral_code)
grant update (full_name, campus) on public.profiles to authenticated;

create policy "profiles_select_own" on public.profiles
  for select to authenticated using (auth.uid() = user_id);
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check (auth.uid() = user_id and coalesce(referral_count, 0) = 0);
create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 3) USER_CONSENTS: traza de consentimiento (solo se puede insertar y leer lo propio; no editar ni borrar)
create table if not exists public.user_consents (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null,
  consent_type   text not null check (consent_type in ('terms_privacy','marketing')),
  granted        boolean not null,
  policy_version text,
  client_at      timestamptz,
  user_agent     text,
  created_at     timestamptz not null default now()
);
create index if not exists user_consents_user_idx on public.user_consents (user_id, created_at desc);

alter table public.user_consents enable row level security;
do $$
declare p record;
begin
  for p in select policyname from pg_policies where schemaname = 'public' and tablename = 'user_consents' loop
    execute format('drop policy %I on public.user_consents', p.policyname);
  end loop;
end $$;

revoke all on public.user_consents from anon, authenticated;
grant select, insert on public.user_consents to authenticated;

create policy "consents_select_own" on public.user_consents
  for select to authenticated using (auth.uid() = user_id);
create policy "consents_insert_own" on public.user_consents
  for insert to authenticated with check (auth.uid() = user_id);

-- 4) Contador global (solo devuelve un numero, no expone datos)
create or replace function public.member_count()
returns integer language sql stable security definer set search_path = public
as $$ select count(*)::int from public.profiles; $$;
revoke all on function public.member_count() from public;
grant execute on function public.member_count() to anon, authenticated;

-- 5) Comprobacion: todas las tablas deben salir con rls_activo = true
select tablename, rowsecurity as rls_activo from pg_tables where schemaname = 'public' order by tablename;
