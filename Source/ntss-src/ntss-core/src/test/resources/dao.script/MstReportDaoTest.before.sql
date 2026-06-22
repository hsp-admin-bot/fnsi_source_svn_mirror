delete from mst_facility where facility_cd in ('00001');

insert into
  mst_facility
  (
    facility_cd,
    facility_name
  )
VALUES
  ('00001', 'sisetu1')
  , ('00002', 'sisetu2')
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
    , '{ "bucket": "bucket", "xlsx_zip": "xlsx_zip", "report_zip": "report_zip", "xlsx_filename": "xlsx_filename", "html_filename": "html_filename", "xml_filename": "xml_filename" }'
    , 2
    , 1
    , '{"ord_no": 1, "pat_id": 11}'
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
    , '{ "xlsx_path": "xlsx_path", "html_path": "html_path", "xml_path": "xml_path" }'
    , 2
    , 1
    , '{"ord_no": 2, "pat_id": 22}'
    , 12
    , '0'
    , '0'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
  ,(
    3
    , '00001'
    , 'report'
    , '{ "xlsx_path": "xlsx_path", "html_path": "html_path", "xml_path": "xml_path" }'
    , 2
    , 1
    , '{"ord_no": 3, "pat_id": 33}'
    , 13
    , '1'
    , '1'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
  ,(
    10
    , '00001'
    , 'report'
    , '{ "bucket": "bucket", "xlsx_zip": "xlsx_zip", "report_zip": "report_zip", "xlsx_filename": "xlsx_filename", "html_filename": "html_filename", "xml_filename": "xml_filename" }'
    , 2
    , 2
    , '{"ord_no": 10, "pat_id": 110}'
    , 20
    , '1'
    , '0'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
  ,(
    11
    , '00002'
    , 'report'
    , '{ "bucket": "bucket", "xlsx_zip": "xlsx_zip", "report_zip": "report_zip", "xlsx_filename": "xlsx_filename", "html_filename": "html_filename", "xml_filename": "xml_filename" }'
    , 2
    , 2
    , '{"ord_no": 11, "pat_id": 111}'
    , 21
    , '1'
    , '0'
    , '2019-02-13 14:30:00'
    , '2019-02-13 14:00:00'
  )
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_report
ADD COLUMN dummy character varying(1) -- ダミー列
;

ALTER TABLE
  mst_facility
ADD COLUMN dummy character varying(1) -- ダミー列
;

