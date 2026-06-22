select
  /*%expand */*
from
  mnt_notification_status
where
  notification_message_no = /*notificationMessageNo*/null
and
  user_id = /*userId*/null
;
