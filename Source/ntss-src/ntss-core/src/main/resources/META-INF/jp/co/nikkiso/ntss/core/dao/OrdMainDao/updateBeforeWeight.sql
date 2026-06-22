update ord_main
set
  rst_weight_info = jsonb_merge_recursive(COALESCE(rst_weight_info, '{}'), /*weightInfo*/'{}'::jsonb),
  rst_tare_info = jsonb_merge_recursive(COALESCE(rst_tare_info, '{}'), /*tareInfo*/'{}'::jsonb),
  rst_off_water_info = jsonb_merge_recursive(COALESCE(rst_off_water_info, '{}'), /*offWaterInfo*/'{}'::jsonb),
  rst_accept_date = /*rstAcceptDate*/null,
  ind_dw = /*dw*/null,
  rst_dw = /*dw*/null,
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0
;
