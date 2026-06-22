select
  /*%expand "A" */*
from
  mst_procedure A
where
  A.facility_cd = /* facilityCd*/'0'
and
  A.procedure_cd = /* procedureCd*/'0'
and
  A.is_del = '0'
;
