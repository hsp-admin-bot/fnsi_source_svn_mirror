select
  /*%expand "A" */*
from
  mst_equipment A
where
  A.facility_cd = /* params.facilityCd*/'0'
and
  (A.is_disp = '0' or A.is_del = '1')
;
