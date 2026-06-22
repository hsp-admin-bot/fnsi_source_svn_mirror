select
  /*%expand "A" */*
from
  mst_dialyzer A
where
    A.facility_cd = /* params.facilityCd*/'0'
;
