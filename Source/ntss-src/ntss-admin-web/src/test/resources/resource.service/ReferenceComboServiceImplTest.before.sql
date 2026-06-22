TRUNCATE TABLE mst_selector;
INSERT INTO
  mst_selector
  (
    facility_cd
    , master_physical_name
    , order_settings
  )
VALUES
  (
    '001'
    , 'mst_test_table'
    , '{"items": [ {"code": 1, "name": "name1"}, {"code": 5, "name": "name5"}, {"code": 4, "name": "name4"} ]}'
  ),
  (
    '002'
    , 'mst_m_notice'
    , '{"items": []}'
  )
;

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

TRUNCATE TABLE mst_m_notice;
