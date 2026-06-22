select
  com_format_cd,
  com_type

from
  mst_machine

where
  facility_cd = /*facilityCd*/'1'
  and
  machine_type_cd = /*machineTypeCd*/'1'
  and
  machine_serial = /*machineSerial*/'1'

;
