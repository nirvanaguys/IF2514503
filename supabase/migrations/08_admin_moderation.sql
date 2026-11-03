-- Migration: Sistem admin, laporan produk, dan moderasi
-- Selaras dengan KF-20 (Admin moderasi produk) dan KF-21 (Admin lihat transaksi)

-- 1. Tambah kolom role ke profiles (default 'user', bisa 'admin')
alter table public.profiles add column if not exists role text not null default 'user';

-- 2. PRODUCT_REPORTS — Laporan produk dari pengguna
create table if not exists public.product_reports (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text not null,
  description text,
  status text not null default 'pending', -- pending, reviewed, dismissed
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.product_reports enable row level security;

-- Pengguna bisa membuat laporan
create policy "Pengguna membuat laporan produk"
  on public.product_reports for insert
  with check (auth.uid() = reporter_id);

-- Pengguna bisa melihat laporan sendiri
create policy "Pengguna melihat laporan sendiri"
  on public.product_reports for select
  using (auth.uid() = reporter_id);

-- Admin bisa melihat semua laporan
create policy "Admin melihat semua laporan"
  on public.product_reports for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admin bisa update status laporan
create policy "Admin mengupdate laporan"
  on public.product_reports for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- 3. MODERATION_ACTIONS — Log tindakan admin
create table if not exists public.moderation_actions (
  id uuid primary key default gen_random_uuid(),
  report_id uuid references public.product_reports(id) on delete set null,
  admin_id uuid not null references auth.users(id),
  product_id uuid references public.products(id) on delete set null,
  action_type text not null, -- 'deactivate_product', 'warn_seller', 'dismiss_report'
  notes text,
  created_at timestamptz default now()
);

alter table public.moderation_actions enable row level security;

-- Hanya admin yang bisa membuat dan melihat tindakan moderasi
create policy "Admin mengelola tindakan moderasi"
  on public.moderation_actions for all
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- 4. Update RLS profiles agar admin bisa membaca profil lain (untuk keperluan moderasi)
create policy "Admin membaca semua profil"
  on public.profiles for select
  using (
    auth.uid() = id or
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- 5. Admin bisa membaca semua pesanan (KF-21)
create policy "Admin melihat semua pesanan"
  on public.orders for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admin bisa membaca semua order items
create policy "Admin melihat semua order items"
  on public.order_items for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Admin bisa update produk (untuk nonaktifkan)
create policy "Admin mengelola produk"
  on public.products for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );
