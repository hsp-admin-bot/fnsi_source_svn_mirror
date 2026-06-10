select
  facility_cd
from
  pat_unique
where
  is_del = '0'
  and pat_id = /*patId*/0
;
