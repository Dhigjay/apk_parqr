-- Drop existing constraint if exists
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_role_check;

-- Ensure 'role' has default value and is NOT NULL
ALTER TABLE public.users ALTER COLUMN role SET NOT NULL;
ALTER TABLE public.users ALTER COLUMN role SET DEFAULT 'user';

-- Add role check constraint (lowercase values)
ALTER TABLE public.users ADD CONSTRAINT users_role_check 
    CHECK (role IN ('user', 'operator', 'admin'));
