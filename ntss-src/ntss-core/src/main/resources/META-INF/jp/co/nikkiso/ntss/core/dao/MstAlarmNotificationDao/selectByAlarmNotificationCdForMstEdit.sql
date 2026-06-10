select
  /*%expand "A" */*
from
  mst_alarm_notification A
where
  A.alarm_notification_cd=/*alarmNotificationCd*/0
;
