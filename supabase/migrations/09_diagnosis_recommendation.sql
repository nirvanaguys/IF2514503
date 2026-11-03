-- Migration: Tambah kolom recommendation ke diagnosis_history
-- dan buat storage bucket untuk gambar diagnosis

alter table public.diagnosis_history
  add column if not exists recommendation text;
