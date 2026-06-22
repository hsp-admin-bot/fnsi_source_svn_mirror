select
  count(motion.motion_record_no) as total
from
  mnt_motion_record motion
where
  motion.data_type <> 6
  and
  motion.facility_cd = /*facilityCd*/'1'
  and
  motion.machine_type_cd = /*machineTypeCd*/'1'
  and
  motion.machine_serial = /*machineSerial*/'1'
  /*%if "00000000" != fromDate || "99991231" != toDate */
  and
  to_char(motion.event_reg_date, 'yyyyMMdd') between /*fromDate*/'00000000' and /*toDate*/'9999999'
  /*%end */
  /*%if dataType != null && dataType.size() > 0*/
  and motion.data_type in /*dataType*/(null)
  /*%end */
  /*%if freeWord != null && freeWord != ""*/
  and motion.machine_record_message like /*@infix(freeWord)*/''
  /*%end */
;
 