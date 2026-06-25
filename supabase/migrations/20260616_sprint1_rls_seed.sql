-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

-- Users RLS Policies
-- Users can only read their own profile
CREATE POLICY "Users can view own profile" 
ON public.users FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
ON public.users FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
ON public.users FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Vehicles RLS Policies
-- Users can only read, insert, update, and delete their own vehicles
CREATE POLICY "Users can view own vehicles" 
ON public.vehicles FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own vehicles" 
ON public.vehicles FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vehicles" 
ON public.vehicles FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own vehicles" 
ON public.vehicles FOR DELETE 
USING (auth.uid() = user_id);

-- Storage Policy for vehicles bucket
-- Assume bucket 'vehicles' exists
CREATE POLICY "Users can upload their vehicle photos"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'vehicles' AND auth.role() = 'authenticated');

CREATE POLICY "Users can view vehicle photos"
ON storage.objects FOR SELECT
USING (bucket_id = 'vehicles');

CREATE POLICY "Users can update their vehicle photos"
ON storage.objects FOR UPDATE
USING (bucket_id = 'vehicles' AND auth.uid() = owner);

CREATE POLICY "Users can delete their vehicle photos"
ON storage.objects FOR DELETE
USING (bucket_id = 'vehicles' AND auth.uid() = owner);

-- Seed Data (Minimal for Admin)
-- Auth user must be created separately in auth.users, this is just for public.users
INSERT INTO public.users (id, email, role, full_name, profile_completed, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000000000', 'admin@parqr.com', 'admin', 'Super Admin', true, now(), now())
ON CONFLICT (id) DO NOTHING;
