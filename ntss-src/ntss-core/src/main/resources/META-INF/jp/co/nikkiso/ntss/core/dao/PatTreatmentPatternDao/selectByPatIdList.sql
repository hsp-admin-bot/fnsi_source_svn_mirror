select
  pat_id,
  ctl_no,
  facility_cd,
  treat_type,
  ind_treat_start_date,
  ind_treatment_cd,
  ind_kur_cd,
  treat_week
from
  pat_treatment_pattern
where
  facility_cd = /* facilityCd */null
  /*%if patIdList.size() != 0 */
  and pat_id in /* patIdList */(null)
  /*%end */
;
