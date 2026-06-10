select
  /*%expand "A" */*
from
  mst_machine_type A
where
  A.machine_type_cd = /*machineTypeCd*/'1'
;
