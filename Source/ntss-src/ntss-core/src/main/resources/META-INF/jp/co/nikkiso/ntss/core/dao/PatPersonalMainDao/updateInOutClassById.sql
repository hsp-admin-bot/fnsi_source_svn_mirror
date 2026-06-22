update pat_personal_main
set
  in_out_class = /* in_out_class */null,
  up_date = to_timestamp(/* pat.up_date */null, 'YYYY-MM-DD HH24:MI:SS')
where
  pat_id = /*pat_id*/null
;