-- 保持 add 10389 患者リストのソートが遅い gjn start
select
  pat_id,
  pat_birthday,
  in_out_class,
  hosp_pat_id,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  pat_blood_type_abo,
  -- add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm start
  pat_blood_type_rh,
  pat_blood_type_serovar,
  -- add #11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない　V1.0B zkm end
  pat_sex,
  severity_cd,
  transport_cd,
  dial_diff_com_info
from
  pat_personal_main
where
  is_del = '0'
  and facility_cd = /*facilityCd*/''
/*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
/*%end*/
order by
  lpad(hosp_pat_id, 12, '0')
  ,hosp_pat_id desc
;
-- 保持 add 10389 患者リストのソートが遅い gjn end
