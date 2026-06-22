select
 count(*)
from
  mnt_notification_message m,
  mnt_notification_status s
where
  s.user_id = /*userId*/1
and
  m.notification_message_no = s.notification_message_no and
  s.notification_message_no = /*notificationMessageNo*/null and
  s.facility_cd IN (select distinct facility_cd
  from mnt_notification_message mnm
  where mnm.facility_cd  = /*facilityCd*/000000)
;

