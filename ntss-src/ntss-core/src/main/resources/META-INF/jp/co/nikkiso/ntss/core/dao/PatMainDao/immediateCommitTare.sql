update pat_main
set
  tare_info =  jsonb_merge_recursive(tare_info::jsonb, /*tareInfo*/'{}'::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /*patId*/'1'