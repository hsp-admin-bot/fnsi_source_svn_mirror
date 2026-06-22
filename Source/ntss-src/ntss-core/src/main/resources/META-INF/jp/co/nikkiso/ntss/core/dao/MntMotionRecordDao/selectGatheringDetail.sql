select
  T1.machine_record_message,
  T1.user_id,
  T1.contents

from
  mnt_motion_record T1

where
  motion_record_no = /*motionRecordNo*/'1'
  
;