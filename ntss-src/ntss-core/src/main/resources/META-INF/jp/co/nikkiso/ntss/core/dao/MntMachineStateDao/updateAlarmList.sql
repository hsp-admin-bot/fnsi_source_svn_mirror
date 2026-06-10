update mnt_machine_state
set
  alarm_list = /*alarmList*/'{"0":"1"}'::JSONB,
  up_date = CURRENT_TIMESTAMP
where
  facility_cd = /*facilityCd*/'1' and
  machine_type_cd = /*machineTypeCd*/'1' and
  machine_serial = trim(/*machineSerial*/'1')
  ;
