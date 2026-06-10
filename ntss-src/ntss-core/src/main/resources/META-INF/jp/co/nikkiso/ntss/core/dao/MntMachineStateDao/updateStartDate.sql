update mnt_machine_state
set
  start_date = CURRENT_TIMESTAMP,
  end_date = null
where
	facility_cd = /*param.facilityCd*/null
and
	machine_type_cd = /*param.machineTypeCd*/null
and
  trim(machine_serial) = trim(/*param.machineSerial*/null)
;
