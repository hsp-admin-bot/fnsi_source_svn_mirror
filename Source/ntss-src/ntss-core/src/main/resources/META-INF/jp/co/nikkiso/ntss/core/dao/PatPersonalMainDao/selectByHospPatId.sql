select 
  count(*)
from 
	pat_personal_main 
where
  is_del = '0'
and
  hosp_pat_id = /*hospPatId*/'000000000001'
and
  facility_cd = /*facilityCd*/'000001'
/*%if null != selfPatId*/
and
  pat_id <> /*selfPatId*/1
/*%end*/
;
