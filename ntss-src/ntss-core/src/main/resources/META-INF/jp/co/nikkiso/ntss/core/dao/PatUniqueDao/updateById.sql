update pat_unique
set
  -- pat_id = /* pat.pat_id */null,
  medical_hst_info = /*pat.medical_hst_info*/null,
  in_out_visit_history_info = /*pat.in_out_visit_history_info*/null,
  physical_info = /*pat.physical_info*/null,
  up_date = to_timestamp(/* pat.up_date */null, 'YYYY-MM-DD HH24:MI:SS')
  --reg_date = /* pat.reg_date */null
where
  pat_id = /*pat_id*/null
;