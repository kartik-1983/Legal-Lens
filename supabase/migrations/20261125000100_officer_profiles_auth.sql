-- LEGAL LENS: officer identity profiles for Supabase Auth.
-- Safe to run more than once. This does not alter or delete officer_users or inspection data.
-- Run in the SQL Editor of the selected Supabase project.

begin;

create table if not exists public.officer_profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null,
  email text not null unique,
  badge text not null unique,
  role text not null check (role in ('Admin', 'Enforcement Officer', 'Reviewer')),
  jurisdiction text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.officer_profiles enable row level security;

revoke all on table public.officer_profiles from anon;
grant select on table public.officer_profiles to authenticated;

drop policy if exists "Officers can view their own profile" on public.officer_profiles;
create policy "Officers can view their own profile"
  on public.officer_profiles
  for select
  to authenticated
  using (auth.uid() = id);

commit;

-- After creating an officer under Authentication -> Users, add their profile
-- using that user's Auth UID. Do not put passwords in this table.
--
-- insert into public.officer_profiles
--   (id, name, email, badge, role, jurisdiction, active)
-- values
--   ('AUTH_USER_UUID', 'Kartik Nagar', 'kartik@gov.in',
--    'LM-DL-1004', 'Enforcement Officer', 'Delhi North & Central', true);
