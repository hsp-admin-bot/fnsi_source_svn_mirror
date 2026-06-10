update mnt_machine_state
set
	tmp_device_set_info = null,
	up_date = /*upDate*/null
where
	facility_cd = /*facilityCd*/null
and
	machine_type_cd = /*machineTypeCd*/null
and
	machine_serial = trim(/*machineSerial*/null)
;
