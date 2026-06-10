select
  /*%expand "A" */*
from
  bbs_info A
where
  bbs_ctl_no = /* bbs_ctl_no */null
;
