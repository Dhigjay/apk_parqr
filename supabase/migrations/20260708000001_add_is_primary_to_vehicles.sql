-- ============================================================
-- Migration: Add is_primary and updated_at to vehicles table
-- Date: 2026-07-08
-- ============================================================

-- 1. Create set_updated_at helper function if it does not exist
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  new.updated_at = now();
  RETURN new;
END;
$$;

-- 2. Add is_primary column if not exists
ALTER TABLE public.vehicles
  ADD COLUMN IF NOT EXISTS is_primary BOOLEAN NOT NULL DEFAULT false;

-- 3. Add updated_at column if not exists
ALTER TABLE public.vehicles
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- 3. Create set_updated_at trigger for vehicles if it doesn't exist
DROP TRIGGER IF EXISTS set_vehicles_updated_at ON public.vehicles;
CREATE TRIGGER set_vehicles_updated_at
  BEFORE UPDATE ON public.vehicles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 4. Add unique constraint for (user_id, plate_number) to prevent duplicates
ALTER TABLE public.vehicles
  DROP CONSTRAINT IF EXISTS vehicles_user_plate_unique;

ALTER TABLE public.vehicles
  ADD CONSTRAINT vehicles_user_plate_unique UNIQUE (user_id, plate_number);

-- ============================================================
-- INSTRUCTIONS: Run this in Supabase SQL Editor
-- Dashboard -> SQL Editor -> New Query -> Paste -> Run
-- ============================================================
