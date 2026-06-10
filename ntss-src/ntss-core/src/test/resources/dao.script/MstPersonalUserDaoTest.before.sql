TRUNCATE TABLE mst_personal_user;
INSERT INTO "mst_personal_user"("user_id","facility_cd","user_type","administrator","user_last_name","user_first_name","user_last_name_kana","user_first_name_kana","user_last_name_alpha","user_first_name_alpha","user_email_address_1","user_email_address_2","extension_no","home_no","mobile_phone_no","fax_no","zipcd_3","zipcd_4","address","address_kana","job_cd","reg_date","up_date")
VALUES
(3,E'999900',0,0,E'cd2f4bcd533fd1470b',E'cb4955d3071d',NULL,NULL,NULL,NULL,E'e8cae6e86680cae6da5cc6de5cd4e0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,E'6062',E'2018-06-11 10:26:57.68',E'2018-11-22 15:59:58.609'),
(7,E'009997',1,1,E'c7070dc70573c70711',E'cb4955d3071d',E'c70545c70557c7054dc70767c70711c70731c70767c7056fc7074bc7054d',E'c7070dc70573c70711',NULL,NULL,E'e4f2dee6ead6ca5cd0c2f2c2e6d0d280cae6da5cc6de5cd4e0',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,E'6062',E'2018-06-11 10:26:57.68',E'2018-11-22 15:59:58.609');

-- selectById
INSERT INTO mst_personal_user (user_id, facility_cd, user_type, administrator, user_last_name, user_first_name, user_last_name_kana, user_first_name_kana, user_last_name_alpha, user_first_name_alpha, user_email_address_1, user_email_address_2, extension_no, home_no, mobile_phone_no, fax_no, zipcd_3, zipcd_4, address, address_kana, job_cd, reg_date, up_date)
VALUES
(11, 'test', 0, 0,
 personal_info_encrypt('lastName'),
 personal_info_encrypt('firstName'),
 personal_info_encrypt('lastNameKana'),
 personal_info_encrypt('firstNameKana'),
 personal_info_encrypt('lastNameAlpha'),
 personal_info_encrypt('firstNameAlpha'),
 personal_info_encrypt('emailAddress1@abc.jp'),
 personal_info_encrypt('emailAddress2@xxx.org'),
 personal_info_encrypt('extensionNo'),
 personal_info_encrypt('homeNo'),
 personal_info_encrypt('mobilePhoneNo'),
 personal_info_encrypt('faxNo'),
 personal_info_encrypt('001'),
 personal_info_encrypt('0001'),
 personal_info_encrypt('address'),
 personal_info_encrypt('addressKana'),
 personal_info_encrypt('01'),
 '2018-05-25 17:16:55', '2018-08-22 17:19:19.405'),
(12, '909090', 1, 1,
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 personal_info_encrypt('00'),
 '2000-01-01 00:00:00', '2000-01-01 00:00:00')
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_personal_user
ADD COLUMN dummy character varying(1) -- ダミー列
;
