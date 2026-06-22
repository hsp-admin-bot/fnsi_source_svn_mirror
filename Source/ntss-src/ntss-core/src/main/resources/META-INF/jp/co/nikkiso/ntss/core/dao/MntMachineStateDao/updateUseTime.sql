update mnt_machine_state
set
  use_time = /*param.useTime*/'{"0":"1"}'::JSONB,
  up_date = /*param.upDate*/'2018-01-01 00:00:00'
where
  facility_cd = /*param.facilityCd*/'1' and
  machine_type_cd = /*param.machineTypeCd*/'1' and
  machine_serial = trim(/*param.machineSerial*/'1')
  ;
