select
    /*%expand "A" */*
from
  ord_main A
where
  facility_cd = /*facilityCd*/'000000'
;
