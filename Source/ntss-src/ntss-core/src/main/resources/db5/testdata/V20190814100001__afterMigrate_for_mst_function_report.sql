-- 帳票マスタへデータ登録
UPDATE mst_report
set
  report_name = '透析レポート',
  extraction_condition = '["ordNo", "patId"]'
WHERE report_cd = 1;

INSERT INTO mst_report
(report_cd, facility_cd, report_name, report_path, report_class, is_disp, is_del, reg_date, up_date, report_type, extraction_condition)
VALUES
  (2, '009999', 'ダミー帳票１', '{"bucket": "ntss-esm", "report_zip": "dummyReport1.zip", "xml_filename": "dummyReport1.xml", "html_filename": "dummyReport1.html", "xlsx_filename": "xlsx_filename"}', 1, '1', '0', '2019-08-14 10:00:00.000', '2019-08-14 10:00:00.000', 1, '["patId"]')
, (3, '009999', 'ダミー帳票２', '{"bucket": "ntss-esm", "report_zip": "dummyReport2.zip", "xml_filename": "dummyReport2.xml", "html_filename": "dummyReport2.html", "xlsx_filename": "xlsx_filename"}', 1, '1', '0', '2019-08-14 10:00:00.000', '2019-08-14 10:00:00.000', 1, '["patId"]')
, (4, '009999', 'ダミー帳票３', '{"bucket": "ntss-esm", "report_zip": "dummyReport3.zip", "xml_filename": "dummyReport3.xml", "html_filename": "dummyReport3.html", "xlsx_filename": "xlsx_filename"}', 1, '1', '0', '2019-08-14 10:00:00.000', '2019-08-14 10:00:00.000', 1, '["patId"]')
, (5, '009999', 'ダミー帳票４', '{"bucket": "ntss-esm", "report_zip": "dummyReport4.zip", "xml_filename": "dummyReport4.xml", "html_filename": "dummyReport4.html", "xlsx_filename": "xlsx_filename"}', 1, '1', '0', '2019-08-14 10:00:00.000', '2019-08-14 10:00:00.000', 1, '["ordNo"]')
, (6, '009999', 'ダミー帳票５', '{"bucket": "ntss-esm", "report_zip": "dummyReport5.zip", "xml_filename": "dummyReport5.xml", "html_filename": "dummyReport5.html", "xlsx_filename": "xlsx_filename"}', 1, '1', '0', '2019-08-14 10:00:00.000', '2019-08-14 10:00:00.000', 1, '["ordNo"]')
, (7, '009999', 'ダミー帳票６', '{"bucket": "ntss-esm", "report_zip": "dummyReport6.zip", "xml_filename": "dummyReport6.xml", "html_filename": "dummyReport6.html", "xlsx_filename": "xlsx_filename"}', 1, '1', '0', '2019-08-14 10:00:00.000', '2019-08-14 10:00:00.000', 1, '["ordNo"]')
;

-- 機能帳票マスタへデータ登録
INSERT INTO mst_function_report
(function_report_cd, function_cd, facility_cd, report_cd, is_disp, is_del, reg_date, up_date)
VALUES
  (1, '00601', '009999', 1, '1', '0', '2019-08-14 09:30:00.000', '2019-08-14 09:30:00.000')
, (2, '00602', '009999', 2, '1', '0', '2019-08-14 09:30:00.000', '2019-08-14 09:30:00.000')
, (3, '00602', '009999', 3, '1', '0', '2019-08-14 09:30:00.000', '2019-08-14 09:30:00.000')
, (4, '00602', '009999', 4, '1', '0', '2019-08-14 09:30:00.000', '2019-08-14 09:30:00.000')
, (5, '00606', '009999', 5, '1', '0', '2019-08-14 09:30:00.000', '2019-08-14 09:30:00.000')
, (6, '00607', '009999', 6, '1', '0', '2019-08-14 09:30:00.000', '2019-08-14 09:30:00.000')
, (7, '00607', '009999', 7, '1', '0', '2019-08-14 09:30:00.000', '2019-08-14 09:30:00.000')
;

