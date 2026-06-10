select
  /*%expand "A" */*
from
  sys_report_class A
where
  A.is_disp = '1'
  and report_class_cd =/*classCd*/0
;
