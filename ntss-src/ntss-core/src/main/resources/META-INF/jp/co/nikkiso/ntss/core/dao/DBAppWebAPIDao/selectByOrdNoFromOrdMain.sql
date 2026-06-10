select
  /*%expand "A" */*
from
  ord_main A
where
/*%if ord_no != null */
  ord_no = /*ord_no*/0
/*%end*/
;
