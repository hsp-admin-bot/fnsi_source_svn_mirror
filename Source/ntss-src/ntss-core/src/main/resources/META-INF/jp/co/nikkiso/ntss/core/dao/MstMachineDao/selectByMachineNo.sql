select
  /*%expand "MM" */*
from
  mst_machine MM
where
  MM.machine_no = /*machineNo*/0
;