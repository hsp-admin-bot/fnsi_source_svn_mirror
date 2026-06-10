select
  motion.motion_record_no,
  to_char(motion.event_reg_date, 'yyyy/MM/dd') as event_reg_date,
  to_char(motion.event_reg_date, 'HH24:MI:SS') as event_reg_time,
  motion.data_type,
  motion.test_type,
  motion.machine_record_message,
   motion.is_correction,
   motion.user_id,
   manage.gathering_status,
   motion.is_correction_up_date,
   motion.service_support_type,
   motion.service_support_user_id,
   motion.service_support_up_date
from
  mnt_motion_record motion
  left outer join mnt_gathering_manage manage
    on motion.gathering_manage_no = manage.gathering_manage_no

where
  motion.facility_cd = /*facilityCd*/'1'
  and
  motion.machine_type_cd = /*machineTypeCd*/'1'
  and
  motion.machine_serial = /*machineSerial*/'1'
  /*%if "00000000" != fromDate || "99991231" != toDate */
  and
  to_char(motion.event_reg_date, 'yyyyMMdd') between /*fromDate*/'00000000' and /*toDate*/'9999999'
  /*%end */

order by
  motion.event_reg_date desc, motion.data_type

;
