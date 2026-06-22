select 
  /*%expand "A" */*
from mst_weight A
where
  A.facility_cd = /*facilityCd*/'999999'
and
  A.weight_no = /*weightNo*/1
;