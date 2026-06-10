update ord_main
set
  ind_va_cd =
    case
    when /*ord_info*/'{}'::json->'2' is not null then
      (/*ord_info*/'{}'::json#>>'{2,value}')::integer
    else
      ind_va_cd
    end,
-- add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.13(外結)対応 韓 start
    ind_dw =
    case
    when /*ord_info*/'{}'::json->'39' is not null then
      (/*ord_info*/'{}'::json#>>'{39,value}')::float
    else
      ind_dw
    end,
-- add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.13(外結)対応 韓 end
-- modify by chamaojia 2023-10-27 [9973] A針/V針とSN針の排他的修正  start
  ind_cond_info = jsonb_merge_recursive(ind_cond_info::jsonb, /*ord_info*/'{}'::jsonb)
  /*%if needExcludeItem != null */
   - /*needExcludeItem*/'{}'::text[]
  /*%end */
  ,
-- modify by chamaojia 2023-10-27 [9973] A針/V針とSN針の排他的修正  end

    /*%if up_ind_user_id != null */
    up_ind_user_id = /*up_ind_user_id*/null,
    /*%end */

    /*%if up_user_id != null */
    up_user_id = /*up_user_id*/null,
    /*%end */

  up_date = CURRENT_TIMESTAMP
where
  /*%for ord : ord_no*/
  ord_no = /*ord*/-1
    /*%if ord_has_next */
  /*# "or" */
    /*%end*/
  /*%end*/
