select
  /*%expand "A" */*
from
  mnt_machine_state A
where
  A.facility_cd = /*facilityCd*/null
and
  A.machine_type_cd = /*machineTypeCd*/null
and
  A.machine_serial = /*machineSerial*/null
/*%if(null != processState)*/
and
  A.process_state = /*processState*/null
/*%end*/
;