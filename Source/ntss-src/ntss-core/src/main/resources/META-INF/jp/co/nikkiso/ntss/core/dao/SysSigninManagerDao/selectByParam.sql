select
  /*%expand "A" */*
from
  sys_signin_manager A
where
  /*%if sysSigninManager.terminalUniqueString != null */
  A.terminal_unique_string = /*sysSigninManager.terminalUniqueString*/null
  /*%end*/
  /*%if sysSigninManager.userId != null */
  and
  A.user_id = /*sysSigninManager.userId*/0
  /*%end*/
  /*%if sysSigninManager.facilityCd != null */
  and
  A.facility_cd = /*sysSigninManager.facilityCd*/'0'
  /*%end*/
order by
  A.terminal_unique_string
;
