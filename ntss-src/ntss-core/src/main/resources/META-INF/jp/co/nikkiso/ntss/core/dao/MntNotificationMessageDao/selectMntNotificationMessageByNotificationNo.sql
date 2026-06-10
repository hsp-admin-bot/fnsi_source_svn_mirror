select
    *
from
  mnt_notification_message
where
  to_char(reg_date,'yyyy-mm-dd') = to_char(now(),'yyyy-mm-dd')
and
  facility_cd = /*facilityCd*/000000
and
  notification_no = /*notificationNo*/null
;
