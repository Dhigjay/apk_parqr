-- Migration to add Midtrans QRIS fields to payments table

ALTER TABLE public.payments
ADD COLUMN IF NOT EXISTS midtrans_transaction_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS qris_url TEXT;

-- We don't need to change RLS policies since they should already allow the user to read their own payments.
