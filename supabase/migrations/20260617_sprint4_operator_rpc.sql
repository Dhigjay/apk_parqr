-- Sprint 4: Operator Dashboard Stats RPC
-- Calculates vehicles entered today, currently active vehicles, and revenue today for a specific operator.

create or replace function public.get_operator_dashboard_stats(p_operator_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_vehicles_entered_today integer;
  v_active_vehicles integer;
  v_revenue_today numeric(12, 2);
begin
  -- 1. Vehicles entered today (based on entered_at and lot owned by operator)
  select count(*)
  into v_vehicles_entered_today
  from public.parking_sessions ps
  join public.parking_lots pl on pl.id = ps.lot_id
  where pl.operator_id = p_operator_id
    and ps.entered_at >= date_trunc('day', timezone('utc', now()));

  -- 2. Currently active vehicles (status = 'active')
  select count(*)
  into v_active_vehicles
  from public.parking_sessions ps
  join public.parking_lots pl on pl.id = ps.lot_id
  where pl.operator_id = p_operator_id
    and ps.status = 'active';

  -- 3. Revenue today (from payments related to sessions in operator's lots, paid today)
  select coalesce(sum(p.amount), 0)
  into v_revenue_today
  from public.payments p
  join public.parking_sessions ps on ps.id = p.session_id
  join public.parking_lots pl on pl.id = ps.lot_id
  where pl.operator_id = p_operator_id
    and p.status = 'paid'
    and p.paid_at >= date_trunc('day', timezone('utc', now()));

  return jsonb_build_object(
    'vehicles_entered_today', v_vehicles_entered_today,
    'active_vehicles', v_active_vehicles,
    'revenue_today', v_revenue_today
  );
end;
$$;
