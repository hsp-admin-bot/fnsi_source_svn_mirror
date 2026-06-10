-- add 9664 by kangjie 20240425 start
update ord_main
set
  ind_cond_info = jsonb_merge_recursive(ind_cond_info::jsonb, /*fluidJSONString*/'{}'::jsonb),
    /*%if up_ind_user_id != null */
    up_ind_user_id = /*up_ind_user_id*/null,
    /*%end */
    /*%if up_user_id != null */
    up_user_id = /*up_user_id*/null,
    /*%end */
  up_date = CURRENT_TIMESTAMP
where
  ord_no  in /*ordNos*/('0')
;

-- add 9664 by kangjie 20240425 end
