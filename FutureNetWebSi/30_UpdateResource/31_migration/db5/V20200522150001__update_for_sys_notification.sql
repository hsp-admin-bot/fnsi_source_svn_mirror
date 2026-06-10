update
  sys_notification
set
  message = '新規患者：[LASTNAME] [FIRSTNAME] さんが登録されました。',
  help = '新規患者が登録されると通知します。'
where
  notification_no = '1';
