DELETE FROM mst_facility where facility_cd in ('1001', '1002', '1003', '9999');
INSERT INTO
  mst_facility
  (
    facility_cd
    , facility_name
  )
VALUES
  (
    '1001'
    , 'sisetu1'
  )
  , (
    '1002'
    , 'sisetu2'
  )
  , (
    '1003'
    , 'sisetu3'
  )
;

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
    '1001'
    , 'mst_round_type'
    , '{"items": [ {"code": 1, "name": "name1"}, {"code": 5, "name": "name5"}, {"code": 4, "name": "name4"} ]}'
  ),
  (
    '1002'
    , 'mst_round_type'
    , '{"items": [ {"code": 2, "name": "name2"}, {"code": 6, "name": "name6"}, {"code": 3, "name": "name3"} ]}'
  ),
  (
    '1003'
    , 'mst_round_type'
    , '{"items": []}'
  )
;

TRUNCATE TABLE mst_round_type;
INSERT INTO
  mst_round_type
  (
    round_type_cd
    , facility_cd
    , round_type_name
    , content
    , is_content_omission
    , comment_post_default
    , posting_class_default
    , is_disp
    , is_del
  )
VALUES
  (
    1
    , '1001'
    , 'name1'
    , 'content1'
    , '0'
    , '0'
    , '1'
    , '0'
    , '0'
  )
  , (
    2
    , '1001'
    , 'name2'
    , 'content2'
    , '0'
    , '0'
    , '1'
    , '1'
    , '0'
  )
  , (
    3
    , '1001'
    , 'name3'
    , 'content3'
    , '0'
    , '1'
    , '0'
    , '0'
    , '1'
  )
  , (
    4
    , '1001'
    , 'name4'
    , 'content4'
    , '0'
    , '1'
    , '0'
    , '0'
    , '0'
  )
  , (
    5
    , '1001'
    , 'name5'
    , 'content5'
    , '1'
    , '0'
    , '1'
    , '0'
    , '0'
  )
  , (
    6
    , '1001'
    , 'name6'
    , 'content6'
    , '0'
    , '0'
    , '1'
    , '0'
    , '0'
  )
  , (
    7
    , '1003'
    , 'name7'
    , 'content7'
    , '0'
    , '0'
    , '1'
    , '0'
    , '0'
  )
;
