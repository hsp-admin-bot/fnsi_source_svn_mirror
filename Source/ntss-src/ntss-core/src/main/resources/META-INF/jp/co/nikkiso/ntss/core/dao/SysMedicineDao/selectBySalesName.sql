select
  /*%expand "A" */*
from
  sys_medicine A
where
  A.sales_name like '%' || /* salesName */null || '%'
;
