select 
  /*%expand "A" */*
from
  sys_notification_list A
where
  A.facility_cd = /*facilityCd*/'999999'
and
  A.user_id = /*userId*/0
;