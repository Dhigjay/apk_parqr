-- ============================================================
-- Migration: Fix payments table for Midtrans Sandbox integration
-- Date: 2026-07-08
-- ============================================================

-- 1. Add Midtrans transaction tracking column
ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS midtrans_transaction_id VARCHAR(255);

-- 2. Add QRIS URL column (stores the URL returned by Midtrans for QRIS QR code)
ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS qris_url TEXT;

-- 3. Add Virtual Account number column
ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS va_number VARCHAR(100);

-- 4. Add bank name column (bca, bni, bri, mandiri)
ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS bank VARCHAR(50);

-- 5. Fix the method check constraint to support VA methods (lowercase)
--    Existing constraint only allows: 'cash', 'qris'
--    We need to add: 'va_bca', 'va_bni', 'va_bri', 'va_mandiri'
ALTER TABLE public.payments
  DROP CONSTRAINT IF EXISTS payments_method_check;

ALTER TABLE public.payments
  ADD CONSTRAINT payments_method_check
  CHECK (method IN ('cash', 'qris', 'va_bca', 'va_bni', 'va_bri', 'va_mandiri'));

-- 6. Ensure status values are lowercase (they should already be, but confirm)
--    Current allowed: 'pending', 'waiting_operator', 'paid', 'failed', 'expired', 'cancelled'
--    No change needed if already correct.

-- ============================================================
-- INSTRUCTIONS: Run this in Supabase SQL Editor
-- Dashboard -> SQL Editor -> New Query -> Paste -> Run
-- ============================================================
