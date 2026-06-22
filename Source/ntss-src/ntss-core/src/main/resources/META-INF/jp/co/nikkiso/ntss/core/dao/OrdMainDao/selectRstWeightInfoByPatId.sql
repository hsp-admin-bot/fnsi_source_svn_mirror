select
  A.ord_no,
  A.rst_dialysis_state,
  A.rst_weight_info
from
  ord_main A
where
  A.facility_cd = /* facilityCd */'000000'
  and
  A.treat_date In(/* today */'00000000' , /* yesterday */'00000000')
  and
  A.pat_id = /* patId */0
  and
  A.is_del = '0'
  /*%if patId != null*/
  and A.rst_dialysis_state in /*state*/(NULL) 
  /*%end */ 
order by 
  A.up_date DESC
limit 1
;