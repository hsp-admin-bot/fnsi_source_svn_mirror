update mnt_machine_state
set
  machine_status = /*param.machineStatus*/0,
  cond_set_date = /*param.condSetDate*/'1970/01/01 00:00:00',
  is_pat_verified = /*param.isPatVerified*/'0',
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  facility_cd = /*param.facilityCd*/'1' and
  machine_type_cd = /*param.machineTypeCd*/'1' and
  machine_serial = trim(/*param.machineSerial*/'1')
  ;
