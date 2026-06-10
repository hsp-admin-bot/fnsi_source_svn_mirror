select
 ord_no,
 model,
 machine_serial
from
 mnt_machine_state
where
  facility_cd = /*param.facilityCd*/'1' and
  machine_type_cd = /*param.machineTypeCd*/'1' and
  machine_serial = trim(/*param.machineSerial*/'1')
  ;
