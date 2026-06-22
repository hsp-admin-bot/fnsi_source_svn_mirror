select
  /*%expand "A" */*
from
  mst_facility A
where
  facility_cd in /* facilityCds */(null)
;
