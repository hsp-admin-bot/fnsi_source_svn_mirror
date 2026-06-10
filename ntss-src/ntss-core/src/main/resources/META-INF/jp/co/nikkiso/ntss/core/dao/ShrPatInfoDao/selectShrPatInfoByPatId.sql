select
  A.*
from
  shr_pat_info A
where
  A.to_facility_cd = /*facilityCd*/'1'
  and A.to_pat_id = /*patId*/0
  and A.is_disp = '1'
  and A.is_del = '0'
  and A.from_facility_cd is not null
  and A.from_facility_cd <> ''
  and A.from_pat_id is not null
  and A.is_from_consent = '1'
  and A.is_to_consent = '1'
  and A.is_pat_consent = '1'
;
