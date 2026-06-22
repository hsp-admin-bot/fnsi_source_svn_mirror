delete from mst_checklist;
delete from mst_device_set_info_default;
delete from mst_facility;

insert into
  mst_facility
  (
    facility_cd
    , facility_name
  )
VALUES
  (
    '000001'
    , 'テスト施設1'
  )
  ,(
    '000002'
    , 'テスト施設2'
  )
  ,(
    '000003'
    , 'テスト施設3'
  )
  ,(
    '999999'
    , 'テスト施設999999'
  )
;

delete from mst_report;

insert into
  mst_report
  (
    report_cd
    , facility_cd
  )
VALUES
  (
    101
    , '000001'
  )
  ,(
    102
    , '000001'
  )
;

delete from mst_function_report;

insert into
  mst_function_report
  (
    function_report_cd
    , function_cd
    , facility_cd
    , report_cd
    , is_disp
    , is_del
    , reg_date
    , up_date
  )
VALUES
  (
    1
    , '001'
    , '000001'
    , 101
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    2
    , '001'
    , '000001'
    , 102
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    3
    , '999'
    , '000001'
    , 101
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    4
    , '001'
    , '999999'
    , 101
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    5
    , '002'
    , '000002'
    , 101
    , '0'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    6
    , '003'
    , '000003'
    , 101
    , '1'
    , '1'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_checklist
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_report
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_function_report
ADD COLUMN dummy character varying(1) -- ダミー列
;
