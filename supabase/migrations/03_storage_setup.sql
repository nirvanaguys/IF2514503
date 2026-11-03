-- ============================================================================
-- DaunKu - Konfigurasi Supabase Storage untuk Gambar Produk & Diagnosis
-- Jalankan di SQL Editor Supabase untuk membuat bucket penyimpanan foto.
-- ============================================================================

-- 1. Buat Bucket 'products' untuk foto produk marketplace
insert into storage.buckets (id, name, public)
values ('products', 'products', true)
on conflict (id) do nothing;

-- 2. Kebijakan Storage Produk: Publik dapat melihat foto produk
create policy "Foto produk dapat dilihat publik"
  on storage.objects for select
  using (bucket_id = 'products');

-- 3. Kebijakan Storage Produk: Penjual yang login dapat mengunggah foto ke foldernya
create policy "Penjual dapat mengunggah foto produk"
  on storage.objects for insert
  with check (
    bucket_id = 'products' and
    auth.role() = 'authenticated'
  );

-- 4. Kebijakan Storage Produk: Penjual dapat menghapus foto produk miliknya
create policy "Penjual dapat mengelola foto produk sendiri"
  on storage.objects for delete
  using (
    bucket_id = 'products' and
    auth.uid()::text = (storage.foldername(name))[1]
  );

