select
  to_char(event_reg_date, 'yyyy/MM/dd') as event_reg_date,
  to_char(event_reg_date, 'HH24:MI:SS') as event_reg_time,
  test_type,
  contents

from
  mnt_motion_record

where
  data_type = 4
  and
  facility_cd = /*facilityCd*/'1'
  and
  machine_type_cd = /*machineTypeCd*/'1'
  and
  machine_serial = /*machineSerial*/'1'
  and
  to_char(event_reg_date, 'yyyyMMdd') between /*fromDate*/'00000000' and /*toDate*/'9999999'

order by
  event_reg_date desc,
  event_reg_time desc
;
