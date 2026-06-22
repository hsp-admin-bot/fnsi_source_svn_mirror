update mnt_machine_state
set
  up_date = /*machineState.upDate*/'2020-09-05 11:48:11',
  monitor_data = /*machineState.monitorData*/'{"0":"1"}'::JSONB
where
  facility_cd = /*machineState.facilityCd*/'1' and
  machine_type_cd = /*machineState.machineTypeCd*/'1' and
  machine_serial = trim(/*machineState.machineSerial*/'1')
;
