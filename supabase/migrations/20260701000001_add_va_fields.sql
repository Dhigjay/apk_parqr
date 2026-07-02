-- Migration to add Virtual Account fields to payments table

ALTER TABLE public.payments
ADD COLUMN IF NOT EXISTS va_number VARCHAR(100),
ADD COLUMN IF NOT EXISTS bank VARCHAR(50);
