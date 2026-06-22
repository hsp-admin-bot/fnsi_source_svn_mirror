select
  /*%expand "A" */*
from
  sys_system_define A
where
  A.facility_cd = /*facilityCd*/'1'
  and
  A.ctl_no = /*ctlNo*/'1'
;
