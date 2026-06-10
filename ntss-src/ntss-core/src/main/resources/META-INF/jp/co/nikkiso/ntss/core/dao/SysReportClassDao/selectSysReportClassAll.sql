select
  /*%expand "A" */*
from
  sys_report_class A
where
  A.is_disp = '1'
and
  A.is_del = '0'
order by report_class_cd
;
