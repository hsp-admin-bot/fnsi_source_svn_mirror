select
  /*%expand "A" */*
from
  ord_main A
where
 facility_cd = /*facilityCd*/'1'
 AND
  A.pat_id in /*patIdList*/(null)
;
