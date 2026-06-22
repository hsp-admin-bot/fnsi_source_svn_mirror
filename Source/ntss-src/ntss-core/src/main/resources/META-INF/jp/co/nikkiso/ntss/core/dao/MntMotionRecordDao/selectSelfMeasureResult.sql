select
 /*%expand */*

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
 motion_record_no > /*motionRecordNo*/1

order by
 motion_record_no desc
;
