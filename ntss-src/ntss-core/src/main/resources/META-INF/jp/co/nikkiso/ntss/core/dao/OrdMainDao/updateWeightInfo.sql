update ord_main
set
  rst_weight_info = jsonb_merge_recursive(COALESCE(rst_weight_info, '{}'), /*weightInfo*/'{}'::jsonb),
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0
;