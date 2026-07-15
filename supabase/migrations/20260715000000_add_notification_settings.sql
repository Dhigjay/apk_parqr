create table if not exists public.notification_settings (
  user_id uuid references public.users(id) on delete cascade primary key,
  booking_success boolean default true,
  booking_cancelled boolean default true,
  booking_expiring boolean default true,
  qr_created boolean default true,
  vehicle_checkin boolean default true,
  vehicle_checkout boolean default true,
  parking_duration_reminder boolean default true,
  payment_success boolean default true,
  payment_failed boolean default true,
  refund boolean default true,
  password_changed boolean default true,
  new_device_login boolean default true,
  profile_updated boolean default true,
  operator_approved boolean default true,
  operator_rejected boolean default true,
  promo_new boolean default true,
  parking_discount boolean default true,
  maintenance boolean default true,
  app_update boolean default true,
  security_info boolean default true,
  updated_at timestamptz default now()
);

alter table public.notification_settings enable row level security;

create policy "Users can view their own notification settings"
on public.notification_settings for select
using (
  user_id = (
    select id from public.users where auth_id = auth.uid()
  )
);

create policy "Users can insert their own notification settings"
on public.notification_settings for insert
with check (
  user_id = (
    select id from public.users where auth_id = auth.uid()
  )
);

create policy "Users can update their own notification settings"
on public.notification_settings for update
using (
  user_id = (
    select id from public.users where auth_id = auth.uid()
  )
)
with check (
  user_id = (
    select id from public.users where auth_id = auth.uid()
  )
);
