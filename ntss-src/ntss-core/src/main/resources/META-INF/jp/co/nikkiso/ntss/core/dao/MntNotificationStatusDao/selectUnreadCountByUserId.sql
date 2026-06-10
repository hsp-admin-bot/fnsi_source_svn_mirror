select count
  (*)
from
  mnt_notification_status
where
  user_id = /*userId*/1
and
  is_read = '0'
;
