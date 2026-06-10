select
  /*%expand "A" */*
from
  mst_treatment_status_layout A
where
  /*%if params.facilityCd != null */
  facility_cd = /* params.facilityCd*/'0'
  /*%end */
;
