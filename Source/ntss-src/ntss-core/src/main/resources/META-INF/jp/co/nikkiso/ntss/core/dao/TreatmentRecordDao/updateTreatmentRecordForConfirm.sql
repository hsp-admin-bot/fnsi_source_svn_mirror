update
  ord_main
set
  /*%if confirm == "1"*/
  rst_edition = case when rst_dialysis_state = '6' then rst_edition + 1 else rst_edition end,
  /*%end*/
  is_confirm = /*confirm*/'1'
  , up_date = CURRENT_TIMESTAMP
  , cur_edition_date = CURRENT_TIMESTAMP
-- del #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou start
--     mod FNSI-7531 劉全航 start
--     /*%if updStaffId != null*/
--   , up_user_id = /*updStaffId*/null
--     /*%end*/
--     mod FNSI-7531 劉全航 end
-- del #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou end
where
  ord_no = /*ordNo*/1
;
