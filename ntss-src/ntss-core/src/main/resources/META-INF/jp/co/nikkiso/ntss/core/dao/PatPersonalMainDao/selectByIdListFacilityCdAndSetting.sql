select
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
  personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
  personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
  personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
  personal_info_decrypt(pat_birth_name) as pat_birth_name,
  personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
  personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info,
  personal_info_decrypt_jsonb(other_contact_info) as other_contact_info,
  personal_info_decrypt_jsonb(vendor_contact_info) as vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  personal_info_decrypt(remote_monitor_user_id) as remote_monitor_user_id,
  personal_info_decrypt(remote_monitor_user_pw) as remote_monitor_user_pw
from
  pat_personal_main
where
  is_del = '0'
  and facility_cd = /*facilityCd*/'0'
/*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
/*%end*/
--- 2: 死亡, 3: 転出, 離脱, 移植, 拒否・不明
/*%if simpleSearchConditions != 0 */
  /*%if simpleSearchConditions == 1 */
    and (in_out_class not in (2) or in_out_class is null)
  /*%else*/
    and (in_out_class not in (2, 3) or in_out_class is null)
  /*%end*/
/*%end*/
order by
  -- mod 7523 「対象患者の並び順が不正」について、対応する。 dengshen start
  -- pat_id
  -- mod 7523 「対象患者の並び順が不正」について、対応する。 dengshen end
  -- #8587:患者リストのソート変更による修正 start
  -- hosp_pat_id
  case
  when pat_last_name_kana is null AND pat_first_name_kana is null then concat(pat_last_name,pat_first_name)
  when pat_last_name_kana is null then concat(pat_last_name,pat_first_name_kana)
  when pat_first_name_kana is null then concat(pat_last_name_kana,pat_first_name)
  else concat(pat_last_name_kana,pat_first_name_kana)
  end
  -- #8587:患者リストのソート変更による修正 end
;
