update ord_main
set
/*%if null != jsonOffWaterValue*/
  rst_off_water_info = jsonb_merge_recursive(COALESCE(rst_off_water_info, '{}'), /*jsonOffWaterValue*/'{}'::jsonb),
/*%end*/
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ord_no*/0
;