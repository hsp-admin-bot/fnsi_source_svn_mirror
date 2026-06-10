select
  /*%expand "A" */*
from
  pat_rad_main A
where
  A.pat_id = /* patId */-1
and
  A.reg_rad_date = /* regRadDate */'1970/01/01 00:00:00'
and
  A.reg_order_class = /* regOrderClass */'-1'
and
  A.is_del = '0'
;
