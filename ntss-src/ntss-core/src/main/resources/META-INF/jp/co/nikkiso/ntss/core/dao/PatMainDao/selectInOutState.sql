select
  in_out_current_state,
  in_out_plan_state,
  in_out_plan_date
from
  pat_main
where
  is_del = '0'
and
  facility_cd = /*facility_cd*/null
and
  pat_id = /* pat_id */null
