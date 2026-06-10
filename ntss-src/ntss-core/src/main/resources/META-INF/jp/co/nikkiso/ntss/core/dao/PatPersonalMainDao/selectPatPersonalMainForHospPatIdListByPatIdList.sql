select
  facility_cd,
  pat_id,
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id
from
  pat_personal_main
where
  facility_cd = /* facilityCd */0
  and pat_id in /* patIdList */(null)
