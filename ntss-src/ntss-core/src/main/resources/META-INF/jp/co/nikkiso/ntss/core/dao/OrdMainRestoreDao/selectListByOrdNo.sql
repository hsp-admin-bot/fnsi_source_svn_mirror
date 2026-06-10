select
  /*%expand "A" */*
from
  ord_main_restore A
where
  ord_no in /* ordNoList */(1)
;
