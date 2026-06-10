delete from
  tmp_comm_failure_recovery
where
  facility_cd = /*facilityCd*/'1'
and
  machine_type_cd = /*machineTypeCd*/'1'
and
  machine_serial = TRIM(/*machineSerial*/'1')
;
