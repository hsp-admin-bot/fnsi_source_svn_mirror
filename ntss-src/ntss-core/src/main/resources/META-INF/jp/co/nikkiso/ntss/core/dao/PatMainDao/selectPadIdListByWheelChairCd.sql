select
 pat_id
from
  pat_main A
where
  A.is_del = '0'
and 
  A.facility_cd = /*facilityCd*/'000001'
and
  A.wheel_chair_cd = /* wheelChairCd */1
;
