update
  ord_main
set
  rst_weight_info = /*entity.rstWeightInfo*/null
  , rst_tare_info = /*entity.rstTareInfo*/null
  , rst_off_water_info = /*entity.rstOffWaterInfo*/null
  , rst_dw = /*entity.rstDw*/null
  , is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end
  , up_date = /*entity.upDate*/'2000-01-01 00:00:00'
-- del 8277 周安寧 start
--   , up_user_id = /*entity.upUserId*/null
-- del 8277 周安寧 end
where
  ord_no = /*ordNo*/1
  and is_del = '0'
;
