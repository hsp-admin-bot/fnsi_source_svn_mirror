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

TRUNCATE TABLE mst_complaint;
INSERT INTO
  mst_complaint
  (
    complaint_cd
    , facility_cd
    , complaint_name
    , is_disp
    , is_del
    , reg_date
    , up_date
  )
VALUES
  (
    1
    , '1001'
    , 'name1'
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    2
    , '1001'
    , 'name2'
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    3
    , '1001'
    , 'name3'
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    4
    , '1001'
    , 'name4'
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    5
    , '1001'
    , 'name5'
    , '1'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    6
    , '1001'
    , 'name6'
    , '1'
    , '1'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
  , (
    7
    , '1003'
    , 'name7'
    , '0'
    , '0'
    , '2019-07-08 13:00:00'
    , '2019-07-08 14:00:00'
  )
;
SELECT setval('mst_complaint_complaint_cd_seq', 7);

-- テスト前にダミー列を追加
ALTER TABLE
  mst_complaint
ADD COLUMN dummy character varying(1) -- ダミー列
;
