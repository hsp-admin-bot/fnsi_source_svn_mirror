delete from mst_facility where facility_cd in ('00001');

insert into
  mst_facility
  (
    facility_cd,
    facility_name
  )
VALUES
  ('00001', 'sisetu1')
  ,('00002', 'sisetu2')
  ,('00003', 'sisetu3')
  ,('99999', 'sisetu99999')
;

delete from mst_report;

insert into
  mst_report
  (
    report_cd
    , facility_cd
    , report_name
    , report_path
    , report_class
    , report_type
    , extraction_condition
    , default_printer
    , is_disp
    , is_del
    , reg_date
    , up_date
  )
values
  (
    1
    , '00001'
    , 'report'
    , '{ "bucket": "ntss-esm", "report_zip": "テスト英字ファイル.zip", "html_filename": "testReport.html", "xml_filename": "testReport.xml" }'
    , 2
    , 3
    , null
    , 11
    , '1'
    , '0'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
  ,(
    2
    , '00001'
    , 'report'
    , '{ "bucket": "ntss-esm", "report_zip": "testReport.zip", "html_filename": "testReport.html", "xml_filename": "testReport_xml" }'
    , 2
    , 3
    , null
    , 12
    , '0'
    ,'0'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
  ,(
    3
    , '00001'
    , 'report'
    , '{ "bucket": "ntss-esm", "report_zip": "testReport.zip", "html_filename": "testReport.html", "xml_filename": "testReport_xml" }'
    , 2
    , 3
    , null
    , 13
    , '1'
    , '1'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
  ,(
    101
    , '00001'
    , 'テスト帳票1'
    , '{ "bucket": "ntss-esm", "report_zip": "testReport.zip", "html_filename": "testReport.html", "xml_filename": "testReport_xml" }'
    , 9
    , 8
    , '["pat_id", "ord_no"]'
    , 21
    , '1'
    , '0'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
  ,(
    102
    , '00001'
    , 'テスト帳票2'
    , '{ "bucket": "ntss-esm", "report_zip": "testReport.zip", "html_filename": "testReport.html", "xml_filename": "testReport_xml" }'
    , 7
    , 6
    , '["pat_id"]'
    , 22
    , '1'
    , '0'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
  ,(
    103
    , '00001'
    , 'テスト帳票3'
    , '{ "bucket": "ntss-esm", "report_zip": "testReport.zip", "html_filename": "testReport.html", "xml_filename": "testReport_xml" }'
    , 5
    , 4
    , '["ord_no"]'
    , 23
    , '1'
    , '0'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
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
    , '00001'
    , 101
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    2
    , '001'
    , '00001'
    , 102
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    3
    , '999'
    , '00001'
    , 101
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    4
    , '001'
    , '99999'
    , 101
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    5
    , '002'
    , '00002'
    , 101
    , '0'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
  ,(
    6
    , '003'
    , '00003'
    , 3
    , '1'
    , '0'
    , '2019-08-14 12:00:00.000'
    , '2019-08-14 13:00:00.000'
  )
;

delete from mst_facility_setting;

insert into
  mst_facility_setting
  (
    facility_setting_no
    , facility_cd
    , value
    , reg_date
    , up_date
  )
values
  (
    '1006'
    , '00001'
    , '1'
    , '2019-09-14 10:00:00.000'
    , '2019-09-14 10:00:00.000'
   )
;

delete from mst_printer;

insert into
  mst_printer
  (
    printer_cd
    , facility_cd
    , client_key
    , printer_name
    , disp_printer_name
    , is_disp
    , is_del
    , reg_date
    , up_date
  )
VALUES
  (
    1
    , '00001'
    , 'clientKey1'
    , 'name1'
    , 'dispName1'
    , '1'
    , '0'
    , '2019-09-14 10:00:00.000'
    , '2019-09-14 10:00:00.000'
  )
  , (
    2
    , '00001'
    , 'clientKey2'
    , 'name2'
    , 'dispName2'
    , '1'
    , '0'
    , '2019-09-14 10:00:00.000'
    , '2019-09-14 10:00:00.000'
  )
  , (
    3
    , '00001'
    , 'clientKey3'
    , 'name3'
    , 'dispName3'
    , '1'
    , '0'
    , '2019-09-14 10:00:00.000'
    , '2019-09-14 10:00:00.000'
  )
  , (
    4
    , '00001'
    , 'clientKey4'
    , 'name4'
    , 'dispName4'
    , '0'
    , '0'
    , '2019-09-14 10:00:00.000'
    , '2019-09-14 10:00:00.000'
  )
  , (
    5
    , '00001'
    , 'clientKey5'
    , 'name5'
    , 'dispName5'
    , '0'
    , '1'
    , '2019-09-14 10:00:00.000'
    , '2019-09-14 10:00:00.000'
  )
  , (
    6
    , '00001'
    , 'clientKey6'
    , 'name6'
    , 'dispName6'
    , '1'
    , '0'
    , '2019-09-14 10:00:00.000'
    , '2019-09-14 10:00:00.000'
  )
;

delete from mst_selector;

insert into mst_selector
  (
    facility_cd
    , master_physical_name
    , order_settings
    , reg_date
    , up_date
  )
values
  (
    '00001'
    , 'mst_printer'
    , '{"items": [{"code": 1, "name": "name1"}, {"code": 3, "name": "name3"}, {"code": 2, "name": "name2"}]}'
    , '2019-09-14 10:00:00.000'
    , '2019-09-14 10:00:00.000'
  )
;


