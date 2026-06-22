select
  /*%expand "A" */*
from
  mst_alarm_notification A
where
  A.alarm_notification_cd=/*alarmNotificationCd*/0
and
  is_disp = '1'
and
  is_del = '0'
;
