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
  data_type = 2
  and
  (is_correction = '0' OR is_correction = '2' OR is_correction IS NULL)
;
