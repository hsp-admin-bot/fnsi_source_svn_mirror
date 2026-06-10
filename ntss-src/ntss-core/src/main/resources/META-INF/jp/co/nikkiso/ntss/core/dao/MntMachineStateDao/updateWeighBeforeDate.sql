update mnt_machine_state
set
  weigh_before_date = /*weightAfterDate*/null,
  up_date = CURRENT_TIMESTAMP
where
  facility_cd = /*facilityCd*/'1' and
  machine_type_cd = /*machineTypeCd*/'1' and

  machine_serial = trim(/*machineSerial*/'1')
  ;
