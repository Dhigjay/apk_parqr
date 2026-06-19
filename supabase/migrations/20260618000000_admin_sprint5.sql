-- Sprint 5: Admin RPC for Global Stats

create or replace function public.get_global_stats()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_total_users int;
  v_total_operators int;
  v_total_lots int;
  v_active_sessions int;
  v_total_revenue numeric;
begin
  -- Ensure only admin can run this
  if not public.is_admin() then
    raise exception 'Access denied';
  end if;

  select count(*) into v_total_users from public.users;
  select count(*) into v_total_operators from public.users where role = 'operator';
  select count(*) into v_total_lots from public.parking_lots;
  
  select count(*) into v_active_sessions 
  from public.parking_sessions 
  where status in ('booked', 'active', 'checkout_requested', 'payment_pending');

  select coalesce(sum(amount), 0) into v_total_revenue 
  from public.payments 
  where status = 'paid' and date(paid_at) = current_date;

  return jsonb_build_object(
    'total_users', v_total_users,
    'total_operators', v_total_operators,
    'total_parking_lots', v_total_lots,
    'active_sessions_today', v_active_sessions,
    'total_revenue_today', v_total_revenue
  );
end;
$$;
