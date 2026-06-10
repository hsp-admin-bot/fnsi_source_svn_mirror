select
  /*%expand "A" */*
from
  sys_facility A
where
  A.is_disp = '1'
  and A.is_del = '0'
  /*%if facilityCd != null*/
   and A.facility_cd = /*facilityCd*/null
  /*%end*/
  limit 1
;
