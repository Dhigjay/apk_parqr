-- ============================================================
-- Migration: Perbaikan menyeluruh skema database & RLS
-- Date: 2026-07-09
-- Masalah yang diperbaiki:
--   1. Kolom full_name, phone, address, profile_completed, updated_at
--      tidak ada di tabel users
--   2. Kolom is_primary, updated_at tidak ada di tabel vehicles
--   3. RLS policy untuk vehicles memblokir INSERT
-- ============================================================

-- =====================
-- BAGIAN 1: FUNGSI HELPER
-- =====================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  new.updated_at = now();
  RETURN new;
END;
$$;

-- =====================
-- BAGIAN 2: PERBAIKI TABEL USERS
-- =====================
-- Tambahkan kolom yang hilang di tabel users
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS full_name TEXT;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS phone TEXT;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS address TEXT;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- Trigger updated_at untuk users
DROP TRIGGER IF EXISTS set_users_updated_at ON public.users;
CREATE TRIGGER set_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =====================
-- BAGIAN 3: PERBAIKI TABEL VEHICLES
-- =====================
-- Tambahkan kolom yang hilang di tabel vehicles
ALTER TABLE public.vehicles
  ADD COLUMN IF NOT EXISTS is_primary BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE public.vehicles
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- Trigger updated_at untuk vehicles
DROP TRIGGER IF EXISTS set_vehicles_updated_at ON public.vehicles;
CREATE TRIGGER set_vehicles_updated_at
  BEFORE UPDATE ON public.vehicles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Constraint unik plat nomor per user
ALTER TABLE public.vehicles
  DROP CONSTRAINT IF EXISTS vehicles_user_plate_unique;
ALTER TABLE public.vehicles
  ADD CONSTRAINT vehicles_user_plate_unique UNIQUE (user_id, plate_number);

-- =====================
-- BAGIAN 4: PERBAIKI RLS POLICIES
-- =====================

-- == USERS RLS ==
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Hapus semua policy lama users agar tidak konflik
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Users can read own profile or admins can read all" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile or admins can update all" ON public.users;

-- Buat ulang policy users
CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- == VEHICLES RLS ==
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

-- Hapus semua policy lama vehicles agar tidak konflik
DROP POLICY IF EXISTS "Users can view own vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Users can insert own vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Users can update own vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Users can delete own vehicles" ON public.vehicles;
DROP POLICY IF EXISTS "Users manage own vehicles" ON public.vehicles;

-- Buat ulang policy vehicles
CREATE POLICY "Users can view own vehicles"
  ON public.vehicles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own vehicles"
  ON public.vehicles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vehicles"
  ON public.vehicles FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own vehicles"
  ON public.vehicles FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- SELESAI!
-- Jalankan seluruh isi file ini di Supabase SQL Editor.
-- Dashboard -> SQL Editor -> New Query -> Paste -> Run
-- ============================================================
