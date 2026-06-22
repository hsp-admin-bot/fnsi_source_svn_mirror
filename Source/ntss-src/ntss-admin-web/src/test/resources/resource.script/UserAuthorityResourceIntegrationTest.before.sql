INSERT INTO mst_user
  (
    user_id
    , user_settings
    , is_provisional
    , reg_date
    , up_date
    , is_disp
    , is_del
  )
VALUES
  (
    2
    , '{"theme": 0, "authorized_authorities": ["001", "002", "003"]}'
    , 0
    , NULL
    , NULL
    , '1'
    , '0'
  ),(
    3
    , '{"theme": 0, "authorized_authorities": ["201", "202", "203"]}'
    , 0
    , NULL
    , NULL
    , '1'
    , '0'
  )
;
