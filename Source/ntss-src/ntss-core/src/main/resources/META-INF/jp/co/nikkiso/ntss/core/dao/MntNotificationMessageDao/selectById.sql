select
  /*%expand */*
from
  mnt_notification_message
where
  notification_message_no = /*notificationMessageNo*/null
;
