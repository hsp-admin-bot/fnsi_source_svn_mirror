CREATE TABLE
  test_table_has_a_record
(
  key1 bigserial
  , col1_1 character varying(10)
  , col1_2 integer
)
;
INSERT INTO
  test_table_has_a_record
(
  key1
  , col1_1
  , col1_2
)
VALUES
(
  1
  , 'record1-1'
  , 111
)
;

CREATE TABLE
  test_table_has_some_records
(
  key2 bigserial
  , col2_1 character varying(10)
  , col2_2 integer
)
;
INSERT INTO
  test_table_has_some_records
(
  key2
  , col2_1
  , col2_2
)
VALUES
(
  11
  , 'record2-1'
  , 101
)
,(
  12
  , 'record2-2'
  , 102
)
,(
  13
  , 'record2-3'
  , 103
)
,(
  14
  , 'record2-4'
  , 104
)
;

CREATE TABLE
  test_table_has_no_records
(
  key3 bigserial
  , col3_1 character varying(10)
  , col3_2 integer
)
;

CREATE TABLE
  test_table_not_present_at_mst_selector
(
  key4 bigserial
  , col4_1 character varying(10)
  , col4_2 integer
)
;

-- mst_selectorに上記3テーブルを追加
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
    '000001'
    , 'test_table_has_a_record'
    , '{"items": [ {"code": 1, "name": "record1-1"} ]}'
  ),
  (
    '000001'
    , 'test_table_has_some_records'
    , '{"items": [ {"code": 11, "name": "record2-1"}, {"code": 12, "name": "record2-2"}, {"code": 14, "name": "record2-4"}]}'
  ),
  (
    '000022'
    , 'test_table_has_some_records'
    , '{"items": [ {"code": 14, "name": "record2-4"}, {"code": 13, "name": "record2-3"}]}'
  ),
  (
    '000001'
    , 'test_table_has_no_records'
    , '{"items": []}'
  )
;
