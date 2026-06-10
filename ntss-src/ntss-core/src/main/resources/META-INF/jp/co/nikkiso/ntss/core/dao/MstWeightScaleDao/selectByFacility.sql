select
  /*%expand "A" */*
from
 mst_weight_scale A
where
 A.facility_cd = /*facilityCd*/'999999'
;