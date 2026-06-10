select
  user_id,
  facility_cd,
  user_type,
  administrator,
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
  reg_date,
  up_date
from
  mst_personal_user
where
  job_cd = personal_info_encrypt(/* jobCd */'')
/*%if facilityCd != null */
  And facility_cd = /* facilityCd */'0'
/*%end */
;
