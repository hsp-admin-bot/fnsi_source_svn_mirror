update ord_main
set
/*%if 0 == updateMode */
  /*%if null != indKurCd */
  ind_kur_cd = /*indKurCd*/0,
  ind_kur_name = /*indKurName*/null,
-- add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
  /*%if rstUpdFlg*/
  rst_kur_cd = /*indKurCd*/0,
  rst_kur_name = /*indKurName*/null,
  --9806 add ljx start
  is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end,
  --9806 add ljx end
  /*%end*/
-- add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
  /*%end*/
  ind_treat_start_time = /*indTreatStartTime*/'0000',
/*%end*/
/*%if null != indBedCd */
  ind_bed_cd = /*indBedCd*/0,
  ind_bed_name = /*indBedName*/null,
-- add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
/*%if rstUpdFlg*/
  rst_bed_cd = /*indBedCd*/0,
  rst_bed_name = /*indBedName*/null,
/*%end*/
-- add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
/*%end*/
  up_ind_user_id = /*indUserId*/null,
  up_user_id = /*updUserid*/null,
--   ind_schedule_user_info = jsonb_merge_recursive(
--       jsonb_merge_recursive(
--           jsonb_merge_recursive(
--               jsonb_merge_recursive(ind_schedule_user_info, jsonb_build_object('ind_user_first_name', /*indUserFirstName*/'null'::text)),
--               jsonb_build_object('ind_user_last_name', /*indUserLastName*/' '::text)), jsonb_build_object('ind_user_id', /*indUserId*/null)),
--       jsonb_build_object('upd_user_id', /*updUserid*/null)),
  -- modify by chamaojia 2023-07-31 [8547]「ind_kur_cd、ind_treat_start_time」の新規保存   --start
  ind_schedule_user_info = ind_schedule_user_info ||
                           jsonb_build_object('ind_user_first_name', /*indUserFirstName*/'null'::text,
                                              'ind_user_last_name', /*indUserLastName*/' '::text,
                                              'ind_user_id', /*indUserId*/null,
                                              'upd_user_id', /*updUserid*/null
                             -- add 10196 by kangjie 20240122 start
                               ,'upd_user_first_name', /*updUserFirstName*/'null'::text
                               ,'upd_user_last_name', /*updUserLastName*/' '::text
                             -- add 10196 by kangjie 20240122 end
-- //mod 10860 ind_schedule_user_infoのデータ不正 zhao start
--                                               , 'ind_kur_cd', ind_kur_cd
--                                               , 'ind_treat_start_time', ind_treat_start_time
                                              , 'ind_kur_cd_before', ind_kur_cd
                                              , 'ind_treat_start_time_before', ind_treat_start_time
-- //mod 10860 ind_schedule_user_infoのデータ不正 zhao end
                               ),
  -- modify by chamaojia 2023-07-31 [8547]「ind_kur_cd、ind_treat_start_time」の新規保存   --end
  up_date = CURRENT_TIMESTAMP
where
  ord_no in /*ordNoList*/(null)
;
