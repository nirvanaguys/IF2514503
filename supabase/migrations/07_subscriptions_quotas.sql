-- Migration: Tabel langganan premium dan kuota diagnosis
-- Selaras dengan KF-18 (kuota diagnosis) dan KF-19 (berlangganan premium)

-- 1. SUBSCRIPTION_PLANS — Daftar paket yang tersedia
create table if not exists public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  price integer not null check (price >= 0),
  duration_days integer not null check (duration_days > 0),
  diagnosis_quota integer not null, -- -1 berarti unlimited
  description text,
  is_active boolean default true,
  created_at timestamptz default now()
);

alter table public.subscription_plans enable row level security;

create policy "Paket aktif dapat dibaca publik"
  on public.subscription_plans for select
  using (is_active = true);

-- Seed paket awal
insert into public.subscription_plans (name, slug, price, duration_days, diagnosis_quota, description)
values
  ('Bulanan', 'monthly', 29900, 30, 50, 'Paket Premium Bulanan — 50 diagnosis per bulan'),
  ('Tahunan', 'yearly', 249000, 365, -1, 'Paket Premium Tahunan — Diagnosis tanpa batas');

-- 2. USER_SUBSCRIPTIONS — Langganan aktif pengguna
create table if not exists public.user_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_id uuid not null references public.subscription_plans(id),
  status text not null default 'active',
  starts_at timestamptz not null default now(),
  expires_at timestamptz not null,
  payment_reference text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.user_subscriptions enable row level security;

create policy "Pengguna mengelola langganan sendiri"
  on public.user_subscriptions for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 3. DIAGNOSIS_QUOTAS — Pencatatan penggunaan kuota per bulan
create table if not exists public.diagnosis_quotas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  year_month text not null, -- format: '2026-11'
  used_count integer not null default 0 check (used_count >= 0),
  quota_limit integer not null default 10, -- kuota gratis default
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (user_id, year_month)
);

alter table public.diagnosis_quotas enable row level security;

create policy "Pengguna mengelola kuota sendiri"
  on public.diagnosis_quotas for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Function: mengecek dan menambah pemakaian kuota
-- Return: remaining quota (>= 0 jika boleh, -1 jika habis)
create or replace function check_and_use_quota(p_user_id uuid)
returns integer
language plpgsql
security definer
as $$
declare
  v_year_month text;
  v_quota_limit integer;
  v_used integer;
  v_has_premium boolean;
  v_plan_quota integer;
begin
  v_year_month := to_char(now(), 'YYYY-MM');

  -- Cek apakah user punya langganan premium aktif
  select true, sp.diagnosis_quota
  into v_has_premium, v_plan_quota
  from public.user_subscriptions us
  join public.subscription_plans sp on sp.id = us.plan_id
  where us.user_id = p_user_id
    and us.status = 'active'
    and us.expires_at > now()
  order by us.expires_at desc
  limit 1;

  if v_has_premium is true then
    -- Unlimited (-1)
    if v_plan_quota = -1 then
      return 999;
    end if;
    v_quota_limit := v_plan_quota;
  else
    v_quota_limit := 10; -- Kuota gratis
  end if;

  -- Upsert quota record untuk bulan ini
  insert into public.diagnosis_quotas (user_id, year_month, used_count, quota_limit)
  values (p_user_id, v_year_month, 0, v_quota_limit)
  on conflict (user_id, year_month) do update
  set quota_limit = v_quota_limit,
      updated_at = now();

  -- Ambil used_count
  select used_count into v_used
  from public.diagnosis_quotas
  where user_id = p_user_id and year_month = v_year_month;

  -- Cek apakah masih bisa
  if v_used >= v_quota_limit then
    return -1; -- habis
  end if;

  -- Tambah pemakaian
  update public.diagnosis_quotas
  set used_count = used_count + 1, updated_at = now()
  where user_id = p_user_id and year_month = v_year_month;

  return v_quota_limit - v_used - 1; -- sisa setelah pakai
end;
$$;

grant execute on function check_and_use_quota(uuid) to authenticated;

-- Function: mengambil info kuota saat ini tanpa menambah pemakaian
create or replace function get_quota_info(p_user_id uuid)
returns table(quota_limit integer, used_count integer, remaining integer, is_premium boolean)
language plpgsql
security definer
as $$
declare
  v_year_month text;
  v_quota_limit integer;
  v_used integer;
  v_has_premium boolean := false;
  v_plan_quota integer;
begin
  v_year_month := to_char(now(), 'YYYY-MM');

  -- Cek premium
  select true, sp.diagnosis_quota
  into v_has_premium, v_plan_quota
  from public.user_subscriptions us
  join public.subscription_plans sp on sp.id = us.plan_id
  where us.user_id = p_user_id
    and us.status = 'active'
    and us.expires_at > now()
  order by us.expires_at desc
  limit 1;

  if v_has_premium is true then
    if v_plan_quota = -1 then
      return query select 999::integer, 0::integer, 999::integer, true;
      return;
    end if;
    v_quota_limit := v_plan_quota;
  else
    v_quota_limit := 10;
    v_has_premium := false;
  end if;

  -- Ambil/buat record bulan ini
  insert into public.diagnosis_quotas (user_id, year_month, used_count, quota_limit)
  values (p_user_id, v_year_month, 0, v_quota_limit)
  on conflict (user_id, year_month) do update
  set quota_limit = v_quota_limit, updated_at = now();

  select dq.used_count into v_used
  from public.diagnosis_quotas dq
  where dq.user_id = p_user_id and dq.year_month = v_year_month;

  return query select v_quota_limit, coalesce(v_used, 0),
    greatest(v_quota_limit - coalesce(v_used, 0), 0),
    coalesce(v_has_premium, false);
end;
$$;

grant execute on function get_quota_info(uuid) to authenticated;
