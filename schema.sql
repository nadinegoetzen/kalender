-- ============================================================
--  ehorses / edogs · Adventskalender + Holiday Week
--  Supabase-Datenbankschema  (analog zum Tippspiel aufgebaut)
--
--  Anwendung: Supabase-Dashboard → SQL Editor → New query →
--  diesen kompletten Inhalt einfügen → "Run".
--  Danach ist die Datenbank fertig.
-- ============================================================

-- 1) PROFILES – ein Eintrag pro angemeldetem Nutzer
--    (wird beim ersten Login automatisch aus den Anmelde-Daten erzeugt)
create table if not exists public.profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  email              text,
  display_name       text,
  newsletter_consent boolean default false,
  lang               text default 'de',
  is_admin           boolean default false,
  created_at         timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = id);

-- 2) DOORS – Türchen-Inhalte (im Admin gepflegt; pro Kampagne + Tag)
create table if not exists public.doors (
  campaign        text not null,                 -- 'ehorses-advent' | 'ehorses-holiday' | 'edogs-advent' | 'edogs-holiday'
  day             int  not null,
  sponsor         text,
  value           text,
  link            text,
  name            jsonb default '{}'::jsonb,      -- {"de":"…","en":"…"}
  descr           jsonb default '{}'::jsonb,      -- {"de":"…","en":"…"}
  question        jsonb default '{}'::jsonb,      -- {"de":"…","en":"…"}
  answers         jsonb default '[]'::jsonb,      -- [{"de":"…","en":"…"}, …]
  correct         int  default 0,
  q_link          text,
  size            jsonb default '{}'::jsonb,      -- {"enabled":bool,"label":{de,en},"options":[…]}
  infos           jsonb default '[]'::jsonb,      -- Zusatz-Blöcke (Bild/Text/Button)
  prod_image_url  text,
  logo_url        text,
  published       boolean default false,
  primary key (campaign, day)
);
alter table public.doors enable row level security;
-- Veröffentlichte Türchen darf jeder lesen:
create policy "doors_public_read" on public.doors for select using (published = true);
-- Admins dürfen alles (lesen/schreiben):
create policy "doors_admin_all" on public.doors for all
  using      (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin));

-- 3) ENTRIES – Teilnahmen (genau eine pro Nutzer & Türchen)
create table if not exists public.entries (
  id          uuid primary key default gen_random_uuid(),
  campaign    text not null,
  day         int  not null,
  user_id     uuid not null references auth.users(id) on delete cascade,
  answer_idx  int,
  is_correct  boolean,
  size_value  text,
  created_at  timestamptz default now(),
  unique (campaign, day, user_id)
);
alter table public.entries enable row level security;
create policy "entries_insert_own" on public.entries for insert with check (auth.uid() = user_id);
create policy "entries_select_own" on public.entries for select using (auth.uid() = user_id);
create policy "entries_admin_read" on public.entries for select
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin));

-- 4) WINNERS – Gewinner (manuell oder zufällig markiert; nur Admin verwaltet)
create table if not exists public.winners (
  id           uuid primary key default gen_random_uuid(),
  campaign     text not null,
  day          int  not null,
  user_id      uuid not null references auth.users(id) on delete cascade,
  drawn_at     timestamptz default now(),
  notified_at  timestamptz,
  unique (campaign, day, user_id)
);
alter table public.winners enable row level security;
create policy "winners_admin_all" on public.winners for all
  using      (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_admin));
create policy "winners_read_own" on public.winners for select using (auth.uid() = user_id);

-- 5) Profil automatisch bei der Registrierung anlegen
--    (zieht display_name / newsletter_consent / lang aus den Anmelde-Daten)
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, email, display_name, newsletter_consent, lang)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'display_name', 'Teilnehmer'),
    coalesce((new.raw_user_meta_data->>'newsletter_consent')::boolean, false),
    coalesce(new.raw_user_meta_data->>'lang', 'de')
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
--  FERTIG. Tipp: Um dich selbst zum Admin zu machen, melde dich
--  einmal in der App an und führe dann aus:
--    update public.profiles set is_admin = true where email = 'DEINE@EMAIL.de';
-- ============================================================
