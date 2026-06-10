INSERT INTO
  mst_report
  (
    report_cd
    , facility_cd
    , report_name
    , report_path
    , report_class
    , is_disp
    , is_del
    , reg_date
    , up_date
    , report_type
    , extraction_condition
  )
VALUES
  (
    8
    , '009999'
    , 'テンプレート繰り返し帳票'
    , '{
      "bucket": "ntss-esm"
      , "report_zip": "onePatient.zip"
      , "xml_filename": "onePatient.xml"
      , "html_filename": "onePatient.html"
      , "xlsx_filename": "onePatient.xlsx"
    }'
    , 2
    , '1'
    , '0'
    , '2019-09-17 11:00:00.000'
    , '2019-09-17 11:00:00.000'
    , 1
    , '["patId"]'
  )
;
