UPDATE
  mst_report
SET
  report_path = '{ "bucket": "ntss-esm", "report_zip": "dialysisReport.zip", "xml_filename": "dialysisReport.xml", "html_filename": "dialysisReport.html", "xlsx_filename": "xlsx_filename" }'
WHERE
  report_cd = 1
;
