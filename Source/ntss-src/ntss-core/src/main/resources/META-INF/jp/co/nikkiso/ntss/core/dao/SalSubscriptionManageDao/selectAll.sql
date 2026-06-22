select
  /*%expand "A" */*
from
  sal_subscription_manage A
where 
  A.is_disp = '1' and A.is_del = '0' 
;
