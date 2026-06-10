DELETE FROM mst_personal_user
WHERE facility_cd = 'F_hQ03';

INSERT INTO mst_personal_user (
  user_id
, facility_cd
, user_type
, user_last_name
, user_first_name
, user_last_name_kana
, user_first_name_kana
, user_last_name_alpha
, user_first_name_alpha
, user_email_address_1
, user_email_address_2
, extension_no
, home_no
, mobile_phone_no
, fax_no
, zipcd_3
, zipcd_4
, address
, address_kana
, job_cd
, reg_date
, up_date
, administrator
, is_disp
, is_del
, in_hospital_cd_1
, in_hospital_cd_2
, info_disp_to_admin
, anesthesiologist_license_no
) values (
  999
, 'F_hQ03'
, 0
, personal_info_encrypt('ああああ')
, personal_info_encrypt('いいいい')
, personal_info_encrypt('アアアア')
, personal_info_encrypt('イイイイ')
, personal_info_encrypt('AAAA')
, personal_info_encrypt('IIII')
, personal_info_encrypt('mail1@example.com')
, personal_info_encrypt('mail2@example.com')
, personal_info_encrypt('1020')
, personal_info_encrypt('033-AAAA-AAAA')
, personal_info_encrypt('090-XXXX-XXXX')
, personal_info_encrypt('033-YYYY-YYYY')
, personal_info_encrypt('001')
, personal_info_encrypt('0011')
, personal_info_encrypt('東京都千代田区霞が関')
, personal_info_encrypt('トウキョウトチヨダクカスミガセキ')
, personal_info_encrypt('KK')
, '20200803'
, '20200803'
, '1'
, '1'
, '0'
, 'TEX-ENG_001'
, '0000'
, '1'
, personal_info_encrypt('311-46-2210')
);

