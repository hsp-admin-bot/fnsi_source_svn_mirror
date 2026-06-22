update ord_main
set
  rst_tare_info = jsonb_merge_recursive(COALESCE(rst_tare_info, '{}'), /*jsonTareValue*/'{}'::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ord_no*/0
;