select
  /*%expand "A" */*
from
  tmp_comm_failure_recovery A
where
  A.facility_cd = /*facilityCd*/'1'
and
  A.machine_type_cd = /*machineTypeCd*/'1'
and
  A.machine_serial = /*machineSerial*/'1'
;
