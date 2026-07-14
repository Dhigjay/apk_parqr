-- ============================================================
-- Migration: Fix auth trigger on_auth_user_created
-- Date: 2026-07-10
--
-- MASALAH:
--   Trigger lama mencoba insert ke public.users dengan kolom 'name'
--   yang tidak ada. Schema kita menggunakan 'full_name'.
--   Ini menyebabkan error:
--   "null value in column "name" of relation "users" violates not-null constraint"
--
-- SOLUSI:
--   Buat ulang trigger function agar:
--   1. Pakai kolom 'full_name' (bukan 'name')
--   2. Pakai kolom 'phone' (bukan 'phone_number')
--   3. Gunakan ON CONFLICT DO NOTHING agar aman jika row sudah ada
-- ============================================================

-- Drop trigger lama dulu (jika ada)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Hapus function lama (jika ada)
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Buat ulang function dengan schema yang benar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    id,
    email,
    full_name,
    phone,
    role,
    profile_completed,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    -- Ambil dari metadata registrasi (dikirim dari Flutter saat signUp)
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone', NULL),
    'user',       -- default role
    false,        -- profile belum lengkap
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;  -- Aman jika row sudah ada

  RETURN NEW;
END;
$$;

-- Pasang trigger baru
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- CARA MENJALANKAN:
-- 1. Buka https://supabase.com/dashboard/project/rtchxgkayaquwzuicuzy
-- 2. Klik "SQL Editor" → "New Query"
-- 3. Paste seluruh isi file ini → klik "Run"
-- ============================================================
