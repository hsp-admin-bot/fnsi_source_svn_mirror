select
  /*%expand "A" */*
from
  sys_facility A
where
  1 = 1
/*%if cdList.size() > 0 */
  and A.medical_institution_cd in /* cdList */(null)
/*%end*/
;
