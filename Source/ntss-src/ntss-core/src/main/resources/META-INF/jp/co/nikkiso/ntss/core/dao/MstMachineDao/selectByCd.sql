select
  /*%expand*/*
from
  mst_machine
where
  machine_type_cd = /*machineTypeCd*/'1'
and
  machine_serial = /*machineSerial*/'1'
and
  facility_cd = /*facilityCd*/'1'
;
