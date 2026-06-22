DELETE FROM sys_data_set;

INSERT INTO
  sys_data_set
  (
    sql_cd
    , "sql"
    , db_class
    , detail
    , use_application
    , reg_date
    , up_date
  )
VALUES
  (
    1
    , 'select * from ord_main where pat_id = @pat_id order by ord_no'
    , 2
    , '[{"data_code": "pat_id", "field_name": "pat_id"}, {"data_code": "facility_cd", "field_name": "facility_cd"}]'
    , ' { "applications" : [1, 2] } '
    , '2019-05-29 17:24:00.000'
    , '2019-05-29 17:25:00.000'
  )
  ,(
    2
    , 'select * from pat_personal_main where pat_id = @pat_id'
    , 3
    , '[{"data_code": "pat_id", "field_name": "pat_id"}, {"data_code": "facility_cd", "field_name": "facility_cd"}]'
    , '{ "test" : 1 }'
    , '2019-05-29 17:24:00.000'
    , '2019-05-29 17:25:00.000'
  )
  ,(
    3
    , 'select * from mst_user_authentication where user_id = @user_id'
    , 1
    , '[{"data_code": "sql_cd", "field_name": "sql_cd"}, {"data_code": "sql", "field_name": "sql"}]'
    ,null
    , '2020-03-16 13:00:00.000'
    , '2020-03-16 13:05:00.000'
  )
  ,(
    4
    , 'select * from pat_personal_main where pat_id = @pat_id'
    , 4
    , '[{"data_code": "sql_cd", "field_name": "sql_cd"}, {"data_code": "sql", "field_name": "sql"}]'
    ,null
    , '2020-03-16 13:00:00.000'
    , '2020-03-16 13:05:00.000'
  )
  ,(
    5
    , ''
    , 2
    , '[{"data_code": "pat_id", "field_name": "pat_id"}, {"data_code": "facility_cd", "field_name": "facility_cd"}]'
    ,null
    , '2019-05-29 17:24:00.000'
    , '2019-05-29 17:25:00.000'
  )
  ,(
    6
    , '不正なSQL'
    , 3
    , '[{"data_code": "sql_cd", "field_name": "sql_cd"}, {"data_code": "sql", "field_name": "sql"}]'
    ,null
    , '2020-03-16 13:00:00.000'
    , '2020-03-16 13:05:00.000'
  )
;

DELETE FROM ord_main;

INSERT INTO
  ord_main
  (
    ord_no
    , pat_id
    , facility_cd
    , is_del
    , up_date
    , reg_date
  )
VALUES
  (
    1
    , 10
    , '009999'
    , '0'
    , '2019-05-29 17:24:00.000'
    , '2019-05-29 17:25:00.000'
  )
  ,(
    2
    , 10
    , '009999'
    , '0'
    , '2019-05-29 17:24:00.000'
    , '2019-05-29 17:25:00.000'
  )
;
