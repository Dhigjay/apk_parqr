-- Migration to add operator_verifications table for logging cash payments

CREATE TABLE IF NOT EXISTS public.operator_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    operator_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'VERIFIED',
    verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.operator_verifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Operators can insert verifications" ON public.operator_verifications
    FOR INSERT WITH CHECK (auth.uid() = operator_id);

CREATE POLICY "Operators can view their verifications" ON public.operator_verifications
    FOR SELECT USING (auth.uid() = operator_id);

CREATE POLICY "Users can view verifications for their payments" ON public.operator_verifications
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.payments p
            JOIN public.parking_sessions s ON p.session_id = s.id
            WHERE p.id = operator_verifications.payment_id
            AND s.user_id = auth.uid()
        )
    );
