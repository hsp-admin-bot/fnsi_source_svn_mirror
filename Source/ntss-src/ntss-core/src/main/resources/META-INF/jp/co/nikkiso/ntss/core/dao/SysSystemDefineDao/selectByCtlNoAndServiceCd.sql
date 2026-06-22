select
  /*%expand*/*
from
  sys_system_define
where
  ctl_no = /*ctlNo*/0
and
  service_cd = /*serviceCd*/NULL
;
