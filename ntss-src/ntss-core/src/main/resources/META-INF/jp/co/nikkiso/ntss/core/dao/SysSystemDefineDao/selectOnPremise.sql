select
  /*%expand "A" */*
from
  sys_system_define A
where
  A.ctl_no = /*ctlNo*/'0'
;
