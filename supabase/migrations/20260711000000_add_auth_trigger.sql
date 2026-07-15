-- ============================================================
-- Migration: COMPREHENSIVE FIX - Drop ALL auth triggers, recreate correctly
-- Date: 2026-07-11
-- Problem: Trigger lama mungkin pakai nama berbeda dan insert 'visitor'
--          yang melanggar CHECK constraint role IN ('user','operator','admin')
-- ============================================================

-- STEP 1: Drop SEMUA trigger pada auth.users (apapun namanya)
DO $$
DECLARE
    trigger_record RECORD;
BEGIN
    FOR trigger_record IN
        SELECT tgname
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE n.nspname = 'auth' AND c.relname = 'users'
        AND NOT t.tgisinternal
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON auth.users', trigger_record.tgname);
        RAISE NOTICE 'Dropped trigger: %', trigger_record.tgname;
    END LOOP;
END;
$$;

-- STEP 2: Drop semua function terkait (yang umum dipakai untuk trigger auth)
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.create_user_on_signup() CASCADE;
DROP FUNCTION IF EXISTS public.on_auth_user_created() CASCADE;
DROP FUNCTION IF EXISTS public.create_profile_for_user() CASCADE;

-- STEP 3: Buat function baru yang ROBUST (dengan error handling)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, phone, role, profile_completed)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    'user',
    false
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    -- Jangan block signup meskipun insert ke public.users gagal
    -- App akan handle pembuatan profile nanti
    RAISE WARNING 'handle_new_user failed: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- STEP 4: Buat trigger baru
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- INSTRUCTIONS: 
-- 1. Buka Supabase Dashboard -> SQL Editor -> New Query
-- 2. Paste SEMUA isi file ini
-- 3. Klik Run
-- 4. Cek output/messages untuk melihat trigger apa saja yang di-drop
-- ============================================================
