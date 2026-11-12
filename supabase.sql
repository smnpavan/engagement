-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run
create table if not exists public.wishes (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 60),
  message text not null check (char_length(message) between 5 and 400),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now()
);
alter table public.wishes enable row level security;

-- Guests: can send a new blessing (always starts as pending) and read only approved ones
create policy "guests send wishes" on public.wishes for insert to anon, authenticated with check (status = 'pending');
create policy "guests read approved" on public.wishes for select to anon, authenticated using (status = 'approved');

-- Admin (the one signed-in user you create): read everything, approve/reject, delete
create policy "admin read all" on public.wishes for select to authenticated using (true);
create policy "admin update" on public.wishes for update to authenticated using (true) with check (true);
create policy "admin delete" on public.wishes for delete to authenticated using (true);
