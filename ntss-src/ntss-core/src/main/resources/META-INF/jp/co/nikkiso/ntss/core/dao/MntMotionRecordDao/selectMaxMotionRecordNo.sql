select
 max(motion_record_no)

from
 mnt_motion_record

where
 facility_cd = /*facilityCd*/'1'
 and
 machine_type_cd = /*machineTypeCd*/'1'
 and
 machine_serial = /*machineSerial*/'1'
 and
 data_type = 1
 and
-- mod #10063 自己診断結果レコードのコード不正修正 高 start
-- machine_record_cd in ('- ', '-  ')
 machine_record_cd in ('G100', 'G102')
-- mod #10063 自己診断結果レコードのコード不正修正 高 end
;
