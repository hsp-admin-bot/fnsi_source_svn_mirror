update ord_main
set
  rst_weight_info = rst_weight_info::jsonb || json_build_object(
    'weight_after',CAST(/*weightAfter*/NULL AS NUMERIC),
    'weight_after_date',CAST(/*afterDate*/NULL AS TEXT)
  )::jsonb, 
  up_date = CURRENT_TIMESTAMP
where 
  ord_no = /*ordNo*/0
;