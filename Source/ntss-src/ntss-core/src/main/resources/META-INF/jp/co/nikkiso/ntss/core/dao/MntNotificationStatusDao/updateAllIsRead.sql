update
  mnt_notification_status
set
  is_read = '1'
  , up_date = current_timestamp
where
  user_id = /*userId*/1
  and is_read = '0'
;
