-- ELEVEN ACADEMY : tables et règles d'accès Supabase.
-- À coller une seule fois dans Supabase > SQL Editor > New query, puis "Run".

-- Progression : un document JSON par utilisatrice, lisible et modifiable par elle seule.
create table if not exists public.progress (
  user_id uuid primary key references auth.users on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.progress enable row level security;

drop policy if exists "progress_select_own" on public.progress;
create policy "progress_select_own" on public.progress
  for select using (auth.uid() = user_id);

drop policy if exists "progress_insert_own" on public.progress;
create policy "progress_insert_own" on public.progress
  for insert with check (auth.uid() = user_id);

drop policy if exists "progress_update_own" on public.progress;
create policy "progress_update_own" on public.progress
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Signalements d'erreur : l'utilisatrice peut en créer, personne ne peut les lire depuis l'application.
-- Tu les consultes dans Supabase > Table Editor > reports.
create table if not exists public.reports (
  id bigint generated always as identity primary key,
  user_id uuid default auth.uid() references auth.users on delete set null,
  question text,
  message text not null check (char_length(message) between 5 and 2000),
  version text,
  created_at timestamptz not null default now()
);
alter table public.reports enable row level security;

drop policy if exists "reports_insert_own" on public.reports;
create policy "reports_insert_own" on public.reports
  for insert with check (auth.uid() = user_id);
