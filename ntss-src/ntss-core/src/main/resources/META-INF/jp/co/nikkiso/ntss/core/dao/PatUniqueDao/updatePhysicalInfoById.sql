update pat_unique
set
  -- pat_id = /* pat.pat_id */null,
  physical_info = /*pat.physical_info*/null,
  up_date = to_timestamp(/* pat.up_date */null, 'YYYY-MM-DD HH24:MI:SS')
  --reg_date = /* pat.reg_date */null
where
  pat_id = /*pat_id*/null
;