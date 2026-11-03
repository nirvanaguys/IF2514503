-- Migration: Tabel product_reviews untuk rating dan ulasan produk
-- Selaras dengan KF-12 SRS: Rating dan ulasan setelah pesanan selesai

create table if not exists public.product_reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  order_id uuid not null references public.orders(id) on delete cascade,
  rating integer not null check (rating >= 1 and rating <= 5),
  review_text text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  -- Satu ulasan per produk per pesanan per user
  unique (product_id, user_id, order_id)
);

alter table public.product_reviews enable row level security;

-- Ulasan dapat dibaca oleh siapa saja (publik)
create policy "Ulasan produk dapat dibaca publik"
  on public.product_reviews for select
  using (true);

-- Hanya pemilik ulasan yang dapat membuat ulasan
create policy "Pengguna membuat ulasan sendiri"
  on public.product_reviews for insert
  with check (auth.uid() = user_id);

-- Hanya pemilik ulasan yang dapat mengubah ulasan
create policy "Pengguna mengubah ulasan sendiri"
  on public.product_reviews for update
  using (auth.uid() = user_id);

-- Hanya pemilik ulasan yang dapat menghapus ulasan
create policy "Pengguna menghapus ulasan sendiri"
  on public.product_reviews for delete
  using (auth.uid() = user_id);

-- Function untuk menghitung ulang rating produk setelah review baru
create or replace function update_product_rating()
returns trigger
language plpgsql
security definer
as $$
declare
  avg_rating numeric;
  total_reviews integer;
begin
  select avg(rating)::numeric(3,1), count(*)
  into avg_rating, total_reviews
  from public.product_reviews
  where product_id = coalesce(NEW.product_id, OLD.product_id);

  update public.products
  set rating = coalesce(avg_rating, 5.0),
      review_count = coalesce(total_reviews, 0),
      updated_at = now()
  where id = coalesce(NEW.product_id, OLD.product_id);

  return coalesce(NEW, OLD);
end;
$$;

-- Trigger: otomatis update rating setiap kali review ditambah/diubah/dihapus
drop trigger if exists trg_update_product_rating on public.product_reviews;
create trigger trg_update_product_rating
  after insert or update or delete on public.product_reviews
  for each row execute function update_product_rating();
