-- Migration: Fungsi atomik untuk pengurangan stok produk
-- Digunakan oleh checkout service saat pembuatan pesanan.
-- Jika p_quantity negatif, stok akan bertambah (untuk pembatalan pesanan).

CREATE OR REPLACE FUNCTION decrement_stock(p_product_id uuid, p_quantity integer)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE products
  SET stock = GREATEST(stock - p_quantity, 0),
      updated_at = now()
  WHERE id = p_product_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Produk dengan ID % tidak ditemukan.', p_product_id;
  END IF;
END;
$$;

-- Berikan akses ke authenticated users agar bisa dipanggil dari client
GRANT EXECUTE ON FUNCTION decrement_stock(uuid, integer) TO authenticated;
