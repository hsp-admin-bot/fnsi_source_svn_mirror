update ord_main
set
  ind_off_water_info =  jsonb_merge_recursive(ind_off_water_info::jsonb, /*offWaterInfo*/'{}'::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/'1'