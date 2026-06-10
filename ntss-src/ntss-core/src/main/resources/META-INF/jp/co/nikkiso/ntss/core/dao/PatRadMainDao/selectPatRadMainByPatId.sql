select
  /*%expand "A" */*
from
  pat_rad_main A
where
  A.pat_id = /* patId */-1
and
  A.is_del = '0'
;
