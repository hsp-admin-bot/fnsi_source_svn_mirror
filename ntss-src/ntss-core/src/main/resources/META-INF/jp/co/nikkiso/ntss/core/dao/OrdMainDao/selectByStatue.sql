select
  A.ord_no,
  A.rst_dialysis_state
from
  ord_main A
where
  A.facility_cd = /* facilityCd */'000000'
  and
  A.is_del = '0'
  and A.rst_dialysis_state in /*state*/(NULL) 
order by 
  A.up_date DESC
limit 1
;