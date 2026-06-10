select
  /*%expand "A" */*
from
  mst_medicate_timing A
where
  A.medicate_timing_cd = /* medicateTimingCd*/'0'
and
  A.is_del = '0'
;
