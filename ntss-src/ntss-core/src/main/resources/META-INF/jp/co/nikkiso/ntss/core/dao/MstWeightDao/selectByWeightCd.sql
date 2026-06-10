select
  /*%expand "A" */*
from
  mst_weight A
where
  A.weight_cd = /*weightCd*/0
;