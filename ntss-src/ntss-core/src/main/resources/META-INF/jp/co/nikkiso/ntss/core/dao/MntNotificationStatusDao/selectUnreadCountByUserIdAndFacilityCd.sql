select
 count(*)
from
  mnt_notification_message m,
--mod FNSi6143メーカー通知で正常に通知しない 周 start
--     inner join mnt_notification_status s
--       on m.notification_message_no = s.notification_message_no
--      and m.facility_cd = s.facility_cd
  mnt_notification_status s
--mod FNSi6143メーカー通知で正常に通知しない 周 end
where
  s.user_id = /*userId*/1
and
--mod FNSi6143メーカー通知で正常に通知しない 周 start
  --s.facility_cd = /*facilityCd*/000000
  m.notification_message_no = s.notification_message_no and
  s.facility_cd IN (select distinct facility_cd
  from mnt_notification_message mnm
  where mnm.facility_cd  = /*facilityCd*/000000
  or mnm.notification_no = 0)
--mod FNSi6143メーカー通知で正常に通知しない 周 end
and
  s.is_read = '0'
;

