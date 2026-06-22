select
  /*%expand "A" */*
from
  sys_application A
where
  POSITION(/*filename*/null IN path) > 0
/*%if null != is_disp */
and
  is_disp=/*is_disp*/null
/*%end*/
/*%if null != is_del */
and
  is_del=/*is_del*/null
/*%end*/
;
