-- ベッド移動時のデータ更新(メインスケジュール)
-- 治療日、クールコード、ベッドコードが変更されます
update ord_main
set
  treat_date = /*newTreatDate*/'',
  ind_kur_cd = /*kurCd*/0,
  ind_bed_cd = /*bedCd*/0,
  treat_week = EXTRACT(ISODOW FROM to_date(/*newTreatDate*/'error', 'yyyyMMdd')),
  -- mod 11206 治療開始時刻を標準開始時刻から変えた状態で治療状況マップでベッド未登録に変更すると治療開始時刻が標準開始時刻に変更される zrx start
--   ind_treat_start_time = (select substr(kur_standard_start_time,1,4) from mst_kur where kur_cd = /*kurCd*/0 and facility_cd = /*facilityCd*/'' and is_del = '0'),
  ind_treat_start_time =
      CASE WHEN ind_kur_cd <> /*kurCd*/0
          THEN (select substr(kur_standard_start_time,1,4) from mst_kur where kur_cd = /*kurCd*/0 and facility_cd = /*facilityCd*/'' and is_del = '0')
      ELSE ind_treat_start_time
      END,
  -- mod 11206 治療開始時刻を標準開始時刻から変えた状態で治療状況マップでベッド未登録に変更すると治療開始時刻が標準開始時刻に変更される zrx end
  -- rst_dialysis_state = '0',
  --指示者IDと更新者IDの更新(両方nullだと何もしない)
  -- modify by chamaojia 2023-07-31 [8547] 元のsql関数の書き方を変えて、「ind_kur_cd、ind_treat_start_time」の新規保存   --start  
--   /*%if updUserId != null */
--     /*%if indUserId != null */
--       --updUserId != null && indUserId != null なので 指示者ID、更新者IDを設定
--       ind_schedule_user_info = jsonb_merge_recursive(jsonb_merge_recursive(ind_schedule_user_info, jsonb_build_object('ind_user_id', /*indUserId*/null)), jsonb_build_object('upd_user_id', /*updUserId*/null)),
--     /*%else*/
--       --updUserId != null && indUserId == null なので 更新者IDのみの設定
--       ind_schedule_user_info = jsonb_merge_recursive(ind_schedule_user_info,  jsonb_build_object('upd_user_id', /*updUserId*/null)),
--     /*%end*/
--   /*%elseif indUserId != null*/
--       --updUserId == null && indUserId != null なので 指示者IDのみの設定
--       ind_schedule_user_info = jsonb_merge_recursive(ind_schedule_user_info, jsonb_build_object('ind_user_id', /*indUserId*/null)),
--   /*%end*/

  ind_schedule_user_info = ind_schedule_user_info ||
                           jsonb_build_object(
--                            mod 10860 ind_schedule_user_infoのデータ不正 zhao start
--                                'ind_kur_cd', ind_kur_cd,
--                                'ind_treat_start_time', ind_treat_start_time
--                                /*%if indUserId != null */
--                                , 'ind_user_id', /*indUserId*/null
--                                /*%end*/
--                                /*%if updUserId != null */
--                                , 'upd_user_id', /*updUserId*/null
--                                /*%end*/
                               'ind_kur_cd_before', ind_kur_cd,
                               'ind_treat_start_time_before', ind_treat_start_time
                               /*%if indUserId != null */
                               , 'ind_user_id', /*indUserId*/null
                               /*%end*/
                               /*%if updUserId != null */
                               , 'upd_user_id', /*updUserId*/null
                               /*%end*/
                               /*%if indUserLastName != null */
                               , 'ind_user_last_name', /*indUserLastName*/'null' ::text
                               /*%end*/
                               /*%if indUserFirstName != null */
                               , 'ind_user_first_name', /*indUserFirstName*/'null' ::text
                               /*%end*/
                               /*%if updUserLastName != null */
                               , 'upd_user_last_name', /*updUserLastName*/'null' ::text
                               /*%end*/
                               /*%if updUserFirstName != null */
                               , 'upd_user_first_name', /*updUserFirstName*/'null' ::text
                               /*%end*/
--                                mod 10860 ind_schedule_user_infoのデータ不正 zhao end
                               ),
  -- modify by chamaojia 2023-07-31 [8547] 元のsql関数の書き方を変えて、「ind_kur_cd、ind_treat_start_time」の新規保存   --end  
  up_date = transaction_timestamp(),
  -- mod FNSI 1006 395 スケジュール表 part 孫灝 20201211 start
  up_ind_user_id = /*indUserId*/null,
  up_user_id = /*updUserId*/null
  -- mod FNSI 1006 395 スケジュール表 part 孫灝 20201211 end
where
  ord_no = /*ordNo*/0
  and
  facility_cd = /*facilityCd*/''
  and
  treat_date = /*condTreatDate*/''
