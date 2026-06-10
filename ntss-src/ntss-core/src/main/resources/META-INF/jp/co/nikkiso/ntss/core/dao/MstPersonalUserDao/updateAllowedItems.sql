update
  mst_personal_user
set
  user_last_name_kana = personal_info_encrypt(/*entity.userLastNameKana*/'1'),
  user_first_name_kana = personal_info_encrypt(/*entity.userFirstNameKana*/'1'),
  user_last_name_alpha = personal_info_encrypt(/*entity.userLastNameAlpha*/'1'),
  user_first_name_alpha = personal_info_encrypt(/*entity.userFirstNameAlpha*/'1'),
  user_email_address_1 = personal_info_encrypt(/*entity.userEmailAddress1*/'1'),
  user_email_address_2 = personal_info_encrypt(/*entity.userEmailAddress2*/'1'),
  extension_no = personal_info_encrypt(/*entity.extensionNo*/'1'),
  in_hospital_cd_1 = /*entity.inHospitalCd_1*/null,
  in_hospital_cd_2 = /*entity.inHospitalCd_2*/null,
  up_date = /*entity.upDate*/'2000-01-01 00:00:00'
where
  user_id = /*entity.userId*/1
;
