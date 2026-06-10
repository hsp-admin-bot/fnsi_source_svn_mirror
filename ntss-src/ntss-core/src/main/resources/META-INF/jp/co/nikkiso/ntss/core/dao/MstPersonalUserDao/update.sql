update
  mst_personal_user
set
  user_last_name = personal_info_encrypt(/*entity.userLastName*/'1'),
  user_first_name = personal_info_encrypt(/*entity.userFirstName*/'1'),
  user_last_name_kana = personal_info_encrypt(/*entity.userLastNameKana*/'1'),
  user_first_name_kana = personal_info_encrypt(/*entity.userFirstNameKana*/'1'),
  user_last_name_alpha = personal_info_encrypt(/*entity.userLastNameAlpha*/'1'),
  user_first_name_alpha = personal_info_encrypt(/*entity.userFirstNameAlpha*/'1'),
  user_email_address_1 = personal_info_encrypt(/*entity.userEmailAddress1*/'1'),
  user_email_address_2 = personal_info_encrypt(/*entity.userEmailAddress2*/'1'),
  extension_no = personal_info_encrypt(/*entity.extensionNo*/'1'),
  home_no = personal_info_encrypt(/*entity.homeNo*/'1'),
  mobile_phone_no = personal_info_encrypt(/*entity.mobilePhoneNo*/'1'),
  fax_no = personal_info_encrypt(/*entity.faxNo*/'1'),
  zipcd_3 = personal_info_encrypt(/*entity.zipcd3*/'1'),
  zipcd_4 = personal_info_encrypt(/*entity.zipcd4*/'1'),
  address = personal_info_encrypt(/*entity.address*/'1'),
  address_kana = personal_info_encrypt(/*entity.addressKana*/'1'),
  job_cd = personal_info_encrypt(/*entity.jobCd*/'1'),
  up_date = /*entity.upDate*/'2000-01-01 00:00:00',
  anesthesiologist_license_no = personal_info_encrypt(/*entity.anesthesiologistLicenseNo*/'1'),
  in_hospital_cd_1 = /*entity.inHospitalCd_1*/null,
  in_hospital_cd_2 = /*entity.inHospitalCd_2*/null,
  info_disp_to_admin = /*entity.infoDispToAdmin*/'0'
where
  user_id = /*entity.userId*/1
;
