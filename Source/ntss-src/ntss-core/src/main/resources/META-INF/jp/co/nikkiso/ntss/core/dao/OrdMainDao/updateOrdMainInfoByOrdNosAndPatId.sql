update ord_main
set
  ind_va_cd =
    case
    when /*ord_info*/'{}'::json->'2' is not null then
      (/*ord_info*/'{}'::json#>>'{2,value}')::integer
    else
      ind_va_cd
    end,
    ind_dw =
    case
    when /*ord_info*/'{}'::json->'39' is not null then
      (/*ord_info*/'{}'::json#>>'{39,value}')::float
    else
      ind_dw
    end,
--     add 10443 身体情報・DW・目標体重バグ 関 start
    ind_dw_user_info =
    case
    when /*ord_info*/'{}'::json->'39' is not null then
    jsonb_merge_recursive(ind_dw_user_info::jsonb, /*indDwUserInfo*/'{}'::jsonb)
     else
      ind_dw_user_info
    end,
--     add 10443 身体情報・DW・目標体重バグ 関 end
  ind_cond_info = (WITH DATA1 AS ( SELECT KEY, VALUE FROM jsonb_each ( ind_cond_info ) ), DATA2 AS ( SELECT KEY, VALUE FROM jsonb_each ( /*ord_info*/'{}'::jsonb) )
  select jsonb_merge_recursive(ind_cond_info, COALESCE((SELECT jsonb_object_agg ( KEY, VALUE ) FROM DATA2 WHERE KEY IN ( SELECT KEY FROM DATA1 )), '{}'::jsonb)))
  ,

    /*%if up_ind_user_id != null */
    up_ind_user_id = /*up_ind_user_id*/null,
    /*%end */

    /*%if up_user_id != null */
    up_user_id = /*up_user_id*/null,
    /*%end */

  up_date = CURRENT_TIMESTAMP
where
  ord_no in /*ord_no*/(0)
   and ord_no NOT IN (select ord_no from ord_main ord INNER JOIN mst_treatment mst on ord.ind_treatment_cd = mst.treatment_cd and mst.device_mode != 6 and mst.device_mode != 10
   where pat_id =  /*patId*/null )
