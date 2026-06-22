select
  A.pat_id, A.ctl_no, A.facility_cd
from
  pat_treatment_pattern A
where
  A.pat_id = /*patId*/null
and
  A.facility_cd = /*facilityCd*/null
/*%if 0 != indTreatmentCdList.size() */
and
  A.ind_treatment_cd in /*indTreatmentCdList*/(1)
/*%end*/
/*%if null != treatWeekList */
and
  A.treat_week in /*treatWeekList*/(1)
/*%end*/
/*%if indKurCdList != null && 0 != indKurCdList.size()*/
and A.ind_kur_cd IN /*indKurCdList*/(NULL)
/*%end*/
