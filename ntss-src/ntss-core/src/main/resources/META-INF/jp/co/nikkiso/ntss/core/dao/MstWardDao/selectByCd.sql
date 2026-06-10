select
  /*%expand "A" */*
from
  mst_ward A
where
  A.is_del = '0'
and
  A.ward_cd = /* wardCd*/'0'
;
