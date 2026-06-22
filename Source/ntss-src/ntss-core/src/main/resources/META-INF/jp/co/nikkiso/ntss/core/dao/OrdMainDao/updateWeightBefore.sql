update ord_main
set
  rst_weight_info = rst_weight_info::jsonb || json_build_object(
    'weight_before',CAST(/*weightBefore*/NULL AS NUMERIC),
    'weight_before_date',CAST(/*beforeDate*/NULL AS TEXT)
  )::jsonb, 
  up_date = CURRENT_TIMESTAMP
where 
  ord_no = /*ordNo*/0
;