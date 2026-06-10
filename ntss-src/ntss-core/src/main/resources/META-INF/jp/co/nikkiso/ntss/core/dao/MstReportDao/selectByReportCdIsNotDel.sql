select
  /*%expand*/*
from
  mst_report
where
  report_cd = /*reportCd*/1
and
  is_del = '0'
;
