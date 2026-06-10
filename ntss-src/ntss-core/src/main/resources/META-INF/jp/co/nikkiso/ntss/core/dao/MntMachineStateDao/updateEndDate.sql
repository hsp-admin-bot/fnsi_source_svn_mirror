update mnt_machine_state
set
  end_date = CURRENT_TIMESTAMP
where
	facility_cd = /*param.facilityCd*/null
and
	machine_type_cd = /*param.machineTypeCd*/null
and
  trim(machine_serial) = trim(/*param.machineSerial*/null)
;
