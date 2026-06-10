select
  to_char(event_reg_date, 'yyyy/MM/dd') as event_reg_date,
  to_char(event_reg_date, 'HH24:MI:SS') as event_reg_time,
  contents

from
  mnt_motion_record

where
  data_type = 5
  and
  facility_cd = /*facilityCd*/'1'
  and
  machine_type_cd = /*machineTypeCd*/'1'
  and
  machine_serial = /*machineSerial*/'1'
  and
  /*%if isGraph*/
  to_char(event_reg_date, 'yyyyMMdd') between /*fromDate*/'00000000' and /*toDate*/'9999999'
  /*%else*/
  to_char(event_reg_date, 'yyyyMMdd') <= /*toDate*/'9999999'
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
  /*%end*/
order by
  event_reg_date desc,
  event_reg_time desc

/*%if !isGraph*/
limit /*limit*/0
offset /*offset*/0
/*%end*/
;
