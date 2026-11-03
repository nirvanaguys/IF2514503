-- Migration: RLS policy agar penjual dapat memperbarui status pesanan
-- yang berkaitan dengan produk miliknya.

-- Izinkan penjual membaca pesanan yang memiliki item miliknya
create policy "Penjual melihat pesanan terkait produknya"
  on public.orders for select
  using (
    exists (
      select 1 from public.order_items oi
      where oi.order_id = orders.id and oi.seller_id = auth.uid()
    )
  );

-- Izinkan penjual meng-update status pesanan yang memiliki item miliknya
-- Pembatasan transisi status dilakukan di sisi aplikasi (SellerService)
create policy "Penjual memperbarui status pesanan terkait"
  on public.orders for update
  using (
    exists (
      select 1 from public.order_items oi
      where oi.order_id = orders.id and oi.seller_id = auth.uid()
    )
  );

-- Izinkan penjual membaca order_items miliknya sendiri
create policy "Penjual membaca item pesanannya"
  on public.order_items for select
  using (auth.uid() = seller_id);

-- Izinkan insert order_items (diperlukan saat checkout membuat item)
create policy "Pembeli membuat order items"
  on public.order_items for insert
  with check (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id and o.buyer_id = auth.uid()
    )
  );
