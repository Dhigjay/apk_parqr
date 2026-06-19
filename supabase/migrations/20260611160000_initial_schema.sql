-- ParQr MVP initial Supabase schema draft.
-- Run after creating a Supabase project. Review policies before production use.

create extension if not exists "pgcrypto";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text,
  phone text,
  address text,
  role text not null default 'user' check (role in ('user', 'operator', 'admin')),
  profile_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  brand text not null,
  model text not null,
  vehicle_type text not null check (vehicle_type in ('motor', 'mobil')),
  plate_number text not null,
  photo_url text,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint vehicles_user_plate_unique unique (user_id, plate_number)
);

create table if not exists public.operator_registrations (
  id uuid primary key default gen_random_uuid(),
  applicant_user_id uuid not null references public.users(id) on delete cascade,
  business_name text not null,
  address text not null,
  latitude double precision,
  longitude double precision,
  lot_size_m2 numeric(12, 2),
  floors integer not null default 1 check (floors > 0),
  capacity_per_floor jsonb not null default '{}'::jsonb,
  total_capacity integer not null check (total_capacity > 0),
  price_per_hour numeric(12, 2) not null check (price_per_hour >= 0),
  photo_url text,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  reject_reason text,
  reviewed_by uuid references public.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.parking_lots (
  id uuid primary key default gen_random_uuid(),
  operator_id uuid not null references public.users(id) on delete cascade,
  registration_id uuid references public.operator_registrations(id) on delete set null,
  name text not null,
  address text not null,
  latitude double precision,
  longitude double precision,
  floors integer not null default 1 check (floors > 0),
  total_capacity integer not null check (total_capacity > 0),
  price_per_hour numeric(12, 2) not null check (price_per_hour >= 0),
  rounding_minutes integer not null default 60 check (rounding_minutes in (30, 60)),
  photo_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.parking_slots (
  id uuid primary key default gen_random_uuid(),
  lot_id uuid not null references public.parking_lots(id) on delete cascade,
  floor_number integer not null default 1 check (floor_number > 0),
  code text not null,
  status text not null default 'available' check (status in ('available', 'reserved', 'occupied', 'maintenance')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint parking_slots_code_unique unique (lot_id, floor_number, code)
);

create table if not exists public.parking_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  vehicle_id uuid not null references public.vehicles(id) on delete restrict,
  lot_id uuid not null references public.parking_lots(id) on delete restrict,
  slot_id uuid references public.parking_slots(id) on delete set null,
  status text not null default 'booked' check (
    status in (
      'booked',
      'active',
      'checkout_requested',
      'payment_pending',
      'paid',
      'completed',
      'cancelled',
      'expired'
    )
  ),
  entry_qr_token text not null unique,
  exit_qr_token text unique,
  entry_qr_expires_at timestamptz not null,
  entered_at timestamptz,
  checkout_requested_at timestamptz,
  paid_at timestamptz,
  exited_at timestamptz,
  saved_latitude double precision,
  saved_longitude double precision,
  amount_due numeric(12, 2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null unique references public.parking_sessions(id) on delete cascade,
  method text not null check (method in ('cash', 'qris')),
  status text not null default 'pending' check (status in ('pending', 'waiting_operator', 'paid', 'failed', 'expired', 'cancelled')),
  amount numeric(12, 2) not null check (amount >= 0),
  qris_reference text,
  qris_payload text,
  expires_at timestamptz,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.operator_verifications (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references public.payments(id) on delete cascade,
  operator_id uuid not null references public.users(id) on delete restrict,
  amount numeric(12, 2) not null check (amount >= 0),
  notes text,
  verified_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  title text not null,
  body text not null,
  type text not null default 'info',
  metadata jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists vehicles_user_id_idx on public.vehicles(user_id);
create index if not exists operator_registrations_status_idx on public.operator_registrations(status);
create index if not exists parking_lots_operator_id_idx on public.parking_lots(operator_id);
create index if not exists parking_slots_lot_status_idx on public.parking_slots(lot_id, status);
create index if not exists parking_sessions_user_status_idx on public.parking_sessions(user_id, status);
create index if not exists parking_sessions_lot_status_idx on public.parking_sessions(lot_id, status);
create index if not exists payments_status_idx on public.payments(status);
create index if not exists notifications_user_read_idx on public.notifications(user_id, read_at);

drop trigger if exists set_users_updated_at on public.users;
create trigger set_users_updated_at
before update on public.users
for each row execute function public.set_updated_at();

drop trigger if exists set_vehicles_updated_at on public.vehicles;
create trigger set_vehicles_updated_at
before update on public.vehicles
for each row execute function public.set_updated_at();

drop trigger if exists set_operator_registrations_updated_at on public.operator_registrations;
create trigger set_operator_registrations_updated_at
before update on public.operator_registrations
for each row execute function public.set_updated_at();

drop trigger if exists set_parking_lots_updated_at on public.parking_lots;
create trigger set_parking_lots_updated_at
before update on public.parking_lots
for each row execute function public.set_updated_at();

drop trigger if exists set_parking_slots_updated_at on public.parking_slots;
create trigger set_parking_slots_updated_at
before update on public.parking_slots
for each row execute function public.set_updated_at();

drop trigger if exists set_parking_sessions_updated_at on public.parking_sessions;
create trigger set_parking_sessions_updated_at
before update on public.parking_sessions
for each row execute function public.set_updated_at();

drop trigger if exists set_payments_updated_at on public.payments;
create trigger set_payments_updated_at
before update on public.payments
for each row execute function public.set_updated_at();

create or replace function public.current_app_role()
returns text
language sql
security definer
set search_path = public
as $$
  select role from public.users where id = auth.uid()
$$;

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select coalesce(public.current_app_role() = 'admin', false)
$$;

create or replace function public.is_operator_for_lot(target_lot_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.parking_lots
    where id = target_lot_id
      and operator_id = auth.uid()
  )
$$;

alter table public.users enable row level security;
alter table public.vehicles enable row level security;
alter table public.operator_registrations enable row level security;
alter table public.parking_lots enable row level security;
alter table public.parking_slots enable row level security;
alter table public.parking_sessions enable row level security;
alter table public.payments enable row level security;
alter table public.operator_verifications enable row level security;
alter table public.notifications enable row level security;

create policy "Users can read own profile or admins can read all"
on public.users for select
using (id = auth.uid() or public.is_admin());

create policy "Users can update own profile or admins can update all"
on public.users for update
using (id = auth.uid() or public.is_admin())
with check (id = auth.uid() or public.is_admin());

create policy "Users can insert own profile"
on public.users for insert
with check (id = auth.uid());

create policy "Users manage own vehicles"
on public.vehicles for all
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

create policy "Users manage own operator registration"
on public.operator_registrations for all
using (applicant_user_id = auth.uid() or public.is_admin())
with check (applicant_user_id = auth.uid() or public.is_admin());

create policy "Everyone authenticated can read active parking lots"
on public.parking_lots for select
using (is_active = true or operator_id = auth.uid() or public.is_admin());

create policy "Operators manage own parking lots"
on public.parking_lots for all
using (operator_id = auth.uid() or public.is_admin())
with check (operator_id = auth.uid() or public.is_admin());

create policy "Authenticated users can read available slots"
on public.parking_slots for select
using (
  public.is_admin()
  or public.is_operator_for_lot(lot_id)
  or exists (
    select 1 from public.parking_lots lots
    where lots.id = lot_id and lots.is_active = true
  )
);

create policy "Operators manage own parking slots"
on public.parking_slots for all
using (public.is_operator_for_lot(lot_id) or public.is_admin())
with check (public.is_operator_for_lot(lot_id) or public.is_admin());

create policy "Users and operators can read related sessions"
on public.parking_sessions for select
using (
  user_id = auth.uid()
  or public.is_operator_for_lot(lot_id)
  or public.is_admin()
);

create policy "Users can create own parking sessions"
on public.parking_sessions for insert
with check (user_id = auth.uid() or public.is_admin());

create policy "Users operators and admins can update related sessions"
on public.parking_sessions for update
using (
  user_id = auth.uid()
  or public.is_operator_for_lot(lot_id)
  or public.is_admin()
)
with check (
  user_id = auth.uid()
  or public.is_operator_for_lot(lot_id)
  or public.is_admin()
);

create policy "Users and operators can read related payments"
on public.payments for select
using (
  public.is_admin()
  or exists (
    select 1
    from public.parking_sessions sessions
    where sessions.id = session_id
      and (
        sessions.user_id = auth.uid()
        or public.is_operator_for_lot(sessions.lot_id)
      )
  )
);

create policy "Users can create payment for own session"
on public.payments for insert
with check (
  public.is_admin()
  or exists (
    select 1
    from public.parking_sessions sessions
    where sessions.id = session_id
      and sessions.user_id = auth.uid()
  )
);

create policy "Operators and admins can update related payments"
on public.payments for update
using (
  public.is_admin()
  or exists (
    select 1
    from public.parking_sessions sessions
    where sessions.id = session_id
      and public.is_operator_for_lot(sessions.lot_id)
  )
)
with check (
  public.is_admin()
  or exists (
    select 1
    from public.parking_sessions sessions
    where sessions.id = session_id
      and public.is_operator_for_lot(sessions.lot_id)
  )
);

create policy "Operators can insert own cash verifications"
on public.operator_verifications for insert
with check (operator_id = auth.uid() or public.is_admin());

create policy "Operators admins and session owners can read verifications"
on public.operator_verifications for select
using (
  public.is_admin()
  or operator_id = auth.uid()
  or exists (
    select 1
    from public.payments payments
    join public.parking_sessions sessions on sessions.id = payments.session_id
    where payments.id = payment_id
      and sessions.user_id = auth.uid()
  )
);

create policy "Users manage own notifications"
on public.notifications for all
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());
