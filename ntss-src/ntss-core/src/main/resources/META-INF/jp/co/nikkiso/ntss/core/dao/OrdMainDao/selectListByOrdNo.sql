select
  /*%expand "A" */*
from
  ord_main A
where
  ord_no in /* ordNoList */(1)
;
