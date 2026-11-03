-- ============================================================================
-- DaunKu - Migrasi Skema Awal & Row Level Security (RLS)
-- Selaras dengan DaunKu_Rancangan_Pengembangan_Fitur.md (Fase 0 - Fase 3)
-- ============================================================================

-- 1. PROFILES
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_path text,
  phone text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Profil dapat dibaca oleh pemilik"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Profil dapat diupdate oleh pemilik"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Profil dapat dibuat oleh pemilik"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Otomatis buat profil saat registrasi user baru
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 2. SELLER PROFILES
create table if not exists public.seller_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  store_name text not null,
  description text,
  status text not null default 'active',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.seller_profiles enable row level security;

create policy "Toko aktif dapat dibaca publik"
  on public.seller_profiles for select
  using (status = 'active' or auth.uid() = user_id);

create policy "Penjual dapat mengelola profil toko sendiri"
  on public.seller_profiles for all
  using (auth.uid() = user_id);

-- 3. CATEGORIES
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  icon text,
  is_active boolean default true,
  created_at timestamptz default now()
);

alter table public.categories enable row level security;

create policy "Kategori aktif dapat dibaca publik"
  on public.categories for select
  using (is_active = true);

-- 4. PRODUCTS
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  name text not null,
  description text,
  price integer not null check (price >= 0),
  stock integer not null default 0 check (stock >= 0),
  image_paths text[] default '{}',
  is_published boolean default true,
  rating numeric default 5.0,
  review_count integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.products enable row level security;

create policy "Katalog produk aktif dapat dibaca publik"
  on public.products for select
  using (is_published = true or auth.uid() = seller_id);

create policy "Penjual dapat mengelola produknya sendiri"
  on public.products for all
  using (auth.uid() = seller_id);

-- 5. WISHLIST ITEMS
create table if not exists public.wishlist_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz default now(),
  unique (user_id, product_id)
);

alter table public.wishlist_items enable row level security;

create policy "Pengguna mengelola wishlist sendiri"
  on public.wishlist_items for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 6. CART ITEMS
create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (user_id, product_id)
);

alter table public.cart_items enable row level security;

create policy "Pengguna mengelola keranjang sendiri"
  on public.cart_items for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 7. ADDRESSES
create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  recipient_name text not null,
  phone text not null,
  address_line text not null,
  city text not null,
  province text not null,
  postal_code text,
  is_default boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.addresses enable row level security;

create policy "Pengguna mengelola alamat sendiri"
  on public.addresses for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 8. ORDERS
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references auth.users(id),
  status text not null default 'pending_payment',
  subtotal integer not null check (subtotal >= 0),
  shipping_cost integer not null default 0 check (shipping_cost >= 0),
  total integer not null check (total >= 0),
  shipping_address_snapshot jsonb not null,
  payment_provider text,
  payment_reference text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.orders enable row level security;

create policy "Pembeli melihat pesanannya sendiri"
  on public.orders for select
  using (auth.uid() = buyer_id);

create policy "Pembeli membuat pesanan sendiri"
  on public.orders for insert
  with check (auth.uid() = buyer_id);

-- 9. ORDER ITEMS
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  seller_id uuid not null references auth.users(id),
  product_name_snapshot text not null,
  unit_price integer not null check (unit_price >= 0),
  quantity integer not null check (quantity > 0),
  line_total integer not null check (line_total >= 0)
);

alter table public.order_items enable row level security;

create policy "Akses order item untuk pembeli dan penjual terkait"
  on public.order_items for select
  using (
    auth.uid() = seller_id or
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id and o.buyer_id = auth.uid()
    )
  );

-- 10. DIAGNOSIS HISTORY
create table if not exists public.diagnosis_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  image_path text,
  plant_name text,
  result_summary text not null,
  confidence numeric,
  created_at timestamptz default now()
);

alter table public.diagnosis_history enable row level security;

create policy "Pengguna mengelola riwayat diagnosis sendiri"
  on public.diagnosis_history for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

