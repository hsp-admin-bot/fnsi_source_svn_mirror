select
  /*%expand "A" */*
from
  mst_treatment A
where
  A.treatment_cd = /* treatmentCd*/'0'
;
