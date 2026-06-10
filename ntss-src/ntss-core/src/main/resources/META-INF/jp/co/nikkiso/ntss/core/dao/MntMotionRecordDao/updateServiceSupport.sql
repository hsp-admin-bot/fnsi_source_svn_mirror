update
  mnt_motion_record
set
  service_support_type = /*mntMotionRecord.serviceSupportType*/'0',
  service_support_user_id = /*mntMotionRecord.serviceSupportUserId*/0,
  service_support_up_date = current_timestamp,
  up_date = /*mntMotionRecord.upDate*/null
where
  motion_record_no = /*mntMotionRecord.motionRecordNo*/'1'
;
