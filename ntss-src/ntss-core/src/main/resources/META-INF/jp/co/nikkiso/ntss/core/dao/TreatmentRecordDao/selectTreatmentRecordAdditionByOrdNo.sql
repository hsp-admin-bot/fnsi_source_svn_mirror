select
  /*%expand */*
from
  ord_main
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
