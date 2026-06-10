select
  motion_record_no,
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
  to_char(event_reg_date, 'yyyyMMdd') <= /*baseDate*/'9999999'
  and
  test_type = /*testType*/null
  /*%if jsonAddressList.size() != 0 */
  and
  (
  /*%for jsonAddress : jsonAddressList */
    (contents->> /*jsonAddress*/'0' is not null and contents->> /*jsonAddress*/'0' != '')
    /*%if jsonAddress_has_next */
    or
    /*%end */
  /*%end */
  )
  /*%end */
order by
  event_reg_date desc,
  event_reg_time desc

limit /*limit*/0
offset /*offset*/0
;
