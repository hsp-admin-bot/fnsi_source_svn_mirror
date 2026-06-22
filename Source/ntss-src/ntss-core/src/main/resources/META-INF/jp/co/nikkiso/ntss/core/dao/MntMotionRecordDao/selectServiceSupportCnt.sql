select
  count(*)

from
  mnt_motion_record

where
  facility_cd = /*facilityCd*/null
  and
  machine_type_cd = /*machineTypeCd*/null
  and
  trim(machine_serial) = trim(/*machineSerial*/null)
  and
  (data_type = 2 OR data_type = 3)
  and
  (service_support_type = '0' OR service_support_type = '1' OR service_support_type IS NULL)
;
