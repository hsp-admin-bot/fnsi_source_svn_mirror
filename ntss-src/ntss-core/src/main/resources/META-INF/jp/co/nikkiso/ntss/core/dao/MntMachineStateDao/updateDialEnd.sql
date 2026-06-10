update mnt_machine_state
set
  machine_status = /*param.machineStatus*/0,
  is_pat_verified = '0',
  alarm_list = '{}'::JSONB,
  end_date = /*param.endDate*/'1970/01/01 00:00:00',
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  facility_cd = /*param.facilityCd*/'1' and
  machine_type_cd = /*param.machineTypeCd*/'1' and
  machine_serial = trim(/*param.machineSerial*/'1')
  ;
