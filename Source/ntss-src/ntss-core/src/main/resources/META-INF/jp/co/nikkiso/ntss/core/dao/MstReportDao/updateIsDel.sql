update mst_report
set
is_del = '1',
up_date = /*rec.upDate*/null
where
  report_cd = /*rec.reportCd*/1
;
