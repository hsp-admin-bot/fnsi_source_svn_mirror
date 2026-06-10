-- 利用者マスタ
TRUNCATE TABLE mst_personal_user;
INSERT INTO
  mst_personal_user
  (
    user_id
    , facility_cd
    , user_type
    , user_last_name
    , user_first_name
    , job_cd
    , is_del
  )
VALUES
  (
    11
    , '009999'
    , 0
    , personal_info_encrypt('lastName11')
    , personal_info_encrypt('firstName11')
    , personal_info_encrypt('1')
    , '0'
  )
  ,(
    12
    , '009999'
    , 0
    , personal_info_encrypt('lastName12')
    , personal_info_encrypt('firstName12')
    , personal_info_encrypt('1')
    , '0'
  )
  ,(
    13
    , '009999'
    , 0
    , personal_info_encrypt('lastName13')
    , personal_info_encrypt('firstName13')
    , personal_info_encrypt('2')
    , '0'
  )
  ,(
    14
    , '009999'
    , 0
    , personal_info_encrypt('lastName13')
    , personal_info_encrypt('firstName13')
    , personal_info_encrypt('1')
    , '1'
  )
  ,(
    15
    , '999999'
    , 0
    , personal_info_encrypt('lastName15')
    , personal_info_encrypt('firstName15')
    , personal_info_encrypt('1')
    , '0'
  )
;
