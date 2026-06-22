update mnt_machine_state
set
  machine_type_cd = /*newMachineTypeCd*/null,
  machine_serial = /*newMachineSerial*/null,
  model = /*model*/null,
  machine_name = /*machineName*/null,
  up_date = /*upDate*/null
where
  facility_cd = /*facilityCd*/null
and
  machine_type_cd = /*oldMachineTypeCd*/null
and
  trim(machine_serial) = trim(/*oldMachineSerial*/null)
;
