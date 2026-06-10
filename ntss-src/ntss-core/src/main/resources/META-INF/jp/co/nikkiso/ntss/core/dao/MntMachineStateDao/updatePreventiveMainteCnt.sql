update mnt_machine_state
set
  preventive_mainte_cnt = /*preventiveMainteCnt*/0,
  up_date = /*upDate*/null
where
	facility_cd = /*facilityCd*/null
and
	machine_type_cd = /*machineTypeCd*/null
and
  trim(machine_serial) = trim(/*machineSerial*/null)
;
