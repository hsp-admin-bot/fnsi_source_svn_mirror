select
  /*%expand "A" */*
from
  pat_rad_main A
where
    A.rad_result_cd in /* ratResultCdList */(0)
  and
    A.is_del = '0'
;
