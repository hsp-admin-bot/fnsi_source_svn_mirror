update pat_main
set
  off_water_info =  jsonb_merge_recursive(off_water_info::jsonb, /*offWaterInfo*/'{}'::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /*patId*/'1'