update
  mnt_motion_record
set
  is_correction = /*isCorrection*/'0',
  user_id = /*userId*/1,
  is_correction_up_date = current_timestamp,
  up_date = current_timestamp
where
  motion_record_no = /*motionRecordNo*/'1'
;
