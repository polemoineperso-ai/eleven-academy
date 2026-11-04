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

-- Éditeur de fiches. Seuls les comptes listés dans "editors" peuvent modifier ; tout compte connecté peut lire.
-- Pour ajouter un éditeur : insert into public.editors select id from auth.users where email = '...';
create table if not exists public.editors (
  user_id uuid primary key references auth.users on delete cascade
);
alter table public.editors enable row level security;

drop policy if exists "editors_select_own" on public.editors;
create policy "editors_select_own" on public.editors
  for select to authenticated using (auth.uid() = user_id);

create table if not exists public.fiche_edits (
  chapter_id text primary key,
  html text not null check (char_length(html) between 1 and 100000),
  updated_at timestamptz not null default now()
);
alter table public.fiche_edits enable row level security;

drop policy if exists "fiche_edits_read" on public.fiche_edits;
create policy "fiche_edits_read" on public.fiche_edits
  for select to authenticated using (true);

drop policy if exists "fiche_edits_insert" on public.fiche_edits;
create policy "fiche_edits_insert" on public.fiche_edits
  for insert to authenticated with check (exists (select 1 from public.editors e where e.user_id = auth.uid()));

drop policy if exists "fiche_edits_update" on public.fiche_edits;
create policy "fiche_edits_update" on public.fiche_edits
  for update to authenticated
  using (exists (select 1 from public.editors e where e.user_id = auth.uid()))
  with check (exists (select 1 from public.editors e where e.user_id = auth.uid()));

drop policy if exists "fiche_edits_delete" on public.fiche_edits;
create policy "fiche_edits_delete" on public.fiche_edits
  for delete to authenticated using (exists (select 1 from public.editors e where e.user_id = auth.uid()));
