select
  medicine_cd
from
  mst_medicine A
where
  A.standard_medicine_cd in /* standardMedicineCdList*/(null)
and
  A.is_del = '0'
and
  A.is_disp = '1'
;
