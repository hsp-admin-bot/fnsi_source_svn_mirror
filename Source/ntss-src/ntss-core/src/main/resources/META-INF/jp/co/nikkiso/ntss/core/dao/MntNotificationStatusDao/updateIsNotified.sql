update
  mnt_notification_status
set
  is_notified = /*isNotified*/'0'
  , up_date = current_timestamp
where
  notification_message_no in /*notificationMessageNos*/(1)
and
  user_id = /*userId*/1
;
