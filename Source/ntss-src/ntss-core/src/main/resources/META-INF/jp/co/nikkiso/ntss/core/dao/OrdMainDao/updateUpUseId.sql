update ord_main
set
  up_ind_user_id = /*up_ind_user_id*/null,
  up_user_id = /*up_user_id*/null,
  up_date = CURRENT_TIMESTAMP
where
  -- ord_no in /*ordNoList*/(null)
  ord_no = /*ordNo*/null
;
