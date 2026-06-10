update
  mnt_motion_record
set
  is_correction = '1',
  user_id = /*userId*/1,
  is_correction_up_date = current_timestamp,
  up_date = current_timestamp
where
  facility_cd = /*facilityCd*/'1'
  and
  machine_type_cd = /*machineTypeCd*/'1'
  and
  machine_serial = /*machineSerial*/'1'
  and
  is_correction in ('0','2')
  and
  data_type = /*dataType*/1

;
