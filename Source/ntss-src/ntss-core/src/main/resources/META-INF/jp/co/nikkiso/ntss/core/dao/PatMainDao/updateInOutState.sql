update pat_main
set
  in_out_current_state = /* in_out_current_state */null,
  in_out_plan_state = /* in_out_plan_state */null,
  in_out_plan_date = /* in_out_plan_date */null,
  up_date = to_timestamp(/* pat.up_date */null, 'YYYY-MM-DD HH24:MI:SS')
where
  pat_id = /* pat_id */null
;