update ord_main
set
  ind_tare_info =  jsonb_merge_recursive(ind_tare_info::jsonb, /*tareInfo*/'{}'::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/'1'