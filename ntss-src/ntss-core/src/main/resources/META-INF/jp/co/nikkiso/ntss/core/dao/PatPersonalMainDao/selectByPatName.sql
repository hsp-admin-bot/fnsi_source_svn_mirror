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
  and facility_cd = /*facilityCd*/'000001'
  and
  (
    (
      pat_last_name = personal_info_encrypt(/*patLastName*/null)
      and pat_first_name = personal_info_encrypt(/*patFirstName*/null)
    )
--     mod FNSI-同姓同名のバグ修正 江 start
--      modify 同姓同名のバグ修正 maxueqiang,bug:5401 start
    /*%if null != patLastNameKana && null != patFirstNameKana*/
    or (
      pat_last_name_kana = personal_info_encrypt(/*patLastNameKana*/null)
      and pat_first_name_kana = personal_info_encrypt(/*patFirstNameKana*/null)
    )
    /*%end*/
    /*%if null != patLastNameAlpha && null != patFirstNameAlpha*/
    or (
      pat_last_name_alpha = personal_info_encrypt(/*patLastNameAlpha*/null)
      and pat_first_name_alpha = personal_info_encrypt(/*patFirstNameAlpha*/null)
    )
    /*%end*/
--     /*%if null != patLastNameKana*/
--     and pat_last_name_kana = personal_info_encrypt(/*patLastNameKana*/null)
--     /*%else*/
--     and pat_last_name_kana is null
--     /*%end*/
--     /*%if null != patFirstNameKana*/
--     and pat_first_name_kana = personal_info_encrypt(/*patFirstNameKana*/null)
--     /*%else*/
--     and pat_first_name_kana is null
--     /*%end*/
--     /*%if null != patLastNameAlpha*/
--     and pat_last_name_alpha = personal_info_encrypt(/*patLastNameAlpha*/null)
--     /*%else*/
--     and pat_last_name_alpha is null
--     /*%end*/
--     /*%if null != patFirstNameAlpha*/
--     and pat_first_name_alpha = personal_info_encrypt(/*patFirstNameAlpha*/null)
--     /*%else*/
--     and pat_first_name_alpha is null
--     /*%end*/
--     mod FNSI-同姓同名のバグ修正 江 end
  )
--    modify 同姓同名のバグ修正 maxueqiang,bug:5401 end
  /*%if null != selfPatId*/
  and pat_id <> /*selfPatId*/null
  /*%end*/
order by
  pat_id;
