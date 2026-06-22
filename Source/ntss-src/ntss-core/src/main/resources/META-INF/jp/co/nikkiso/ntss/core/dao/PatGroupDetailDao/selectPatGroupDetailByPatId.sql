select
  A.pat_group_cd,
  A.pat_id,
  A.facility_cd
from
  pat_group_detail A
where
  A.pat_id = /*patId*/null
;
