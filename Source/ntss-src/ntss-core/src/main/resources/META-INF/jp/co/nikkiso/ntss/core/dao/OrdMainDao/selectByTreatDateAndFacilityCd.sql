select
  /*%expand "A" */*
from
  ord_main A
where
    treat_date = /*treatDate*/''
    and facility_cd = /*facilityCd*/'000000'
;
