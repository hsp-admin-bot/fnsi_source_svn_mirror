select
  /*%expand "A" */*
from
  mst_course A
where
  A.is_del = '0'
;
