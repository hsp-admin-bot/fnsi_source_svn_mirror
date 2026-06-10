TRUNCATE TABLE mst_personal_user;
INSERT INTO
  mst_personal_user
  (
    user_id
    , facility_cd
    , user_type
    , user_last_name
    , user_first_name
    , user_email_address_1
    , user_email_address_2
    , job_cd
    , is_del
  )
VALUES
  (
    1
    , '0001'
    , 0
    , personal_info_encrypt('lastName1')
    , personal_info_encrypt('firstName1')
    , personal_info_encrypt('email_address1_1')
    , personal_info_encrypt('email_address1_1')
    , personal_info_encrypt('anything good')
    , '0'
  )
  ,(
    2
    , '0001'
    , 0
    , personal_info_encrypt('lastName2')
    , personal_info_encrypt('firstName2')
    , personal_info_encrypt('email_address1_2')
    , personal_info_encrypt(null)
    , personal_info_encrypt('anything good')
    , '0'
  )
  ,(
    3
    , '0001'
    , 0
    , personal_info_encrypt('lastName3')
    , personal_info_encrypt('firstName3')
    , personal_info_encrypt('email_address1_3')
    , personal_info_encrypt(null)
    , personal_info_encrypt('anything good')
    , '0'
  )
  ,(
    4
    , '9999'
    , 0
    , personal_info_encrypt('last_name_4')
    , personal_info_encrypt('first_name_4')
    , personal_info_encrypt('email_address1_4')
    , personal_info_encrypt('email_address2_4')
    , personal_info_encrypt('anything good')
    , '0'
  )
;
