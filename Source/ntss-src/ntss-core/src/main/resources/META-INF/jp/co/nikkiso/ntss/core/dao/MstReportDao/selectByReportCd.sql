select
  /*%expand "A" */*
from
  mst_report A
where
  report_cd = /*reportCd*/1
;
