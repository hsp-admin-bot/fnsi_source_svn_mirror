update
  ord_main
set
  rst_weight_info = COALESCE(rst_weight_info, '{}') ||  ('{"water_removal_target": ' || /*waterRemovalTarget*/'null' || '}') :: jsonb,
  up_date = current_timestamp
where
  ord_no = /*ordNo*/1
;
