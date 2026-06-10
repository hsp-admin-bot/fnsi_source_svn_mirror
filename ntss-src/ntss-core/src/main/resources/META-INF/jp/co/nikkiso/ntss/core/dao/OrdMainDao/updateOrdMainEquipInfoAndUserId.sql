update ord_main
set
  ind_equip_info = /*indEquipInfo*/'{}',
  rst_equip_info = /*rstEquipInfo*/'{}',
-- delete by chamaojia 2024-01-23 [10196] No need to modify this content  --start
--   ind_schedule_user_info = /*indScheduleUserInfo*/'{}',
-- delete by chamaojia 2024-01-23 [10196] No need to modify this content  --end
  up_ind_user_id = /*up_ind_user_id*/null,
  up_user_id = /*up_user_id*/null,
  --9806 add ljx start
  /*%if rstUpdFlg*/
   is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end,
  /*%end*/
  --9806 add ljx end
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ord_no*/'-1'
