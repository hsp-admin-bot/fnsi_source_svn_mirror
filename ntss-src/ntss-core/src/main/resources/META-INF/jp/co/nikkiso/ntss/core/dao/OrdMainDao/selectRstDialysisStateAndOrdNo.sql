select
  A.ord_no,
  A.ind_treatment_name,
  A.rst_dialysis_state
from
  ord_main A
where
  A.facility_cd = /* facilityCd */'000000'
  and
  A.treat_date In(/* today */'00000000' , /* yesterday */'00000000')
  and
  A.pat_id = /* patId */0
  and
  A.rst_dialysis_state In('1', '2', '3', '4')
  and
  A.is_del = '0'
order by
  A.up_date DESC
limit 1
;