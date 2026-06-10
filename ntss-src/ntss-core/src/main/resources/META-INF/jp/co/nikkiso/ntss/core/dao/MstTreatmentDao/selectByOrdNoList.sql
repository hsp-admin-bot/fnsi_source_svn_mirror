select
  /*%expand "A" */*
from
  mst_treatment A, ord_main B
where
  A.is_del = '0' AND
  A.is_disp = '1' AND
  B.ind_treatment_cd = A.treatment_cd AND
  B.ord_no in /*ordNoList*/(null)
;

