-- ============================================================================
-- DaunKu - Data Awal (Seed) Kategori & Produk Marketplace
-- Jalankan di SQL Editor Supabase untuk mengisi katalog awal produk.
-- ============================================================================

-- 1. SEED KATEGORI
insert into public.categories (name, slug, icon, is_active)
values
  ('Pupuk Organik', 'pupuk-organik', 'eco', true),
  ('Pestisida & Anti-Jamur', 'pestisida-anti-jamur', 'pest_control', true),
  ('Media Tanam', 'media-tanam', 'grass', true),
  ('Alat & Pot', 'alat-pot', 'yard', true)
on conflict (slug) do update set name = excluded.name;

-- 2. SEED PRODUK CONTOH (Hanya bila tabel masih kosong)
-- Catatan: Mengaitkan produk ke pengguna admin pertama atau seller publik
do $$
declare
  v_seller_id uuid;
  v_cat_pupuk uuid;
  v_cat_pestisida uuid;
  v_cat_media uuid;
  v_cat_alat uuid;
begin
  select id into v_seller_id from auth.users limit 1;
  select id into v_cat_pupuk from public.categories where slug = 'pupuk-organik';
  select id into v_cat_pestisida from public.categories where slug = 'pestisida-anti-jamur';
  select id into v_cat_media from public.categories where slug = 'media-tanam';
  select id into v_cat_alat from public.categories where slug = 'alat-pot';

  -- Jika sudah ada pengguna di auth.users, kita buatkan data produk awal
  if v_seller_id is not null then
    insert into public.products (
      seller_id, category_id, name, description, price, stock, image_paths, is_published, rating, review_count
    )
    values
      (
        v_seller_id,
        v_cat_pestisida,
        'Fungisida Organik Neem Oil 250ml',
        'Formula konsentrat minyak mimba murni untuk mengendalikan jamur daun, bercak hitam, embun tepung, serta hama kutu putih secara organik dan ramah lingkungan.',
        35000,
        15,
        array['https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=400&q=80'],
        true,
        4.9,
        128
      ),
      (
        v_seller_id,
        v_cat_pupuk,
        'Pupuk Daun NPK Spray 500ml',
        'Pupuk cair siap semprot kaya nutrisi nitrogen, fosfor, dan kalium seimbang untuk merangsang pertumbuhan tunas baru dan mempertebal daun tanaman hias.',
        28000,
        20,
        array['https://images.unsplash.com/photo-1585336261026-c73c24b6f1ea?auto=format&fit=crop&w=400&q=80'],
        true,
        4.8,
        94
      ),
      (
        v_seller_id,
        v_cat_media,
        'Media Tanam Premium Aroid 2kg',
        'Campuran porous terdiri dari kulit pinus terfermentasi, perlite, coco chunk, dan pumice yang sangat ideal untuk Monstera, Philodendron, dan Anthurium.',
        22000,
        12,
        array['https://images.unsplash.com/photo-1463936575829-25148e1db1b8?auto=format&fit=crop&w=400&q=80'],
        true,
        4.9,
        210
      ),
      (
        v_seller_id,
        v_cat_alat,
        'Gunting Dahan Stainless Pruning Shear',
        'Gunting pangkas berkualitas tinggi berbahan stainless steel SK-5 yang tajam, awet, dan nyaman digenggam untuk merapikan dahan dan daun kering.',
        45000,
        8,
        array['https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=400&q=80'],
        true,
        4.9,
        160
      )
    on conflict do nothing;
  end if;
end $$;

