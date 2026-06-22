--薬剤
select
  /*%expand "A" */*
from
  sys_generic_medicine A
where
  A.is_del = '0'
and
  A.is_disp = '1'
;  
