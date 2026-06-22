select
  /*%expand "A" */*
from
  mnt_machine_state A
where
  A.facility_cd = /*facilityCd*/'1'
and
  A.machine_type_cd = /*machineTypeCd*/'1'
and
  A.machine_serial = /*machineSerial*/'1'
;
