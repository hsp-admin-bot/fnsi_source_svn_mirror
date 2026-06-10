select
  /*%expand "A" */*
from
  mnt_motion_record A
where
  A.motion_record_no = /*motionRecordNo*/'1'
;
