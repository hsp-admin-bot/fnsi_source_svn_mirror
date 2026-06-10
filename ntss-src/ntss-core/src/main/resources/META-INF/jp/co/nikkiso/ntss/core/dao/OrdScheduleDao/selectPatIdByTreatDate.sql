select distinct
  pat_id
from
  ord_schedule
where
  is_dummy = '0'
  and facility_cd = /* facilityCd */null
  and treat_date = /* treatDate */null