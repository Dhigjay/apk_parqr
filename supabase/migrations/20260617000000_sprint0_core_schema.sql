create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text,
  phone text,
  address text,
  role text not null default 'user',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  brand text not null,
  model text,
  vehicle_type text not null,
  plate_number text not null,
  photo_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.parking_lots (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid references public.users(id) on delete set null,
  name text not null,
  address text not null,
  latitude double precision,
  longitude double precision,
  capacity integer not null default 0,
  hourly_rate numeric(12,2) not null default 0,
  status text not null default 'active',
  created_at timestamptz not null default now()
);

create table if not exists public.parking_slots (
  id uuid primary key default gen_random_uuid(),
  parking_lot_id uuid not null references public.parking_lots(id) on delete cascade,
  floor text not null default '1',
  code text not null,
  status text not null default 'available',
  created_at timestamptz not null default now()
);

create table if not exists public.parking_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  vehicle_id uuid not null references public.vehicles(id) on delete restrict,
  parking_lot_id uuid not null references public.parking_lots(id) on delete restrict,
  parking_slot_id uuid references public.parking_slots(id) on delete set null,
  entry_qr text not null,
  exit_qr text,
  status text not null default 'booked',
  checked_in_at timestamptz,
  checked_out_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  parking_session_id uuid not null unique references public.parking_sessions(id) on delete cascade,
  method text not null,
  status text not null default 'pending',
  amount numeric(12,2) not null default 0,
  provider_reference text,
  expires_at timestamptz,
  paid_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.operator_verifications (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references public.payments(id) on delete cascade,
  operator_id uuid not null references public.users(id) on delete restrict,
  status text not null,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.operator_registrations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  business_name text not null,
  address text not null,
  lot_size text,
  floors integer not null default 1,
  capacity integer not null default 0,
  hourly_rate numeric(12,2) not null default 0,
  photo_url text,
  status text not null default 'pending',
  rejection_reason text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  title text not null,
  body text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
