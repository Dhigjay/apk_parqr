-- Quick Insert User & Vehicle untuk Testing Payment
-- Ganti 'USER_ID_DARI_AUTH' dengan User ID yang login sekarang

-- 1. Insert User
INSERT INTO public.users (id, email, full_name, phone_number, role, created_at)
VALUES (
  'USER_ID_DARI_AUTH',  -- ⚠️ GANTI INI dengan User ID dari Supabase Auth
  'test@parqr.com',      -- Email user
  'Test User',           -- Nama
  '081234567890',        -- No HP
  'user',                -- Role
  NOW()
)
ON CONFLICT (id) DO NOTHING;

-- 2. Insert Vehicle
INSERT INTO public.vehicles (id, user_id, brand, model, vehicle_type, plate_number, is_primary, created_at)
VALUES (
  gen_random_uuid(),     -- Auto generate ID
  'USER_ID_DARI_AUTH',   -- ⚠️ GANTI INI dengan User ID yang sama
  'Toyota',              -- Merk
  'Avanza',              -- Model
  'mobil',               -- Tipe (mobil/motor)
  'B 1234 TEST',         -- Nomor polisi
  true,                  -- Kendaraan utama
  NOW()
)
ON CONFLICT DO NOTHING;

-- Setelah run query ini, coba payment lagi!
