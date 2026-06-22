select
  /*%expand "A" */*
from
  sys_function_advanced A
where
  A.is_disp = '1'
  and A.is_del = '0'
order by 
  A.disp_order
;
