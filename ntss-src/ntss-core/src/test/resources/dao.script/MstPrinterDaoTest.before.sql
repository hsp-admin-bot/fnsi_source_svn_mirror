DELETE FROM mst_printer;
DELETE FROM mst_facility where facility_cd in ('1001', '1002', '9999');

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
;

INSERT INTO
  mst_printer
  (
    printer_cd
    , facility_cd
    , client_key
    , printer_name
    , disp_printer_name
    , is_disp
    , is_del
  )
VALUES
  (
    1
    , '1001'
    , 'clientKey1'
    , 'name1'
    , 'dispName1'
    , '1'
    , '0'
  )
  , (
    2
    , '1001'
    , 'clientKey2'
    , 'name2'
    , 'dispName2'
    , '1'
    , '0'
  )
  , (
    3
    , '1001'
    , 'clientKey3'
    , 'name3'
    , 'dispName3'
    , '0'
    , '0'
  )
  , (
    4
    , '1001'
    , 'clientKey1'
    , 'name4'
    , 'dispName4'
    , '0'
    , '1'
  )
  , (
    5
    , '1002'
    , 'clientKey5'
    , 'name5'
    , 'dispName5'
    , '1'
    , '0'
  )
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_printer
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;
