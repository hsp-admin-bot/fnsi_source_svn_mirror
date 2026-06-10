select 
  /*%expand "A" */*
from
  mst_weight A
where
  A.weight_scale_cd = /*weightScaleCd*/0
;