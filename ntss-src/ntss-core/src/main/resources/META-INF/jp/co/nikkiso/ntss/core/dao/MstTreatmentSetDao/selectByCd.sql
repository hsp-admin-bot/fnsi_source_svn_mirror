select
  /*%expand "A" */*
from
  mst_treatment_set A
where
  treatment_set_cd = /*treatment_set_cd*/'1'
;
