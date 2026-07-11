-- ============================================================
-- STEP 1: DIAGNOSA - Cek semua trigger yang ada di auth.users
-- Jalankan ini DULU untuk melihat trigger apa saja yang aktif
-- ============================================================
SELECT 
  tgname AS trigger_name, 
  proname AS function_name,
  CASE WHEN tgtype & 2 = 2 THEN 'BEFORE' ELSE 'AFTER' END AS timing,
  CASE WHEN tgtype & 4 = 4 THEN 'INSERT' 
       WHEN tgtype & 8 = 8 THEN 'DELETE'
       WHEN tgtype & 16 = 16 THEN 'UPDATE'
       ELSE 'OTHER' END AS event
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'auth' AND c.relname = 'users'
AND NOT t.tgisinternal;

-- ============================================================
-- Juga cek struktur kolom public.users yang sebenarnya
-- ============================================================
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'users'
ORDER BY ordinal_position;
