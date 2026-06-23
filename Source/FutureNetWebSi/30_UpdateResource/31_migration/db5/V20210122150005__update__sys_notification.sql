--在宅機能の無効化
UPDATE sys_notification
SET
  is_del = '1',
  up_date = now()
WHERE notification_no = 13;
