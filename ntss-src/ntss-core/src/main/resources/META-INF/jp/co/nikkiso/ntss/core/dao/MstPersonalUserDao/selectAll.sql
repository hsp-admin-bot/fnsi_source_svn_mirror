select
  user_id,
  facility_cd,
  user_type,
  administrator,
  patient_shared,
  personal_info_decrypt(user_last_name) as user_last_name,
  personal_info_decrypt(user_first_name) as user_first_name,
  personal_info_decrypt(user_last_name_kana) as user_last_name_kana,
  personal_info_decrypt(user_first_name_kana) as user_first_name_kana,
  personal_info_decrypt(user_last_name_alpha) as user_last_name_alpha,
  personal_info_decrypt(user_first_name_alpha) as user_first_name_alpha,
  personal_info_decrypt(user_email_address_1) as user_email_address_1,
  personal_info_decrypt(user_email_address_2) as user_email_address_2,
  personal_info_decrypt(extension_no) as extension_no,
  personal_info_decrypt(home_no) as home_no,
  personal_info_decrypt(mobile_phone_no) as mobile_phone_no,
  personal_info_decrypt(fax_no) as fax_no,
  personal_info_decrypt(zipcd_3) as zipcd_3,
  personal_info_decrypt(zipcd_4) as zipcd_4,
  personal_info_decrypt(address) as address,
  personal_info_decrypt(address_kana) as address_kana,
  personal_info_decrypt(job_cd) as job_cd,
  in_hospital_cd_1,
  in_hospital_cd_2,
  info_disp_to_admin,
  personal_info_decrypt(anesthesiologist_license_no) as anesthesiologist_license_no,
  is_disp,
  is_del,
  reg_date,
  up_date,
  signin_date
from
  mst_personal_user
where
-- mod bug 6163 修正 chen start
  facility_cd = /* facilityCd */'0'
  --mod 11931 コンバートされた車いすマスタの重量校正者が登録されていない zkm start
--   and is_del = /* isDel */'0'
-- --   is_del = /* isDel */'0'
-- --   /*%if facilityCd != null */
-- --   And facility_cd = /* facilityCd */'0'
-- --   /*%end */
-- -- mod bug 6163 修正 chen end
-- --add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる zhou start
-- and is_disp = '1'
-- --add 8474 送信先グループマスタ詳細画面に表示される利用者の表示順が利用者マスタの表示順と異なる zhou end
  /*%if isDel.equals("0") */
  and is_del = '0'
  and is_disp = '1'
  /*%else*/
  and (is_del != '0' or is_disp != '1')
  /*%end*/
  --mod 11931 コンバートされた車いすマスタの重量校正者が登録されていない zkm end
  And user_type != '2'
order by user_id;
