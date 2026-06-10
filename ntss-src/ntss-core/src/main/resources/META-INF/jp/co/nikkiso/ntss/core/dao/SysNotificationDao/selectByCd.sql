select
  /*%expand "A" */*
from
  sys_notification A
where
  is_disp = '1'
and
  is_del = '0'
and
  notification_no = /* notificationNo */0
;
