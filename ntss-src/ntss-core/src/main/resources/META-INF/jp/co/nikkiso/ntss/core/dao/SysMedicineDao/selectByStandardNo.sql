select
  /*%expand "A" */*
from
  sys_medicine A
where
  A.standard_no = /*standardNo*/'0'
;
