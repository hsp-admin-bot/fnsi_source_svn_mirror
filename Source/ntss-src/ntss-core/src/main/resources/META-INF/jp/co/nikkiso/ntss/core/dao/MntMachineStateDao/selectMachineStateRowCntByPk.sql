select
  count(*)
from
  mnt_machine_state
where
  facility_cd = /*facilityCd*/null
and
  machine_type_cd = /*machineTypeCd*/null
and
  TRIM(machine_serial) = TRIM(/*machineSerial*/null)
;
