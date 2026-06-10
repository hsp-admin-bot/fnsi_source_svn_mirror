update
  ord_main
set
  rst_equip_info = /*entity.rstEquipInfo*/null
  , is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end
  , up_date = /*entity.upDate*/'2000-01-01 00:00:00'
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
