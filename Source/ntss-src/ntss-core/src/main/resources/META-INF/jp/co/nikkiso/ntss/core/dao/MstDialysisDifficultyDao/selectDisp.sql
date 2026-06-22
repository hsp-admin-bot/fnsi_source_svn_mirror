select
  /*%expand "A" */*
from
  mst_dialysis_difficulty A
where
  facility_cd = /* facilityCd*/'0'
  and is_disp = '1' and is_del = '0'
;
