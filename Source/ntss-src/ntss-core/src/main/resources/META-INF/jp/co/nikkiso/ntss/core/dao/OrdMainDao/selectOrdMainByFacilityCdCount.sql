select
  /*%expand "A" */*
from
  ord_main A
where
 A.facility_cd = /*facilityCd*/'000000'
 and A.is_del = '0'
 order by
  A.up_date DESC
  limit 1
;
