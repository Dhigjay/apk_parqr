create table if not exists public.notification_settings (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.users(id) on delete cascade unique not null,
  booking_notification boolean default true,
  payment_notification boolean default true,
  parking_notification boolean default true,
  promotion_notification boolean default true,
  created_at timestamptz default now(),
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
