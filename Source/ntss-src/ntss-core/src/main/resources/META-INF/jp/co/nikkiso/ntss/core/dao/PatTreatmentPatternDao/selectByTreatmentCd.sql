select
  /*%expand "A" */*
from
  pat_treatment_pattern A
where
  A.facility_cd = /*facility_cd*/null
/*%if null != ind_treatment_cd */
and
  A.ind_treatment_cd = /*ind_treatment_cd*/'0'
/*%end*/
