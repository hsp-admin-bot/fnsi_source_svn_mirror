update ord_main
set
-- mod 10443 身体情報・DW・目標体重バグ 関  start
  -- modify by chamaojia 2023-11-29 [9973] A針/V針とSN針の排他的修正  start
--   ind_cond_info = jsonb_merge_recursive(ind_cond_info::jsonb, /*rst_info*/'{}'::jsonb)
  ind_cond_info = (jsonb_merge_recursive(ind_cond_info::jsonb, /*rst_info*/'{}'::jsonb)-'39')::jsonb
  /*%if needExcludeItem != null */
      - /*needExcludeItem*/'{}'::text[]
  /*%end */,
--   rst_cond_info = jsonb_merge_recursive(rst_cond_info::jsonb, /*rst_info*/'{}'::jsonb)
  rst_cond_info = (jsonb_merge_recursive(rst_cond_info::jsonb, /*rst_info*/'{}'::jsonb)-'39')::jsonb
  /*%if needExcludeItem != null */
      - /*needExcludeItem*/'{}'::text[]
  /*%end */,
  -- modify by chamaojia 2023-11-29 [9973] A針/V針とSN針の排他的修正  end
--   mod 10443 身体情報・DW・目標体重バグ 関  end
-- add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.13(外結)対応 韓 start
  rst_dw =
    case
    when /*rst_info*/'{}'::json->'39' is not null then
      (/*rst_info*/'{}'::json#>>'{39,value}')::float
    else
      rst_dw
    end,
-- add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.13(外結)対応 韓 end
  --9806 add ljx start
  is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end,
  --9806 add ljx end
  up_date = CURRENT_TIMESTAMP
where
  /*%for ord : ord_no*/
  ord_no = /*ord*/-1
    /*%if ord_has_next */
  /*# "or" */
    /*%end*/
  /*%end*/
