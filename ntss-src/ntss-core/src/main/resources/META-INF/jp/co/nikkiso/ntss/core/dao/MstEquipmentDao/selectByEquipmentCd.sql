select
  /*%expand "A" */*
from
  mst_equipment A
where
  A.is_del = '0'
and
  A.equipment_cd = /* equipCd */0
;
