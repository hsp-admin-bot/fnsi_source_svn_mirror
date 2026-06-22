select
  ind_treatment_cd,
  rst_treatment_cd
from
  ord_main A
where
  A.ord_no in /*ordNoList*/(null)
;