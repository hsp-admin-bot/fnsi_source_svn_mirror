INSERT INTO mst_personal_user
  (user_id, facility_cd, user_type, user_last_name, user_first_name, user_email_address_1, job_cd)
VALUES
  (900000000001,
   '900001',
   0,
   personal_info_encrypt('lastName'),
   personal_info_encrypt('firstName'),
   personal_info_encrypt('emailAddress1@abc.jp'),
   personal_info_encrypt('01'))
;
