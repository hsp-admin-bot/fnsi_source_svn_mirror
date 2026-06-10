select
  /*%expand "A" */*
from
  sys_signin_manager A
order by
  A.terminal_unique_string
;
