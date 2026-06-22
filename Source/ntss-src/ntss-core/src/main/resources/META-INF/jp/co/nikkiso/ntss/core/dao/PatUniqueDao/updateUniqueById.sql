update pat_unique
set
  in_out_visit_history_info = /*pat.in_out_visit_history_info*/null,
  up_date = to_timestamp(/* pat.up_date */null, 'YYYY-MM-DD HH24:MI:SS')
where
  pat_id = /*pat_id*/null
;
