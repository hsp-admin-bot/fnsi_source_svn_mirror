select
 to_char(event_reg_date, 'yyyy/MM/dd') as event_reg_date,
 to_char(event_reg_date, 'HH24:MI:SS') as event_reg_time,
 test_type,
 contents

from
 mnt_motion_record

where
 facility_cd = /*facilityCd*/'1'
 and
 machine_type_cd = /*machineTypeCd*/'1'
 and
 machine_serial = /*machineSerial*/'1'
 and
 data_type = 4
 and
 test_type <> 7
 and
 motion_record_no > /*motionRecordNo*/1

order by
 motion_record_no desc
;
