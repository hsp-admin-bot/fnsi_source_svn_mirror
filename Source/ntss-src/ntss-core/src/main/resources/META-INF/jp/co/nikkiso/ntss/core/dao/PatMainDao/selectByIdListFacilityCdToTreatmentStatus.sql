select
  pat_id,  
  facility_cd,
  is_same
from
  pat_main
where
  is_del = '0'
  and facility_cd = /*facilityCd*/''
  and pat_id in /* patIdList */(null)
order by
  pat_id
;
