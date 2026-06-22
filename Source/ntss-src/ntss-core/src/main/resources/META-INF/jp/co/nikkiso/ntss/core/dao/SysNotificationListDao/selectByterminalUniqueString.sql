select
  /*%expand "A" */*
from
  sys_notification_list A
where
  A.terminal_unique_string = /*terminalUniqueString*/null
  /*%if userId != "undefined" */
  and A.user_id = /*userId*/null
  /*%end */
  /*%if facilityCd != "undefined" */
  and A.facility_cd = /*facilityCd*/null
  /*%end */
;
