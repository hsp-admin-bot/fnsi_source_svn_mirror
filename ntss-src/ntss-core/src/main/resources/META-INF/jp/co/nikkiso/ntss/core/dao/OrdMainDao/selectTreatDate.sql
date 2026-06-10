select
  /*%expand "A" */*
from
  ord_main A
where
  ord_no = /*ordNo*/1
  and
  is_del = '0'
;
