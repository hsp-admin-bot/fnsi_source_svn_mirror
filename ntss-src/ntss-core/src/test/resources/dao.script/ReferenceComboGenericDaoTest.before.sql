TRUNCATE TABLE mst_test_table;
INSERT INTO
  mst_test_table
  (
    facility_cd
    , die_cd
    , die_name
    , memo
    , test_numeric
  )
VALUES
  (
    'cd1'
    ,1
    , 'name1'
    , 'memo1'
    , 11
  ),
  (
    'cd2'
    , 2
    , 'name2'
    , 'memo2'
    , 22
  ),
  (
    'cd3'
    , 3
    , 'name3'
    , 'memo3'
    , 33
  ),
  (
    'cd4'
    , 4
    , 'name4'
    , 'memo4'
    , 44
  ),
  (
    'cd5'
    , 5
    , 'name5'
    , 'memo5'
    , 55
  )
;
