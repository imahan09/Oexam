-- Oexam database schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 role text not null default 'student' check (role in ('student','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.exams (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 description text,
 starts_at timestamptz not null,
 ends_at timestamptz not null,
 duration_minutes int not null check(duration_minutes > 0),
 published boolean not null default false,
 created_by uuid references auth.users(id),
 created_at timestamptz not null default now(),
 check(ends_at > starts_at)
);
create table if not exists public.questions (
 id uuid primary key default gen_random_uuid(),
 exam_id uuid not null references public.exams(id) on delete cascade,
 body text not null,
 options jsonb not null,
 correct_option int not null check(correct_option between 0 and 3),
 points numeric not null default 1 check(points > 0),
 sort_order int not null default 0
);
create table if not exists public.attempts (
 id uuid primary key default gen_random_uuid(),
 exam_id uuid not null references public.exams(id),
 user_id uuid not null references auth.users(id),
 answers jsonb not null default '{}',
 score numeric not null default 0,
 max_score numeric not null default 0,
 started_at timestamptz not null default now(),
 submitted_at timestamptz,
 unique(exam_id,user_id)
);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,full_name) values(new.id,coalesce(new.raw_user_meta_data->>'full_name','')); return new; end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
alter table public.profiles enable row level security;
alter table public.exams enable row level security;
alter table public.questions enable row level security;
alter table public.attempts enable row level security;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin') $$;
create policy "profiles read self or admin" on public.profiles for select using(id=auth.uid() or public.is_admin());
create policy "profiles update self" on public.profiles for update using(id=auth.uid()) with check(id=auth.uid() and role='student');
create policy "exams visible when published" on public.exams for select using(published=true or public.is_admin());
create policy "admin manage exams" on public.exams for all using(public.is_admin()) with check(public.is_admin());
create policy "questions visible for published exams" on public.questions for select using(exists(select 1 from public.exams e where e.id=exam_id and e.published=true and now() between e.starts_at and e.ends_at) or public.is_admin());
create policy "admin manage questions" on public.questions for all using(public.is_admin()) with check(public.is_admin());
create policy "attempts read own or admin" on public.attempts for select using(user_id=auth.uid() or public.is_admin());
create policy "student create own attempt" on public.attempts for insert with check(user_id=auth.uid());
create policy "student update own attempt" on public.attempts for update using(user_id=auth.uid() and submitted_at is null) with check(user_id=auth.uid());
-- IMPORTANT: promote the intended administrator manually in SQL Editor after registering:
-- update public.profiles set role='admin' where id=(select id from auth.users where email='YOUR_ADMIN_EMAIL');
-- For production, calculate grades server-side (Edge Function/RPC); never expose correct_option to student clients.
