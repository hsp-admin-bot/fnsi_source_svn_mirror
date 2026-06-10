select
  /*%expand "A" */*
from
  sys_subscription_plan A
where 
  A.is_disp = '1' and A.is_del = '0' 
;
