-- 帳票マスタのデータ更新
UPDATE mst_report
set
  report_path = '{"bucket": "ntss-esm", "report_zip": "dialysisReport.zip", "xml_filename": "dialysisReport.xml", "html_filename": "dialysisReport.html", "xlsx_filename": "dialysisReport.xlsx"}'
WHERE
  report_cd = 1;
