select
  /*%expand "A" */*
from
  mst_equipment A
where
  A.facility_cd = /* params.facilityCd*/'0'
;
