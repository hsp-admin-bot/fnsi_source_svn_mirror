select
  /*%expand "A" */*
from
  ord_main_restore A
where
  ord_no = /*ordNo*/1
;
