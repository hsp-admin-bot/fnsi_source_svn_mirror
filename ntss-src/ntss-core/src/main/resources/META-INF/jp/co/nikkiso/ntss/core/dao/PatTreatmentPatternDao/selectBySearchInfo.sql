select
  /*%expand "A" */*
from
  pat_treatment_pattern A
where
  A.pat_id = /*pat_id*/null
and
  A.facility_cd = /*facility_cd*/null
/*%if 0 != ind_treatment_cd.size() */
and
  A.ind_treatment_cd in /*ind_treatment_cd*/(1)
/*%end*/
/*%if 0 != ind_kur_cd.size() */
and
  A.ind_kur_cd in /*ind_kur_cd*/(1)
/*%end*/
/*%if null != week_pattern */
and
  A.treat_week in /*week_pattern*/(1)
/*%end*/
