update ord_main
set
  ind_ind_comment_info = /*indIndCommentInfo*/'{}',
  rst_ind_comment_info = /*rstIndCommentInfo*/'{}',
-- delete by chamaojia 2024-01-23 [10196] No need to modify this content  --start    
--   ind_schedule_user_info = /*indScheduleUserInfo*/'{}',
-- delete by chamaojia 2024-01-23 [10196] No need to modify this content  --end
-- del 8277 周安寧 start
--   up_ind_user_id = /*up_ind_user_id*/null,
--   up_user_id = /*up_user_id*/null,
-- del 8277 周安寧 end
    --9806 add ljx start
  -- add by chamaojia 2024-01-23 [10196] To modify the "ind" information, the modification content needs to be added  --start
  /*%if isIndFlag*/
   up_ind_user_id = /*up_ind_user_id*/null,
   up_user_id = /*up_user_id*/null,
  /*%end*/
  -- add by chamaojia 2024-01-23 [10196] To modify the "ind" information, the modification content needs to be added  --end
  /*%if rstUpdFlg*/
   is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end,
  /*%end*/
  --9806 add ljx end
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ord_no*/'-1'
