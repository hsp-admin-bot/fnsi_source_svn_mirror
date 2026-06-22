select
  /*%expand "A" */*
from
  mnt_machine_state A
where
  A.machine_serial = /*machineSerial*/'1'
;
