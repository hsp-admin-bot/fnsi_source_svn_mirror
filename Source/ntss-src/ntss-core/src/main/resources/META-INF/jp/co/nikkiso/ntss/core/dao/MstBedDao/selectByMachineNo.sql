select
  /*%expand "A" */*
from
  mst_bed A
where
  A.machine_no = /*machineNo*/0
;
