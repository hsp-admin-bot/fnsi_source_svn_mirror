update mst_report
set
report_name = /*rec.reportName*/'透析レポート',
up_date = /*rec.upDate*/null
where
  report_cd = /*rec.reportCd*/1
;
