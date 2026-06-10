select
  to_char(event_reg_date, 'yyyyMMdd') as reg_date

from
  mnt_motion_record

where
  to_char(event_reg_date, 'yyyyMMdd') <= /*baseDate*/'99999999'
  and
  facility_cd = /*facilityCd*/'1'
  and
  machine_type_cd = /*machineTypeCd*/'1'
  and
  machine_serial = /*machineSerial*/'1'

group by
  to_char(event_reg_date, 'yyyyMMdd')

order by
  reg_date desc

;
